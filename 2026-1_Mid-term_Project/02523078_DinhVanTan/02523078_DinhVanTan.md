⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

# App Name: ResearchPilot

## 1. Problem Statement
**What problem does this solve? Why does it matter?**  
Scientific research often suffers from "Data Silos"—valuable information trapped in static, non-interactive formats. Researchers frequently face two major bottlenecks:

1. **The Digitization Gap:** Critical data is often locked in printed plots or legacy PDF images, requiring tedious manual extraction (e.g., using WebPlotDigitizer).  
2. **Analysis Fragmentation:** Once data is available, generating visualizations and analysis requires switching between multiple tools and manual coding.

**Who currently suffers from this problem, and how?**  
Graduate students, R&D engineers, and academic researchers. They spend significant time on manual data handling and repetitive plotting tasks, which introduces errors and slows down insight generation.

---

## 2. Target Users
**Who will use this? What is their skill level?**
- **Primary Users:** STEM Graduate students and Research Scientists  
- **Skill Level:** Intermediate to Advanced  

**What is their context?**  
Users typically work in laboratory or simulation-heavy environments using tools such as MATLAB, ANSYS, or OriginLab. They need a more integrated and efficient workflow for data processing and analysis.

---

## 3. Core Features
| Feature | Description | Priority |
|--------|-------------|----------|
| **Vision-to-Data Agent** | Extracts numerical data from plot images or PDF graphs. | **Must-have** |
| **Agentic CSV Visualizer** | Generates plots directly from structured data (CSV, table). | **Must-have** |
| **Scientific Critic Agent** | Analyzes data/plots to identify trends, anomalies, and inconsistencies. | **Must-have** |
| **Multi-Agent Orchestrator** | Routes the workflow based on input type and coordinates agents. | **Must-have** |
| **Markdown Export** | Generates a structured report with data, plots, and analysis. | **Nice-to-have** |

---

## 4. Human-AI Interaction Flow

### Mode 1: Data-to-Insight (CSV / Numeric Data)
- **Step 1:** User uploads CSV or numeric data  
- **Step 2:** **Visualizer Agent** generates plots  
- **Step 3:** User selects or adjusts visualization  
- **Step 4:** **Critic Agent** analyzes results  
- **Step 5:** System outputs insight and report  

---

### Mode 2: Plot-to-Insight (Image / PDF Graph)
- **Step 1:** User uploads plot image or PDF  
- **Step 2:** **Vision Agent** extracts data  
- **Step 3:** User reviews and confirms extracted data  
- **Step 4:** **Visualizer Agent** generates plots  
- **Step 5:** **Critic Agent** analyzes results  
- **Step 6:** System outputs insight and report  

---

## 5. Technical Approach
- **LLM:** Gemini 3.1 Flash Lite (multimodal capability)  
- **Framework:** Streamlit + LangChain / CrewAI  
- **Libraries:**  
  - Pandas, NumPy (data processing)  
  - Plotly (visualization)  
  - Pillow (image processing)  

- **Data Input:**  
  - Structured: CSV, tables  
  - Unstructured: plot images (PNG, JPG, PDF)  

---

## 6. Success Criteria
- **Accuracy:** Vision Agent deviation < 5% from original plot  
- **Efficiency:** From input to insight < 60 seconds  
- **Transparency:** Clear agent interaction log (workflow trace)  