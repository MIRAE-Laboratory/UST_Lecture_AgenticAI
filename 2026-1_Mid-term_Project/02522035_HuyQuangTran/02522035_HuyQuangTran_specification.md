⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

# App Name: EpistemicScout: Agentic Research Gap Discovery System

## 1. Problem Statement
- Problem: The "Information Explosion" in academic publishing has created a bounded rationality problem for researchers. With thousands of papers published monthly, it is humanly impossible to synthesize all existing data to find "white space" (novel research gaps).
- Impact: Currently, graduate students and R&D professionals spend months on manual literature reviews, often missing inter-disciplinary contradictions or untested experimental parameters simply because the connections are non-obvious across different sub-fields. This leads to redundant research and missed opportunities for innovation.

## 2. Target Users
- Primary User: Graduate students (Master’s/PhD) and Academic Researchers.
- Skill Level: High domain expertise in their field, but they require a tool that handles the "heavy lifting" of cross-paper data extraction.
- Context: Early-stage research development, thesis proposal drafting, or corporate R&D trend analysis.

## 3. Core Features
| Feature | Description | Priority |
|---------|-------------|----------|
| Agentic Entity Extraction | Multi-agent team extracts "Claims," "Methods," and "Results" from local PDFs using NER (Named Entity Recognition). | Must-have |
| Knowledge Graph Synthesis | Maps extracted entities into a relational graph (Nodes = Concepts, Edges = Relationships). | Must-have |
| Contratiction Engine | An agent that specifically audits the graph for conflicting results (e.g., Paper A says $X$ increases $Y$, Paper B says it decreases $Y$). | Must-have |
| Gap Topology Analysis | Identifies "islands" in the knowledge graph where two concepts should logically be connected but have no supporting literature. | Must-have |
| Citation-Backed Engine | Generates a ranked list of research ideas, each hyperlinked to the specific text segments in the source PDFs. | Must-have |
| Visual Graph Explorer | An interactive UI to see the "shape" of the research field. | Must-have |
| Hybrid Backend Selector | Dropdown to toggle between Gemini (for speed/large context) and Ollama (for local privacy). Dynamically polls local Ollama tags. | Must-have |
| Persistent Chat Lab | A dedicated tab for conversational Q&A with the paper corpus, including session history. | Must-have |
| Dialectical Debate Chamber | A multi-agent debate between a Conceptualist and an Empiricist to stress-test research ideas. | Must-have |
| Moderator Interface | A multi-agent debate between a Conceptualist and an Empiricist to stress-test research ideas. | Must-have |

## 4. Enhanced UI/UX Design & Interaction Flow
### A. Layout Structure (Streamlit Dashboard)
#### Sidebar (The Control Tower):
- Model Config: Toggle (Online/Local). If Local, a dynamic dropdown shows available Ollama models.
- Session History: A clickable list of previous chat and debate logs.
- Document Manager: Upload/View processed PDFs.

#### Main Stage (Tabbed Interface):
- Discovery Map: The Knowledge Graph and Gap analysis results.
-  Research Chat: Standard RAG-based chat with "Memory" of the current corpus.
-  Debate Chamber: The three-column view where agents argue over the research gap.

### B. The "Debate Chamber" Logic
To make the R&D process interactive, the system initiates a Triadic Agent Loop:
- Agent 1 (The Conceptualist): Focuses on high-level theory, definitions, and logic. Arguments are based on "How this fits into existing frameworks."
- Agent 2 (The Empiricist): Focuses on data, benchmarks, and experimental contradictions. Arguments are based on "What the numbers actually say."
- The Moderator (User or Generalist AI): Synthesizes the two viewpoints. The user can toggle "AI Moderator" to let a third persona (Specialist/Generalist) summarize the "Truth" of the gap.

## 5. Human-AI Interaction Flow
- Step 1 (Human): Uploads a folder of PDFs (local) and provides a "seed" research question.
- Step 2 (AI - Extraction Agent): Parses PDFs via Ollama and populates a structured data store.
- Step 3 (AI - Synthesis Agent): Constructs the Knowledge Graph and identifies clusters of high/low activity.
- Step 4 (AI - Critic Agent): Runs a "Conflict Check" to find where literature disagrees.
- Step 5 (Human): Reviews the "Ranked Gaps" dashboard.
- Step 6 (Human/AI): Human selects a gap; AI generates a formal research hypothesis and experimental draft based on that gap.
- Step 7 (Human/AI): Human moves to the Debate Tab. The Conceptualist and Empiricist argue over the validity of the gap.
- Step 8 (Human/AI): User chats with the "Moderator" to finalize a research hypothesis.
- Step 9 (Human): System generates a LaTeX/Markdown proposal draft.

## 6. Technical Approach
- LLM: Ollama / Gemini
- Framework: Streamlit
- Agent Orchestration: LangGraph or CrewAI
- Key libraries: PyMuPDF or Marker, NetworkX, ChromaDB
- Data: Local PDFs research papers.
- Memory: ChromaDB for for vector storage and Streamlit Session State for the chat history.

## 7. Success Criteria
- Performance: The app should be able to extract entities from at least 10 PDFs in under 10 minutes.
- Accuracy: 0% hallucination of citations (every claim must map to a real PDF page/line).
- Utility: The generated "Research Proposal" draft requires less than 30% manual editing to be usable. The debate must surface at least two "counter-arguments" to the user's initial research hypothesis.
- Novelty: The system identifies at least one "Contradiction Gap" that the user was not previously aware of.
- Interactivity: The Debate Chamber should be able to generate a debate between the two agents in under 30 seconds.
- Flexibility: System must seamlessly switch between Gemini and Ollama without losing the Knowledge Graph state.