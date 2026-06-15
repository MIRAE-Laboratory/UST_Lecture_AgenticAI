⭐ **[2026-1 Final-term Project - INDEX](../2026-1_Final-term_Project.md)**

# ResearchMate v2 — Director's Report
**Student Number:** 02522068  
**Name:** Nazhiefah Dalila 
**Course:** Agentic AI| UST-KRISS  

---

## 1. What I Built

ResearchMate v2 is an AI-powered supervisor simulator designed for student-researchers who meet their supervisors infrequently, once a week or less. The problem student usually have is sometimes they have many things to prepare for meeting with their supervisor, but when they meet their professor, they will forget some of the thing that they want to discuss, and arrive at real meetings looks like unprepared, while in fact they just forget or got nervous. The agent reads the student's own research materials, including papers that student read, research notebooks, and experimental results, and conducts a mock supervisor meeting, asking fundamental and challenging questions based on student materials. After the meeting session, the agent can score each response, generate specific answers to improve the weak responses, and log document every session for review. After this, student also can turn two-persona debate mode (Defender vs Critic) to watch their research arguments from opposing sides. The system runs entirely locally using Ollama, thus there is no internet, no API keys, no data leaving the machine.

---

## 2. Architecture & Design Decisions

### RAG — Retrieval-Augmented Generation (Week 12)
The first version of ResearchMate (midterm) extracted full PDF text and sent everything to the model at once. However, with large papers (1MB+), this caused context overflow, so the model cut off mid-sentence and repeated questions. 

For v2, I implemented a vector store using `sentence-transformers` (`all-MiniLM-L6-v2`) to chunk documents into 500-character pieces with 30-word overlap, embed each chunk, and retrieve only the top 2 most relevant chunks per turn using cosine similarity. This reduced context size per turn from ~20,000 characters to ~1,000 characters, fixing overflow and enabling PDF support. I also implemented `used_indices` tracking to prevent the same chunk from being retrieved twice, forcing topic variety across turns.

### Tool Use (Week 9)
I defined three tools for the supervisor: `check_claim` (verifies student claims against documents), `search_chunks` (searches the vector store for relevant content), and `find_contradiction` (detects when student answers contradict their own materials).

### Evaluation — Rubric Scoring (Week 10)
Each student answer is scored against four criteria: Clarity, Evidence, Depth, and Relevance (0-10 each). The evaluator calls the same local Ollama model with a structured JSON prompt. Scores appear in the Meeting Report as expandable cards per answer.

### Self-Reflection — Critique (Week 11)
For answers scoring below 7/10 average, the system generates a three-part critique: what was missing, a specific rewrite suggestion, and one concrete study action. This implements the Week 11 Reflexion pattern.

### Multi-Agent Debate (Week 7 / Week 13)
The Research Debate tab implements a two-persona debate: Defender argues for the student's research approach, Critic argues against it. The student moderates. Both personas use the same `qwen3:1.7b` model with different system prompts.
In Week 13 terms, this is a **round-robin** orchestration pattern: Defender → Critic → Defender → Critic, with the student as the human orchestrator who can interject at any turn.

### HITL — Human in the Loop (Week 14)
Every significant action is logged to `hitl_audit.jsonl`:

```json
{"ts": "2026-06-11 14:56:38", "type": "meeting_started", "topic": "triple negative complementary metamaterial", "style": "Rigorous & Unpredictable"}
{"ts": "2026-06-11 14:58:07", "type": "supervisor_question", "turn": 1, "preview": "Why is achieving triple negativity in elastic metamaterials particularly challen..."}
{"ts": "2026-06-11 15:03:43", "type": "meeting_ended", "turns_completed": 4, "topic": "triple negative complementary metamaterial"}
{"ts": "2026-06-11 15:07:51", "type": "report_generated", "gaps": 1}
```

The log uses JSON Lines format, append-only, one event per line, safe to read while writing.

---

## 3. Where the Humans Are in the Loop

Following the Week 14 autonomy spectrum framework, I mapped each action to its checkpoint level:

| Action | Autonomy Level | Reasoning |
|---|---|---|
| Loading research materials | **Manual** | Student decides what context matters |
| Setting meeting topic | **Manual** | Student defines the agenda |
| Choosing supervisor style | **Manual** | Student knows their real supervisor's style |
| Generating supervisor questions | **Full Auto** | Routine, reversible — bad question costs nothing |
| Evaluating answer scores | **Full Auto** | Cheap, immediate feedback |
| Generating critique | **Full Auto** | Student reviews and judges relevance |
| Ending the meeting | **In the Loop** | Student decides when they are done |
| Generating report | **In the Loop** | Student explicitly requests it |
| Debate interjection | **On the Loop** | Student can intervene at any round |

---

## 4. The Failures I Saw — And the Lessons

### Failure 1: Context Overflow with Large PDFs
**What happened:** Uploading a 1MB PDF caused the supervisor to cut off mid-sentence and repeat questions. The model was overwhelmed.

**What I did:** Implemented RAG chunking, 500-character chunks, top-2 retrieval per turn.

### Failure 2: Question Repetition
**What happened:** Even after RAG, `qwen3:1.7b` fixated on the same topic across turns, asking variations of the same question. Adding explicit rules ("NEVER ask about something already discussed") and `used_indices` tracking reduced but did not eliminate this.

**Lesson:** Some failures are model capability failures, not prompt failures. `qwen3:1.7b` lacks the context tracking ability to reliably avoid repetition across 8 turns. The architectural fix is a larger model, not a better prompt. This is what the course called the boundary between coordination conflicts and epistemic conflicts.

### Failure 3: 0/10 Scores from JSON Parsing Failure
**What happened:** The evaluator consistently returned 0/10 because `qwen3:1.7b` wraps JSON responses in natural language ("Here is the evaluation: {...}") instead of pure JSON.

**Lesson:** Model version upgrades are not free and not all model suit this. So I stick to the first model I use.

## 5. Critical Reflection on Management

### Leading an AI workflow vs writing a program
Leading an AI workflow does not same as writing a program that has exact outputs. The same prompt, the same model, the same context can produce a brilliant question one run and lad to another answer next.

This made me to think like a Research Director rather than a developer. My job was not to write code that works but to design a system where failures are contained, documented, and recoverable.

### Where I would place more or fewer agents
In hindsight, I would add one more agent, a dedicated **Topic Tracker** that runs after each student answer and updates a shared list of covered topics. The supervisor agent would query this list before generating each question. This separates concerns, one agent asks questions and one agent tracks state, and directly solves the repetition problem without overloading a single model.

I would remove the scoring evaluator as a separate call and fold it into the report generation call. Two separate LLM calls for scoring and report generation is redundant, they could be one call with a richer prompt.

### The irreplaceable human skill
**Epistemic taste** the ability to recognize when a question is genuinely challenging versus superficially similar to the last one. The student must bring this judgment to every session. The AI cannot tell the difference between a profound follow-up and a rephrased repeat. Only the student, who knows their research deeply, can make that call and decide whether to answer, push back, or end the meeting.

---

## 6. What I Would Do Differently / Next

### Immediately
- **Upgrade to a 4B+ model with thinking disabled** using ollama newest version. The thinking mode discovery came too late in development.
- **Implement a Topic Tracker agent** a lightweight second agent that maintains a list of covered topics and injects it into the supervisor's context each turn.
- **Fix JSON scoring** use structured output mode or constrained decoding to force valid JSON, rather than relying on prompt instructions.

### Longer term
- **Persistent vector store** — currently the vector store resets every session. With a persistent store (e.g., ChromaDB), papers uploaded once are searchable forever — the app gets smarter with every paper added.
- **Cross-model critique** — use a different model for scoring than for question generation. The self-bias problem from Week 11 applies here: the same model that generated the question will be lenient when evaluating the answer.
- **Answer history tracking** — store past meeting reports so students can track improvement over time. Right now every session is isolated.

### What I learned that I will actually use
The autonomy spectrum from Week 14 is the most practically useful framework from this course. Before this project, I would have built an app where the AI does everything automatically. Now I think first about which actions are reversible and which are not, which decisions require human judgment and which can be safely automated. That disposition — not the specific code patterns — is what I will carry into future research.

---

*Built with: Python, Streamlit, Ollama (qwen3:1.7b), sentence-transformers (all-MiniLM-L6-v2), PyPDF2*  
*Running entirely locally — no cloud API, no data leaves the machine*