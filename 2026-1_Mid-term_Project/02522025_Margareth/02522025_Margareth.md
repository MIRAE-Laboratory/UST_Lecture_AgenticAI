⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

# App Name: AspenChat — AI-Powered Simulation Report Analyst

---

## 1. Problem Statement

Aspen Plus generates detailed documentation of every simulation run automatically — stream tables, block results, reaction stoichiometry, sensitivity analyses, session logs, and input specifications. This information is complete and accurate. The problem is that it is scattered across three separate files, none of which are optimized for easy reading.

**Understanding a simulation currently has three options:**

1. **The GUI** — open the simulation in Aspen Plus, click through blocks and streams one at a time. Requires the software, the original `.bkp` file, and active navigation. This is how most engineers actually work.
2. **Read the documents** — the three output files contain everything, but no one reads them. They are long, dense, filled with boilerplate, and require knowing exactly where to look.
3. **Custom Python scripts** — parse the report programmatically. Works for a specific flowsheet but has poor generalizability; flowsheet structure varies widely between simulations, making any parser brittle.

**AspenChat is a fourth option:** take the same files that already exist, preprocess them to remove noise, and let an LLM answer questions about the simulation in plain English — directly from the source material, without needing the GUI or writing any code.

**The core user need is:** you are handed a simulation you did not build, and you have no idea where to start — what is this process, what does it produce, how is it set up, and what decisions did the original author make.

**All Aspen Plus output files are plain `.txt`.** The app detects file type automatically by reading the content:

| Header marker found in file | Detected as |
|---|---|
| `ASPEN PLUS CALCULATION REPORT` | Report — stream tables, block results, sensitivity output |
| `ASPEN PLUS CALCULATION HISTORY` | History — session log, input summary, warnings |

The user drops all files into `input_reports/` and the app classifies and loads them automatically.

---

## 2. Target Users

Any undergraduate-level chemical engineer who has used Aspen Plus should be able to use this application comfortably — no programming knowledge required.

---

## 3. Core Features

| Feature | Description | Priority |
|---|---|---|
| Report Directory | User places `.txt` files in `input_reports/`; app detects type and lists them for selection | Must-have |
| Preprocessing | Rule-based + optional LLM pass strips boilerplate before sending to LLM; saves to `preprocessed_reports/` | Must-have |
| Context Injection | Preprocessed text injected directly into the LLM system prompt — no tool calls required for Q&A | Must-have |
| Flowsheet Summary | On load, auto-generate a plain-English summary: feed/product streams, key unit ops, convergence status | Must-have |
| Product Stream Card | Structured output computed from parsed stream data: terminal streams, flow rates, component fractions | Must-have |
| Natural Language Q&A | Chat interface; AI reads from injected context and answers with values and chemical explanations | Must-have |
| Flowsheet Graph | Auto-generate process flowsheet from stream connectivity; node shapes by model type (RSTOIC, FILTER, FLASH2, MIXER) | Must-have |
| Model Selection | Toggle between Gemini and local Ollama (auto-detected) | Must-have |
| Sensitivity Analysis | AI answers questions about sensitivity blocks from report context | Nice-to-have |
| Multi-report Comparison | Load two reports, ask what changed — future tab | Nice-to-have |

---

## 4. Human-AI Interaction Flow

```
Step 1: User drops .txt files into input_reports/
        App reads each file, detects type from content header
         ↓
Step 2: Sidebar: select files, click Preprocess
        - Stage 1: rule-based stripping (~35% token reduction)
        - Stage 2 (optional): LLM compression pass
        - Saved to preprocessed_reports/
         ↓
Step 3: Click "Start Chat"
        - Preprocessed text injected as system prompt context
        - Auto-generated process summary displayed
        - Product stream card rendered
        - Flowsheet graph rendered
         ↓
Step 4: User types a question in plain English
        e.g. "What is this process doing?"
        e.g. "What is the conversion in EXTRACT1?"
        e.g. "Are there any warnings I should know about?"
        → AI answers from context with values and explanations
         ↓
Step 5: User follows up naturally
        e.g. "Why is that reactor set to 85% conversion?"
```

---

## 5. Technical Approach

- **LLM:** Gemini (via `google-genai` SDK) or local Ollama
- **Framework:** Streamlit
- **Key libraries:**
  - `google-genai` — Gemini API client
  - `ollama` — local model inference
  - `python-dotenv` — load `GEMINI_API_KEY` from `.env`
  - `graphviz` — flowsheet graph rendering
  - `streamlit` — UI

- **File handling:** All files are `.txt`. Type detected from content header on load. Raw files in `input_reports/`, preprocessed in `preprocessed_reports/`. Preprocessing done once per file.

- **No structured parsing for Q&A:** Preprocessed text is the source of truth for the LLM. Structured parsing is used only for the flowsheet graph and product stream card.

- **Product stream card:** Terminal streams (dest = `----`) parsed from connectivity section. Component mass fractions computed from stream composition table. Dominant solid-phase component flagged as likely product.

- **Flowsheet graph:** Parsed from `FLOWSHEET CONNECTIVITY BY STREAMS/BLOCKS`. Node shapes by MODEL type. Graphviz `dot` layout (left-to-right).

- **Directory layout:**
```
AspenChat/
├── input_reports/        ← drop .txt files here
├── preprocessed_reports/ ← stripped versions
├── preprocess.py         ← strip_rules(), strip_llm(), preprocess()
├── parser.py             ← terminal streams, component fractions, flowsheet graph
├── llm.py                ← chat(), generate_summary()
├── graph.py              ← render_flowsheet()
├── app.py                ← Streamlit UI
└── .env                  ← GEMINI_API_KEY
```

---

## 6. Preprocessing Rules

**Stage 1 — Rule-based (always applied):**
- Header banner and copyright block
- Page headers: `ASPEN PLUS   PLAT: WIN-X64   VER: 40.0 ... PAGE N`
- Table of Contents entries (lines containing `....`)
- Entire **PROPERTY CONSTANT ESTIMATION SECTION**
- **CO2 Equivalent Summary** blocks after each unit op
- **`*** INPUT DATA ***`** blocks inside UOS blocks
- Per-block config lines: `PROPERTY OPTION SET:`, `HENRY-COMPS ID:`, `CHEMISTRY ID:`
- Flash iteration settings: `TWO PHASE FLASH`, `MAXIMUM NO. ITERATIONS`, `CONVERGENCE TOLERANCE`
- Consecutive blank lines collapsed to one

**Stage 2 — LLM pass (optional, user-triggered):**
- Zero-flow rows in OVERALL FLOWSHEET BALANCE
- Redundant section banners on continuation pages
- RUN CONTROL SECTION boilerplate

---

## 7. Success Criteria

- Preprocessing reduces token count by ≥30% without dropping stream, block result, or sensitivity data
- Auto-generated summary correctly identifies feed streams, product streams, and key unit operations
- Product stream card correctly computes terminal streams and component fractions
- AI correctly answers numerical questions by reading from context
- Flowsheet graph renders correctly from connectivity data
- App works without any API key when using Ollama

See `demo.md` for the presentation demo scenario.
