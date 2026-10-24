# NMR-Titra Lite: Agentic AI Assistant for NMR Titration Curve Analysis

**Project Type:** Agentic AI Midterm Project
**Research Field:** Chemistry, Catalysis, and Chemical Engineering
**Application Type:** Web-Based Scientific Data Analysis Assistant
**Development Platform:** Google Antigravity

---

## 1. Problem Statement

### The Challenge

Nuclear Magnetic Resonance (NMR) titration experiments are a gold standard for studying host-guest binding, organometallic catalysis, and chemical equilibrium. However, analyzing titration datasets (typically 10 to 20 distinct spectra at varying titrant equivalents) presents severe procedural bottlenecks:

* **Manual Peak Tracking:** Researchers must manually align spectra, locate target resonances, and record chemical shifts ($\delta$, ppm) across all samples.
* **Error-Prone Data Transfer:** Manually copying data points into plotting tools introduces human transcription errors.
* **Repetitive Workflows:** Performing non-linear curve fitting or derivative calculations for every new experimental system is tedious and inefficient.
* **Interpretation Overhead:** Evaluating whether a chemical shift has reached a true equilibrium plateau vs. insufficient titrant addition requires manual mathematical calculations.

### The Solution

**NMR-Titra Lite** provides a unified, intelligent environment that:

1. Ingests extracted chemical shift tables or raw spectral series (Lorentzian intensity data).
2. Uses automated peak-detection algorithms (`scipy.signal.find_peaks`) to track peak trajectories across titration steps.
3. Computes total chemical shift changes ($\Delta\delta$) and generates dynamic Plotly titration curves.
4. Performs slope-based numerical plateau analysis to determine equilibrium saturation.
5. Leverages an AI Agent to coordinate tool execution and deliver natural language scientific summaries.

---

## 2. Target Users & Research Niche

### Target Audience

* **Primary Users:** Graduate students, postdocs, and research scientists conducting binding assays, supramolecular studies, or catalytic reaction monitoring using NMR spectroscopy.
* **Secondary Users:** Chemistry undergraduate students learning chemical equilibrium and binding isotherms.

### Supported Fields

* Organometallic Chemistry
* Coordination Chemistry
* Catalysis & Chemical Engineering
* Physical Chemistry
* Supramolecular & Host-Guest Chemistry

### Example User Scenarios

| System Type        | Host / Reactant         | Titrant                | Target Resonance                  | Analytical Goal                             |
| :----------------- | :---------------------- | :--------------------- | :-------------------------------- | :------------------------------------------ |
| **System A** | N-Methylimidazole (NMI) | Formic Acid (FA)       | $\text{C2-H}$ proton (~7.4 ppm) | Determine protonation saturation plateau    |
| **System B** | Macrocyclic Host        | Metal Ion ($M^{2+}$) | Aromatic ring $H$               | Evaluate host-guest complexation saturation |
| **System C** | Phosphine Ligand        | Transition Metal       | $^{31}\text{P}$ resonance       | Track coordination equilibrium shift        |

---

## 3. Core Features

### 1. Experiment Metadata Management

Captures experimental parameters including experiment name, target molecule, titrant, solvent (e.g., $\text{CDCl}_3$, $\text{CD}_3\text{CN}$), nucleus ($^1\text{H}, ^{13}\text{C}, ^{19}\text{F}, ^{31}\text{P}$), and unit mode (equivalents or concentration).

### 2. Dual Data Ingestion Modes

* **Mode A (Extracted Table CSV):** Accepts structured tables listing samples, titrant equivalents, and chemical shifts.
* **Mode B (Spectral Data CSVs):** Ingests raw intensity vs. chemical shift data per sample.
* **Built-in Synthetic Generator:** Includes pre-loaded synthetic demonstration datasets generated using Lorentzian peak functions with controlled baseline noise.

### 3. Automated Peak Detection & Cross-Sample Tracking

* Identifies candidate peaks in initial spectra using `scipy.signal.find_peaks`.
* Dynamically tracks target resonance drift across titration steps within a defined moving window ($\Delta\delta_{\text{max}} = \pm 0.15\text{ ppm}$).

### 4. Interactive Titration Curve & Plateau Engine

* Plots chemical shift ($\delta$) vs. titrant equivalents using Plotly.
* Evaluates plateau state by calculating the first derivative $\frac{d(\delta)}{d(\text{Eq})}$ over the final $25\%$ of titration points:
  * **Plateau Detected:** $\left|\frac{d(\delta)}{d(\text{Eq})}\right| < 0.01 \times \Delta\delta_{\text{total}}$
  * **No Plateau:** Slope remains significant ($> 0.05 \times \Delta\delta_{\text{total}}$)
  * **Insufficient Data:** Fewer than 4 sample points provided.

### 5. LLM-Based Scientific Agent

Interprets user requests in natural language, delegates tasks to deterministic Python tools, detects potential anomalies, and provides a structured scientific summary.

### 6. Comprehensive Result Export

Allows users to download:

* Processed peak-tracking data tables (`.csv`).
* High-resolution interactive titration plots (`.html` / `.png`).
* AI-generated scientific reports (`.md` / `.txt`).

---

## 4. Human–AI Interaction Flow

The application implements a **Human-in-the-Loop (HITL)** agentic workflow:

```
[User Input / Prompt] 
       │
       ▼
[Experiment Setup & Data Upload] ──► (Synthetic Generator or CSV Ingestion)
       │
       ▼
[Data Validation Rules] ──────────► (Checks columns, numerical sorting, SNR)
       │
       ▼
[Peak Selection (Human Decision)] ─► User picks target peak from 1D Stack
       │
       ▼
[Agent Tool Planning] ────────────► Agent plans tool call sequence
       │
       ▼
[Python Engine Execution] ────────► Peak Tracking ──► Curve Plotting ──► Plateau Engine
       │
       ├─► (Ambiguity Detected?) ──► [Human Confirmation Modal]
       │
       ▼
[AI Interpretation Generator] ───► Summarizes starting/ending shifts, slope, and Kd limitations
       │
       ▼
[Export & Download Hub]
```

### Detailed Interaction Steps

1. **Setup:** User sets experiment parameters in the sidebar.
2. **Data Selection:** User toggles "Built-in Synthetic Data" or uploads a custom CSV file.
3. **Validation:** System validates file format, sorts data by equivalent, and screens out bad rows.
4. **Human Peak Pick:** The application displays candidate peaks; the user chooses the target peak ($\delta_0$).
5. **Instruction Input:** User gives instructions (e.g., *"Track the peak at 7.41 ppm and check if it reaches a plateau"*).
6. **Agent Orchestration:** The AI agent triggers Python backend tools to perform calculations.
7. **Human Confirmation (Fallback):** If two peaks overlap or a tracking jump exceeds tolerance, the app prompts the user to confirm peak assignment.
8. **Summary & Export:** The AI displays a natural language summary alongside interactive charts for export.

---

## 5. Technical Approach & Architecture

### Application Inputs & Outputs

#### Input Specifications

* **Metadata Input:** Experiment Name, Target Molecule, Titrant, Solvent, Nucleus.
* **Spectral Input Formats:**
  * *Option 1 (Extracted CSV):* Columns `[Sample, Equivalent, Peak_ppm]`
  * *Option 2 (Spectral Series):* Columns `[Chemical_Shift_ppm, Intensity]` paired with equivalent labels.
* **Agent Prompts:** Natural language instructions for execution.

#### Output Specifications

* **Interactive Spectra Stack:** 1D overlaid view of all titration steps with tracked trajectories highlighted.
* **Summary Metrics:** Initial $\delta$, Final $\delta$, Net Shift ($\Delta\delta$), Peak Direction (Downfield / Upfield).
* **Titration Plot:** Interactive Plotly graph of $\delta$ vs. Equivalents.
* **Plateau Evaluation:** Numerical status badge (Plateau Detected / No Plateau / Insufficient Data).
* **Agent Response:** Scientific interpretation of binding trends and structural limitations.

### Architecture Overview

![1792755311622](image/02621135_AzzahraSalsabilaSM/1792755311622.png)

---

## 6. Preprocessing Rules & Failure Handling

### Preprocessing Rules

1. **File Format Enforcement:** Accepts strictly `.csv` files.
2. **Column Validation:** Enforces expected headers before processing.
3. **Data Ordering:** Automatically sorts datasets in ascending order of titrant equivalents.
4. **Non-Destructive Integrity:** Never modifies raw input values or invents artificial experimental points.
5. **Signal-to-Noise Screening:** Enforces a minimum intensity threshold to prevent noise spikes from being tracked as peaks.

### Failure States & Recovery Mechanisms

| Failure State                       | Root Cause                                   | System Response & Recovery                                                      |
| :---------------------------------- | :------------------------------------------- | :------------------------------------------------------------------------------ |
| **Invalid File Format**       | Non-CSV file uploaded                        | Displays `st.error` asking for a valid `.csv` file format.                  |
| **Missing Columns**           | Uploaded CSV missing `Equivalent` column   | Flags missing fields and displays expected template layout.                     |
| **Peak Overlap / Broadening** | Signal coalescence or severe line broadening | Prompts user with Human-in-the-Loop confirmation modal to assign peak manually. |
| **No Plateau Reached**        | Titration ended before saturation            | Plateau engine flags "No Plateau Detected" and suggests higher titrant ratios.  |
| **API Timeout / Offline**     | LLM API key missing or network drop          | Gracefully degrades to deterministic Python outputs without crashing the UI.    |

---

## 7. Success Criteria & Verification Matrix

| Criterion                     | Development Target                                                | Status / Verification Method                      |
| :---------------------------- | :---------------------------------------------------------------- | :------------------------------------------------ |
| **Data Ingestion**      | Support CSV uploads & synthetic data toggle                       | Verified via built-in synthetic datasets          |
| **Spectral Generation** | Generate 13 simulated Lorentzian spectra                          | Verified via System A & B data engine             |
| **Peak Detection**      | Auto-detect peaks on initial spectrum ($\delta_0$)              | Verified using `scipy.signal.find_peaks`        |
| **Peak Tracking**       | Track shifting peak within $\Delta\delta = \pm 0.15\text{ ppm}$ | Verified across all 13 titration steps            |
| **Plateau Analysis**    | Correctly classify plateau vs. non-plateau                        | Verified via terminal slope derivative thresholds |
| **Human-in-the-Loop**   | Allow user confirmation on ambiguous peaks                        | Implemented via selection overrides in UI         |
| **Scientific Export**   | Export numerical tables and Plotly plots                          | Verified via download button handlers             |

---

## 8. Value Proposition & Research Impact

### Research Niche

Unlike generic plotting tools (e.g., Excel or Origin), **NMR-Titra Lite** is custom-engineered for NMR titration workflows. It bridges raw spectral visualization, numerical derivative analysis, and AI reasoning into a single light-weight application.

### Key Benefits

* **Time Savings:** Reduces multi-sample peak tracking time from hours to seconds.
* **Consistency:** Eliminates human transcription errors during peak shift logging.
* **Accessibility:** No programming knowledge required for researchers.
* **Scientific Reliability:** Combines transparent, deterministic math with AI explanations.
