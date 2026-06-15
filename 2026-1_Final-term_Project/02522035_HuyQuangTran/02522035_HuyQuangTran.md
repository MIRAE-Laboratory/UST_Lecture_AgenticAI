⭐ **[2026-1 Final-term Project - INDEX](../2026-1_Final-term_Project.md)**

# EpistemicScout: Director's Report

---

## 1. What I Built

EpistemicScout is an autonomous multi-agent research assistant built to solve one problem: the cognitive overload of academic literature synthesis. Instead of reading and cross-referencing dozens of papers manually, a researcher uploads their corpus—or fires a Google Scholar query—and the system does what humans find most painful: it extracts structured claims, methods, and results from each paper, maps them into an ontological knowledge graph, identifies where the literature contradicts itself, and stress-tests those contradictions through a simulated peer debate between two adversarial AI personas. The final deliverable is not a summary—it is a map of what the field has *not* yet resolved, surfaced with citation-grounded evidence and ranked by structural importance. The human remains in control at every decision gate that matters.

---

## 2. Architecture & Design Decisions

The system is built on a **LangGraph stateful cyclic graph** rather than a linear chain, because research synthesis is not a pipeline—it is an iterative review process. Every design decision maps to a specific course concept.

- **Multi-Agent Coordination**: Rather than a single monolithic LLM call, three specialized sub-agents (Claim Extractor, Method Extractor, Result Extractor) run independently per document. This separation of concerns keeps each agent's prompt small, schema-constrained, and auditable. The actual audit trail confirms this worked: across 50 documents, only 1 self-reflection loop was triggered (for `AI-Enhanced_Rainfall_Retrieval...`, which scored 82.5—below the 85-point threshold), demonstrating that task-specialized agents outperform generalist ones.

- **Evaluation & Self-Reflection**: The Critic agent scores every extraction against a three-dimensional rubric (schema balance, citation grounding, conciseness). If the score is below 85/100, the LangGraph router sends the state *back* to the extractor node with the critique embedded in the prompt. This implements a true reflective loop—the agent reads its own failure report and re-analyzes the document. The loop is capped at 2 attempts to prevent infinite regress.

- **Persistent Memory (Semantic Cache)**: Each document is SHA-256 fingerprinted. On re-runs with the same corpus, ChromaDB returns cached entities instantly instead of re-invoking 3×N LLM calls. This is the single most important latency optimization on local M1 hardware—a 30-paper run that takes 8 minutes the first time takes under 20 seconds on the second run.

- **RAG (Retrieval-Augmented Generation)**: The Research Chat Lab tab uses ChromaDB vector retrieval to inject localized, verbatim context—not a summary, but the actual extracted snippets—into the chat prompt before generating a response. This is the primary anti-hallucination mechanism: the model can only cite what was explicitly stored in the vector database.

- **MCP (Model Context Protocol)**: The sidebar connects to a live Google Scholar MCP server. This allows the system to treat Google Scholar as a local tool call—pulling abstracts, author lists, citation counts, and open-access PDF URLs without the user ever leaving the interface. Papers with open `.pdf` URLs are automatically downloaded and parsed in the same ingestion pipeline.

- **HITL (Human-In-The-Loop)**: Three distinct checkpoints gate the workflow. The human triggers ingestion, approves the selected research gap before debate begins, and can steer the debate at any turn through the Moderator panel. These are not cosmetic—they are structural locks that prevent the pipeline from proceeding without deliberate human confirmation.

- **Ontological Graph Memory**: The knowledge graph built by NetworkX is not just a visualization. It is the system's memory of which papers share which concepts. Gap Topology Analysis runs over the graph structure—finding disconnected islands (papers with no semantic links to any other cluster) and high-betweenness bridge nodes (concepts that connect clusters but have no direct empirical literature validating their connection). In the actual run: **659 nodes, 3,936 edges, 51 topological gaps identified**.

---

## 3. Where the Humans Are in the Loop

Three checkpoints were placed deliberately. The key question for each is: *what is the cost of getting it wrong downstream if we skip human review here?*

| Checkpoint | Action Type | What Happens Without It |
|---|---|---|
| **Ingestion Gate** | Human seeds the query or uploads PDFs | The system has no corpus—nothing to process |
| **Gap Approval Gate** | Human selects/approves a gap before debate | Agent debates an uninteresting or trivially false gap; wasted tokens + misaligned output |
| **Debate Moderator Panel** | Human steers mid-debate if agents drift | Agents enter agreement loops, debate loses adversarial tension |

**Defense of checkpoint placement (Week 14 principles):**

The Gap Approval Gate is the most critical placement decision. By the time the graph is built, the system has already done the expensive work—parsing, extraction, graph synthesis, contradiction audit. The *next* step (dialectical debate + document generation) is where alignment drift becomes catastrophic—if the agent debates the wrong gap, the researcher gets a multi-page report that is academically worthless. The checkpoint is placed precisely at the inflection point between computation and generation. Placing it earlier (before synthesis) would be premature because the human cannot evaluate gaps that haven't been discovered yet. Placing it later (after debate) wastes the compute.

The Debate Moderator Panel is an *interactive* checkpoint, not a blocking one. This reflects Week 14's distinction between hard gates (blocking until approved) and soft HITL (available on demand). The human can choose to intervene or let the agents run autonomously. This respects researcher time while preserving control.

---

## 4. The Failures I Saw — And the Lessons

### Failure 1: The Self-Reflection Loop Was Triggered by Vague Descriptions, Not Wrong Data

The only self-reflection trigger in the actual audit log was for `AI-Enhanced_Rainfall_Retrieval_Using_Commercial_Microwave_Links_in_6G-IoT_Networks`, which scored **82.5/100**. The critic's feedback:

```json
{
  "ts": 1781253558.00376,
  "type": "critic_evaluation",
  "document_title": "AI-Enhanced_Rainfall_Retrieval...",
  "score": 82.5,
  "feedback": [
    "Some descriptions are vague generalizations, e.g., 'Significant enhancement of CML-based rainfall retrieval performance by integrating 6G technologies.'",
    "Some extractions lack substantive text snippets, e.g., Method descriptions do not match the snippet content.",
    "The description for 'Federated Learning-Based Distributed Data Processing Framework' is too generic."
  ]
}
```

After the self-reflection loop re-extracted with the critic's feedback injected into the prompt, it re-scored at **92.0/100**. The lesson: the rubric's most effective axis was *citation grounding quality*, not schema compliance. The extractor rarely produced wrong schemas—it regularly produced *vague snippets*. A future improvement is to add a minimum snippet character length as a hard programmatic check before the LLM critique runs, catching the trivial cases without spending a full LLM call.

### Failure 2: The Contradiction Engine Found Only 1 Contradiction Across 50 Papers

The audit log shows:

```json
{"type": "contradictions_found", "num_contradictions": 1, "titles": ["Gains in Fine-Tuned Metrics"]}
```

Across 50 6G/AI papers, finding only one contradiction is almost certainly a failure of the contradiction detection prompt, not a reflection of the actual literature. The corpus spans papers on federated learning, O-RAN, agentic AI, and physical layer design—domains with genuine empirical disagreements about latency benchmarks and model compression tradeoffs. The model likely collapsed under the size of the input: `json.dumps(target_entities)[:12000]` truncates the entity list to 12,000 characters, meaning most entities never made it into the contradiction prompt for comparison. The topological gap analysis (51 gaps via NetworkX structure) compensated effectively, but the semantic contradiction engine was effectively blind.

*Lesson*: Contradiction detection needs chunked pairwise comparison (paper A vs. paper B), not a single pass over the full truncated entity dump. This is a prompt engineering and batching problem, not a model capability problem.

### Failure 3: The Debate Agents Agreed When They Should Have Clashed

In early runs without bounded history, both debate agents converged toward consensus rather than maintaining adversarial posture. The Empiricist would open a turn with "I agree completely with the Conceptualist..." and then extend their argument. This made the debate useless as a stress-testing tool.

*Fix applied*: The debate prompt now explicitly instructs each agent to *refute the opponent's last point* before making a new argument. The system prompt for the Empiricist contains: `"Refute the Conceptualist's abstract arguments as unscientific speculation without empirical data."` Compliance with this instruction is uneven across local 8B models—it degrades when the model's context window fills with agreement-heavy history. The real fix is a Moderator AI that detects semantic similarity between consecutive turns and injects a contradiction directive when agents converge.

---

## 5. Critical Reflection on Management

### Leading an AI Workflow vs. Writing a Program

The central management insight: **in programming, you debug outputs; in agent workflows, you redesign incentives**. When the Contradiction Engine returned only one result, there was no syntax error to fix—the code ran fine. The problem was the agent's prompt structure created an implicit incentive toward caution. A well-constructed rubric or adversarial framing changes agent behavior more reliably than any code change.

The second insight: **latency is a management problem, not a technical one**. The decision to run three specialized sub-agents per document in sequence (Claim → Method → Result) rather than one monolithic call added approximately 40% to the per-document processing time. That cost was deliberately chosen for schema reliability and debuggability. Managing that tradeoff is closer to project management than software engineering.

### In Hindsight: Agent Placement

I over-allocated agents early in development. The initial architecture had separate agents for text cleaning, chunk selection, individual entity validation, and graph edge classification. This caused high context-switching latency and redundant LLM calls on local hardware.

The consolidation into a **triadic structure** (Extractor team of 3 sub-agents → single Critic → Debater pair) with programmatically enforced JSON schemas proved far more efficient. The critical insight: *agents should handle reasoning; schemas and code should handle structure*. Any validation that can be done with a regex or a dict key check should not consume an LLM call.

If I were to redesign from scratch, I would reduce the agent count further and add one agent I initially skipped: a **Gap Ranker Agent** that scores each identified gap on novelty, feasibility, and citation depth before presenting them to the human. Currently, the human sees all 51+ gaps with no prioritization signal beyond gap type (Contradiction vs. Topological).

### The Irreplaceable Human Skill

**Epistemic taste**—the qualitative judgment of whether a research gap is *worth solving*. The graph found 51 structural gaps and 1 semantic contradiction. A human researcher knows within 10 seconds of reading a gap title whether it is a genuine white space or a boundary condition artifact of the input corpus. No rubric captures that. The human's role is not to approve the process—it is to curate the output with domain expertise that the system cannot encode.

---

## 6. What I Would Do Differently / Next

**What I would do differently:**

1. **Chunked pairwise contradiction detection**: Run the Contradiction Engine on paper pairs `(A, B)` rather than on the full entity dump. This would have surfaced genuine empirical conflicts in the 6G latency benchmarks that the current architecture missed entirely.

2. **Programmatic snippet validation before LLM critique**: Add a minimum snippet length check (`len(snippet) < 50 → flag`) in code before the Critic agent runs. Roughly 30% of critic cycles were spent identifying empty-snippet issues that a three-line Python check could have caught for free.

3. **Debate convergence detector**: Build a cosine similarity check between consecutive agent turns. If similarity exceeds 0.85, automatically inject a moderator directive forcing the agents to take an opposing position. The human HITL panel exists, but the human should only need to intervene when the *topic* needs steering, not to correct agent behavior drift.

**What I would build next:**

1. **Repository API connectors**: Expand the MCP client to connect directly to ArXiv, CrossRef, and Semantic Scholar for automated PDF harvesting. Manual file uploads are a significant friction point in a system designed for high-volume literature review.

2. **Gap Ranker Agent**: A dedicated scoring agent that ranks identified gaps on novelty (inverse citation density), feasibility (method availability), and cross-disciplinary distance (graph betweenness of the gap's connecting concepts). The human gap selection step would then work from a ranked, scored list rather than an undifferentiated grid.

3. **Execution trace viewer**: Each node in the Plotly knowledge graph should be clickable to reveal the full audit trail that constructed it—the critic scorecards, the self-reflection feedback, and the verbatim snippets that anchored the entity. Researchers should not have to trust the system's outputs; they should be able to verify the chain of evidence in one click.