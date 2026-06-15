# Design: `pipeline/r2r_ml_pipeline.py`

## Table of Contents

1. [Purpose and Scope](#1-purpose-and-scope)
2. [Input/Output Contract per Stage](#2-inputoutput-contract-per-stage)
3. [Determinism Table](#3-determinism-table)
4. [Manifest Design](#4-manifest-design)
5. [GPU Auto-Detection Logic](#5-gpu-auto-detection-logic)
6. [CLI Design](#6-cli-design)
7. [Frozen Hyperparameters](#7-frozen-hyperparameters)
8. [Implementation Order](#8-implementation-order)
9. [Open Questions for the Human](#9-open-questions-for-the-human)
10. [Not in Scope](#10-not-in-scope)

---

## 1. Purpose and Scope

`pipeline/r2r_ml_pipeline.py` is the frozen ML module for stages 5–8 of the PNT R2R
pipeline: hard filtering, AI-driven input selection, multi-model Optuna comparison, and
extended winner tuning. It reads `4.Fusioning/merged_z*.csv` (the deterministic outputs of
stages 0–4) and writes filtered datasets, feature-selection traces, model artifacts, OOF
predictions, and structured performance reports. It does **not** produce training or
research decisions — it mechanically executes a frozen procedure and records whether
re-running it on the same inputs yields the same structural result.

This file is **separate from `r2r_pipeline_frozen.py`** for three reasons. First, stages
0–4 are byte-identical across any machine with matching library versions; stages 5–8 are
not — even with seeds pinned, Optuna TPE trial ordering is deterministic only within a
single OS/thread-scheduler context, and GPU floating-point is hardware-dependent. Merging
the two reproducibility regimes into one file would silently weaken the byte-identical
guarantee of stages 0–4. Second, stages 5–8 require additional dependencies (`xgboost`,
`lightgbm`, `optuna`, `shap`, `scipy`) that are not needed for stages 0–4; separating
them allows the stages 0–4 environment to remain lean. Third, the version contract
differs: `r2r_pipeline_frozen.py` increments `PIPELINE_VERSION` on every logic change and
treats any output drift as a hard error; `r2r_ml_pipeline.py` uses `ML_PIPELINE_VERSION`
and treats drift within a defined tolerance as a pass.

What this file explicitly does NOT do: it does not retrain or tune beyond the frozen
Optuna trial budgets, it does not modify stages 0–4 outputs or manifests, it does not
produce a byte-identical manifest (Regime A applies only to Stage 5 filtering outputs),
and it does not run `generate_rich_outputs.py` (that remains a separate post-processor).

---

## 2. Input/Output Contract per Stage

### Stage 5 — Hard Filtering

**Governing spec:** `5-8/agent_instructions/05_filtering_agent.md`
**Reproducibility regime:** A (SHA-256 byte-identical)

| Item | Value |
|------|-------|
| Input folder | `{root}/4.Fusioning/` |
| Input file pattern | `merged_z*.csv` |
| Required columns | At minimum: the zone target column (`Address{Z}_zone_data_4`); all numeric sensor columns |
| Output folder | `{root}/6.Filtering/ai_driven/{case_name}/` |
| Output files | `Filtered_{case_name}.csv` — filtered feature matrix with target column retained |
| | `hard_filter_report.csv` — every dropped column with its drop reason |

`Filtered_{case_name}.csv` and `hard_filter_report.csv` are deterministic given identical
inputs and identical library versions. Their SHA-256 hashes are written to
`manifest_filtering.json`. Both files use UTF-8-with-BOM encoding and CRLF line endings
(matching the source code's `encoding="utf-8-sig"` + Windows pandas default).

---

### Stage 7 — Input Selection (including embedded Stage 6 Standardization)

**Governing spec:** `5-8/agent_instructions/07_input_selection_agent.md`,
`5-8/agent_instructions/06_standardization_agent.md`
**Reproducibility regime:** B (structural + metrics tolerance)

Stage 6 (Standardization) has no standalone stage. `StandardScaler` is fit on the
training fold only inside `cv_score()`, which is called throughout stage 7 and 8.
This is correct by design and is not extracted.

| Item | Value |
|------|-------|
| Input folder | `{root}/6.Filtering/ai_driven/{case_name}/` |
| Input file | `Filtered_{case_name}.csv` |
| Required columns | Target column present; at least one numeric feature column |
| CV strategy | Passed in from `get_cv_strategy(n_rows)` — see Frozen Hyperparameters |
| Output folder | `{root}/5.InputSelection/ai_driven/{case_name}/` |
| Output files | `stage_A_survivors.csv` — columns: `feature, pearson, spearman, mutual_info`; all Stage A survivors sorted by `\|pearson\|` desc |
| | `stage_B_importance.csv` — columns: `feature, mean_importance`; top-30 by mean RF importance desc |
| | `stage_D_forward_selected.csv` — columns: `feature, cumulative_cv_r2, marginal_gain, selected`; forward-selection trace for all Stage C survivors |

Note: Stage C (redundancy removal) produces no output file; its result is held in memory
only.

All three output files use UTF-8-with-BOM encoding (`encoding="utf-8-sig"`).

Regime B verification for stage 7: the final selected feature list (from
`stage_D_forward_selected.csv`, rows where `selected=True`) must match the baseline
feature list exactly (same names, same set). Feature list is written to
`manifest_ml.json` per case as `selected_feature_list` (sorted alphabetically for
stable comparison).

---

### Stage 8 — AI Modeling

**Governing spec:** `5-8/agent_instructions/08_ai_modeling_agent.md`
**Reproducibility regime:** B (structural + metrics tolerance)

| Item | Value |
|------|-------|
| Input folder (features) | `{root}/5.InputSelection/ai_driven/{case_name}/stage_D_forward_selected.csv` |
| Input folder (data) | `{root}/6.Filtering/ai_driven/{case_name}/Filtered_{case_name}.csv` |
| Output folder | `{root}/7.Ai modeling/ai_driven/{case_name}/` |
| Output files | `model_comparison.csv` — columns: `model, cv_r2, n_trials, time_sec, best_params` |
| | `optuna_{ModelName}_trials.csv` — per-model Optuna trial log; one file per model evaluated |
| | `extended_tuning_{WinnerName}.csv` — 50-trial extended Optuna log for the winner |
| | `winner_predictions.csv` — columns: `actual, predicted, residual, abs_error`; one row per dataset row (OOF predictions) |
| | `scatter_actual_vs_pred.jpg` — scatter actual vs predicted; 6×5 in, 100 dpi |
| | `decision_log.txt` — human-readable per-case summary |
| | `final_predictions_all.csv` — OOF predictions with `original_index` column |
| | `final_predictions_test.csv` — same OOF predictions with `y_true_test`/`y_pred_test` column names |
| | `final_metrics.json` — train/test MAE, MSE, RMSE, R², n_train, n_test, n_features |
| | `case_summary.json` — full metadata: winner, features, base R², new R², best params |
| | `final_model_importance.csv` / `.jpg` — feature importance (tree models and linear models only) |
| | `final_model_shap.csv` / `.jpg` — SHAP mean absolute values (if `shap` installed) |
| | `winner_model.joblib` — serialized model + scaler + feature list |
| Aggregate outputs | `{root}/7.Ai modeling/ai_driven/all_case_summary.csv` |
| | `{root}/7.Ai modeling/ai_driven/all_case_test_r2.jpg` |
| | `{root}/8.Report/agentic_gpu_results.csv` — **all processed cases** (7 if all present; never filtered by `ONLY_CASES`) |
| | `{root}/8.Report/AGENTIC_SUMMARY.txt` |

Regime B verification for stage 8: `winner_model_name` must match baseline exactly;
`selected_feature_list` must match exactly; `cv_r2` must be within ±0.001 of baseline;
`cv_rmse` must be within ±1.0% of baseline.

---

## 3. Determinism Table

All of these exist in `5-8/run_agentic_gpu_pipeline.py` and must be addressed in the
frozen module. "Regime after pinning" is the reproducibility class that applies after
the listed fix is applied.

| Source of randomness | Location (source line range) | How pinned in frozen module | Regime after pinning |
|---|---|---|---|
| `np.random.seed(42)` global | Module level, line 200 | Keep; also call at top of each stage entry function to reset state | B |
| `KFold(shuffle=True, random_state=42)` | `get_cv_strategy()`, lines 222–228 | Keep `random_state=42`; change `shuffle=True` is required for reproducibility and is already seeded | B |
| `mutual_info_regression(random_state=42)` | Stage A, lines 356–358 | Keep `random_state=42`; seed already set | B |
| `RandomForestRegressor(random_state=42, n_jobs=-1)` — Stage B | Stage B objective, line 404 | Change `n_jobs=-1` → `n_jobs=1` | B |
| `cross_val_score(rf, ..., n_jobs=-1)` — Stage B | Stage B objective, line 406 | Change `n_jobs=-1` → `n_jobs=1` | B |
| `RandomForestRegressor(n_jobs=-1)` — Stage D forward selection | Stage D, line 462 | Change `n_jobs=-1` → `n_jobs=1` | B |
| `cross_val_score(rf_q, ..., n_jobs=-1)` — Stage D | Stage D, line 465 | Change `n_jobs=-1` → `n_jobs=1` | B |
| `TPESampler(seed=42)` — Stage B study | Stage B, line 415 | Keep seed; add `n_jobs=1`; **remove MedianPruner** (replace with `NopPruner`) | B |
| `TPESampler(seed=42, multivariate=True)` — compare study | `compare_all_models()`, line 555 | Keep seed and multivariate; **remove MedianPruner** (replace with `NopPruner`) | B |
| `MedianPruner(n_startup_trials=5)` — compare | `compare_all_models()`, line 556 | **Remove** — replace with `optuna.pruners.NopPruner()` | B |
| `TPESampler(seed=42, multivariate=True)` — tune study | `tune_winner()`, line 751 | Keep seed and multivariate; **remove MedianPruner** | B |
| `MedianPruner(n_startup_trials=10)` — tune | `tune_winner()`, line 752 | **Remove** — replace with `optuna.pruners.NopPruner()` | B |
| `make_xgb()` hardcodes `n_jobs=-1` | Line 495 | Change `n_jobs=-1` → `n_jobs=1` | B |
| `make_rf()` hardcodes `n_jobs=-1` | Line 508 | Change `n_jobs=-1` → `n_jobs=1` | B |
| XGBoost CUDA device floating-point | `make_xgb()`, lines 491–496 | Record `gpu_used` in manifest; two runs on different GPU/CPU modes are treated as different baseline regimes, not drift | B (regime-tagged) |
| LightGBM GPU device | `make_lgb()`, lines 498–504 | Same treatment as XGBoost | B (regime-tagged) |
| `RandomForestRegressor(n_jobs=-1)` — compare study | `rf_obj` inside `compare_all_models()`, line 608 indirectly via `make_rf` | `make_rf()` fix propagates here | B |
| Full-data fit for SHAP / importance (`_final_model.fit(_X_full, y)`) | Lines 903–904 | Seeded via model constructors; `n_jobs=1` propagation covers RF/XGB/LGB | B |
| `ONLY_CASES` selective filtering | Lines 1159–1162 | **Remove** — always process all discovered `merged_z*.csv` files | A (policy: no selective reporting) |

**Net result:** With `n_jobs=1` everywhere, `NopPruner`, `random_state=42` throughout,
and GPU mode recorded in the manifest, Regime B outputs are expected to be
**bit-identical on the same machine across successive runs**. The ±0.001 tolerance in
the manifest exists as a safety margin for minor floating-point ordering differences
within the OS; it is not expected to be needed routinely.

---

## 4. Manifest Design

Two manifest files, both written to `{root}/` (the project root passed via `--root`).

---

### `manifest_filtering.json` — Regime A (SHA-256)

Written at the end of the `filter` stage. Tracks byte-identical reproducibility of
`Filtered_{case}.csv` and `hard_filter_report.csv` for every case.

```json
{
  "ml_pipeline_version": "1.0.0",
  "stage": "filtering",
  "written_at": "2026-05-29T14:22:01",
  "files": {
    "6.Filtering/ai_driven/merged_z1d1u0/Filtered_merged_z1d1u0.csv": "sha256:...",
    "6.Filtering/ai_driven/merged_z1d1u0/hard_filter_report.csv": "sha256:...",
    "6.Filtering/ai_driven/merged_z3d0u1/Filtered_merged_z3d0u1.csv": "sha256:...",
    "..."
  }
}
```

Comparison logic: identical to `r2r_pipeline_frozen.py` — first run writes baseline;
subsequent runs recompute SHA-256 for every file in `6.Filtering/ai_driven/**/*.csv` and
compare against baseline. Any mismatch → `DRIFT DETECTED` (exit code 2). All files
present and matching → `OK filtering reproducible — N files match baseline`.

JPG files are excluded by pattern (`*.csv` glob only).

---

### `manifest_ml.json` — Regime B (structural)

Written at the end of the `model` stage (or at the end of `all`). One entry per case.
The manifest is structural, not byte-hash-based.

```json
{
  "ml_pipeline_version": "1.0.0",
  "stage": "model",
  "written_at": "2026-05-29T15:44:10",
  "gpu_mode": {
    "xgboost_device": "cuda",
    "lightgbm_device": "cpu",
    "hardware_class": "Intel64 Family 6 Model 141 Stepping 1|cuda_12.4"
  },
  "cases": {
    "merged_z1d1u0": {
      "winner_model_name": "RandomForest",
      "selected_feature_list": ["Address1_zone_data_3"],
      "n_features": 1,
      "cv_r2_baseline": 0.9854,
      "cv_rmse_baseline": 142.3,
      "gpu_used": true
    },
    "...": {}
  },
  "tolerances": {
    "cv_r2_abs": 0.001,
    "cv_rmse_rel_pct": 1.0
  }
}
```

**Comparison logic:**

| Check | Pass condition | Fail condition |
|-------|---------------|----------------|
| `winner_model_name` | Exact string match | Different model selected |
| `selected_feature_list` (sorted) | Exact list match | Any feature added or removed |
| `n_features` | Exact integer match | Implied by feature list check |
| `cv_r2` | `\|current - baseline\| <= 0.001` | Outside tolerance |
| `cv_rmse` | `\|current - baseline\| / baseline <= 0.01` | Outside 1% tolerance |
| `gpu_mode.xgboost_device` | Exact match | GPU mode changed — treated as **new baseline**, not drift; print warning and write new baseline |

**GPU mode change handling:** If `xgboost_device` differs from baseline (e.g., baseline
was `cuda`, current run is `cpu`), the manifest treats this as a different hardware
regime rather than drift. It prints:

```
[MANIFEST] GPU mode changed (baseline=cuda, current=cpu).
           Writing new baseline for this hardware regime.
```

and overwrites the manifest with a new baseline. The user is responsible for not
comparing GPU-trained and CPU-trained baselines.

**`hardware_class` field:** Constructed at startup as:
`platform.processor() + "|" + cuda_driver_version_if_present`.
CUDA driver version obtained via `nvidia-smi --query-gpu=driver_version --format=csv,noheader`
(subprocess, timeout=5s, ignored on failure → `"cpu_only"`).
This field is informational; it is not used in drift comparison logic.

---

## 5. GPU Auto-Detection Logic

The existing `setup_gpu()` function (lines 109–157 of the source) is the most reliable
approach: it attempts a tiny fit on actual hardware rather than inferring from environment
variables. Port it directly, making two changes:

1. The random data used for the probe fit (`np.random.rand(50, 5)`) must use a fixed
   seed so the probe itself is reproducible: `rng = np.random.default_rng(42); X_t = rng.random((50, 5))`.
2. Return a typed `GpuConfig` dataclass (or `dict`) rather than mutating a module-level
   global, so the frozen module can pass it explicitly to model factories.

**Pseudocode:**

```python
def detect_gpu() -> dict:
    cfg = {"xgboost_device": "cpu", "lightgbm_device": "cpu"}
    rng = np.random.default_rng(42)
    X_t = rng.random((50, 5)).astype(np.float32)
    y_t = rng.random(50).astype(np.float32)

    # XGBoost probe
    try:
        import xgboost as xgb
        for device in ("cuda", "gpu_hist"):
            try:
                m = xgb.XGBRegressor(device=device, n_estimators=5,
                                     verbosity=0, n_jobs=1)
                m.fit(X_t, y_t)
                cfg["xgboost_device"] = device
                break
            except Exception:
                pass
    except ImportError:
        cfg["xgboost_device"] = "not_installed"

    # LightGBM probe
    try:
        import lightgbm as lgb
        import contextlib, io
        ds = lgb.Dataset(X_t, label=y_t)
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                lgb.train({"device": "gpu", "verbose": -1, "num_leaves": 4},
                          ds, num_boost_round=5,
                          callbacks=[lgb.log_evaluation(-1)])
            cfg["lightgbm_device"] = "gpu"
        except Exception:
            cfg["lightgbm_device"] = "cpu"
    except ImportError:
        cfg["lightgbm_device"] = "not_installed"

    print(f"[GPU] xgboost={cfg['xgboost_device']}  lightgbm={cfg['lightgbm_device']}")
    return cfg
```

**Behavior at runtime:**
- Printed at stage startup: `[GPU] xgboost=cuda  lightgbm=cpu`
- Recorded in `manifest_ml.json` under `gpu_mode.xgboost_device` and
  `gpu_mode.lightgbm_device`.
- Model factories receive `gpu_config` and select device accordingly — no global state.

---

## 6. CLI Design

```
python pipeline/r2r_ml_pipeline.py <stage> --root <path> [--check]

<stage> = filter | inputselect | model | all
--root   = path to project root (folder containing 4.Fusioning/, 6.Filtering/, etc.)
--check  = write or verify manifest after each stage
```

Mirrors the CLI shape of `r2r_pipeline_frozen.py` exactly. The `--check` flag follows
the same contract: first run writes baseline manifest, subsequent runs compare.

**Stage ordering for `all`:**

```
filter → inputselect → model
```

There is no `--from-stage` flag in this module (no equivalent skip needed; all three
stages must run in order for a valid ML result).

**Exit codes:**
- `0` — all stages passed, manifests match (or baseline written)
- `2` — Regime A drift detected (filtering outputs changed)
- `3` — Regime B structural drift detected (winner changed or features changed or metrics
  outside tolerance)
- `1` — unhandled exception or bad arguments

**Example commands:**

```bash
# Run all stages, verify manifests
python pipeline/r2r_ml_pipeline.py all --root "C:/path/to/project" --check

# Run filtering only
python pipeline/r2r_ml_pipeline.py filter --root "C:/path/to/project" --check

# Run input selection only (expects 6.Filtering/ already populated)
python pipeline/r2r_ml_pipeline.py inputselect --root "C:/path/to/project" --check

# Run modeling only (expects 5.InputSelection/ and 6.Filtering/ already populated)
python pipeline/r2r_ml_pipeline.py model --root "C:/path/to/project" --check
```

---

## 7. Frozen Hyperparameters

All values below are frozen constants. A `ML_PIPELINE_VERSION` bump is required if any
are changed. Values are sourced from direct code inspection of `run_agentic_gpu_pipeline.py`
cross-referenced against the agent instruction `.md` files.

### Global

| Parameter | Value | Source lines |
|-----------|-------|-------------|
| `ML_PIPELINE_VERSION` | `"1.0.0"` | (new — not in source) |
| `RANDOM_SEED` | `42` | line 199 |
| `np.random.seed()` call | at module level and at entry of each stage function | line 200 |

### Stage 5 — Filtering (`hard_filter()`)

| Parameter | Value | Source lines |
|-----------|-------|-------------|
| Drop-by-name patterns | `["rw1", "^sec$", "^_time$"]` (regex, case-insensitive) | lines 262–263 |
| Leakage name patterns | `["target", "label", "answer", "future", "y_", "next_"]` (regex, case-insensitive) | line 263 |
| Missing value threshold | `>= 0.70` (≥70% NaN → drop) | line 277 |
| Near-zero variance std threshold | `<= 1e-12` | line 288 |
| Dominant value ratio threshold | `>= 0.995` (one value accounts for ≥99.5% of rows) | line 290 |
| Identifier cardinality threshold | `>= 0.995` unique values / n rows | line 296 |
| Identifier exclusion | `Address*` columns exempt from identifier drop | line 296 |
| Target column | Never dropped by any pass | all drop lists guard `c != target_col` |

### CV Strategy (`get_cv_strategy()`)

| n_rows condition | Strategy | Parameters | Source lines |
|-----------------|----------|-----------|-------------|
| `< 50` | `LeaveOneOut` | n/a | line 223 |
| `50 <= n < 300` | `KFold` | `n_splits=5, shuffle=True, random_state=42` | lines 226–227 |
| `>= 300` | `KFold` | `n_splits=3, shuffle=True, random_state=42` | line 228 |

### Stage 7 — Input Selection

#### Stage A — Univariate screening

| Parameter | Value | Source lines |
|-----------|-------|-------------|
| Pearson threshold | `> 0.02` (absolute) | line 376 |
| Spearman threshold | `> 0.02` (absolute) | line 376 |
| Mutual Information threshold | `> 0.0005` | line 376 |
| Min valid rows for correlation | `>= 5` | line 365 |
| MI estimator | `mutual_info_regression(discrete_features=False, random_state=42)` | lines 356–357 |
| ADDR SIGNAL threshold | `\|Pearson r\| > 0.25` (see Open Question #1) | lines 328–333 |

#### Stage B — RF importance via Optuna

| Parameter | Value | Source lines | Frozen change |
|-----------|-------|-------------|---------------|
| Optuna trials | `15` | line 416 | None (code comment at line 391 says "30" — comment is wrong; code is authoritative) |
| RF n_estimators range | `[50, 300]` step 50 | line 399 | None |
| RF max_depth range | `[2, 12]` | line 400 | None |
| RF min_samples_split range | `[2, 20]` | line 401 | None |
| RF min_samples_leaf range | `[1, 10]` | line 402 | None |
| RF max_features options | `["sqrt", "log2", None]` | line 403 | None |
| RF n_jobs | `-1` | line 404 | **→ `1`** |
| cross_val_score n_jobs | `-1` | line 406 | **→ `1`** |
| Optuna sampler | `TPESampler(seed=42)` | line 415 | None |
| Optuna pruner | *(none in Stage B — already no pruner in source)* | line 414 | Add `NopPruner()` explicitly |
| Top-k features retained | `min(30, n_features)` | line 425 | None |

#### Stage C — Redundancy removal

| Parameter | Value | Source lines |
|-----------|-------|-------------|
| Pairwise correlation threshold | `> 0.92` (absolute Pearson) | line 443 |
| Tie-breaking rule | Keep feature with higher `\|Pearson r with target\|` | lines 444–445 |

#### Stage D — Forward selection

| Parameter | Value | Source lines | Frozen change |
|-----------|-------|-------------|---------------|
| RF: n_estimators | `100` | line 462 | None |
| RF: max_depth | `8` | line 462 | None |
| RF: random_state | `42` | line 462 | None |
| RF: n_jobs | `-1` | line 463 | **→ `1`** |
| cross_val_score n_jobs | `-1` | line 465 | **→ `1`** |
| Marginal gain threshold | `> 0.003` | line 473 | None |
| Maximum features to select | `20` | line 476 | None |
| Fallback when zero selected | `survivors_c[:min(15, len(survivors_c))]` | line 482 | None |

### Stage 8 — AI Modeling

#### Model comparison (`compare_all_models()`)

| Parameter | Value | Source lines | Frozen change |
|-----------|-------|-------------|---------------|
| Optuna trials per model | `30` | line 197, used at lines 581–668 | None |
| Optuna sampler | `TPESampler(seed=42, multivariate=True)` | line 555 | None |
| Optuna pruner | `MedianPruner(n_startup_trials=5, n_warmup_steps=0)` | line 556 | **→ `NopPruner()`** |
| SVR skip condition | `n_rows > 200` | line 594 | None |
| KNN skip condition | `n_rows >= 200` | line 660 | None |
| KNN max neighbors | `max(2, min(20, n_rows // 5))` | line 661 | None |

#### Ridge (comparison)
`alpha`: log-uniform `[0.001, 1000.0]`

#### ElasticNet (comparison)
`alpha`: log-uniform `[0.001, 100.0]`; `l1_ratio`: uniform `[0.0, 1.0]`; `max_iter=5000`

#### SVR (comparison)
`kernel`: `["rbf", "linear"]`; `C`: log-uniform `[0.1, 1000.0]`; `epsilon`: log-uniform `[0.01, 10.0]`

#### RandomForest (comparison)
`n_estimators`: int `[100, 500]` step 50; `max_depth`: `[2, 15]`; `min_samples_split`: `[2, 20]`;
`min_samples_leaf`: `[1, 10]`; `max_features`: `["sqrt", "log2", None]`; `random_state=42`, `n_jobs=1`

#### XGBoost (comparison)
`n_estimators`: int `[50, 500]` step 50; `max_depth`: `[2, 10]`; `learning_rate`: log-uniform `[0.01, 0.3]`;
`subsample`, `colsample_bytree`: uniform `[0.5, 1.0]`; `reg_alpha`, `reg_lambda`: uniform `[0.0, 5.0]`;
`tree_method="hist"`, `verbosity=0`, `random_state=42`, `n_jobs=1`

#### LightGBM (comparison)
`n_estimators`: int `[50, 500]` step 50; `max_depth`: `[2, 10]`; `learning_rate`: log-uniform `[0.01, 0.3]`;
`num_leaves`: `[10, 100]`; `min_child_samples`: `[2, 30]`; `subsample`, `colsample_bytree`: uniform `[0.5, 1.0]`;
`reg_alpha`, `reg_lambda`: uniform `[0.0, 5.0]`; `verbose=-1`, `random_state=42`

#### Extended winner tuning (`tune_winner()`)

| Parameter | Value | Source lines | Frozen change |
|-----------|-------|-------------|---------------|
| Optuna trials | `50` | line 197, used at line 754 | None |
| Optuna sampler | `TPESampler(seed=42, multivariate=True)` | line 751 | None |
| Optuna pruner | `MedianPruner(n_startup_trials=10, n_warmup_steps=2)` | line 752 | **→ `NopPruner()`** |

Extended search spaces differ from comparison (wider ranges). See `5-8/agent_instructions/08_ai_modeling_agent.md` for the full per-model extended search space tables — they are reproduced there in full and are not repeated here to avoid duplication.

#### Status classification (`process_case()`)

| Condition | Status | Source lines |
|-----------|--------|-------------|
| `cv_r2 >= 0.95` | `EXCELLENT` | line 1101 |
| `0.90 <= cv_r2 < 0.95` | `TARGET_MET` | line 1103 |
| `cv_r2 > base_r2 + 0.01` | `IMPROVED` | line 1105 |
| `cv_r2 < base_r2 - 0.01` | `DEGRADED` | line 1107 |
| otherwise | `MATCHED` | line 1109 |

#### Base reference R² values (frozen constants)

| Case | Base R² |
|------|---------|
| merged_z1d1u0 | 0.8636 |
| merged_z3d0u1 | 0.9550 |
| merged_z3d1u0 | 0.9209 |
| merged_z3d1u1 | 0.8875 |
| merged_z4d0u1 | 0.0971 |
| merged_z4d1u0 | 0.9485 |
| merged_z4d1u1 | 0.8834 |

Source: lines 208–216 of `run_agentic_gpu_pipeline.py`.

---

## 8. Implementation Order

### Pass 1 — Stage 5 (Filtering): Regime A foundation

**What to port:** `hard_filter()` function, lines 261–317.

**What changes:**
- Remove hardcoded `FILTER_DIR` path; accept `root` parameter and construct paths at runtime.
- Remove the `[DIAGNOSIS]` console block (lines 303–315) — it is informational and not part of the spec's required output. Or keep it (it's harmless and useful). Decision: keep it, it helps users spot near-constant targets early.
- Add `ML_PIPELINE_VERSION` constant.
- Add `detect_gpu()` (even though Stage 5 doesn't use GPU — it runs at startup before any stage).
- Add CLI argument parsing (`argparse`).
- Add `_manifest_for_stage()` for Regime A (port the SHA-256 manifest logic from `r2r_pipeline_frozen.py`, adapted to `6.Filtering/**/*.csv`).

**Verification against existing results:**
- Run frozen module's `filter` stage on the same `4.Fusioning/` inputs.
- SHA-256 of every `Filtered_*.csv` and `hard_filter_report.csv` must **match byte-for-byte** with the existing `6.Filtering/ai_driven/` files (assuming identical pandas/numpy versions). If they don't match, investigate before proceeding to Stage 7.
- Run twice; second run must print `OK filtering reproducible`.

---

### Pass 2 — Stage 7 (Input Selection): Regime B introduced

**What to port:**
- `get_cv_strategy()`, lines 222–228
- `cv_score()` (including embedded StandardScaler), lines 231–254
- `ai_input_selection()`, lines 324–484

**What changes (all changes from the determinism table apply):**
- Lines 404, 406: `n_jobs=-1` → `n_jobs=1` in Stage B RF and cross_val_score
- Line 415: Add `NopPruner()` explicitly (Stage B study has no pruner in source, but make it explicit)
- Lines 462–463: `n_jobs=-1` → `n_jobs=1` in Stage D RF and cross_val_score
- Line 465: `n_jobs=-1` → `n_jobs=1`
- ADDR SIGNAL: **see Open Question #1** — implementation waits for human decision
- Add manifest-write call at end of `run_inputselect_all()` — writes `selected_feature_list` per case to `manifest_ml.json` (or creates it if it doesn't exist yet; modeling run will extend it)

**Verification against existing results:**
- `stage_A_survivors.csv`: same feature set (not necessarily byte-identical — mutual_info values may differ slightly with `n_jobs=1`; but the set of features that pass the threshold should be identical if MI variance is small)
- `stage_B_importance.csv`: same top-30 feature set (ordering may differ by small importance values if `n_jobs=1` changes accumulation order)
- `stage_D_forward_selected.csv`: **feature set must match exactly**; cumulative R² values may differ by ≤0.001 with `n_jobs=1`
- Compare with reference outputs in `5-8/5.InputSelection/ai_driven/` for all 7 cases

---

### Pass 3 — Stage 8 (Modeling): Regime B complete

**What to port:**
- `make_xgb()`, `make_lgb()`, `make_rf()`, `make_model_from_params()`, lines 491–539
- `compare_all_models()`, lines 546–670
- `tune_winner()`, lines 677–764
- `process_case()`, lines 771–1129
- Main entry point logic, lines 1136–1309

**What changes:**
- Lines 495, 508: `n_jobs=-1` → `n_jobs=1` in `make_xgb()` and `make_rf()`
- Lines 556, 556: `MedianPruner(...)` → `NopPruner()` in `compare_all_models()`
- Line 752: `MedianPruner(...)` → `NopPruner()` in `tune_winner()`
- Lines 1159–1162: `ONLY_CASES` variable **removed entirely**; always process all discovered files
- Hardcoded `ROOT`, `NEW_ROOT`, `OUTPUT_ROOT` paths replaced by `--root` CLI argument
- Add Regime B structural manifest write in main entry after all cases complete
- `8.Report/agentic_gpu_results.csv` must always contain all processed cases

**Verification against existing results (`5-8/` reference):**
- `model_comparison.csv`: winner model name must match. CV R² may differ slightly with `n_jobs=1`.
- `winner_predictions.csv`: OOF predictions will be numerically close but not byte-identical (same seed, different parallelism → same fold splits, potentially different internal float accumulation). Structural manifest tolerance (±0.001 R²) covers this.
- `manifest_ml.json`: first run writes baseline; second run must pass all structural checks.
- `agentic_gpu_results.csv`: must contain all 7 cases (not 2).

---

### Pass 4 — Skills and HANDOFF update

After all three stage passes produce passing manifests (Run 1 baseline, Run 2
reproducible), update:
- `HANDOFF.md`: add stages 5–8 to the pipeline description, add `r2r_ml_pipeline.py`
  and `manifest_filtering.json`/`manifest_ml.json` to the manifest table.
- `.claude/skills/` — create new skills for filtering, input selection, and modeling
  stages (or one combined ML skill).

This pass is separate so the human can review the implementation before documentation is
updated.

---

## 9. Open Questions for the Human

These are decisions that could not be resolved from the existing code or agent specs
alone. Implementation of affected sections will pause until each is answered.

---

**Q1. ADDR SIGNAL — keep, fix, or remove?**

The `ai_input_selection()` function builds a supplementary feature pool from all
`Address*` columns with `|Pearson r with target| > 0.25`, without excluding columns
from the same zone as the target. This caused scientifically invalid results in cases
z1d1u0 and z4d1u1 (intra-register proxy leakage). The frozen module must choose one of:

- **(a) Keep as-is** — same behavior as source; first-run baseline will include same-zone
  features; results are reproducible but scientifically suspect. Any research use needs a
  separate leakage-exclusion step.
- **(b) Add zone-exclusion rule** — before ADDR SIGNAL, remove all `Address{Z}_zone_data_*`
  columns where Z equals the zone of the target. Scientifically correct; produces
  different outputs from the prior run; existing `5-8/` results become a different baseline.
- **(c) Remove ADDR SIGNAL entirely** — the feature candidate pool consists only of
  non-Address numeric columns. Matches the behavior of the first run (`pipeline_out.txt`,
  all 7 cases, no ADDR SIGNAL) which is the "primary defensible results" cited in
  `09_pipeline_runbook.md`.

The agent spec (`07_input_selection_agent.md`) explicitly says to add zone-exclusion
before any publication. Option (b) is the scientifically correct frozen design; option
(c) is the simpler conservative choice.

**Decision needed before implementing `ai_input_selection()` in the frozen module.**

---

**Q2. `winner_model.joblib` — include in manifests or exclude?**

Joblib pickle bytes vary by Python version (and by `joblib` version). Options:

- **(a) Write the file, exclude from `manifest_ml.json`** — same treatment as JPG files;
  the file exists for downstream use but is not integrity-checked.
- **(b) Write the file and record a hash of its predictions** — rather than hashing the
  pickle itself, fit the saved model on a fixed probe dataset (`np.zeros((10, n_features))`)
  and record the hash of the resulting prediction array. This is more meaningful than a
  pickle hash and is stable across joblib versions.
- **(c) Do not write `winner_model.joblib` at all** — the frozen module's job is
  reproducibility verification; model serialization can be done separately by
  `generate_rich_outputs.py`.

Option (a) is the most conservative and matches the established JPG precedent.

**Decision needed before finalizing the manifest spec.**

---

**Q3. SHAP CSV — included in Regime B structural manifest or not?**

`final_model_shap.csv` is computed from a full-data fit (`_final_model.fit(_X_full, y)`)
and SHAP TreeExplainer. The full-data fit is seeded and `n_jobs=1`, so SHAP values
should be numerically stable on the same machine. Options:

- **(a) Include `final_model_shap.csv` in `manifest_ml.json`** — record the top feature
  by SHAP mean absolute value (as a structural check, not a byte hash). Drift = different
  top-SHAP feature.
- **(b) Exclude SHAP outputs from manifest** — treat them like JPG outputs; informational
  only. `shap` library internals may add their own numerical variation even with seeds.

Option (b) is safer given that `shap` is not required (`ImportError` path exists in the
source). The manifest should not depend on optional libraries.

---

**Q4. `final_predictions_test.csv` — keep or remove?**

This file (lines 930–935 of source) writes the same OOF predictions as
`winner_predictions.csv` with different column names (`y_true_test`, `y_pred_test`,
`sample_index` instead of `actual`, `predicted`, `original_index`). It is not mentioned
in `08_ai_modeling_agent.md`. It appears to be a duplicate written for downstream
compatibility with some external consumer. Options:

- **(a) Keep** — matches existing source behavior; downstream consumers may depend on it.
- **(b) Remove** — `winner_predictions.csv` already contains the same data; duplication
  creates manifest ambiguity.

---

**Q5. Median imputation leakage — fix or preserve?**

`X_all = X_all.fillna(X_all.median())` (line 343) computes the median over the full
dataset before CV splits begin. Test-fold values therefore leak into the imputed medians.
For most features the effect is negligible; for very small datasets (n<50, LOO-CV) it
could be material. Options:

- **(a) Preserve** — matches source behavior exactly; Regime B baseline stays comparable
  to existing `5-8/` outputs.
- **(b) Fix** — move imputation inside `cv_score()` to be fit-on-training-fold-only.
  Scientifically correct, but produces different outputs; existing `5-8/` outputs become
  a different baseline.

If the goal is to freeze the existing (proven) procedure, option (a) is correct. If the
goal is to freeze a scientifically defensible procedure, option (b) is correct but the
existing baseline is then invalid for comparison.

---

**Q6. `run_comparison_pipeline.py` — in scope or out?**

The comparison harness imports and reruns an external `merged_pipeline_full.py` from a
`base code/` folder, then diffs the outputs. This is a development/validation tool, not
a production pipeline stage. Should `r2r_ml_pipeline.py` absorb any of its logic, or
is it permanently out of scope?

**If out of scope:** state so explicitly in the NOT IN SCOPE section and close the question.

---

**Q7. Structural manifest R² tolerance — exact or ±0.001?**

With `n_jobs=1`, `NopPruner`, and `random_state=42` throughout, Regime B outputs are
expected to be **bit-identical** on the same machine across successive runs. If that
proves true in practice, the ±0.001 tolerance is never needed and could be set to 0.0
for maximum strictness. If floating-point non-determinism persists even with `n_jobs=1`
(possible with GPU or OS-level thread scheduling), the ±0.001 guard is necessary.

Options:
- **(a) ±0.001 as designed** — conservative; allows for rare OS-level variance.
- **(b) Exact match first; if any failure, expand to ±0.001** — strictest by default,
  tolerant on failure.

Recommend (a) for the first release; can be tightened after observing actual variance.

---

## 10. Not in Scope

The following are explicitly excluded from `r2r_ml_pipeline.py`. This list exists to
prevent scope creep during implementation.

- **No new model types.** The seven algorithms (Ridge, ElasticNet, SVR, RandomForest,
  XGBoost, LightGBM, KNN) are fixed. No neural networks, no CatBoost, no additional
  ensembles.
- **No changes to Optuna trial budgets beyond the frozen values.** 15 trials for Stage B,
  30 for comparison, 50 for extended tuning — these are frozen constants; changing them
  requires `ML_PIPELINE_VERSION` bump and human sign-off.
- **No automated retuning beyond the frozen trial budget.** The pipeline runs exactly once
  per invocation; it does not loop until a target R² is achieved.
- **No changes to stages 0–4.** `r2r_pipeline_frozen.py` is not touched. Manifests
  `manifest_transform.json`, `manifest_sync.json`, `manifest_partition.json`,
  `manifest_fusion.json` are not read or modified.
- **No absorption of `generate_rich_outputs.py`.** That file remains a standalone
  post-processor. The frozen module writes `winner_predictions.csv` and
  `decision_log.txt` (the inputs `generate_rich_outputs.py` needs), but does not call
  the post-processor.
- **No absorption of `run_comparison_pipeline.py`** (pending Q6 confirmation).
- **No changes to the `DIST` table, `ZONE_TARGET_MAP`, or `BASE_REFERENCE_R2`** without
  human sign-off and `ML_PIPELINE_VERSION` bump. These are calibrated constants from the
  process domain.
- **No SHAP-based feature selection.** SHAP outputs are informational artifacts only.
- **No TimeSeriesSplit replacement for KFold.** The shuffled KFold is the frozen CV
  strategy; it is documented as a known limitation (issue #4 in `09_pipeline_runbook.md`)
  but is not changed in the frozen module without explicit human direction.
- **No requirements.txt for stages 5–8 is generated by this module.** A separate
  `requirements_ml.txt` must be maintained manually.
