⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

# PhysiAudit Pro: Technical Specification
### An Autonomous Physics-Aware Multi-Agent Framework for Scientific Research Validation

**Author:** Nguyen Khac Bao Minh  
**Affiliation:** Korea Electrotechnology Research Institute (KERI) / University of Science and Technology (UST)  
**Research Field:** Electrical Motor Design  
**Date:** April 2026

---

## 1. Executive Summary
**PhysiAudit Pro** is an advanced autonomous framework designed to simulate a professional editorial board for auditing scientific manuscripts. Unlike generic LLMs that focus primarily on linguistic quality, PhysiAudit Pro evaluates technical rigor, numerical accuracy, and adherence to fundamental physical laws. It is specifically engineered to bridge the "Validation Gap" in electrical engineering research, ensuring that proposed designs are not only high-performing but also physically viable.

---

## 2. The Core Problem: The "Validation Gap"
In modern engineering research—ranging from **Carbon Nanotube (CNT)** wire applications to **Physics-Informed Neural Networks (PINNs)**—there is a critical need for cross-domain validation. 
* **Numerical Inconsistency:** FEA or AI models might produce "correct-looking" results that violate conservation laws.
* **Reviewer Overload:** Human experts often struggle to simultaneously verify complex material properties, electromagnetic field equations, and industrial efficiency standards (IE4/IE5).

PhysiAudit Pro addresses this by enforcing a **Multi-Agent Consensus** where specialized agents cross-examine research data against fundamental physical constraints.

---

## 3. System Architecture & Agent Personas
The system utilizes **LangGraph** to manage a stateful, cyclical agentic workflow. This architecture allows for an "Error-Correction" mechanism through agent debate and synthesis.



### 3.1. Agent Definitions
* **Reviewer A (Domain Expert):**
    * **Focus:** Audits the "What" of the research.
    * **Scope:** Machine topology (PMSM, SRM, EESM), material feasibility (e.g., CNT conductivity limits), and compliance with international standards (IEC 60034-30-1).
* **Reviewer B (Technical Auditor):**
    * **Focus:** Audits the "How" of the research (The Guardian of Rigor).
    * **Dual Role:** * *Traditional Engineering:* Checks FEA mesh sensitivity, solver convergence, and boundary condition logic.
        * *AI/SciML:* If applicable, audits PINN consistency, loss function gradients, and PDE adherence.
* **Editor-in-Chief (Decision Engine):**
    * **Goal:** Synthesizes critiques into a formal decision (Accept/Major Revision/Reject) and generates a prioritized technical roadmap for the researcher.

---

## 4. Key Operational Features

### 4.1. Dual-Objective Cognitive Logic
* **Self-Learning Mode:** Acting as a technical mentor, the agents explain complex methodologies and provide educational context on why certain theories apply.
* **Submission Audit:** Acting as a strict peer-reviewer, the agents hunt for flaws, inconsistencies, and lack of experimental evidence.

### 4.2. Universal Motor Audit (UMA) Framework
The system adapts its internal logic based on the machine category selected:
* **SRM:** Focuses on radial force density and acoustic noise.
* **Synchronous (EESM/PMSM):** Focuses on flux weakening and demagnetization risks.
* **Induction:** Focuses on slip-loss analysis and rotor integrity.

### 4.3. Technical Focus Tags
Users can enable "Focused Review" filters, including:
* **Multi-Physics Coupling:** Interaction between electromagnetic and thermal fields.
* **Material Science:** Specific auditing for advanced materials like CNT windings.
* **Efficiency Standards:** Strict validation against IE4/IE5 classes.

---

## 5. Technical Stack
* **Orchestration:** `LangGraph` for stateful multi-agent communication.
* **Logic Engine:** `Google Gemini 2.5 Flash-Lite` (Optimized for scientific reasoning).
* **Interface:** `Streamlit` (Professional Researcher Dashboard).
* **Live Knowledge:** `DuckDuckGo Search API` for real-time State-of-the-Art (SOTA) benchmarking.
* **Parsing:** Native `pypdf` and `python-docx` integration.

---

## 6. Research Impact & Future Work
PhysiAudit Pro represents a leap toward **Automated R&D Validation**. Future versions will include:
1. **Direct LaTeX Patching:** Automatically correcting mathematical errors in manuscript source code.
2. **Semantic Scholar Integration:** Deep citation auditing against 200M+ research papers.
3. **Digital Twin Sync:** Directly comparing simulation audits with real-time experimental data from the lab.

---
*© 2026 PhysiAudit Pro Framework | Nguyen Khac Bao Minh | KERI - UST*