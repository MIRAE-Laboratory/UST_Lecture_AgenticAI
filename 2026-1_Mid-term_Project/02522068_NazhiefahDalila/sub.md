⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

# ResearchMate — Supplementary Notes

## Pipeline Diagram

```
┌─────────────────────────────────────────────────────┐
│                   USER UPLOADS                      │
│  📄 PDF Papers + 📓 Notebook + 📊 Results           │
└───────────────────┬─────────────────────────────────┘
                    │ document_loader.py
                    ▼
┌─────────────────────────────────────────────────────┐
│              EXTRACTED TEXT CONTEXT                 │
│  {filename: text, notebook: text, results: text}    │
└───────────────────┬─────────────────────────────────┘
                    │
         ┌──────────┴──────────┐
         ▼                     ▼
┌─────────────────┐   ┌─────────────────────────────┐
│  MOCK MEETING   │   │      RESEARCH DEBATE        │
│  supervisor.py  │   │        debate.py            │
│                 │   │                             │
│ RICE Prompt     │   │  🔵 Defender Persona        │
│ + check_claim   │   │  🔴 Critic Persona          │
│   tool use      │   │  👤 Student Moderates       │
│                 │   │                             │
│ Turn-by-turn    │   │  Round-by-round             │
│ Q&A loop        │   │  debate loop                │
└────────┬────────┘   └─────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────┐
│               MEETING REPORT                        │
│  ✅ Strengths  ⚠️ Gaps  📚 What to Prepare          │
│  ⬇️ Download as .txt                                │
└─────────────────────────────────────────────────────┘
```

---

## Design Decisions

### Why Ollama instead of cloud API?
- Free with no usage limits — important for repeated practice sessions
- Runs locally — research materials never leave the student's machine
- Same OpenAI-compatible interface taught in class (Week 2)

### Why 4 supervisor styles?
Different students need different practice. A student before their first meeting
needs "Encouraging but Thorough". A student preparing for a defense needs
"Devil's Advocate". The style selector gives the student control.

### Why `check_claim` as the tool?
The most natural tool for this context — the supervisor should be able to
verify whether what the student says is actually supported by their own
materials. It directly implements Week 4's principle: tools replace
probabilistic guessing with deterministic checking.

### Why one LLM called twice for debate?
Following the Week 7 pattern — the same model with different system prompts
produces genuinely different perspectives. The Defender and Critic personas
are grounded in the same meeting transcript, so their arguments are specific
rather than generic.

### Why .txt for report download?
Universal format — opens on any computer without special software. The student
can keep a record of every practice session and track their progress over time.

---

## Supervisor Style Comparison

| Style | Best For | How It Behaves |
|---|---|---|
| Rigorous & Unpredictable | General practice | Switches angles freely, never accepts vague answers |
| Socratic | Deep understanding | Only asks questions, never gives hints |
| Encouraging but Thorough | First practice | Acknowledges good points, then probes gaps |
| Devil's Advocate | Pre-defense prep | Challenges everything, forces active defense |

---

## Limitations & Future Work

- `qwen3:1.7b` is a small model — responses are sometimes incomplete
- `check_claim` uses keyword matching — not semantic search
- No memory between sessions — each meeting starts fresh
- Future: add RAG (Week 12) for deeper paper search
- Future: add LangGraph (Week 9) for more structured meeting flow