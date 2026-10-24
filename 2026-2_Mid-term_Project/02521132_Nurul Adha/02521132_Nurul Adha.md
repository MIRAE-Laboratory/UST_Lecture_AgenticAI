# Jakarta Carbon Map Agent — Specification

**An agentic assistant that estimates building-electricity carbon for Jakarta on a 500 m grid and benchmarks it
against Korea's metered CarbonMap**
UST Agentic AI 2026-2 · Mid-term project · Nurul Adha (Lulu), KICT / UST

---

## 1. Problem

Korea's Carbon Space Map (탄소공간지도, carbonmap.kr, MOLIT) shows building emissions for every 500 m cell of Seoul.
It can do this because Korea meters electricity, gas and district heating for every building and links the bills to the
building register. Jakarta has no such data, so nobody can say where in the city building electricity — and therefore
carbon — is concentrated.

My research estimates this for Jakarta from open geospatial proxies (night-time light, population, building footprint,
roads, built-up layers). Doing it by hand in GIS has three problems I hit in my own data:

* **Silent data errors.** Zonal-statistics tables were joined to the grid by row order instead of cell ID. Values ended
  up on the wrong cells, the table looked fine, and models gave R² ≈ 0 without saying why.
* **Hidden assumptions.** Weights, floors, EUI and the city total are scattered across spreadsheets, so results cannot
  be audited or repeated.
* **No benchmark.** A Jakarta map alone cannot tell whether it is plausible; it needs to be compared with a metered map in
  the same format.

## 2. Users

* **Primary:** urban-carbon researchers working on data-scarce cities (myself first: building operational carbon in
  Jakarta).
* **Secondary:** supervisors and reviewers who need to see which data was used, what was fixed, and which assumptions
  drive the numbers; city planners who want a CarbonMap-style view of Jakarta.

## 3. Features

| Agent | What it does | Deterministic? |
|---|---|---|
| **A1 Planner** | Parses a free-text request (*"emisi listrik bangunan Jakarta"*) into sector / energy carrier / city. Rejects what cannot be estimated (building gas, district heating, transport) with the reason | Rules; LLM optional for parsing only |
| **A2 Data Catalog** | Lists every dataset the plan needs (target, proxies, calibration, emission factor, Seoul reference) with role, resolution, per-cell statistic, access type, download link and **current status** for the loaded data; ranks what to obtain next | Yes — curated list, the LLM cannot invent sources |
| **A3 Data Check** | Tests every layer for spatial alignment with neighbour correlation; searches the file for a zone-ID column that restores alignment and proposes a re-key; excludes layers that cannot be fixed; shows before/after maps | Yes |
| **A4 Estimation** | **Method A (top-down):** distributes the PLN building-electricity total to cells by weighted proxies. **Method B (bottom-up):** footprint × floors × EUI (the method validated against CarbonMap in Seoul). Weights: equal, custom, or learned from Seoul metered data. Low–high range for every cell | Yes |
| **A5 Map & Compare** | CarbonMap-style 500 m map in tCO₂ or MWh, relative or shared legend, Seoul metered map alongside, summary statistics | Yes |

**Key design decisions**

1. **Deterministic core, LLM at the edge.** Numbers, checks and dataset choices come from code and a curated catalog. The
   LLM only interprets the request, so it cannot hallucinate a dataset, a fix or a value.
2. **Verify before you model.** No layer reaches the estimation unless it passes the alignment test or the researcher
   approved a fix. This check found real errors in my own data.
3. **Two independent methods.** Agreement between top-down and bottom-up (and the bottom-up total vs PLN) is the
   plausibility test, since Jakarta has no per-cell ground truth.
4. **Compare energy, not only carbon.** Jakarta's grid factor (0.87 tCO₂/MWh) is about twice Korea's, so the app also
   shows MWh to separate energy use from grid carbon intensity.
5. **Every decision logged.** Fixes, assumptions, acceptance and exports go to an audit log and a method JSON.

## 4. Interaction Flow

1. **Plan (tab 1).** The researcher types a request. A1 shows the plan; A2 shows the data checklist with links and status.
2. **Data check (tab 2).** Load the Jakarta grid (demo table or upload). A3 maps columns and CRS (editable) and runs the
   alignment test. **Human control point:** the researcher approves each proposed fix after seeing the before/after maps.
   Unfixable layers are excluded with an explanation. Optionally load Seoul's CarbonMap grid, which is checked the same way.
3. **Estimate (tab 3).** Choose proxies and weighting, enter the PLN total, set floors and EUI. A4 runs both methods and
   reports totals, B ÷ PLN and A-vs-B agreement. **Human control point:** the researcher accepts the estimate.
4. **Map (tab 4).** Jakarta estimate (with range in the tooltip) next to Seoul metered, same units, relative or shared
   legend, summary table. Marked *draft* until accepted.
5. **Export (tab 5).** Only after acceptance: grid CSV (lon/lat, central, low, high), method & checks JSON, audit log.

### Failure states and how the app handles them

| Failure | Detection | Behaviour |
|---|---|---|
| Layer joined by row order (values on wrong cells) | Neighbour correlation < 0.3 | Searches for a zone-ID column; if r recovers ≥ 0.5 proposes a fix (needs approval), else excludes the layer and says how to recompute it |
| Fix proposed but not approved | Approval checkbox | Layer is not used |
| Seoul reference scrambled | Neighbour correlation of `e_tot` | Comparison and learned weights are blocked with an explanation |
| Unsupported request (gas, heating, transport) | Planner | Explains why instead of guessing |
| PLN total unknown | Value = 0 | Method A shows each cell's share only; no MWh or tCO₂ |
| Bottom-up assumptions unrealistic | B ÷ PLN outside 0.5–2 | Warning to revisit floors / EUI |
| Building footprint missing | Data check | Method B disabled |
| Redundant proxies | Spearman > 0.85 | Warning about double counting |
| Wrong CRS / coordinate columns | Auto-guess shown | Editable before checking |
| LLM unavailable | Exception | Planner falls back to rules |
| Unaccepted estimate | Acceptance flag | Map marked draft; export blocked |

## 5. Success Criteria

Tested on my real Jakarta 500 m proxy table (3,075 cells: VIIRS, WorldPop, OSM roads and buildings, GHSL, ESA).

* **Data check catches real errors:** misaligned layers detected and, where possible, repaired. Achieved on the real table:
  NTL r 0.01 → 0.97, population −0.01 → 0.87; GHSL and ESA correctly excluded.
* **End to end:** plan → check → estimate → map → export runs without errors on the real table.
* **Plausibility:** Method B total within 0.5–2× of the PLN building-electricity total, and Method A vs B Spearman ≥ 0.7.
* **Benchmark:** with an aligned Seoul CarbonMap grid, the same bottom-up method reproduces Seoul's metered pattern
  (earlier offline test: Spearman 0.85 per cell, total ≈ 1.05×).
* **Traceability:** 100 % of fixes, assumptions and acceptance decisions appear in the audit log and method JSON.

### Limitations — what the human still has to check

* Jakarta values are estimates; there is no metered per-cell truth to validate against.
* Without an aligned Seoul table, proxy weights are assumptions (equal or custom).
* Floors and EUI are assumptions unless a building-height layer is added (GHS-BUILT-H is the top-priority missing layer).
* The alignment test detects scrambled layers, not subtle errors such as a wrong year or unit.
* Building gas, district heating and transport are out of scope.

---

**Tech:** Python, Streamlit, pydeck, pandas, NumPy, SciPy, pyproj, pyshp, Pydantic; Gemini or OpenAI optional (planner
only). No API keys are stored in the code.
