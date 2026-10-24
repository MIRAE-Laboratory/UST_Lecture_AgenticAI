# 🧬 Claim Gate — may the AI say *that*?

**UST · Agentic AI · 2026-2 · Mid-term project** — **02621059 · Park Seongsu** (M.S. program, UST)<br>
📄 Specification: [`02621059_ParkSeongsu.md`](02621059_ParkSeongsu.md) · 🎬 Video pitch: `02621059_ParkSeongsu.mp4` (in the submission zip)

![Claim Gate — header and sidebar](assets/1.png)

> **Numbers in code · claims licensed by code · words by the AI · decisions by you.**

An AI drafts the Results paragraph comparing two antibody (BCR) repertoires.
Code computes every number, **decides which comparisons are allowed (the license)**, and checks the draft
twice before it can be exported. The analysis itself is standard (rarefaction, Change-O-style clones,
Hill numbers). **What is new is the gate between an AI-written sentence and the report.**

---

## ✨ How it works

**Two checks on every sentence**

| | Check | Rule | On failure |
|---|---|---|---|
| 1 | **Numbers** (Week 7 verifier) | Every number must be in the computed `facts` | 🔒 export locked |
| 2 | **Claims** (new) | Every comparison between the two samples ("P has more clones than H", "in contrast…", "no difference…") must match the license | 🔒 export locked |
| + | Number ownership | A number that seems to sit with the wrong sample ("the patient had 636 clones, compared to 714 in the donor" when 714 is the patient's) | ⚠️ warning, not a lock |

**When is a direction (P>H or H>P) licensed?** Only if all three hold:

- ✅ **Depth matched** — a human clicks *Match depth* (Undo available); 20 random draws with a fixed seed (2026):
  same files, same license, every run.
- ✅ **Robust** — the direction holds in all 20 draws under all 3 clone rules (diversity: Hill q=1 *and* q=2 agree).
- ✅ **No open confounder** — study, species, isotype, tissue and cell type match, or a human accepted the
  difference *with a written reason*. Age, vaccine and duplicate ratio are shown but never block.

Otherwise the license is `NOT_COMPARABLE`, `INCONCLUSIVE` or `CONFOUNDED`. The human can edit the draft
(every edit is re-checked). Export stays locked until everything passes.

<p align="center"><img src="assets/workflow.png" width="720" alt="Workflow: researcher, Claim Gate code and LLM across steps 1 to 6"></p>

## 🖼️ Screenshots (Demo A, real OAS data)

| **[1–2] Two samples · sequencing depth** | **[3] Results under three clone rules → license** |
|---|---|
| ![Steps 1-2](assets/2.png) | ![Step 3](assets/3.png) |
| **[4] What code cannot fix — human review** | **[5] AI draft, checked sentence by sentence** |
| ![Step 4](assets/4.png) | ![Step 5](assets/5.png) |
| **[6] Export — unlocks only when all checks pass** | |
| ![Step 6](assets/6.png) | |

<sub>Captions for each step: specification, Section 4.</sub>

## 🚀 Run

```bash
pip install -r requirements.txt
streamlit run app.py          # Windows: double-click run_app.bat
```

Python 3.10+. Pick the writer in the sidebar:

| Writer | Setup |
|---|---|
| **Ollama (local)** — default | `ollama pull qwen2.5:7b` |
| **Google Gemini (cloud)** | `GOOGLE_API_KEY` in `.env` (never committed) or pasted in the sidebar |
| **No LLM (template)** | Nothing — also used automatically if the LLM is unreachable |

## 🧪 Tests and evaluation

| Command | What it checks |
|---|---|
| `python tests/test_claim_checker.py` | 122 cases: 74 claim sentences + 48 number-ownership cases on real facts from `tests/fixtures_facts.json` (rebuilt by `tests/make_fixtures.py`) |
| `python tests/app_smoke_test.py` | 13-step headless UI flow |
| `run_heldout.bat` (Ollama) · `run_heldout_gemini.bat` | Held-out evaluation: checker frozen, new drafts at temperature 0.7 → `eval/` (raw drafts `.jsonl`, summary `.md`, manual review `heldout_run*_review.md`) |

## 📊 Data (real, public — Observed Antibody Space)

| Demo | Sample | OAS unit | Study | Condition | Isotype | Productive seqs |
|---|---|---|---|---|---|---|
| **A** (same study) | P | SRR13082941 | Bernardes et al., 2020, *Immunity* | SARS-CoV-2 | bulk | 3,797 |
| | H | SRR13082953 | Bernardes et al., 2020 | healthy | bulk | 819 |
| **B** (confounded) | P | SRR13082923 | Bernardes et al., 2020 | SARS-CoV-2 | IgA | 38,188 |
| | H | ERR3153716 | Bernat et al., 2019, *Front. Immunol.* | healthy | bulk | 6,629 |

- Olsen, Boyles & Deane (2022), *Protein Science*, doi:10.1002/pro.4205.
- `prepare_oas.py` keeps the OAS metadata line and every row and drops long alignment columns (`data_raw/` → `data/`;
  `data_raw/` is not included).
- `data/TEST_*.csv.gz` are **modified test files** (`make_test_files.py`): a 300-row sample (too small) and a copy
  whose metadata carries a prompt-injection attempt.
- **Upload:** two OAS units (`.csv.gz`) or AIRR rearrangement tables (`.tsv`, e.g. from IgBLAST / Change-O / MiXCR);
  required columns `v_call, j_call, junction, junction_aa` (`cdr3_aa` is derived if missing).

## 📁 Files

```
02621059_ParkSeongsu.md  specification (problem, users, features, interaction flow, success criteria, failure states)
README.md                this file
app.py                   Streamlit UI (single page, 6 steps; Plotly charts, dark theme in .streamlit/config.toml)
bcr_facts.py             deterministic engine: loading, clones, Hill numbers, depth matching, license, both checkers
llm_client.py            Ollama / Gemini; gated vs baseline (Week 7) prompt; metadata fenced as untrusted
prepare_oas.py           raw OAS unit -> small bundled file
make_test_files.py       builds the two TEST files
requirements.txt         Python dependencies
run_app.bat              Windows one-click start (installs requirements if missing)
run_heldout*.bat         held-out evaluation (Ollama / Gemini)
assets/                  concept.svg + Concept.png (30-second primer) · workflow.png (sequence diagram) · 1–6.png (screenshots)
data/                    4 real OAS units (Demo A, B) + 2 TEST files
eval/                    held-out drafts (.jsonl), summaries and manual reviews (.md)
tests/                   claim-checker cases (+ real-facts fixtures), held-out script, headless UI smoke test
```

## ⚠️ Limitations

- Depth matching fixes sampling depth only — confounders are shown and must be accepted by a human.
- Age, vaccine and duplicate ratio are shown but never block; the human judges them.
- One sample vs one sample is descriptive, not a statistical test, and says nothing about patients in general.
- "Similar" clones use a fixed 85 % junction identity threshold (Change-O fits it per dataset).
- A licensed direction can be tiny; the license means "robust to sampling", not "biologically meaningful".
- The claim checker uses keyword rules tuned on real drafts; unusual phrasing can be missed or over-flagged.
- Number ownership only warns (held-out: 0 real swaps, 16 false flags in 40 drafts before fixes) and reads standard patterns only.
- Minimum 500 productive sequences per sample (lowered from 1,000 after seeing Demo A's 819-sequence donor).
