# PilotLab Pro: AI-Orchestrated Scientific Research Copilot
**UST Agentic AI Course (2026-2) Mid-term Project Specification Document**  
*Template: The 5-Question Framework + Failure States Analysis*  
*Author*: **Rustam Yuldashev**  
*Student ID*: **02522033**  
*Institution*: **University of Science and Technology (UST) — KRICT Campus**  
*Date*: **23 October 2026**

---

## 1. Problem: The Scientific Workflow Bottleneck

### 1.1 Context & Real Research Challenge
In experimental sciences (such as solid oxide electrochemical cells [SOEC/SOFC], battery degradation, catalysis, and chemical biology), researchers frequently suffer from **three chronic bottlenecks**:
1. **Confirmation Bias & Post-Hoc Rationalization**: When experimental results deviate from initial intuition, researchers often rationalize the outcome retrospectively (HARKing — Hypothesizing After Results are Known) rather than systematically testing competing hypotheses.
2. **Disconnected Analytical Pipelines**: Raw experimental diagnostic data (e.g., Electrochemical Impedance Spectroscopy [EIS], chronoamperometry, kinetic assays) require manual script execution in Python, OriginLab, or MATLAB. The resulting fits are decoupled from the initial experimental design and future decision-making.
3. **Suboptimal Next-Step Experiment Selection**: Deciding what experiment to run next is usually driven by subjective habit or trial-and-error, rather than quantitative metrics like **Expected Information Gain (EIG)** or **Expected Value of Information (EVPI)**.

### 1.2 What PilotLab Pro Solves
PilotLab Pro transforms scientific inquiry from an ad-hoc process into a disciplined, closed-loop orchestrator:
* It forces **pre-registration of competing falsifiable hypotheses** before experiments are run.
* It directly deconvolves real physical laboratory data (SciPy equivalent-circuit fitting, Kramers-Kronig stationarity tests, ANOVA).
* It calculates posterior probabilities using a **Bayesian decision engine** to recommend the highest-gain next experiment.
* It anchors every human decision and automated computation in a **tamper-evident SHA-256 cryptographic audit trail**.

---

## 2. Target Users & Personas

### 2.1 Primary User: Experimental Researcher / Graduate Student
* **Profile**: Bench scientists, materials engineers, and PhD candidates designing and conducting laboratory experiments.
* **Pain Points**: Time-consuming manual data formatting, uncertainty about which rival mechanism best explains anomalous drift, pressure to produce defensible publications.
* **Workflow with PilotLab**: Uses PilotLab daily to formulate rival hypotheses, generate standardized operating procedures (SOPs), validate assumptions against an adversarial red-team AI critic, fit real datasets, and export complete study dossiers.

### 2.2 Secondary User: Principal Investigator (PI) / Lab Director
* **Profile**: Research group leaders, senior scientists, and peer reviewers.
* **Pain Points**: Ensuring reproducibility, catching unverified assumptions, and verifying that post-doc researchers didn't cherry-pick data.
* **Workflow with PilotLab**: Inspects the **Cryptographic Audit Trail** and pre-registered predictions in the executive PDF dossier to verify that hypotheses were locked *before* data was collected and that Kramers-Kronig data validation passed.

---

## 3. Concrete Features & Capabilities

| Feature Category | Concrete Capability | Scientific & Technical Implementation |
|---|---|---|
| **1. Hypothesis Pre-Registration** | Competing Rival Formulations | Multi-hypothesis generation (manual or via open-source LLMs like Qwen-2.5-72B / Llama-3.1). Requires at least 2 competing mechanisms with predicted physical signatures locked into state before results stage. |
| **2. Adversarial Red-Team Critic (Aegis-AI)** | Confounder & Blindspot Audit | Proactively challenges experimental assumptions (e.g., thermal gradients, 4-wire lead inductance, contact mesh relaxation) and proposes concrete engineering mitigations. |
| **3. Real Laboratory Data Deconvolution** | Non-Linear Least Squares (SciPy) | Fits multi-frequency EIS spectra to equivalent circuits (`Rs + (R1‖CPE1) + (R2‖CPE2)`), separates ohmic bulk ($R_\Omega$) from polarization ($R_p$) drift, and validates Kramers-Kronig compliance. |
| **4. Bayesian Next-Step Engine** | Expected Information Gain (EIG) | Evaluates hypothesis posterior probabilities and computes information entropy reduction (in bits) to rank candidate follow-up experiments by feasibility, cost, and diagnostic power. |
| **5. Tamper-Evident Audit Trail** | SHA-256 Hash Chaining | Every action (human decision, parameter adjustment, AI suggestion, and data fit) is chained cryptographically to the preceding entry. A single-click audit verifier detects any retroactive manipulation. |
| **6. Multi-Modal Interactive Avatar Assistant** | Movable Voice & 3D Copilot | 5 selectable visual styles (2D Vector Walking Researcher Lumi, Cute Bot Nova, 3D WebGL Three.js VRM Aria, Siri Fluid Orb, Voice Waveform Visualizer) with personalized naming, gender/voice selection, and speech synthesis. |
| **7. Multi-Domain Templates & Generic Data Lab** | Broad Cross-Field Applicability | Pre-configured templates across Solid Oxide Cells, Battery Degradation, Catalysis, and Chemical Biology. Generic Data Lab supports dose-response (4PL/Hill), Arrhenius kinetics, and ANOVA tests. |

---

## 4. End-to-End Interaction Flow

```
[1. Research Question] ──> [2. Competing Hypotheses] ──> [3. Controlled DOE Matrix]
        │                             │                              │
        ▼                             ▼                              ▼
[6. Validation Checkpoint] <── [5. Lab SOP & Plan] <── [4. Pre-Registered Outcomes]
(Adversarial Critic)
        │
        ▼
[7. Quantitative Results] ──> [8. Bayesian Decision Engine] ──> [9. Dossier & Publishing]
(Real CSV Upload & EIS Fit)    (Posterior Probabilities & EIG)   (PDF, JSON, MD Export)
```

1. **Step 1 — Frame Question**: Researcher defines the core inquiry, factor under study (e.g., composite electrolyte ratio), capacity, and primary diagnostic (EIS).
2. **Step 2 — Competing Hypotheses**: User articulates rival mechanistic explanations (e.g., $H_1$: cation interdiffusion vs $H_2$: triple-phase boundary delamination).
3. **Step 3 — Factorial Matrix**: Clamps isolator controls (isothermal $750^\circ\text{C}$, 80/20 $H_2/H_2O$, flow rates) to ensure strict causality.
4. **Step 4 — Pre-Registration**: Expected signatures are locked into the cryptographic log with timestamps.
5. **Step 5 — SOP Generation**: Chronological bench checkpoints ($0\,\text{h}$, $24\,\text{h}$, $50\,\text{h}$, $100\,\text{h}$) are scheduled.
6. **Step 6 — Adversarial Validation**: Aegis-AI flags potential experimental blindspots (e.g., high-frequency lead inductance) before expensive lab runs.
7. **Step 7 — Real Data Upload & Fitting**: Researcher uploads laboratory CSV (`condition, time_h, z_real, z_imag, freq_hz`). SciPy fits circuit parameters, verifies Kramers-Kronig residuals, and plots Nyquist curves.
8. **Step 8 — Bayesian Recommendation**: Posterior belief is updated based on physical drift ($95\%$ increase in $R_\Omega$ supports $H_1$ at $88\%$). The engine ranks follow-up experiments, recommending an electrolyte thickness series with $1.42\text{ bits}$ expected gain.
9. **Step 9 — Dossier Compilation & Audit Verification**: Researcher verifies the SHA-256 chain and exports a comprehensive peer-review dossier.

---

## 5. Success Criteria & Quantitative Metrics

| Evaluation Metric | Baseline (Traditional Manual Workflow) | Target with PilotLab Pro |
|---|---|---|
| **Analysis & Fitting Time** | 2–4 hours manually importing CSVs into standalone scripts | **< 30 seconds** automated end-to-end curve fitting and Kramers-Kronig validation |
| **Bias Mitigation** | Pre-registration rarely practiced; hypotheses often rewritten post-hoc | **100% pre-registered** with timestamped cryptographic locks |
| **Next-Step Selection Efficiency** | Heuristic trial-and-error; 30–50% of follow-up runs yield ambiguous data | **Maximized Information Gain**; follow-up experiments rank-ordered by mathematical utility |
| **Auditability & Traceability** | Disconnected lab notebook notes and unlinked spreadsheet versions | **Single immutable SHA-256 hash chain** linking all decisions, raw data, and fits |
| **Zero-Config Usability** | Complex command-line environments and package conflicts | **Single-click run script (`streamlit run streamlit_app.py` or `run.bat`)**, instant browser workstation, offline fallback |

---

## 6. Comprehensive Failure States & Mitigations

PilotLab Pro treats failure states as first-class scientific events rather than silent crashes. Every failure mode includes explicit visual indicators, root-cause diagnostics, and actionable recovery pathways:

```
+-----------------------------------------------------------------------------------------+
|                                PILOTLAB FAILURE MODES                                    |
+------------------------------------+----------------------------------------------------+
| Failure State                      | System Behavior & Recovery Pathway                 |
+------------------------------------+----------------------------------------------------+
| 1. Kramers-Kronig Residual > 5%    | Flags non-stationary/degrading cell; warns against |
|    (EIS Physical Invalidity)       | over-interpreting circuit fit without steady-state.|
+------------------------------------+----------------------------------------------------+
| 2. Malformed / Incomplete CSV      | Auto-detects inverted Z'', missing frequencies, or |
|    (Wrong Columns / Bad Syntax)    | insufficient points (<6); provides syntax helper.   |
+------------------------------------+----------------------------------------------------+
| 3. Backend / Model Offline         | Gracefully falls back to zero-config offline rule  |
|    (No LLM or Network Cut)         | engine; all analysis, fitting, and UI work locally.|
+------------------------------------+----------------------------------------------------+
| 4. Audit Chain Breakage            | Red-alert badge flags exact corrupted entry index;  |
|    (Tampering / Database Desync)   | provides recovery and backup audit trail options.  |
+------------------------------------+----------------------------------------------------+
| 5. Statistically Inconclusive Data | Bayesian entropy remains distributed; system warns |
|    (Flat Hypothesis Likelihoods)   | that current test did not differentiate rival hyps.|
+------------------------------------+----------------------------------------------------+
```

### Detailed Failure Handling:
1. **Physical Validity Failure (Non-Stationary EIS Data)**:
   * *Trigger*: Chemical drift during impedance measurement causes frequency-domain dispersion.
   * *Mitigation*: The built-in Kramers-Kronig check calculates residuals using a linear Voigt test chain. Residuals $> 5\%$ trigger an alert warning that equivalent-circuit values may be artifacts rather than true physical resistances.
2. **Data Parsing & Polarity Inversion**:
   * *Trigger*: Potentiostat exports positive vs. negative imaginary impedance $-Z''$ inconsistently.
   * *Mitigation*: Automatic polarity detection flips $Z''$ when needed; missing column headers trigger an inline template exemplar.
3. **Network or LLM Provider Disconnection**:
   * *Trigger*: Hugging Face API rate limit or missing local Ollama instance.
   * *Mitigation*: The app detects network status instantly (`status-dot`), automatically falling back to the built-in domain inference engine with zero interruption to experimental design or SciPy fitting.
4. **Audit Trail Verification Failure**:
   * *Trigger*: Manual editing of SQLite database or file corruption.
   * *Mitigation*: `audit-verify` recalculates hashes from Genesis to Head, highlighting the exact row where the cryptographic link broke.
5. **Human Control & Override Points**:
   * The AI *never* unilaterally eliminates hypotheses, submits pre-registrations, or concludes an experimental question. All AI suggestions (from Dr. Nova and Aegis-AI) require explicit researcher confirmation and checkbox endorsements.
