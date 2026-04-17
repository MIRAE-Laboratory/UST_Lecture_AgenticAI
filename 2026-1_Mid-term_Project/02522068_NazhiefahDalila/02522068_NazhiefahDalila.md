⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

# ResearchMate — AI Supervisor Simulator
### Midterm Project | AI Frameworks for R&D | UST
**Student:** [Nazhiefah Dalila-02522068]
**Submission Date:** April 17, 2026

---

## 1. Problem Statement

Graduate student-researchers in STEM fields typically meet their supervisor
once every 1–2 weeks. Between meetings, students accumulate questions and doubts
with no one to challenge their thinking. Before meetings, students feel prepared,
but once questioned by their supervisor, they realize they cannot clearly explain
their reasoning, have gaps in their literature knowledge, or cannot connect their
results to prior work.

This leads to:
- Wasted meeting time covering basics instead of advancing research
- Loss of confidence when unable to answer unexpected questions
- Slow research progress due to unresolved conceptual gaps

**ResearchMate** solves this by giving students a safe space to practice defending
their research before the real meeting — using their own papers, lab notes, and
experimental results as context.

---

## 2. Target Users

Graduate students (MSc / PhD) especially in STEM fields who:
- Meet their supervisor infrequently (once a week or less)
- Have real research materials but no practice space
- Want to arrive at meetings more prepared and confident

---

## 3. Core Features

| Feature | Description | Priority |
|---|---|---|
| Multi-material Upload | Upload PDFs + paste research notebook + paste results | Yes |
| Supervisor Persona | RICE-designed AI supervisor with 4 selectable styles | Yes |
| Mock Meeting Mode | Turn-by-turn Q&A where AI challenges your answers | Yes |
| Tool Use (check_claim) | Supervisor verifies student claims against uploaded materials | Yes |
| Meeting Report | Auto-generated: strengths, gaps, what to prepare | Yes |
| Research Debate | Two AI personas (Defender vs Critic) debate your research | Yes |
| Downloadable Report | Export meeting report as .txt file | Yes |

---

## 4. Human-AI Interaction Flow

```
[Upload papers (PDF) + paste notebook + paste results]
                    ↓
        [Set meeting topic + supervisor style]
                    ↓
        [Supervisor AI asks first question]
                    ↓
           [Student types answer]
                    ↓
    [Supervisor challenges / follows up]
         ← loop until max turns →
                    ↓
          [Student ends meeting]
                    ↓
      [AI generates Meeting Report]
           ↙               ↘
    [Strengths]      [Gaps + What to Prepare]
                    ↓
         [Optional: Research Debate]
        🔵 Defender vs 🔴 Critic
        (student as moderator)
```

**Human controls:**
- Which materials to upload (context selection)
- Meeting topic and supervisor style
- When to end the meeting
- Whether to interject in the debate

**AI executes:**
- Generates questions grounded in student's actual materials
- Produces structured meeting report
- Runs two-persona debate about the student's research

---

## 5. Technical Approach

| Component | Choice | Reason |
|---|---|---|
| LLM | Ollama `qwen3:1.7b` | Free, local, privacy-friendly, no API key needed |
| Framework | Streamlit | Simple web UI, rapid prototyping, matches course stack |
| PDF extraction | PyPDF2 | Lightweight, works locally |
| API client | OpenAI-compatible | Same pattern taught in Week 2/4 |

### Project Structure
```
researchmate/
├── app.py              — Main Streamlit UI (3 tabs)
├── document_loader.py  — PDF + text extraction
├── supervisor.py       — Supervisor persona, tool use, report generation
├── nazhiefah_02522068.md  — Midterm Project Specification
├── sub.md    — Supplementary Specification of ResearchMate
└── debate.py           — Two-persona debate engine
```

---

## 6. Connection to Course Concepts (Weeks 1–7)

### Week 1 — Research Director Mindset
The student acts as the **Research Director**: they choose what materials to load,
set the meeting topic, choose the supervisor style, decide when to end the meeting,
and moderate the debate. The AI executes within those boundaries.

### Week 2 — LLM via Local API (Ollama)
The app uses `qwen3:1.7b` via Ollama running on `localhost:11434`, accessed through
the OpenAI-compatible Python client — exactly the pattern taught in Week 2 practice.

```python
client = OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"
)
```

### Week 3 — Prompt Engineering (RICE Framework)
The supervisor system prompt is designed using the RICE framework:

- **Role:** "You are a university research supervisor conducting a weekly meeting..."
- **Instructions:** Rules 1–8 defining questioning style and behavior
- **Context:** Student's uploaded papers, notebook, and results injected directly
- **Examples:** 4 selectable supervisor styles (Rigorous, Socratic, Encouraging, Devil's Advocate)

### Week 4 — Tool Use (Function Calling)
The supervisor has access to a `check_claim` tool that verifies student claims
against their uploaded research materials:

```python
TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "check_claim",
            "description": "Check if a student's claim is supported by their research materials.",
            ...
        }
    }
]
```

When the student makes a factual claim, the supervisor can call this tool to check
whether the claim is grounded in the student's own documents — replacing probabilistic
guessing with deterministic checking.

### Week 5 — Streamlit App + Specification
The app is built with Streamlit and follows the 5-question specification framework:
Problem → Users → Features → Interaction Flow → Success Criteria.
The UI includes sidebar for material upload, tabs for different modes, and
progressive disclosure (Start button only activates when checklist is complete).

### Week 6 — PDF Extraction Pipeline
`document_loader.py` extracts text from uploaded PDFs using PyPDF2, with truncation
to fit Ollama's context window:

```python
def extract_pdf_text(uploaded_file):
    reader = PdfReader(io.BytesIO(uploaded_file.read()))
    pages = []
    for page in reader.pages:
        text = page.extract_text()
        if text:
            pages.append(text.strip())
    full_text = "\n\n".join(pages)
    if len(full_text) > MAX_CHARS:
        full_text = full_text[:MAX_CHARS] + "\n[...truncated...]"
    return full_text
```

### Week 7 — Multi-Agent Debate
`debate.py` implements the two-persona debate pattern from Week 7:
- 🔵 **Defender** — argues FOR the student's research approach
- 🔴 **Critic** — argues AGAINST the methodology and findings
- Both share the same meeting transcript as evidence
- Student acts as **moderator** — can interject, redirect, and synthesize

---

## 7. Success Criteria

- Supervisor questions feel specific and grounded in student's actual materials
- Report correctly identifies what the student could not explain
- Student arrives at real supervisor meetings more prepared and confident
- App runs entirely locally with no internet or paid API required
- Debate surfaces assumptions the student didn't know they had

---

## 8. Reflection — Human-AI Boundary

Following the course's discussion themes, ResearchMate is designed so that:

- **AI computes** — generates questions, checks claims, produces report, runs debate
- **Human judges** — decides what materials matter, evaluates AI questions, moderates debate
- **Human-in-the-Loop** — student ends the meeting, approves the report, interjects in debate

---

## 9. How to Run

```bash
# 1. Install Ollama from https://ollama.com
ollama pull qwen3:1.7b

# 2. Install dependencies
pip install streamlit openai PyPDF2

# 3. Run the app
streamlit run app.py
```

Open `http://localhost:8501` in your browser.