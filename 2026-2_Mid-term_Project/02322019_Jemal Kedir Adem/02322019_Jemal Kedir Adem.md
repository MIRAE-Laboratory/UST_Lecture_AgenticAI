⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

# ConcreteMix Agent Pro: Technical Specification
### An Autonomous AI-Agent Framework for Compressive Strength Prediction and Low-Carbon Concrete Mix Design

**Author:** Jemal Kedir Adem  
**Affiliation:** Korea Institute of Geoscience and Mineral Resources (KIGAM) / University of Science and Technology (UST)  
**Research Field:** Resources Engineering / Concrete Materials / Machine Learning  
**Date:** October 2026  

---

## 1. Executive Summary

**ConcreteMix Agent Pro** is an AI-assisted framework designed to support concrete researchers, laboratory engineers, ready-mix producers, and construction engineers in two connected tasks:

1. **Predict the compressive strength** of a proposed concrete mixture.
2. **Recommend candidate concrete mixtures** that satisfy a target strength while reducing estimated material-related CO₂ emissions.

Unlike a conventional machine-learning predictor that returns only a strength value, ConcreteMix Agent Pro combines a trained regression model with an AI agent that validates user inputs, calls numerical prediction and optimization tools, explains the results, and proposes candidate mixes for laboratory verification.

The system is intended as a **decision-support tool**, not a replacement for laboratory testing or engineering approval.

---

## 2. The Core Problem: The “Prediction-to-Design Gap”

Concrete compressive strength depends nonlinearly on mixture composition and curing age. In practice, an engineer may need to evaluate many possible combinations of cement, supplementary cementitious materials, water, fine aggregate, coarse aggregate, admixtures, and curing age.

Three practical problems arise:

- **Trial-and-Error Mix Design:** Repeated laboratory batching is expensive and time-consuming.
- **Strength–Carbon Trade-Off:** A mixture can achieve high compressive strength while using a large amount of high-emission binder.
- **Model Usability Gap:** A trained ML model can predict strength, but ordinary users may not know how to convert that prediction model into a practical mix-design workflow.

ConcreteMix Agent Pro addresses this gap by connecting a trained compressive-strength model to an AI agent that can interpret user goals, validate input conditions, perform predictions, search candidate mixtures, estimate material CO₂ emissions, and explain the final recommendation.

---

## 3. Data and Machine-Learning Framework

### 3.1. Training Data

The model is trained using **real measured concrete compressive-strength data**.

For the initial prototype, the project can use the **UCI Concrete Compressive Strength dataset**, which contains 1,030 measured concrete records.

### 3.2. Model Inputs

Typical model inputs are:

- Cement content (kg/m³)
- Blast-furnace slag content (kg/m³)
- Fly ash content (kg/m³)
- Water content (kg/m³)
- Superplasticizer content (kg/m³)
- Coarse aggregate content (kg/m³)
- Fine aggregate / sand content (kg/m³)
- Curing or test age (days)

### 3.3. Model Output

- **Concrete compressive strength (MPa)**

### 3.4. Example Training-Data Structure

| Cement | Slag | Fly Ash | Water | Fine Aggregate | Coarse Aggregate | Age | Strength |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 350 | 0 | 80 | 175 | 720 | 1050 | 28 | Measured MPa |
| 300 | 100 | 0 | 165 | 740 | 1020 | 28 | Measured MPa |
| 400 | 0 | 0 | 180 | 690 | 1040 | 7 | Measured MPa |

*The table above illustrates the data structure; it is not presented as experimental data generated in this project.*

### 3.5. Candidate Machine-Learning Models

The following regression models can be compared:

- Random Forest
- Gradient Boosting
- **XGBoost**
- CatBoost
- Artificial Neural Network

The final model will be selected using unseen test data.

### 3.6. Evaluation Metrics

Model performance will be evaluated using:

- **R²**
- **RMSE**
- **MAE**

Example reporting format:

> **Best Model:** XGBoost  
> **Test R²:** To be determined after training  
> **RMSE:** To be determined after training  
> **MAE:** To be determined after training

No performance value will be claimed until the model has actually been trained and evaluated.

---

## 4. System Architecture & Agent Personas

ConcreteMix Agent Pro uses an agentic workflow in which specialized agents call numerical tools rather than relying only on free-form LLM reasoning.

### 4.1. Agent Definitions

- **Agent A — Mix & Data Validation Agent**
  - **Focus:** Checks whether the user input is suitable for model prediction.
  - **Tasks:**
    - Checks units and missing values.
    - Calculates water-to-binder ratio.
    - Checks ingredient ranges against the model training domain.
    - Flags unrealistic or out-of-domain mixtures.

- **Agent B — Compressive Strength Prediction Agent**
  - **Focus:** Predicts concrete compressive strength.
  - **Tasks:**
    - Sends validated inputs to the trained ML model.
    - Returns predicted strength in MPa.
    - Reports model-performance information and prediction warnings.
    - Can provide feature-importance or SHAP-based explanations.

- **Agent C — Low-Carbon Mix Optimization Agent**
  - **Focus:** Performs reverse mix design.
  - **Tasks:**
    - Receives the target compressive strength.
    - Generates candidate ingredient combinations.
    - Calls the strength prediction model.
    - Estimates material-related CO₂ emissions.
    - Ranks feasible mixes from lower to higher estimated CO₂ emissions.

- **Coordinator Agent — Concrete Mix Advisor**
  - **Goal:** Manages the complete interaction with the user.
  - **Tasks:**
    - Determines whether the user wants prediction or mix recommendation.
    - Calls the appropriate specialist agents.
    - Summarizes assumptions and limitations.
    - Produces a final recommendation for human review and laboratory validation.

---

## 5. Key Operational Features

### 5.1. Dual-Mode Agent Logic

#### Mode 1 — Strength Prediction

The user enters a proposed concrete mix:

**Input**

Cement + SCMs + Water + Sand + Coarse Aggregate + Admixture + Age

↓

**ML Prediction Model**

XGBoost / Best Validated Model

↓

**Output**

Predicted Compressive Strength (MPa)

---

#### Mode 2 — Target-Strength Mix Recommendation

The user specifies:

- Target compressive strength
- Required curing age
- Available materials
- Allowed ingredient ranges
- Optional water-to-binder limit

The system then searches candidate mixtures and returns a shortlist that satisfies the strength target while minimizing estimated material-related CO₂ emissions.

---

### 5.2. Low-Carbon Objective Function

For each candidate mixture:

**Estimated material CO₂e**

\[
CO_{2e} = \sum_{i=1}^{n} m_i \times EF_i
\]

where:

- \(m_i\) = mass of concrete ingredient *i* in kg/m³
- \(EF_i\) = selected emission factor for ingredient *i* in kg CO₂e/kg

The optimization objective is:

> **Minimize estimated material CO₂e subject to predicted compressive strength ≥ target strength and the selected mix-design constraints.**

The initial version focuses on material-related emissions. Transport, batching energy, placement, service life, and end-of-life impacts require additional system-boundary data.

---

### 5.3. Human-in-the-Loop Validation

The system does **not** automatically approve a concrete mixture for construction.

Final candidate mixes must be checked through:

- Laboratory batching
- Workability testing
- Compressive-strength testing
- Durability requirements
- Project specifications and relevant standards

Measured laboratory results can later be added to the verified dataset for controlled model improvement.

---

## 6. Proposed Technical Stack

- **Development Environment:** `Google Antigravity`
  - Used to develop, debug, and test the application with agentic coding workflows.

- **Machine-Learning Engine:** `Python + scikit-learn + XGBoost + CatBoost`
  - Used for training, evaluation, serialization, and inference of compressive-strength models.

- **Agent Orchestration:** `LangGraph` or a Python tool-calling workflow
  - Manages the validator, prediction, optimization, and coordinator agents.

- **Runtime Reasoning Model:** `Gemini API` or another configurable LLM
  - Interprets user requests, selects tools, and explains numerical results.

- **User Interface:** `Gradio`
  - Provides input forms, prediction results, tables, plots, and agent responses.

- **Deployment:** `Hugging Face Spaces`
  - Hosts the interactive ML/AI-agent application online.

- **Data Processing:** `pandas`, `NumPy`

- **Model Explainability:** `SHAP`

- **Optimization:** `Optuna`, constrained search, or evolutionary optimization

---

## 7. Proposed System Workflow

```text
User
  │
  ▼
Coordinator AI Agent
  │
  ├──────────── Prediction Request ────────────┐
  │                                            │
  ▼                                            ▼
Mix & Data Validator                 Target-Strength Request
  │                                            │
  ▼                                            ▼
Strength Prediction Agent            Low-Carbon Optimization Agent
  │                                            │
  ▼                                            ├── Generate candidate mixes
Trained ML Model                     ├── Call strength model
(XGBoost / selected model)           ├── Calculate estimated CO₂e
  │                                  └── Rank feasible candidates
  │                                            │
  └──────────────────┬─────────────────────────┘
                     ▼
              Coordinator Agent
                     │
                     ▼
         Explanation + Candidate Mixes
                     │
                     ▼
            Human/Laboratory Review
```

---

## 8. Expected Research Impact

ConcreteMix Agent Pro aims to transform a conventional compressive-strength prediction model into an interactive engineering decision-support system.

Expected benefits include:

1. **Faster Preliminary Mix Screening**  
   Reduce the number of low-potential combinations that need to be tested experimentally.

2. **Accessible ML-Based Strength Prediction**  
   Allow non-programming users to interact with a trained prediction model through a web interface.

3. **Low-Carbon Mix Exploration**  
   Compare candidate mixtures according to both predicted strength and estimated material-related CO₂ emissions.

4. **Explainable Decision Support**  
   Provide numerical prediction together with explanations, assumptions, feature contributions, and warnings.

5. **Continuous Research Improvement**  
   Incorporate new verified experimental records into future model versions.

---

## 9. Future Work

Future versions of ConcreteMix Agent Pro can include:

1. **Workability Prediction**
   - Predict slump or flow in addition to compressive strength.

2. **Durability-Aware Mix Design**
   - Include chloride resistance, carbonation resistance, permeability, or other durability indicators.

3. **Multi-Objective Optimization**
   - Simultaneously optimize strength, CO₂ emissions, material cost, and workability.

4. **Local Material Database**
   - Store cement, SCM, aggregate, admixture, density, cost, and environmental data for specific suppliers.

5. **Automatic Laboratory Feedback**
   - Upload measured trial results and compare predicted versus experimental strength.

6. **Model Explainability Dashboard**
   - Visualize SHAP values and explain why a recommended mixture is predicted to achieve the target strength.

7. **Expanded Training Dataset**
   - Combine validated public data with laboratory and industry data while preserving source and testing metadata.

---

## 10. Initial Data Source

**Yeh, I.-C. (1998). Concrete Compressive Strength. UCI Machine Learning Repository.**  
DOI: **10.24432/C5PK67**

The UCI dataset can be used for the first model prototype. Later project versions can incorporate additional verified laboratory and industrial concrete data.

---

*© 2026 ConcreteMix Agent Pro Framework | Jemal Kedir Adem | KIGAM - UST*
