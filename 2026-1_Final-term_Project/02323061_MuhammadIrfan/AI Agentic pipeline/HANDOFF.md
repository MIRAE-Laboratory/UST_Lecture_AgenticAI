# Handoff — PNT R2R Pipeline (Senior Researcher)

## What this package gives you

An eight-stage pipeline that converts raw coater CSV exports into ML model
predictions, proven reproducible by SHA-256 manifests (stages 0–5) and
structural manifests (stages 7–8).

Stages 0–4 (deterministic, **byte-identical** across machines):
1. **Transform** — InfluxDB Flux long-format → wide CSV with domain labels
2. **Sync** — time-aligns sensor channels by physical distance and motor speed
3. **Partition** — extracts stable steady-state segments, labels them `z?d?u?`
4. **Fusion** — concatenates segments by label into `merged_z*.csv`

Stages 5–8 (ML, **same-machine reproducible**):
5. **Filter** — removes low-quality columns (missing ≥ 70 %, zero-var, leakage, identifier)
7. **InputSelect** — 4-stage AI feature selection (univariate → RF → redundancy → forward)
8. **Model** — 7-model Optuna comparison (30 trials) + extended winner tuning (50 trials)

`pipeline/r2r_pipeline_frozen.py` (v1.0.3) — deterministic stages. Run it; do not rewrite it.
`pipeline/r2r_ml_pipeline.py` (v1.0.0) — ML stages. Run it; do not rewrite it.

---

## Step 1 — Install exact library versions

The SHA-256 hashes depend on numpy and pandas float formatting. Wrong versions
→ `DRIFT DETECTED` even on identical raw data.

```bash
pip install -r requirements.txt       # numpy==1.26.4, pandas==2.2.3
pip install -r requirements_ml.txt    # ML stages 5–8
```

Pinned ML: `scikit-learn==1.6.1`, `optuna==4.5.0`, `xgboost==3.0.2`,
`lightgbm==4.6.0`, `shap==0.48.0`.

---

## Step 2 — Place your raw data

**Standard path (raw InfluxDB exports):** Put your Flux CSV files in:

```
0.Transforming/Target/
```

File naming rules:
- Filename must contain `plc` (case-insensitive), e.g. `0218-plc.csv`
- Filename must NOT contain `meniscus`
- Format check: open any file — **row 0 must be** `#group,false,false,...`
  If row 0 shows `D305xxx` column names instead, that is a different (already-wide)
  format and will not be processed correctly.

The register-to-label mapping must exist at:

```
0.Transforming/mapping.csv
```

Two-column, no header: `D305xxx_register_name,domain_label_name`

**Alternative path (already-processed files):** See the section
"Mixing in pre-processed files" below.

---

## Step 3 — Run the pipeline

**Windows — all 8 stages (recommended):**

```bat
scripts\run_full_pipeline.bat "C:/path/to/this/project/folder"
```

**Windows — deterministic stages only (stages 0–4):**

```bat
scripts\run_pipeline.bat all "C:/path/to/this/project/folder"
```

**Or directly:**

```bash
python pipeline/r2r_pipeline_frozen.py all --root "C:/path/to/this/project/folder" --check
```

Use forward slashes in the path. `--root` must point to the folder that
contains `0.Transforming/`, `1.Rawdata/`, etc.

To run one stage at a time, replace `all` with `transform`, `sync`,
`partition`, or `fusion`.

---

## Step 4 — Read the manifest result

After each stage the console prints a `[MANIFEST]` line. The two outcomes:

| Console output | Meaning |
|---|---|
| `OK stage '…' reproducible — N files match baseline` | Pass. Outputs are byte-identical to the baseline recorded on your first run. |
| `DRIFT DETECTED` | Stop. Input data or frozen code changed. Do NOT proceed. |

**First run only:** the line will say `baseline written` instead of `reproducible`.
That is normal — it records your machine's baseline. Every subsequent run will
say `reproducible` if inputs and code are unchanged.

**Do not share `manifest_*.json`** — these are machine-local. Each machine generates
its own baseline on its first run.

---

## Step 5 — Find your outputs

| Stage | Output folder | File pattern | Description |
|---|---|---|---|
| Transform | `1.Rawdata/` | `J1_dataset_<source>.csv` | Wide-format sensor data with domain-label columns |
| Sync | `2.Synchronize/` | `synchronize_final_<MMDD>.csv` | Time-aligned data trimmed to shortest valid channel |
| Sync | `2.Synchronize/` | `shifted_result_common_spd_<MMDD>.csv` | Full-length shifted data before trim (pre-trim intermediate) |
| Sync | `2.Synchronize/` | `delay_summary_common_spd_<MMDD>.csv` | Per-channel delay metadata: Distance, Common SPD, Delay (sec), Shift (rows) |
| Partition | `3.Partitioning/` | `<date>_z?d?u?_<i>.csv` | Steady-state segments labelled by zone and coating condition |
| Fusion | `4.Fusioning/` | `merged_z*.csv` | Segments concatenated by label — inputs for ML stages |
| Filter | `6.Filtering/ai_driven/<case>/` | `Filtered_<case>.csv`, `hard_filter_report.csv` | Column-filtered data; report lists every dropped column and reason |
| InputSelect | `5.InputSelection/ai_driven/<case>/` | `stage_D_forward_selected.csv` | Rows with `selected=True` are the features passed to Model |
| Model | `7.Ai modeling/ai_driven/<case>/` | `model_comparison.csv`, `winner_predictions.csv`, `final_metrics.json`, scatter/residual/SHAP plots | Per-case winner model, predictions, SHAP analysis |
| Model | `8.Report/` | `agentic_gpu_results.csv`, `AGENTIC_SUMMARY.txt` | Cross-case summary table and human-readable report |

`8.Report/AGENTIC_SUMMARY.txt` is the final human-readable result.
`4.Fusioning/merged_*.csv` are the stable inputs for the ML stages.

---

## Stages 5–8 — ML pipeline

ML stages read from `4.Fusioning/merged_z*.csv` and write final predictions to
`8.Report/AGENTIC_SUMMARY.txt`. They use a separate frozen module and separate manifests.

### Run individual ML stages

```bash
python pipeline/r2r_ml_pipeline.py filter      --root "<root>" --check   # stage 5 (~2 min)
python pipeline/r2r_ml_pipeline.py inputselect --root "<root>" --check   # stage 7 (~5 min)
python pipeline/r2r_ml_pipeline.py model       --root "<root>" --check   # stage 8 (60–90 min)
```

### Run all 8 stages at once (recommended)

```bat
scripts\run_full_pipeline.bat "<PROJECT_ROOT>"
```

Runs stages 0–4 (via `r2r_pipeline_frozen.py`), then 5, 7, 8 (via `r2r_ml_pipeline.py`).
Stops immediately on any failure or `DRIFT DETECTED`. Expect **90–120 minutes** total
for 7 cases with GPU acceleration.

### ML manifest notes

| Console line | Meaning |
|---|---|
| `[MANIFEST] baseline written` | First run — baseline recorded. Run again to confirm reproducible. |
| `[MANIFEST] OK … reproducible` | Pass. Same-machine results match baseline. Safe to proceed. |
| `[MANIFEST] DRIFT DETECTED` | Stop. Something changed. Check library versions or data. |

### Reproducibility contract

- **Stages 0–5** are **byte-identical** across machines with matching library versions.
  Your senior can reproduce them exactly with `requirements.txt` + `requirements_ml.txt`.
- **Stages 7–8** are **same-machine reproducible** — same GPU + same library versions →
  same winner model and feature set. Different GPU hardware produces different Optuna
  trial paths; this is expected, not a bug. Do not compare stage 7–8 manifests across
  machines.

---

## Mixing in pre-processed files

If you already have a wide-format `J1_dataset_*.csv` (e.g. produced by a
previous pipeline run, or provided directly), you can drop it into `1.Rawdata/`
and run only the sync→partition→fusion stages — skipping transform entirely:

**Step A — Copy the file:**

```
1.Rawdata/J1_dataset_0305-plc.csv   ← drop it here
```

The filename must start with `J1_dataset_` to be picked up by sync.

**Step B — Run with `--from-stage sync`:**

```bash
python pipeline/r2r_pipeline_frozen.py all --root "C:/path/to/project" --check --from-stage sync
```

`--from-stage sync` skips the transform stage and its manifest check entirely,
so the transform manifest will NOT fire DRIFT even though you added a file to
`1.Rawdata/` without running transform.

**Step C — Schema gate (automatic):**

Before any sync work starts, the pipeline validates every file in `1.Rawdata/`
against `pipeline/canonical_schema.json` (derived from the known-good 0218
reference file, 226 columns). For each file it reports:

- **required matched** — must be 11/11. The 11 required columns are `_time`,
  the three main GSM channels (`Address1/3/4_zone_data_4`), and all 7 motor
  speed channels. If any are missing the run is blocked with exit code 3.
- **extra (not in canonical)** — columns present in your file but not in the
  canonical schema. Informational only; they pass through to sync output.
- **column ORDER differs** — informational only. Sync and partition select
  columns by name, so order differences do not affect processing.

A missing required column is a hard stop. Fix the file before proceeding.

**Step D — Reset manifests when the file set changes:**

If you are adding files to a run that previously only had (say) 3 files, the
old sync/partition/fusion manifests will detect DRIFT because the file count
changed. Delete those three manifests before Run 1 so it writes new baselines:

```bash
rm manifest_sync.json manifest_partition.json manifest_fusion.json
rm -f 2.Synchronize/*.csv 3.Partitioning/*.csv 4.Fusioning/*.csv
```

Then run twice: Run 1 writes baselines, Run 2 confirms reproducible.
Keep `manifest_transform.json` — it guards the transform outputs separately.

---

## If something goes wrong

| Symptom | Likely cause | Action |
|---|---|---|
| `0 PLC CSVs found` | Files in `0.Transforming/Target/` don't have `plc` in name | Rename files |
| `DRIFT DETECTED` and you didn't change anything | Library version mismatch | Re-run `pip install -r requirements.txt` |
| `DRIFT DETECTED` after intentional data change | New raw data or added mix-in file | Delete stale manifests for affected stages and re-run |
| `[SCHEMA] BLOCKED` — missing required columns | Pre-processed file is missing critical columns | Check file has `_time`, `Address1/3/4_zone_data_4`, all `Motor_SPD_*` |
| `[SCHEMA] BLOCKED` — cannot read header | File is corrupt or wrong encoding | Re-export or re-convert the file |
| Row 0 shows `D305xxx` names instead of `#group` | Wrong InfluxDB export format | Re-export using Flux format with annotations |
| Zero segments in `3.Partitioning/` | Data never reaches steady state | Valid result, not an error — report count to lead |
| ML `DRIFT DETECTED` on first rerun after data change | Stale ML manifests | Delete `manifest_filtering.json` and/or `manifest_ml.json`, then re-run twice |
| ML `DRIFT DETECTED` on a different machine | GPU floating-point differs across hardware | Expected for stages 7–8; share `8.Report/AGENTIC_SUMMARY.txt`, not manifests |
| `stage_D_forward_selected.csv` has no `selected=True` rows | InputSelect found no features above threshold | Check filtered CSV has non-constant numeric columns |
| Stage 8 takes 60–90 minutes | Normal for 7-case full Optuna run | Run individual cases or wait — this is expected |

---

## What this pipeline will NOT do

- It will not rewrite any processing logic between runs.
- It will not tune thresholds to produce more or fewer segments.
- It will not produce cross-machine identical ML results — stages 7–8 are
  same-machine reproducible, not cross-machine. Different GPU hardware produces
  different Optuna trial paths; this is expected, not a bug.

---

## Pipeline versions

`r2r_pipeline_frozen.py` PIPELINE_VERSION: **1.0.3**

Changelog:
- 1.0.0 — Initial frozen pipeline (sync, partition, fusion stages)
- 1.0.1 — Transform stage: added InfluxDB Flux long-format → wide conversion
  (replaces the earlier wide-CSV-only transform that produced zero output)
- 1.0.2 — Schema-validation gate at sync start; `--from-stage` flag to run
  sync→partition→fusion without touching transform or its manifest
- 1.0.3 — Sync stage now writes two auxiliary outputs per source file:
  `shifted_result_common_spd_<MMDD>.csv` (full-length pre-trim shifted data)
  and `delay_summary_common_spd_<MMDD>.csv` (per-channel delay metadata).
  `synchronize_final_*.csv` content is unchanged.

`r2r_ml_pipeline.py` ML_PIPELINE_VERSION: **1.0.0**

- 1.0.0 — Initial frozen ML pipeline (filter, inputselect, model stages).
  NopPruner + seed=42 + n_jobs=1 everywhere for same-machine reproducibility.
  GPU auto-detection (XGBoost / LightGBM); silent CPU fallback.
  RULE 1: same-zone column exclusion. RULE 2: fold-internal imputation only.
