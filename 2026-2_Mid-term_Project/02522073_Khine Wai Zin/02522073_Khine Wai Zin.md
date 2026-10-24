# Discharge Report Guard — Specification

**Khine Wai Zin** · UST-KIMS, Lightweight Materials Research Division · Agentic AI 2026-2, Mid-term

> A drafting tool that cannot produce an invalid comparison of Mg anode discharge results:
> numbers come from code, sentences from the LLM, and capacities measured under
> different test conditions are never compared.

---

## 1. Problem

I screen Mg anodes by galvanostatic discharge: each test gives a weight loss, from which
specific capacity (mAh/g), utilization efficiency (%) and discharge potential follow. My
"Current Density Screening" sheet alone has 171 planned rows, of which 115 tests were run,
across 25 groups and 9 current densities. Turning this into a results paragraph has two
recurring failure points:

1. **Invalid comparisons.** A capacity means nothing without its conditions: current
   density, discharge time, OCP time and CO₂ purge. In this sheet discharge time is 1 h,
   3 h or 3.33 h depending on the group, and CO₂ is unrecorded for 17 tests. A summary
   that lines up "capacity by grade" across those rows looks clean and is wrong.
2. **Untraceable numbers.** A general-purpose LLM asked to "summarize this data" computes
   its own averages and percentages, rounds freely, and writes "significantly higher"
   with no test behind it. In a fluent paragraph these errors are hard to see.

The sheet also contains errors a reviewer would catch only by re-calculating: two tests
show utilization above 100% (179% and 107%), which is physically impossible, and one
capacity cell is `#DIV/0!` although its weight loss was recorded.

## 2. Users

- **Primary:** me, writing weekly reports, lab-meeting slides and the results section of
  my anode paper.
- **Secondary:** other researchers in our group and in battery or corrosion labs who
  report capacities or rates from weight-loss tests and need the conditions kept
  attached to every number.

## 3. Features

| # | Feature | Who does the work |
|---|---|---|
| F1 | **Recompute and validate**: specific capacity = I·t/Δm and utilization vs. 2205 mAh/g are recomputed and compared with the spreadsheet (1% tolerance); impossible, missing and unrecorded values are listed per test | pandas |
| F2 | **Test-conditions guard**: before any comparison, every condition other than the comparison variable must be held at one value (filter) or made an explicit second grouping (stratify); unrecorded values also block | pandas + human |
| F3 | **Chart proposal with override**: the LLM returns a schema-constrained chart spec (5 allowed types) with a one-line reason; I accept or override; overrides are logged | LLM proposes, human decides |
| F4 | **Fixed renderer**: mean ± SD, n labelled on every bar/point, y-axis from zero | matplotlib |
| F5 | **Facts-only draft**: the LLM receives only a facts dictionary (n, mean, SD, min, max per group, conditions held constant, small groups, exclusions) and writes ≤150 words | LLM, text only |
| F6 | **Verification and export lock**: every number in the draft must appear in the facts; over-claiming words (significant, proves, superior, …) and `[NUMBER NOT AVAILABLE]` markers are flagged; download is disabled until all checks pass; checks re-run when I edit the draft | code + human |
| F7 | **Fixed report template**: conditions, results, figures, data-quality notes and a "Candidate patterns — NOT TESTED" section (IQR outliers) are always present | code |

## 4. Interaction Flow

```
Upload CSV (or bundled lab data)
  └─ Tab 1 · Data check ── F1 lists errors / warnings  ──► I decide which rows to trust
       (utilization > 100% excluded by default; I can include them explicitly)
  └─ Tab 2 · Compare ──── choose outcome + "compare by" (+ optional stratify)
       ├─ F2 guard: conditions differ? ── BLOCK ── I filter or stratify ──┐
       │                                                                 │
       └─ matched ◄──────────────────────────────────────────────────────┘
            └─ LLM proposes chart + reason (F3) ── I accept / override ── figure saved
  └─ Tab 3 · Draft ────── facts shown to me ── LLM drafts (F5)
       └─ F6 checks: unsupported number / over-claim / missing number?
            ├─ yes → export locked; I edit the draft or reject it
            └─ no  → I download report.md + figures (F7)
```

**Human control points:** (1) which flagged rows to include, (2) how to make conditions
match, (3) the chart type, (4) the final wording, (5) the export itself. The LLM never
decides what a number is, never sees raw data, and its output is never executed.

### Failure states

| Failure | What the app does | What I do |
|---|---|---|
| Conditions differ between compared groups | Blocks Tab 2 and Tab 3; lists each condition and its values | Filter to one value or stratify by it |
| Condition not recorded (e.g. CO₂ blank) | Treated as a mismatch, blocks | Exclude those tests, or fix the lab sheet |
| Physically impossible value (utilization > 100%) | Flagged as error; excluded from facts by default; listed in the report | Check weight and area in the notebook |
| Spreadsheet value missing or disagrees with recomputation | Recomputed value used; row flagged | Correct the formula in the sheet |
| Group with n < 3 | Listed in facts; the prompt requires the draft to mention it; always shown in the report's data-quality notes | Treat the mean as an anecdote |
| LLM invents or re-rounds a number | Number listed in red; export disabled | Edit or regenerate |
| LLM over-claims ("significantly") | Words listed; export disabled | Rewrite as description |
| LLM lacks a number | Writes `[NUMBER NOT AVAILABLE]`; export disabled | Add the fact or drop the claim |
| Invalid chart spec (unknown type or column) | Spec rejected, rule-based default used | Choose the chart manually |
| No API key / network or quota error | Data check, guard and charts still work; drafting disabled with the error shown | Fix `.env` or switch to Ollama |
| Filters changed after drafting | Old draft discarded automatically | Regenerate |

## 5. Success Criteria

Measured on the real dataset (115 tests):

1. **No mismatched comparison reaches a draft.** With default filters the guard blocks
   (current density, discharge time, OCP time and CO₂ all vary or are missing); a draft
   is reachable only after all four are matched or stratified. Target: 100% of
   mismatched configurations blocked.
2. **No untraceable number is exportable.** A draft containing an invented value
   (tested with "47.5% higher") or a banned claim word cannot be downloaded. Target: 0
   exported reports with an unsupported number.
3. **Data errors surface before writing.** Both impossible utilizations (G03-2, G04-14)
   and the `#DIV/0!` capacity are flagged in Tab 1 without me looking for them.
4. **Time.** From opening the CSV to a verified results paragraph with one figure in
   under 10 minutes, against my usual manual write-up (timed in the demo).
5. **Honest output.** Every exported report states the conditions, n per group,
   exclusions and "no statistical test performed".

### Known limitations

- The verifier cannot tell if a correct number is attached to the wrong claim; I still
  read every sentence against the facts.
- The guard knows only the four recorded conditions; unrecorded factors (cleaning delay,
  electrolyte batch, surface preparation) are invisible to it.
- Statistics are descriptive only; any claim of difference needs a test I run myself.
