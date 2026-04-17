⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

# EpistemicScout: Agentic Research Gap Discovery System

EpistemicScout is an agentic, Streamlit-based web application designed to help academic researchers and graduate students discover novel research gaps from local literature (PDFs). It uses a multi-agent orchestrated workflow constructed using LangGraph to extract data, synthesize knowledge, and logically debate research gaps.

## App Architecture

The codebase is organized into several key modules:

### 1. `app.py`
The main entry point for the Streamlit application. It acts as the core controller, rendering the UI layout, handling document uploads, extracting PDF text, and invoking the multi-agent orchestrator state graph.

### 2. `ui/`
This directory encapsulates the visual components of the Streamlit application.
- **`sidebar.py`**: A control tower for user configuration containing model toggles (between local Ollama models and cloud Gemini models) and the document manager.
- **`graph_view.py`**: Visualizes the generated knowledge field as a networked graph connecting research concepts.
- **`gap_dashboard.py`**: Presents ranked research opportunities (gaps) and visual "islands" in the literature graph.
- **`chat_tab.py`**: Defines the interface for user conversational Q&A, backed by vector storage and conversational memory.
- **`debate_chamber.py`**: Features a three-pane UI visualizing real-time "Dialectical Debate" between agent personas (e.g., a "Conceptualist" and an "Empiricist").

### 3. `agents/`
This repository contains the LangGraph nodes governing the system's business logic.
- **`orchestrator.py`**: Compiles the `StateGraph` workflow sequentially moving from Entity Extraction, to Knowledge Synthesizer, to Criticism.
- **`extractor.py`**: Reaches into source texts to scrape "Claims", "Methods", and "Results" via Named Entity Recognition strategies.
- **`synthesizer.py`**: Takes the structured extractions and constructs a relationship map (the Knowledge Graph).
- **`critic.py`**: Audits the resulting graph for missing links or contradictions between sources.
- **`state.py`**: Defines the shared `GraphState` that passes state data between these nodes.

### 4. `utils/`
Standard toolings to provide background services.
- **`vector_store.py`**: A connection module establishing local persistence of extracted embeddings utilizing the ChromaDB framework. 
- **`pdf_parser.py`**: Helper functions to interact with the filesystem and process uploaded PDFs.
- **`llm_client.py`**: Wrapper services to interact effectively with the selected generative AI backends locally or over the cloud.

## Execution Flow

1. **Upload**: Users input their PDFs to the main interface. 
2. **Extraction & Run Workflow**: Clicking "Start Extraction & Synthesis" parses texts, and spins up the multi-agent `orchestrator.py`.
3. **Exploration**: Once processed, users navigate identical conceptual graphs (`Discovery Map`), discuss specific passages (`Research Chat`), and view simulated peer-review (`Debate Chamber`).
