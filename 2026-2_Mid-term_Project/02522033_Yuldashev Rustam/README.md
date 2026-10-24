# PilotLab Pro: AI-Orchestrated Scientific Research Copilot
**UST Agentic AI Course (2026-2) Mid-Term Project**

PilotLab Pro is an autonomous scientific research copilot that closes the loop between **hypothesis pre-registration**, **adversarial critic validation (Aegis-AI)**, **real physical data deconvolution (SciPy)**, **Bayesian next-step experiment ranking (EIG/EVPI)**, and **cryptographic SHA-256 audit chaining**.

---

## 🚀 Quick Run Instructions

You can run PilotLab Pro in any of three convenient modes:

### Mode 1: Streamlit Interactive Prototype (Course Standard)
Run the dedicated Streamlit dashboard with a single command:
```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Launch Streamlit Application
streamlit run streamlit_app.py
```
*Opens automatically at **`http://localhost:8501`**.*
* Features interactive hypothesis pre-registration, real EIS curve fitting, Kramers-Kronig validation, interactive Nyquist plots, failure state tests, and live SHA-256 audit log.

### Mode 2: Complete Client-Server Architecture (FastAPI + Web Workstation)
Runs the full Python FastAPI scientific backend + high-performance web workstation.

1. **One-Click Run (Windows)**:
   Double-click `pilotlab_pro/run.bat` or run:
   ```cmd
   cd pilotlab_pro
   run.bat
   ```
   *This automatically installs dependencies, initializes the SQLite database, and serves the application at **`http://localhost:8000`**.*

2. **Cross-Platform (Windows / macOS / Linux)**:
   ```bash
   pip install -r requirements.txt
   python -m uvicorn app.main:app --app-dir pilotlab_pro/backend --reload --port 8000
   ```
   Open **`http://localhost:8000`** in any modern web browser.
   * Interactive OpenAPI / Swagger Docs: `http://localhost:8000/docs`.
   * Run automated tests with: `python -m pytest pilotlab_pro/backend/tests` (12/12 passing).

### Mode 3: Zero-Install Standalone Workstation
If Python is not available on the evaluator's system:
* Double-click **`PilotLab.html`** to open it directly in Google Chrome, Microsoft Edge, or Safari.
* Runs locally with zero installation using the built-in domain inference engine and synthetic in-silico data generation.

---

## 📦 Project Structure

```
├── streamlit_app.py           # Streamlit working prototype (Deliverable 2)
├── StudentID_Name.md          # 5-Question Specification Document + Failure States (Deliverable 1)
├── StudentID_Name.mp4         # 3–5 Minute Video Pitch Screen Recording (Deliverable 3)
├── requirements.txt           # Python dependencies (Streamlit, FastAPI, SciPy, NumPy, etc.)
├── README.md                  # Comprehensive run & architectural instructions
├── package_submission.ps1     # Automated packaging script for StudentID_Name.zip
├── SUBMISSION_CHECKLIST.md    # Packaging & submission verification checklist
├── datasets/                  # Real benchmark laboratory datasets
│   ├── soec_degradation_real_eis.csv   # Real 100h multi-frequency SOEC degradation
│   ├── battery_aging_eis_cycles.csv    # 18650 Li-ion battery cycle aging EIS
│   ├── eis_nonstationary.csv           # Failure state: Non-stationary K-K violation
│   ├── eis_inverted.csv                # Failure state: Inverted Z'' polarity
│   ├── eis_missing_column.csv          # Failure state: Syntax & malformed columns
│   └── README.md                       # Documentation of benchmark datasets
├── PilotLab.html              # Standalone zero-config distribution workstation
└── pilotlab_pro/
    ├── run.bat                # One-click Windows runner
    ├── README.md              # Technical backend architecture guide
    ├── backend/               # FastAPI, SciPy NLLS, Bayes EIG, SQLite SHA-256
    └── frontend/              # Interactive browser workstation UI & 3D Avatar
```

---

## 🔬 Key Scientific Capabilities & Design Decisions

1. **Hypothesis Pre-Registration**: Formulates competing rival mechanisms ($H_1$ vs $H_2$) and locks predicted physical signatures into a timestamped ledger before data acquisition to eliminate HARKing.
2. **Adversarial Red-Team Critic (Aegis-AI)**: Proactively challenges experimental confounders (thermal gradients, lead inductance, contact mesh relaxation) with engineering fixes.
3. **Real Physical Data Deconvolution**: Uses SciPy non-linear least squares to fit multi-frequency EIS data (`Rs + (R1‖CPE1) + (R2‖CPE2)`), computing Kramers-Kronig residuals ($\text{RMS} < 0.25\%$) to safeguard against non-stationary artifacts.
4. **Bayesian Next-Step Decision Engine**: Evaluates posterior probabilities based on physical drift ($R_\Omega$ increase of $95.5\%$ points to $H_1$ at $88\%$) and computes Expected Information Gain (1.42 bits) to rank follow-up experiments.
5. **Tamper-Evident SHA-256 Audit Trail**: Hash-chains every human decision and computational result. Any retroactive tampering breaks the chain and is detected instantly.
6. **Built-in Failure Handling**: Detects Kramers-Kronig violations ($>5\%$), automatically rectifies inverted imaginary impedance polarity, handles malformed CSVs, and operates 100% offline with zero external dependencies.

---

## 🔒 Security & Privacy Notice
* **No API Keys Included**: The repository contains zero hardcoded API keys or private researcher credentials.
* **Offline Privacy**: PilotLab Pro operates 100% offline by default. Hosted open-source LLM tokens are optional and stored only in server-side memory.
