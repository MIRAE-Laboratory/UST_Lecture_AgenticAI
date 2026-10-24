# 🧪 NMR-Titra Lite: Agentic AI Assistant for NMR Titration Curve Analysis

**NMR-Titra Lite** is an end-to-end, computational chemistry and artificial intelligence workbench for analyzing nuclear magnetic resonance (NMR) titration series. It integrates synthetic spectrum generation, moving-window peak tracking, slope-based plateau detection, non-linear binding isotherm regression ($K_d$/$K_a$), and an autonomous agentic LLM workflow with human-in-the-loop verification.

---

## 🌟 Key Features

1. **Synthetic NMR Spectrum Generator Engine**:
   - Generates realistic 1D NMR spectra using Lorentzian lineshape physics:
     $$I(\delta) = \frac{I_0}{\pi} \left[ \frac{\gamma}{(\delta - \delta_0)^2 + \gamma^2} \right] + \text{Noise}$$
   - Includes 2 pre-loaded chemical systems across 13 titration equivalents:
     - **System A (NMI + Formic Acid)**: C2-H resonance shifts downfield from $\delta = 7.41\text{ ppm}$ to $\delta = 7.87\text{ ppm}$ reaching a saturation plateau.
     - **System B (Host-Guest / Metal-Ligand Complexation)**: Aromatic resonance shifts upfield from $\delta = 8.50\text{ ppm}$ to $\delta = 7.92\text{ ppm}$ with high binding affinity reaching plateau after $2.0\text{ eq}$.

2. **Dual-Mode Data Ingestion & Preprocessing**:
   - **Mode 1 (Extracted CSV)**: Ingests `[Sample, Equivalent, Peak_ppm]`.
   - **Mode 2 (Raw Spectral CSV)**: Ingests stacked or individual `[Chemical_Shift_ppm, Intensity, Equivalent]`.
   - Automatic numeric validation, sorting, missing-data rejection, and auto-indexing.

3. **Peak Detection & Cross-Sample Tracking**:
   - Peak detection via `scipy.signal.find_peaks` with adjustable prominence.
   - Moving-window tracking ($\pm 0.15\text{ ppm}$) across the titration series.
   - **Ambiguity Detection**: Automatically flags multi-peak overlaps, low prominence, or boundary drift for human-in-the-loop review.

4. **Deterministic Plateau Physics & Binding Kinetics Engine**:
   - Finite difference / linear regression slope calculation across the final 25% of the titration curve.
   - **Plateau Rule**: Confirmed if $|d\delta/d\text{Eq}| < 0.01 \times \Delta\delta_{\text{total}}$.
   - **No Plateau Rule**: Triggered if $|d\delta/d\text{Eq}| > 0.05 \times \Delta\delta_{\text{total}}$.
   - Non-linear least-squares fitting of 1:1 binding isotherm ($K_d$, $K_a$, $\Delta\delta_{\text{max}}$, $R^2$) using `scipy.optimize.curve_fit`.

5. **Agentic Human-in-the-Loop AI Assistant**:
   - Structured tool execution workflow (`detect_peaks`, `track_peaks`, `analyze_plateau`).
   - Human confirmation override modal when peak tracking ambiguities occur.
   - Dual-engine AI interpretation:
     - **Google Gemini API** (when API key is provided).
     - **Built-in Deterministic AI Chemist Engine** (operates 100% offline without API keys).

6. **Interactive Plotly Visualizations & Export**:
   - Dark scientific theme with reversed chemical shift axis standard.
   - Spectral series overlay and waterfall stack.
   - Titration curve with non-linear fit overlay, plateau zone, and uncertainty flags.
   - Instant export of plotted CSVs, full spectra, and markdown reports.

---

## 🚀 Quickstart & How to Run

### 1. Requirements
Ensure Python 3.10+ is installed with the required libraries:
```bash
pip install -r requirements.txt
```

### 2. Launch the Application
Run the Streamlit application from the root directory:
```bash
streamlit run app.py
```
Open your browser at `http://localhost:8501`.

---

## 📁 Repository Structure
```
Midterm_Project2026/
├── app.py                      # Main Streamlit web application
├── requirements.txt            # Python dependencies
├── README.md                   # Documentation
├── nmr_engine/                 # Core computational and agentic modules
│   ├── __init__.py
│   ├── synthetic.py            # Lorentzian physics & synthetic systems A & B
│   ├── tracking.py             # scipy peak finding & moving-window tracking
│   ├── plateau.py              # Plateau detection & non-linear Kd fitting
│   ├── visuals.py              # Plotly scientific visualization figures
│   ├── data_io.py              # CSV ingestion, validation, and normalization
│   └── agent.py                # Agent tool execution, Gemini & fallback engine
└── sample_data/                # Pre-generated sample CSV files
    ├── system_a_extracted_peaks.csv
    ├── system_a_raw_spectra.csv
    ├── system_b_extracted_peaks.csv
    └── system_b_raw_spectra.csv
```
