⭐ **[2026-1 Final-term Project - INDEX](../2026-1_Final-term_Project.md)**

# The Director's Report: Managing an Agentic ML Pipeline for Roll-to-Roll Coater Data

*Submitted by: [StudentNumber] — [Name]*

---

## 1. What I Built

I built an eight-stage agentic pipeline that converts raw InfluxDB Flux sensor exports from a roll-to-roll (R2R) coating machine into reproducible ML model predictions of coating quality. The intent was not to build the smartest possible model — it was to make a research workflow *trustworthy enough to hand off*. Every previous run of this pipeline produced slightly different CSVs, different feature lists, and different model winners, depending on who ran it and when; I had no way to tell a senior researcher whether the results they were looking at were the same ones I had discussed the week before. The system I built replaces that guesswork with a verifiable audit trail: frozen code modules, SHA-256 manifest checks after each stage, a structured state log that records every automated decision, and three explicit human checkpoints where a person must confirm — or override — before the pipeline continues.

---

## 2. Architecture & Design Decisions

The pipeline is divided into two regimes, which reflects a genuine design decision rather than an arbitrary split.

**Stages 0–4 (deterministic)** — Transform, Sync, Partition, Fusion — are run by a single frozen module, `pipeline/r2r_pipeline_frozen.py` (v1.0.3). These stages are byte-identical across any machine with matching library versions (`numpy==1.26.4`, `pandas==2.2.3`). A SHA-256 manifest is written after each stage; every subsequent run verifies against it. This is the reproducibility contract the course calls *grounding* — pinning the empirical baseline so that any drift is detected rather than silently accepted.

**Stages 5–8 (ML, same-machine reproducible)** — Filter, InputSelect, Model — are run by a second frozen module, `pipeline/r2r_ml_pipeline.py` (v1.0.0), which adds `scikit-learn`, `optuna`, `xgboost`, `lightgbm`, and `shap`. These stages cannot be byte-identical across machines because Optuna's TPE sampler is sensitive to GPU floating-point arithmetic, but they are *structurally* reproducible: the same hardware produces the same winner model, the same selected features, and R² values within a 0.001 tolerance.

The **agent layer** sits above both modules. It consists of:

- **`orchestrator.py`** — an `R2ROrchestrator` that sequences stages, reads results into a shared state object, and invokes the evaluation agent and HITL gateway after each stage.
- **`evaluation_agent.py`** — an `EvaluationAgent` that inspects every case's filter report, feature selection output, and model summary, then writes structured flags (`critical` / `warning` / `info`) into the pipeline state. It checks for things the frozen code cannot check: too few columns surviving the filter, zero features selected, negative CV R², CV-test gap > 0.10 (overfitting), and test R² falling below the base-code baseline.
- **`hitl_gateway.py`** — a `HITLGateway` that pauses at each stage boundary and requires a typed human decision (`approve` / `reject` / `skip`) before the pipeline continues. If `--auto` is passed and there are no critical flags, the gateway auto-approves and logs it. If critical flags exist, `--auto` is overridden: the human is always asked.
- **`pipeline_state.py`** — a `PipelineState` that serialises every flag, every automated decision, and every human decision to `pipeline_state.json` as it happens. This is the audit trail.
- **Claude skills** (`skills/`) — eight SKILL.md files that encode *how Claude Code should invoke and interpret each stage*. They define the trigger conditions, the frozen command to run, what output files to inspect, and what constitutes a stop condition. These are the agent's written policy: not runtime LLM deliberation, but pre-encoded *epistemic taste* about what good output looks like.

The feature-selection methodology (Stage 7) deliberately chose a four-stage sequential gate — univariate screening → RF importance → redundancy removal → forward CV selection — rather than the base code's consensus-score table or the alternative base code's SHAP-top-K approach. The rationale: no single evidence type is reliable on small industrial datasets; making every feature survive four independent filters reduces the chance of selecting noise. SHAP is reserved for post-hoc explanation only, not selection, which avoids the double-dipping problem.

For modeling (Stage 8), I rejected the base code's assumption that Random Forest is always the best model. The frozen module evaluates up to seven families (Ridge, ElasticNet, SVR, RF, XGBoost, LightGBM, KNN) with 30 Optuna trials each, then runs 50 extended trials on the winner. The winner is chosen by cross-validated R² per case, not by prior expectation.

---

## 3. Where the Humans Are in the Loop

Three HITL checkpoints are wired into `orchestrator.py`, one after each ML stage:

```
[filter] → EVAL → HITL checkpoint ─┬─ approved → [inputselect] → EVAL → HITL checkpoint ─┬─ approved → [model] → EVAL → HITL checkpoint
                                    └─ rejected: pipeline stops                             └─ rejected: pipeline stops
```

**What is automatic:**
- All of stages 0–4 (deterministic transforms, sync, partition, fusion)
- Stage 5 hard filtering (rule-based, no judgement required)
- Stage 7 feature selection (algorithm-driven, seeded)
- Stage 8 model comparison and winner tuning (algorithm-driven, seeded)
- Manifest verification after every stage
- Flag generation by the evaluation agent (rules are encoded, not ad hoc)
- Auto-approval at each checkpoint when `--auto` is passed and there are no critical flags

**What requires human approval:**
- Proceeding past any ML stage when critical flags are present (overfitting detected, zero features selected, test R² below baseline, Rule 4 blocking count anomalous)
- Always: the model stage, unless `--auto` is explicitly set

**What triggers review:**
- `gap > 0.10` between CV R² and test R² → critical flag, overfitting recommendation written to state
- `test_r2 < base_r2 - 0.05` → critical flag, regression-from-baseline logged
- `remaining < 20` columns after filtering → critical flag, inputselect likely to fail
- `KNN` wins a case → decision logged to monitor n_neighbors

I placed checkpoints at stage *boundaries* rather than inside stages for a deliberate reason: the frozen code runs as an atomic subprocess. Interrupting it mid-stage would leave partial outputs that could corrupt the manifest baseline. Checkpointing at boundaries means the human always sees a complete, verifiable state before deciding whether to proceed — which is the correct placement for *alignment checkpoints* rather than *progress checkpoints*.

The `skip` override (which logs an explicit `override_critical` decision to the state) exists because in a research context there are legitimate reasons to continue past a critical flag — for example, when the "critical" is expected for a known bad-data case and the researcher wants to see what the model does anyway. What matters is that the override is named, timestamped, and in the audit trail.

---

## 4. The Failures I Saw — And the Lessons

**The reproducibility failure.** The most concrete failure is recorded in the README itself:

> *"They drifted between runs only because the code was re-written each session from prose instructions, and small differences (column matching, rounding, thresholds, file naming) changed the CSVs."*

Before the frozen-module architecture, every run of the pipeline was effectively a new experiment. The agent (Claude Code) would re-derive the logic from skills and documentation each session, and small paraphrasing differences — column selection order, a rounding call, a filename suffix — compounded into CSV-level differences that were invisible until someone compared two runs side by side. The lesson: *a digital workforce that regenerates its own implementation each session is not a pipeline, it is a lottery*. Freezing the code and verifying its outputs with SHA-256 hashes was not a nice-to-have; it was the minimum requirement for the work to be scientifically defensible.

**The transform stage failure (v1.0.0 → v1.0.1).** The pipeline changelog records:

> *"1.0.1 — Transform stage: added InfluxDB Flux long-format → wide conversion (replaces the earlier wide-CSV-only transform that produced zero output)"*

The original transform stage assumed the input CSVs were already in wide format. They were not — they were InfluxDB Flux long-format exports with a `#group` annotation row. The stage ran without error and produced zero output rows. This is the worst kind of failure: silent, no exception, no manifest drift, just an empty `1.Rawdata/` folder that downstream stages happily accepted. The lesson: *absence of output is not the same as correct output*. The fix was a schema gate at sync start that now validates required columns and blocks with exit code 3 if they are missing — converting a silent failure into a loud one.

**The schema gate addition (v1.0.2).** The v1.0.2 entry records adding `--from-stage` and the schema-validation gate. Before this, if a researcher dropped a pre-processed wide-format CSV into `1.Rawdata/` to skip the transform stage, the sync stage would pick it up and compare it to manifests from a different data lineage, producing spurious `DRIFT DETECTED` failures. The `--from-stage sync` flag and the canonical-schema validator (`pipeline/canonical_schema.json`, 226 columns from the known-good 0218 reference file) were added to make the "mixing in pre-processed files" workflow safe without corrupting the manifest contract.

**The `rule4_blocked` approximation.** In `orchestrator.py:120`, there is a comment:

```python
# FIX 1: approximate rule4_blocked from filter report
rule4_blocked = max(0, candidates_before - 24 - 1 - len(selected))
```

This is an honest admission that the orchestrator cannot directly read Rule 4's block count from the InputSelect output format. It approximates by subtraction. The evaluation agent then checks `rule4_blocked < 50` for Zone 1 cases and flags it as critical if true — but the approximation itself could produce false positives or mask real problems if the arithmetic assumptions are wrong. This is a known rough edge: the right fix is to have the frozen ML pipeline write a structured `inputselect_report.json` that the orchestrator reads directly, rather than back-calculating from subtraction.

**The `cv_r2` double-read.** `orchestrator.py:111`:

```python
# FIX 2: read cv_r2 from case_summary.json
cv_r2 = float(s.get("cv_r2", 0.0))
```

This `FIX 2` comment reveals that the orchestrator originally read `cv_r2` from the wrong file (the stage D forward-selection CSV, which does not contain it). It had to be redirected to `case_summary.json` after model training completes. The implication is that the inputselect evaluation was running with `cv_r2 = 0.0` for all cases until this was caught — meaning the "CV R² very low" warning was never firing for the right reason in early runs. The lesson: *a flag that always returns 0.0 for a metric is not an audit; it is theatre*.

---

## 5. Critical Reflection on Management

Managing this workflow felt less like writing a program and more like writing a *policy document for an employee I cannot directly supervise*. The frozen code handles execution; the skills handle interpretation; the evaluation agent handles triage; the HITL gateway handles escalation. My job as the director was not to write the algorithm — it was to decide which failures the system should handle autonomously, which it should surface to me, and what evidence it should preserve so that I could audit any decision it made without being present.

The hardest judgment calls were about *alarm thresholds*. Setting `gap > 0.10` as the overfitting critical threshold is an assertion that a 10-point CV-test gap is always worth stopping the pipeline for. But in a dataset with 50 rows, a 10-point gap is routine noise, not evidence of overfitting. The evaluation agent does not know dataset size when it checks the gap. A smarter version of this agent would condition its thresholds on `n_rows`; the current version applies a universal rule that will fire false positives on small-data cases and potentially irritate a researcher into hitting `skip` every time — which defeats the purpose of the checkpoint entirely. *Alarm fatigue is the silent killer of HITL systems.*

Where I would add agents: a pre-run data-quality agent that checks every raw CSV before transform stage runs, classifies the file format, verifies the `#group` annotation row, and counts channels — before any frozen code touches the file. This catches the v1.0.0 zero-output failure at the source instead of downstream.

Where I would remove agents: I would remove the `rule4_blocked` approximation and replace it with a direct structured output from the ML pipeline. The current design creates an agent that reasons about another agent's output by subtraction — a fragile dependency that is already documented as `FIX 1` waiting to happen.

The irreplaceable human skill in this workflow is *reading the SHAP plots*. The pipeline generates SHAP beeswarm and bar charts for every case winner. No rule I can write in Python will tell me whether the top-ranked feature makes physical sense for a roll-to-roll coater — whether a motor speed channel being the dominant predictor of coating weight uniformity is an insight or a data artefact. That interpretation requires domain knowledge the pipeline does not have, which is precisely why `8.Report/AGENTIC_SUMMARY.txt` is addressed to a senior researcher and not to a dashboard.

---

## 6. What I Would Do Differently / Next

**Structured inter-stage contracts.** The current design has the orchestrator reading evaluation data by parsing CSVs and approximating missing values. Every `FIX 1` / `FIX 2` comment in `orchestrator.py` is evidence of this gap. The right design is for each frozen stage to write a machine-readable `stage_N_report.json` with exactly the fields the orchestrator needs, and for the orchestrator to validate that file against a schema before proceeding. This removes all approximation from the evaluation path.

**Threshold conditioning on dataset size.** The evaluation agent's critical thresholds (column count, CV-test gap) should be functions of `n_rows` and `n_cols`, not hard constants. The current constants were chosen for the expected data regime but will break silently on edge cases.

**Cross-machine ML reproducibility.** The current design accepts that stages 7–8 are not reproducible across different GPU hardware. This is honest but limiting. A future version should serialize the Optuna study object after the comparison phase and allow it to be resumed on different hardware, which would at least make the winner model and feature list portable even if the exact trial path differs.

**Replace the `pipeline_state.json` audit trail with append-only logging.** The current state file is overwritten on every `save()` call. If the process crashes mid-stage, the last-written state may be incomplete. An append-only JSONL audit log would preserve every decision event regardless of crash timing, which is a better foundation for a production agentic system.

**The hardest lesson.** The most important thing I would do differently is document the *intended behaviour* of each agent separately from the *actual behaviour*. When I read `# FIX 1: approximate rule4_blocked` six weeks after writing it, I do not immediately know whether this approximation is a temporary scaffold waiting for a proper fix or a permanent design decision that someone has accepted. Future me — or a senior researcher inheriting this codebase — deserves a comment that says why, not just what.
