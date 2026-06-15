⭐ **[2026-1 Final-term Project - INDEX](../2026-1_Final-term_Project.md)**

# Architecture Notes
**Name: Vu Thi Ly - Student number: 02523033
**Project:** ResearchLens AI — Agentic System for Research Gap Identification 
## ResearchLens AI — Design Decisions & Rationale

*Companion document to The Director's Report.*
*This document records architectural decisions — what was chosen, what was rejected, and why.*

---

## 1. Architectural Style — Sequential Multi-Agent Pipeline

**Decision:** Seven specialized agents running in strict sequence.

**Alternatives considered:**

| Option                        | Why rejected                                                                 |
|-------------------------------|------------------------------------------------------------------------------|
| Single monolithic prompt      | Collapses all reasoning into one pass — failure points invisible, hallucination risk higher |
| Parallel agent execution      | Agents 3–5 depend on prior outputs — parallelism not structurally possible   |
| LangChain / AutoGen framework | Adds abstraction overhead; direct API calls give more control over retry logic and prompt injection |
| RAG-based retrieval           | Corpus is small and session-scoped — vector indexing adds latency with no benefit at this scale |

**Why sequential won:**
Each agent produces output that the next agent depends on. The dependency chain is linear by design — not a limitation, but a deliberate reasoning structure. Sequential execution makes the chain auditable: when output degrades, the source agent is immediately identifiable.

---

## 2. Agent Boundaries — Why Seven, Not One

**Decision:** Split reasoning into seven discrete agents with hard boundaries.

The core principle: **a single prompt cannot be both generator and critic simultaneously.** Asking one model call to produce gaps and evaluate them in the same pass creates a conflict of interest — the model optimizes for output that looks complete rather than output that is correct.

Separating generation from evaluation (Agent 3 → Agent 4) forces the system to surface its own weaknesses. The Verifier receives no instruction to be kind. It is explicitly prompted to find fault.

**The evaluation structure:**

```
Agent 3  →  generates gaps (optimizes for coverage)
Agent 4  →  attacks gaps   (optimizes for accuracy)
Agent 5  →  scores gaps    (optimizes for prioritization)
```

Three independent passes over the same material, each with a different objective. This is the closest approximation to peer review the system can produce without a human in the loop.

---

## 3. Prompt Engineering as the Primary Architecture Layer

**Decision:** Agent behavior is defined entirely through system prompts — no fine-tuning, no post-hoc filtering.

This was the most consequential architectural decision in the project. The alternative — generating output freely and filtering afterward — was rejected because filtering corrects what has already been produced. Prompt constraints prevent production in the first place.

**The hardest constraint in the system (Agent 3):**
```
Every gap MUST include a direct quote from a specific paper
as its evidence base. If you cannot cite a source,
you cannot generate the gap.
```

This single instruction restructured the model's generation behavior more effectively than any downstream filter. It reflects a core principle: **alignment is cheaper at the generation stage than at the correction stage.**

**Design rule applied across all agents:**
- Explicit output format requirements
- Explicit prohibitions (what the agent must not do)
- Mandatory evidence requirements where hallucination risk is highest

Longer, more ambitious prompts were tested in early iterations. The most reliable agents in the final system have the most constrained prompts — not the most detailed ones.

---

## 4. Centralized API Layer — Single `_call()` Function

**Decision:** All seven agents route through one shared `_call()` function.

**Alternative rejected:** Each agent manages its own API call independently.

**Why centralized won:**
Distributing API calls across agents means distributing error handling across agents. Any change to retry logic, rate limit handling, or model configuration requires touching seven files instead of one. A single `_call()` function means infrastructure changes propagate instantly to the entire system.

**The function handles three distinct failure modes:**

| Failure type         | Cause                              | Response                                    |
|----------------------|------------------------------------|---------------------------------------------|
| `503 ServerError`    | Gemini API overloaded              | Exponential backoff, up to 5 retries        |
| `429 ClientError`    | Rate limit exceeded                | Fixed 30s wait + jitter, then retry         |
| Unhandled exception  | Unexpected client-side error       | Raise immediately — no silent failure       |

**Retry schedule for 503:**

| Attempt fails   | Wait before next retry          |
|-----------------|---------------------------------|
| 1st             | ~10s + random jitter (0–3s)     |
| 2nd             | ~20s + random jitter            |
| 3rd             | ~40s + random jitter            |
| 4th             | ~80s + random jitter            |
| 5th             | Surface error to user           |

**Why jitter:**
Simultaneous retries from multiple agents after a 503 would produce a retry storm — all requests hitting the server at the same instant, causing a second overload. `random.uniform(0, 3)` staggers requests across a 3-second window. Standard distributed systems practice.

---

## 5. State Management — Streamlit Session State

**Decision:** `st.session_state` as the sole working memory layer.

**What it provides:**
- All agent outputs persist across page navigation within a session
- Chat Agent can reference the full analysis context without re-running the pipeline
- No re-computation on tab switch

**What it does not provide:**
- Persistence across browser refresh
- Persistence across sessions
- Any form of durable storage

**Why this is a known architectural debt, not an oversight:**
Streamlit's in-memory state was acceptable for a prototype where the researcher controls the session. It is not acceptable for a production system where data loss on refresh is a user-hostile failure.

**Planned resolution — SQLite persistence layer:**

```sql
CREATE TABLE sessions (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp     TEXT,
    paper_count   INTEGER,
    gaps_json     TEXT,
    priority_json TEXT,
    full_output   TEXT
);
```

Write immediately after each pipeline run completes.
The correct build order — which was not followed — is:
**storage layer first, UI layer second.**

---

## 6. Human-in-the-Loop Placement

**Decision:** No automated action downstream of the analysis output.

The system deliberately has no "Generate Research Proposal" button — no feature that converts AI output into an institutional document without human review. This is an architectural constraint, not a missing feature.

**Governing principle:**
Automate retrieval and synthesis. Never automate the decision.

**Where the boundary sits:**

```
AUTOMATED                          │  HUMAN REQUIRED
───────────────────────────────────┼──────────────────────────────
PDF text extraction                │  Corpus selection
Agent 1–5 sequential execution     │  Gap validation
Priority scoring                   │  Research direction decision
Session state storage              │  Institutional judgment
```

The checkpoint sits between the Priority Scorer output and any downstream action. The higher the stakes of the output, the more explicit the checkpoint must be. A research direction decision has career-level stakes — the checkpoint is mandatory, not optional.

---

## 7. On-Demand Agent Isolation

**Decision:** Agents 6 and 7 run outside the sequential pipeline, on explicit researcher request.

**Agent 6 — Trend Analyzer:**
Reads Analyzer outputs directly. Does not depend on Agents 3, 4, or 5. Isolated because trend analysis is a parallel question — not a downstream refinement of gap analysis. Merging it into the pipeline would force it to run on every analysis, adding latency for a feature not always needed.

**Agent 7 — Chat Agent:**
Reads all stored outputs from session state. Runs on every researcher question. Isolated because it is a query interface, not a processing stage — its job is to make the pipeline's reasoning accessible, not to extend it.

**Isolation rule:** An agent that does not depend on another agent's output should not be coupled to its execution.

---

## 8. Multilingual Architecture

**Decision:** Language injection at the prompt level, not at the application level.

**Alternative rejected:** Separate prompt files per language.

**Why prompt injection won:**
A language suffix appended to every agent prompt before execution requires one change point — the `build_prompt()` function. Separate prompt files per language would require maintaining seven files per language, with no guarantee of consistency across agents.

```python
def build_prompt(base_prompt: str, language: str) -> str:
    return base_prompt + LANGUAGE_INSTRUCTION.get(language, "")
```

One injection point. Full system coverage. Zero per-agent modification required.

---

## 9. Architectural Debt — What Was Built in the Wrong Order

Three decisions were made in the wrong sequence. Recorded here because the order of infrastructure decisions matters as much as the decisions themselves.

| What was built first    | What should have been built first  | Cost of wrong order                          |
|-------------------------|------------------------------------|----------------------------------------------|
| UI (Streamlit pages)    | Storage layer                      | Data loss on browser refresh discovered late |
| Gap Generator prompt    | Verifier evaluation criteria       | Vague early gaps, prompt rewritten twice     |
| API calls (bare)        | Retry logic in `_call()`           | 503 crash mid-pipeline during live testing   |

**The pattern:** infrastructure resilience and evaluation criteria should precede the features they support. Building the generator before the evaluator, and the UI before the storage layer, produced rework that was entirely predictable in hindsight.

---

## 10. Planned Architecture Changes

### Add: Citation Validator (Agent 8)

**Gap in current architecture:**
Agent 4 (Verifier) checks whether citation *logic* is sound.
It does not check whether the cited quote *exists* in the PDF.
A fabricated quote that sounds plausible passes the Verifier.

**Proposed position:** Between Agent 3 and Agent 4.
**Input:** Gap Generator output + raw PDF text.
**Output:** Per-gap citation status — `Verified` · `Approximate` · `Not Found`.

---

### Add: Scope Checker (Agent 0)

**Gap in current architecture:**
The pipeline has no pre-flight check on corpus quality.
A heterogeneous corpus — papers from unrelated fields — produces
confident-sounding gaps that are artifacts of comparing incomparable work.

**Proposed position:** Before Agent 1. Blocks pipeline if corpus fails threshold.
**Input:** Paper titles + abstracts.
**Output:** Corpus compatibility score + warning if below threshold.

---

### Merge: Priority Scorer → Verifier

**Current cost:**
Agent 5 is a separate API call that adds latency and one additional
503 failure point. The scoring it produces could be a second output
section in the Verifier prompt without loss of analytical value.

**Proposed change:** Verifier outputs confidence scores, validity labels,
and priority scores in a single structured response.
Net result: one fewer agent, one fewer API call, one fewer failure point.
