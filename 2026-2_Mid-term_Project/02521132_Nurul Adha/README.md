# Jakarta Carbon Map Agent

Estimate **building-electricity carbon for Jakarta on a 500 m grid**, in the format of Korea's CarbonMap
(탄소공간지도, carbonmap.kr), and compare it side by side with Seoul's metered map.

## Run

```bash
pip install -r requirements.txt
streamlit run app.py        # http://localhost:8501
```

## Workflow (5 tabs)

| Tab | Agent | What happens | Human control point |
|---|---|---|---|
| 1 Plan & data catalog | A1 Planner, A2 Data Catalog | Type a request (e.g. *emisi listrik bangunan Jakarta*). The planner identifies sector / energy / city, rejects what cannot be estimated (gas, district heating, transport), and lists every dataset needed with status, resolution and download link | — |
| 2 Data check | A3 Data Check | Load the Jakarta grid. Each layer is tested for spatial alignment (neighbour correlation). Misaligned layers are re-keyed by a zone-ID column if one exists; otherwise they are excluded | **Approve each fix**; correct column mapping / CRS |
| 3 Proxies & estimate | A4 Estimation | Choose proxies and weights (equal, custom, or learned from Seoul). Method A distributes the PLN total to cells; Method B = footprint × floors × EUI. Shows totals, B ÷ PLN and A-vs-B agreement | Enter PLN total, set floors / EUI, **accept the estimate** |
| 4 Map & compare | A5 Map | CarbonMap-style 500 m map (tCO₂ or MWh, relative or shared legend), Seoul alongside if loaded, summary table | — |
| 5 Export | — | Grid CSV (with lon/lat and low–high range), method & checks JSON, audit log | Export only after acceptance |

## Methods

* **A — top-down (dasymetric):** `MWh_cell = PLN_total × index_cell / Σ index`, where `index` is the weighted mean of
  min–max-normalised proxies. Range = min/max across alternative weightings (chosen, equal, footprint-only, population-only).
* **B — bottom-up:** `MWh_cell = footprint × floors × EUI / 1000` (floors = height / 3.3 m when a height layer exists).
  Range = floors ± 1 and EUI ± 25 %. This is the method validated against CarbonMap in Seoul.
* Carbon = MWh × grid emission factor (Jakarta 0.87 tCO₂/MWh). Seoul tCO₂ is converted back to MWh with the Korean
  factor so energy use can be compared without the difference in grid carbon intensity.
* **Learned weights** (unlocks only with an aligned Seoul table): non-negative least squares of normalised proxies on
  metered CarbonMap electricity.

## Data check

Neighbour correlation = corr(cell value, mean of 4 nearest cells). Real urban layers > 0.5; ≈ 0 means the values are on the
wrong cells. Cause found in the real data: zonal-statistics tables contain only cells with data and were joined by row
order. The agent looks for an integer ID column with the same number of entries as the value column and re-keys by it if
that restores spatial coherence.

On the bundled Jakarta table: NTL 0.01 → 0.97 and population −0.01 → 0.87 after re-keying; roads and buildings were
already aligned; GHSL and ESA cannot be repaired (no zone ID) and are excluded.

## Files

```
app.py                 Streamlit UI
core/planner.py        A1 request parsing + feasibility (LLM optional)
core/catalog.py        A2 curated dataset catalog and column aliases
core/data_check.py     A3 loading, CRS guess, neighbour-correlation test, re-key search
core/estimate.py       A4 Method A, Method B, learned weights
core/maps.py           A5 500 m grid polygons, CarbonMap-style classes, pydeck map
core/llm.py            Gemini / OpenAI JSON wrapper (planner only)
data/                  Jakarta 500 m proxy table (VIIRS, WorldPop, OSM, GHSL, ESA)
```

## Limitations

* Jakarta values are **estimates**; there is no metered per-cell ground truth. Seoul values are metered.
* Method A's spatial pattern depends on the proxies and weights; without an aligned Seoul table the weights are assumptions.
* Method B depends on assumed floors and EUI unless a building-height layer is supplied.
* Building gas, district heating and transport are not estimated.
* No API key is stored; keys entered in the sidebar live only in the browser session.
