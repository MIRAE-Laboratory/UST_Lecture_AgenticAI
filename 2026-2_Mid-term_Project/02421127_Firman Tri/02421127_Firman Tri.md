# BUDDY: End-to-End Personal Research Assistant
**Mid-Term Architecture Blueprint & Progress Evaluation (`v0.3.9`)**

---

## 1. Project Specification & Core Blueprint

### 1.1 Problem Statement & Purpose
Academic literature reviews and cross-paper comparisons are major bottlenecks for researchers. Reviewing, screening, and comparing methodologies across 10 to 15 papers manually takes **3 to 5 hours per research cycle**. Existing off-the-shelf "Chat with PDF" or standard RAG tools fail in scholarly workflows for three specific reasons:
1. **Vector Database Pollution:** Automatically indexing every search result floods the knowledge base with low-relevance preprints and noisy bibliography sections.
2. **Loss of Structural & Page Hierarchy:** Naive character-based chunking slices mathematical formulas, methodology descriptions, and experimental results across arbitrary boundaries without preserving exact page locations.
3. **Technical Keyword Blindness:** Pure dense-vector retrieval struggles to match exact domain acronyms, sensor band designations (e.g., `Sentinel-2 B4`, `ACOLITE`), or specific baseline architectures.

**Purpose:** **BUDDY** is an end-to-end personal research workbench that places the human researcher in the **Director's Role**. It combines dual-source academic discovery (peer-reviewed journals + open-access preprints), AI-assisted relevance screening, section- and page-aware PDF indexing, hybrid Reciprocal Rank Fusion (RRF) retrieval, interactive PDF citation verification, and a pluggable sub-agent ecosystem.

---

### 1.2 Target Users & Operating Context
* **Primary Users:** Graduate students, Ph.D. candidates, and academic lab researchers conducting systematic literature reviews, methodology comparisons, and manuscript drafting.
* **Technical Skill Profile:** Domain specialists (e.g., remote sensing, marine computer vision, environmental engineering) who need an intuitive, visual research workbench rather than maintaining raw command-line scripts.
* **Operating Environment:** Local desktop or lab workstations running a cost-optimized hybrid AI stack—combining zero-cost local inference via **Ollama** with high-speed cloud synthesis via the **Gemini Flash Lite** free tier.

---

### 1.3 Core Features (Implemented MVP vs. Tier 2 Expansion)
Each core capability is designed around an explicit research action:

1. **Discover & Screen (Live in `v0.3.9`):** Search both peer-reviewed literature (**Semantic Scholar API**) and open-access preprints (**ArXiv API**). An optional **AI Precision Query** translator converts conversational questions into strict boolean `AND` keyword expressions, while the screening engine generates collapsible relevance cards (`🟢 High`, `🟡 Medium`, `🔴 Low`).
2. **Curate, Parse & Profile (Live in `v0.3.9`):** Batch-upload local PDFs or approve screened candidates. The ingestion pipeline strips noisy `References` sections, tracks exact 1-based PDF page numbers, and automatically extracts each paper's true `Title`, `Publication Year`, `Authors`, `Research Domain`, `Core Objective`, `Methodology`, `Key Findings`, and `Future Work` into both a **2/3-Column Card Grid** and a **Master-Detail Split View**.
3. **Retrieve, Fuse & Preview Citations (Live in `v0.3.9`):** Execute Hybrid Search combining 768-dimensional local embeddings (`nomic-embed-text`) and sparse keyword matching (`BM25Okapi`) via Reciprocal Rank Fusion (RRF). Grounded answers render interactive numbered badges (`[1]`, `[2]`) that display paper metadata on hover and open a **Live Highlighted PDF Page Preview** on click.
4. **Inspect & Govern Storage (Live in `v0.3.9`):** Audit live relational tables (`projects`, `papers`, `chunks`, `buddy_logs`) and the 768-d vector index (`vectors.sqlite`) directly inside the UI.
5. **Synthesize, Bridge & Peer-Review (Tier 2 Sub-Agents):** Run pluggable specialized agents for multi-paper synthesis matrices, Socratic hypothesis sparring, interdisciplinary concept bridging, and 4-persona adversarial peer review.

---

### 1.4 Human-AI Interaction Flow ("The Researcher as Director")
BUDDY enforces strict Human-in-the-Loop (HITL) gates so the AI never pollutes the curated library autonomously:

| Stage | Actor | Trigger Mechanism | Action & Governance Gate |
| :--- | :--- | :--- | :--- |
| **1. Project Scoping** | **Human** | Sidebar Form Submission | Defines project name, domain variables, and methodology scope in SQLite. |
| **2. Precision Screening** | **AI** | Clicking `🔎 Search & Screen` | Translates query into boolean terms, fetches Semantic Scholar/ArXiv abstracts, and scores relevance into ephemeral staging (`is_curated = 0`). |
| **3. Curation Approval Gate** | **Human** | Clicking `⚡ Approve Abstract` or `📥 Approve + Full PDF` | **Mandatory Human Gate:** Only human-approved papers (or batch-uploaded local PDFs) transition to `is_curated = 1` and enter the vector store. |
| **4. Hybrid RAG & Verification** | **AI + Human** | Clicking `🚀 Run Hybrid Search` & Citation Buttons | AI synthesizes answers using numbered hover citations (`[1]`, `[2]`); Human clicks any reference badge to verify the highlighted passage on the original PDF page. |

---

### 1.5 Technical Stack & Expected Outcomes
* **LLM & Embedding Stack:** Local **Ollama** (`nomic-embed-text` for 768-d embeddings; `qwen2.5:3b` for local screening/chat) + Cloud **Google GenAI SDK** (`gemini-2.5-flash-lite` for structured Pydantic extraction and long-context synthesis).
* **Application & Storage Stack:** `Streamlit` (Theme-adaptive curved pill UI), `pymupdf4llm` & `pymupdf` (page-aware PDF parsing and highlight rendering), `rank-bm25` (sparse retrieval), and a compiler-free `sqlite3` + `numpy>=2.1` relational and vector persistence engine (`research.db` + `vectors.sqlite`).
* **Measurable Outcomes:**
  * Reduces multi-paper screening and methodology comparison from **3+ hours to under 10 minutes**.
  * Guarantees **0% vector store pollution** via the `is_curated` staging gate and automated bibliography stripping.
  * Provides **100% verifiable citation lineage** down to the exact highlighted PDF page number.

---

### 1.6 Failure States, Graceful Fallbacks & Human Verification Boundaries
To ensure production resilience on real research data, BUDDY explicitly handles four operational failure states and defines clear boundaries for what the human researcher must verify:

| Failure State / Risk | System Detection & Automated Fallback Mechanism | What Remains Under Human Control |
| :--- | :--- | :--- |
| **1. External Academic API Rate-Limit (`HTTP 429` on Semantic Scholar)** | `ArxivDiscoveryClient.search_semantic_scholar()` catches `HTTP 429` / timeout errors and **automatically falls back to the OpenAlex Peer-Reviewed API** (`250M+` journal works, reconstructing full abstracts from inverted indices with zero rate-limit blocking). | The human reviews the source badge (`🏛️ Peer-Reviewed` vs. `📄 ArXiv Preprint`) and publication venue before approving any candidate. |
| **2. Over-Constrained Boolean Search (`0 Hits` on Niche Topics)** | If a strict 4-term `AND` query returns `0` preprints on ArXiv, `build_anchored_fallback_arxiv_query()` relaxes secondary method terms using `OR` while **keeping the primary domain keyword mandatory** (e.g., `CDOM`), preventing unrelated keyword soup. | The human can toggle `✨ Enable AI Precision Query` on/off, adjust the `📅 From Year (≥)` filter, or refine domain keywords directly. |
| **3. Cloud LLM Quota Exhaustion, Model Deprecation (`404`), or Offline Mode** | `LLMRouter` and `DiscoveryTriageManager` implement a **3-tier fallback chain**: Primary Cloud Gemini (`gemini-3.5-flash-lite`) $\rightarrow$ Local Ollama (`qwen3.5:4b` / `qwen2.5:3b`) $\rightarrow$ Deterministic regex/heuristic parser (`_build_heuristic_fallback_card`). The UI never crashes or leaves blank cards. | The human can switch between Cloud Gemini and Local Ollama in real time, and re-run `"🔄 Re-Extract Categories"` or `"✨ Refresh Structured Profile"` at any time. |
| **4. Paywalled / Missing Full-Text PDF or LLM Citation Oversimplification** | When a journal record lacks an open-access PDF link, `"📥 Approve + Full PDF"` is automatically disabled and `"⚡ Approve Abstract Only"` remains active. In Tab 3, synthesized claims are forced to use numbered anchors (`[1]`, `[2]`). | **Mandatory Human Verification:** Because LLMs can oversimplify equations or experimental caveats, the human clicks any `[1]`, `[2]` badge in Tab 3 (Block 4) to inspect the **yellow-highlighted passage rendered directly on the original PDF page**. |

---

## 2. Two-Tier System Architecture (Kernel + Plugin Pattern)

To guarantee long-term maintainability and prevent spaghetti code, BUDDY separates foundational data/retrieval operations (**Tier 1 Kernel**) from analytical agent workflows (**Tier 2 Plugins**):

```text
┌────────────────────────────────────────────────────────────────────────┐
│                 TIER 1: CORE ENGINE (The Kernel - v0.3.9)              │
│  • Relational DB (research.db) + Compiler-Free Vector Store (NumPy/SQL)│
│  • Page- & Section-Aware PDF Parser (pymupdf4llm) + Bibliography Filter│
│  • Dual Discovery Client (Semantic Scholar Peer-Reviewed + ArXiv API)  │
│  • Hybrid RRF Engine (768-d Ollama Dense Vectors + BM25Okapi Sparse)   │
│  • Hybrid LLM Router (Local Ollama vs. Cloud Gemini Flash Lite)        │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Injects `context` & enforces `AgentOutputEnvelope`
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│               TIER 2: BUDDY SUB-AGENT ECOSYSTEM (The Plugins)          │
│  • BaseBuddyAgent Abstract Contract + Dynamic BuddyRegistry            │
│  ┌───────────────────────┐  ┌───────────────────────┐  ┌────────────┐  │
│  │ Synthesis Matrix Gen  │  │ Socratic Sparring     │  │ Peer Review│  │
│  └───────────────────────┘  └───────────────────────┘  └────────────┘  │
│  ┌───────────────────────┐  ┌───────────────────────────────────────┐  │
│  │ Cross-Domain Bridge   │  │ Future Custom Sub-Modules / Menus     │  │
│  └───────────────────────┘  └───────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```



---


## 3. End to End System Architecture (Kernel + Plugin Pattern)

```text
====================================================================================================
                     BUDDY END-TO-END SYSTEM ARCHITECTURE & DATA WORKFLOW
====================================================================================================

  [ EXTERNAL SOURCES ]          Semantic Scholar (Peer-Reviewed)  |  ArXiv Preprints  |  Local PDFs
                                                                  |
                                                                  v
+--------------------------------------------------------------------------------------------------+
| TIER 1: CENTRAL MANAGEMENT & THE "RAG HEART" (core/)                                             |
|                                                                                                  |
|  1. STAGING AREA (is_curated = 0)                  2. HUMAN DIRECTOR GATE                        |
|  +-----------------------------------------+       +------------------------------------------+  |
|  | • AI Boolean Query Optimization         | ----> | • User Reviews 9-Category Screening Card |  |
|  | • 9-Category Abstract Screening         |       | • Clicks [Approve] OR [Batch Upload PDF] |  |
|  | • Stored in SQLite (Zero Vector Noise)  |       +--------------------+---------------------+  |
|  +-----------------------------------------+                            |                        |
|                                                                         v (Promotes to           |
|  3. PAGE- & SECTION-AWARE INGESTION                                        is_curated = 1)       |
|  +--------------------------------------------------------------------------------------------+  |
|  | • Strips 'References' & 'Bibliography' noise via Regex                                     |  |
|  | • Splits by Academic Headers & tracks exact 1-based PDF Page Numbers (page_number)         |  |
|  | • Extracts True Title, Year, Authors & 9-Category Profile (Gemini Flash Lite / Ollama)     |  |
|  +----------------------------------------------+---------------------------------------------+  |
|                                                 |                                                |
|                                                 v                                                |
|  4. THE RAG HEART: DUAL PERSISTENT STORAGE & HEALTH INSPECTOR                                    |
|  +----------------------------------------------+---------------------------------------------+  |
|  | 🗄️ Relational Store (research.db - SQLite)   | 🧭 Vector Store (vectors.sqlite - NumPy)     |  |
|  | • projects: Scope & topic definitions        | • 768-d Dense Embeddings (nomic-embed-text) |  |
|  | • papers: Metadata, Year, 9-Category JSON    | • Sub-2ms Vectorized Cosine Similarity      |  |
|  | • chunks: Section text + exact PDF Page #    | • Synchronized with Curated Paper IDs       |  |
|  | • Sparse Index: Tokenized BM25Okapi Corpus   |                                             |  |
|  +----------------------------------------------+---------------------------------------------+  |
|  | 🩺 LIVE HEALTH & DATA INSPECTOR (Tabs 2 & 5):                                              |  |
|  | • Preview Master-Detail Chunks & Sections    • Audit Raw SQLite & 768-d Vector Rows Live   |  |
|  +----------------------------------------------+---------------------------------------------+  |
|                                                 |                                                |
|                                                 v                                                |
|  5. HYBRID RRF RETRIEVAL & PAGE-GROUNDED CITATION ENGINE (Tab 3)                                 |
|  +--------------------------------------------------------------------------------------------+  |
|  | • Reciprocal Rank Fusion (RRF): Combines Dense Semantic Vectors + Sparse BM25 Keywords     |  |
|  | • Numbered Hover Badges [1], [2] -> Click to Render Highlighted Original PDF Page          |  |
|  +----------------------------------------------+---------------------------------------------+  |
+-------------------------------------------------|------------------------------------------------+
                                                  | Injects unified `context` & `AgentOutputEnvelope`
                                                  v
+--------------------------------------------------------------------------------------------------+
| TIER 2: PLUGGABLE ANALYTICAL SUB-AGENTS (buddy/ — Dynamic BuddyRegistry)                         |
|                                                                                                  |
|  +-----------------------+  +-----------------------+  +------------------+  +----------------+  |
|  | 📊 Synthesis Matrix   |  | 🧠 Socratic Sparring  |  | 🌉 Domain Bridge |  | ⚖️ Peer Review |  |
|  +-----------------------+  +-----------------------+  +------------------+  +----------------+  |
+--------------------------------------------------------------------------------------------------+

```

---
## 4. Adjusted Directory Structure & Module Responsibilities

```text
buddyproject/
├── .agents/
│   ├── rules/rules.md              # Always-on architectural & schema rules for Antigravity IDE
│   └── skills/buddy-research-dev/  # Architecture & schema guardian skill (SKILL.md)
├── .env                            # Isolated environment variables (API keys & DB paths)
├── app.py                          # 5-Tab Streamlit Research Workbench (Theme-adaptive UX)
├── core/                           # TIER 1: CORE KERNEL INFRASTRUCTURE
│   ├── config.py                   # Centralized paths, model identifiers, and directory bootstrapper
│   ├── schemas.py                  # Canonical Pydantic v2 contracts (SCHEMA_VERSION = "0.1.1")
│   ├── db/
│   │   ├── sqlite_manager.py       # Relational CRUD, safe auto-migrations, & DB Inspector
│   │   └── vector_store.py         # Persistent SQLite + NumPy 768-d cosine similarity engine
│   ├── ingestion/
│   │   ├── parser.py               # Page- & section-aware PDF parser + References stripper
│   │   └── chunker.py              # Section-bounded overlapping chunker with page_number tracking
│   ├── retrieval/
│   │   └── hybrid_engine.py        # Dense + Sparse BM25 retrieval + Reciprocal Rank Fusion (RRF)
│   ├── discovery/
│   │   ├── arxiv_client.py         # Semantic Scholar (Peer-Reviewed) & ArXiv boolean search client
│   │   └── triage_manager.py       # AI Precision Query optimizer & Structured Paper Card profiler
│   └── llm/
│       └── router.py               # Dual-model router (Ollama local vs. Gemini Flash Lite)
├── buddy/                          # TIER 2: PLUGGABLE SUB-AGENT FRAMEWORK
│   ├── base_agent.py               # Abstract BaseBuddyAgent interface
│   ├── registry.py                 # Dynamic plugin registration & UI discovery
│   └── sub_agents/
│       └── dummy_agents.py         # Registered Tier 2 plugin previews (Matrix, Socratic, Bridge, Review)
├── storage/                        # Persistent local project data
│   ├── raw_papers/                 # Downloaded & batch-uploaded full-text PDFs
│   ├── sqlite/research.db          # Relational metadata, structured profiles, and chunks
│   └── vector_store/vectors.sqlite # 768-d vector index
├── docs/
│   └── DEVELOPMENT_LOG.md          # Live version history & architectural state log
└── tests/                          # Incremental milestone smoke tests (test_v010, test_v020, test_v030)
```

---

## 5. Canonical Data Schema & Safe Auto-Migration (`SCHEMA_VERSION = "0.1.1"`)

* **`projects` (`research.db`):** `id (PK)`, `name`, `topic_description`, `created_at`
* **`papers` (`research.db`):** `id (PK)`, `project_id (FK)`, `title`, `authors (JSON)`, `year (INT)`, `abstract`, `doi`, `pdf_path`, `is_curated (0/1)`, `relevance_score`, `structured_summary_json (JSON)`
* **`chunks` (`research.db`):** `id (PK)`, `paper_id (FK)`, `section_name`, `chunk_index (INT)`, `chunk_text`, `page_number (INT)`
* **`vector_index` (`vectors.sqlite`):** `chunk_id (PK)`, `project_id`, `paper_id`, `section_name`, `chunk_index (INT)`, `page_number (INT)`, `chunk_text`, `embedding_json`
* **`buddy_logs` (`research.db`):** `id (PK)`, `project_id (FK)`, `agent_name`, `input_summary`, `output_json`, `schema_version`, `created_at`
