## Slide: Title
- type: title
- title: Mid-term Evaluation: Proposal
- subtitle: No lecture this week — Video Pitch Screening & Peer Review

> Week 8 of Phase 2: Workflow Automation & Design (Weeks 5-8)

=====

## Slide: Overview
- type: cards
- title: Week 8 — **What Happens**
- subtitle: Your submitted work is the session

- card(blue, 📦): Submission
  - Everything was due **Friday, 23 October 2026, 24:00 (KST)**
  - By email to **hogeony@ust.ac.kr** or upload to the shared Google Drive folder
  - One zip per student: `StudentID_Name.zip` (e.g. `02523035_MinhLeTran.zip`)

- card(green, 🎬): Screening (Mon 26 Oct)
  - All video pitches are **merged into one video** and screened in class
  - Specifications (and code, where possible) are published in the course **GitHub repository**
  - Score every project while you watch

- card(orange, 🗣️): Peer Review
  - Same four criteria as the instructor's grade, 0–3 each
  - Scoring form on **UST LMS**; feedback goes back to each author

> 📚 [Mid-term Project — Submission Notice (GitHub)](https://github.com/MIRAE-Laboratory/UST_Lecture_AgenticAI/blob/main/Mid-term_Project_Notice.md)

=====

## Slide: Deliverables
- type: compare-table
- title: The Three **Deliverables**
- subtitle: Submitted together, in one zip

| # | Item | Filename | Format |
|---|------|----------|--------|
| 1 | **Specification document** | `StudentID_Name.md` | The 5-question template (Problem, Users, Features, Interaction Flow, Success Criteria), including failure states |
| 2 | **Working prototype** | as you wish | Streamlit or Gradio app with runnable code (`requirements.txt`, `README.md` with run instructions) |
| 3 | **Recorded video pitch** | `StudentID_Name.mp4` | 3–5 minutes, screen recording of the app actually running on real data from your research, plus your design decisions |

- highlight-quote: Submitting means you agree to your video and code being shared with classmates for peer review. Remove any API keys, private data, or unpublished results before submitting.

=====

## Slide: Evaluation Criteria
- type: compare-table
- title: Evaluation Criteria — **Four Dimensions, 0–3 Each** (max 12)
- subtitle: Used for both the instructor grade and your peer review

| Criterion | 0 | 1 | 2 | 3 |
|-----------|---|---|---|---|
| **Creativity** | Generic chatbot wrapper | Known pattern applied as-is | Known pattern adapted to the research problem | A new idea or combination that others would want to copy |
| **Usefulness** | Does not address a real research task | Addresses a task, but no one would use it in practice | Would save real time or errors in the author's own work | Would be useful to other researchers in the field too |
| **Concreteness** | Spec and prototype do not match; app does not run | App runs on dummy data only | App runs on real data; human control points are visible | Real data, failure states handled, verification built into the flow |
| **Presentation** | Video missing or app not shown running | App shown, design decisions not explained | Clear problem, demo, and design rationale within 3–5 min | Also honest about limitations and what the human still has to check |

- highlight-quote: Score what you **saw** in the video, not what you assume was built.

=====

## Slide: Peer Review
- type: card-single
- title: 🗣️ **Peer Review** — on UST LMS
- subtitle: No paper sheet — the scoring form is on the LMS

- card(yellow, 📝): How It Works
  - A **scoring form** for every project is posted on **UST LMS** (Class → Mid-term Peer Review)
  - Score each colleague's pitch on the four criteria, 0–3 each, while or right after watching
  - Add **one comment the author can act on** — a location and an action, not a verdict
  - Do not score your own project; submit the form by the end of the session

## Slide: Self-Check
- type: card-single
- title: ✅ **Self-Check** (from the notice)
- subtitle: What every submission was expected to pass

- card(green, 📋): Checklist
  - [ ] The app starts from a clean install using only the files you submitted
  - [ ] The video shows the app running on **real** data, not placeholders
  - [ ] The specification matches what the prototype actually does
  - [ ] You can explain **why** each design decision was made, and where the human stays in control
  - [ ] No API keys or private data are included

=====

## Slide: Next
- type: cards
- title: After the Screening — **Phase 3**
- subtitle: Management & Reliability (Weeks 9–12)

- card(blue, 🧭): Week 9 — Design of Task and Workflow
  - Algorithmic thinking: designing robust workflows

- card(green, 📏): Week 10 — Evaluation of Output from Agent
  - Quality control: metrics and rubrics for AI performance

- card(orange, 🔁): Week 11 — Self-feedback Loop Agent System
  - Metacognition: making agents fix their errors

- card(purple, 🧠): Week 12 — Memory and Retrieval-Augmented Generation
  - Long-term context: vector databases and RAG

**Next week:** Phase 3 begins with **Design of Task and Workflow** — turning a vague request into a flow that survives contact with reality.
