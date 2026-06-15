# PNT R2R Pipeline — Superpowers Skills (stages 0–8)

## Quick Start

### 1. Install dependencies

```bash
pip install -r requirements.txt       # numpy==1.26.4, pandas==2.2.3
pip install -r requirements_ml.txt    # scikit-learn, optuna, xgboost, lightgbm, shap
```

### 2. Place raw data

```
0.Transforming/Target/      ← *.csv files with "plc" in filename (InfluxDB Flux format)
0.Transforming/mapping.csv  ← two-column register-to-label map, no header
```

### 3. Run the full 8-stage pipeline

**Windows (recommended):**
```bat
scripts\run_full_pipeline.bat "C:/path/to/this/project"
```

**Stage by stage:**
```bash
python pipeline/r2r_pipeline_frozen.py all --root "<root>" --check   # stages 0–4 (~5 min)
python pipeline/r2r_ml_pipeline.py filter      --root "<root>" --check  # stage 5 (~2 min)
python pipeline/r2r_ml_pipeline.py inputselect --root "<root>" --check  # stage 7 (~5 min)
python pipeline/r2r_ml_pipeline.py model       --root "<root>" --check  # stage 8 (60–90 min)
```

### 4. Read the results

```
8.Report/AGENTIC_SUMMARY.txt   ← final per-case model performance table
7.Ai modeling/ai_driven/       ← per-case winner models, predictions, SHAP plots
```

On first run each stage prints `[MANIFEST] baseline written`. Every later run
prints `[MANIFEST] OK … reproducible` — stages 0–5 are byte-identical across
machines; stages 7–8 are same-machine reproducible. Stop on `DRIFT DETECTED`.

See `HANDOFF.md` for the full field-by-field output description and troubleshooting guide.

Standardized, **reproducible** skills for the roll-to-roll coater data pipeline.
Four sub-agent skills, one per stage, all driving a single **frozen** code module.

## Why this fixes "different results every run"

The four stages — Transforming, Synchronize, Partitioning, Fusioning — are
deterministic. They drifted between runs only because the code was re-written
each session from prose instructions, and small differences (column matching,
rounding, thresholds, file naming) changed the CSVs.

This bundle removes that. Each skill RUNS one pinned module
(`pipeline/r2r_pipeline_frozen.py`) instead of regenerating logic, and a
`--check` flag writes/verifies a `manifest_<stage>.json` (SHA-256 of every
output file). Identical input → identical output, proven on every run.

> Verified: running the pipeline twice on the same input produced byte-identical
> CSVs and a `✅ reproducible` manifest verdict.

## CRITICAL — library versions must match for identical numeric output

The pipeline output (CSV bytes, SHA-256 hashes) depends on **exact** library
versions. Before running on any machine — yours or the senior's — install the
pinned versions:

```bash
pip install -r requirements.txt
```

Pinned versions (as of initial baseline):
- `numpy==1.26.4`
- `pandas==2.2.3`

Using a different numpy/pandas version can silently change float rounding or CSV
formatting, breaking the reproducibility guarantee even with identical raw data.
If the senior has different versions installed, the manifest check will report
`❌ DRIFT DETECTED` on matching inputs — **fix the versions first**.

## Install (Claude Code)

Copy the four folders in `skills/` into your project's skill directory, then
copy `pipeline/` and `scripts/` into the project. Superpowers discovers skills
from the agent skill directory (e.g. `~/.claude/skills/`) or a project-local
skills folder. The skill descriptions trigger automatically when you mention
transform / sync / partition / fusion.

```
<project>/
├── pipeline/
│   └── r2r_pipeline_frozen.py     # the single source of truth (DO NOT rewrite)
├── scripts/
│   └── run_pipeline.bat           # Windows convenience wrapper
└── skills/
    ├── transforming-r2r-rawdata/SKILL.md
    ├── synchronizing-r2r-data/SKILL.md
    ├── partitioning-r2r-segments/SKILL.md
    └── fusioning-r2r-segments/SKILL.md
```

## Run

For one project root (your J1 / J2 / J3 / J4b folder):

```bash
python pipeline/r2r_pipeline_frozen.py all --root "C:/Users/KIMM/Desktop/PNT_Project_Data_and_reports/Claude code testing_2026.05.27_Irfan/J1" --check
```

Or one stage at a time: `transform`, `sync`, `partition`, `fusion`.

## The reproducibility contract

- **First run** of a stage writes `manifest_<stage>.json` — the baseline.
- **Every later run** compares outputs to the baseline:
  - `✅ reproducible` → outputs match. Safe to proceed.
  - `❌ DRIFT DETECTED` → input data or frozen code changed. STOP, investigate.
- To change behaviour intentionally: edit the module, bump `PIPELINE_VERSION`,
  delete the stale manifests, and regenerate baselines with user sign-off.

## What these skills will NOT do

- They will not rewrite the pipeline logic from scratch.
- They will not tune thresholds to change results.
- They do not cover the downstream ML stages (InputSelection / Training), which
  contain controlled randomness and are out of scope for reproducibility gating.
