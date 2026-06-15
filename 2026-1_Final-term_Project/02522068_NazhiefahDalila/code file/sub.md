# ResearchMate v2 — Supplementary Notes

## Project Structure

```
researchmate/
├── app.py              — Main Streamlit UI (3 tabs)
├── supervisor.py       — Supervisor persona + RAG integration
├── document_loader.py  — PDF + text extraction
├── memory.py           — Vector store + RAG chunking/retrieval
├── evaluator.py        — Answer scoring rubric + self-reflection critique
├── hitl.py             — Audit log (HITL event tracking)
├── debate.py           — Two-persona debate engine
└── hitl_audit.jsonl    — Auto-generated session log
```

---

## Pipeline Diagram

```
┌─────────────────────────────────────────────────────┐
│                   USER UPLOADS                      │
│  📄 PDF Papers + 📓 Notebook + 📊 Results           │
└───────────────────┬─────────────────────────────────┘
                    │ document_loader.py
                    ▼
┌─────────────────────────────────────────────────────┐
│              memory.py — RAG Pipeline               │
│  chunk_text() → embed() → VectorStore               │
│  "27 chunks indexed"                                │
└───────────────────┬─────────────────────────────────┘
                    │ retrieve top-2 chunks per turn
         ┌──────────┴──────────┐
         ▼                     ▼
┌─────────────────┐   ┌─────────────────────────────┐
│  MOCK MEETING   │   │      RESEARCH DEBATE        │
│  supervisor.py  │   │        debate.py            │
│                 │   │                             │
│ RICE Prompt     │   │  🔵 Defender Persona        │
│ + RAG context   │   │  🔴 Critic Persona          │
│ + style select  │   │  👤 Student Moderates       │
│                 │   │                             │
│ Turn-by-turn    │   │  Round-by-round             │
│ Q&A loop        │   │  debate loop                │
└────────┬────────┘   └─────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────┐
│            evaluator.py — Meeting Report            │
│                                                     │
│  score_answer()     → Clarity/Evidence/Depth/       │
│                        Relevance (0-10 each)        │
│  critique_answer()  → What was missing +            │
│                        Rewrite suggestion +         │
│                        What to study               │
│  generate_report()  → Strengths + Gaps + Prepare   │
│                                                     │
│  ⬇️ Download as .txt                               │
└─────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────┐
│              hitl.py — Audit Log                    │
│  log_event() → hitl_audit.jsonl                     │
│  Every session recorded: start/question/end/report  │
└─────────────────────────────────────────────────────┘
```

---

## What Changed from v1 (Midterm) to v2 (Final)

| Component | v1 Midterm | v2 Final |
|---|---|---|
| PDF handling | Full text → context overflow | RAG chunks → stable |
| Supervisor context | All documents every turn | Top-2 relevant chunks per turn |
| Tools | `check_claim` only | `check_claim` + `search_chunks` + `find_contradiction` (architecture only) |
| Meeting report | Text only | Scores + critique + rewrite suggestions |
| Session memory | None | Audit log persists across sessions |
| Debate | Defender vs Critic (basic) | Same + moderator interjection |
| Model | `qwen3.5:0.8b` | `qwen3:1.7b` |

---

## Key Design Decisions

### Why RAG instead of full-text?
The midterm version sent entire PDF text to the model every turn. With a 1MB paper (e.g., PhysRevX paper on anisotropic CMM), this caused:
- Context overflow → cut-off sentences
- Model confusion → repeated questions
- Slow responses → poor UX

RAG fixes this by sending only 2 relevant chunks (~1,000 chars) instead of the full document (~20,000 chars).

### Why tools were removed from active use
Three tools were designed and implemented (`check_claim`, `search_chunks`, `find_contradiction`). However, enabling them alongside RAG context and conversation history overloaded `qwen3:1.7b` — the model returned empty responses and triggered fallback messages. Tools are kept in the codebase as documented architecture but removed from the active API call.

**Tradeoff:** Stability > Capability for small local models.

## Supervisor Style Comparison

| Style | Best For | Behavior |
|---|---|---|
| Rigorous & Unpredictable | General practice | Switches angles freely, never accepts vague answers |
| Socratic | Deep understanding | Only asks questions, never gives hints |
| Encouraging but Thorough | First practice | Acknowledges good points, then probes gaps |
| Devil's Advocate | Pre-defense prep | Challenges everything, forces active defense |

---

## Known Limitations

| Limitation | Cause | Potential Fix |
|---|---|---|
| Question repetition | `qwen3:1.7b` poor context tracking | Larger model (7B+) or explicit topic tracker agent |
| 0/10 scores | Model returns JSON wrapped in natural language | Structured output / constrained decoding |
| Critique cut-off | `max_tokens` too low for long critiques | Increase tokens, or summarize prompt |
| Thinking mode slowness | `qwen3:4b` default behavior | `think=False` parameter, or use `qwen3:1.7b` |

---

## Dependencies

```
streamlit>=1.32.0
openai>=1.0.0
PyPDF2>=3.0.0
sentence-transformers>=2.0.0
numpy
```

Install:
```bash
pip install streamlit openai PyPDF2 sentence-transformers numpy
```

Run:
```bash
ollama pull qwen3:1.7b
streamlit run app.py
```