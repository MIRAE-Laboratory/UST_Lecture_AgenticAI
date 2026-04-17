⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

# Midterm Project Specification
## Medical Literature Review and Hypothesis Assistant

### By Yadanar Lin, 02621077, KIST 
---

### 1. Problem

Beginner and intermediate medical AI researchers face several compounding challenges during the literature review process:

Medical AI research papers are dense with specialized vocabulary spanning both clinical medicine and machine learning. Terms like AUROC, sensitivity, specificity, DICOM, federated learning, and transformer architectures appear without explanation, creating a steep learning curve for researchers who are not yet fluent in both domains.

There is also no lightweight system to record, organize, and revisit these terms as a researcher builds their knowledge over time. Each new paper essentially restarts the vocabulary burden.

Beyond terminology, extracting the core ideas from a paper requires reading it in full, which is time-consuming when reviewing dozens of papers at once. Researchers need a faster way to surface what matters: the methods used, the dataset, the findings, and the limitations.

Finally, identifying research gaps across a set of papers and forming new hypotheses is one of the most valuable but most labor-intensive parts of the research process. Currently this relies entirely on manual effort with no structured support.

---

### 2. Users

The primary users are beginner to intermediate medical AI researchers who are actively conducting literature reviews. These are researchers who understand the general research process but are not yet fully fluent in the combined vocabulary of clinical medicine and AI. The tool is designed to lower the barrier to understanding papers, surface meaningful patterns across a corpus, and support the early stages of hypothesis formation. It is strictly a research productivity tool and is not intended for clinical use.

---

### 3. Features

**Feature 1: Upload Multiple PDFs**
Users can upload multiple research papers at once. The AI ingests each PDF and extracts key metadata including the title, number of pages, and any sources or references cited. All uploaded papers are stored so the user can browse, select, and manage their corpus easily.

**Feature 2: Glossary Table**
As each paper is ingested, the AI automatically detects medical and technical terms and populates a shared glossary table with the term, its definition, and the paper it was sourced from. Users can manually add their own custom terms and definitions at any time. The glossary is searchable and filterable so researchers can quickly look up unfamiliar vocabulary while reading or reviewing outputs. The users can download this table to their system too. 

**Feature 3: Insights and Hypothesis Generator**
The AI analyzes the discussion and conclusion sections of each uploaded paper to extract stated limitations, suggested future work, and unresolved research questions. It produces a ranked and deduplicated list of research gaps across the full corpus, with higher weight given to gaps mentioned across multiple papers. From these gaps, the AI generates candidate hypotheses or proposal content. The researcher then reviews each one and can accept or reject before anything is saved to their working document.

### 4. Interaction Flow

**Flowchart:**
👤 **Researcher**\
&nbsp;&nbsp;↓\
📄 **Upload PDFs** (Single or Bulk)\
&nbsp;&nbsp;↓\
⚙️ **Process Data**\
&nbsp;&nbsp;↳ Extract Metadata (Titles, References)\
&nbsp;&nbsp;↳ Scan for Medical & Technical Terms\
&nbsp;&nbsp;↓\
📖 **Populate Table**\
&nbsp;&nbsp;↳ Autogenerate the Glossary Table (Terms & Definitions)(Manual Addition of terms is allowed)\
&nbsp;&nbsp;↓\
💡 **Analyze & Generate**\
&nbsp;&nbsp;↳ Pull Gaps and Limitations from Discussion/Conclusion sections\
&nbsp;&nbsp;↳ Identify research gaps and propose a new hypothesis\
&nbsp;&nbsp;↓\
✅ **Human Review** (Accept / Reject)\
&nbsp;&nbsp;↓\
📝 **Final Working Document**

**Usage Example:**
* **Scenario:** A researcher is conducting a literature review and uploads 3 recent PDFs about AI in radiology.
* **Extraction & Glossary:** The system processes the PDFs, pulling titles and references. It identifies domain-specific acronyms like *DICOM* or *ResNet-50*, placing their definitions into a searchable Glossary Table.
* **Insights & Gaps:** The system reads the "Discussion" sections and notices a pattern: 2 out of 3 papers cite "lack of diverse training data" as a limitation. The tool suggests a hypothesis based on this: "Fine-tuning existing radiology AI models on underrepresented demographic sets improves cross-site generalization."
* **Review:** The researcher sees this suggestion, reviews that it is grounded in the text, and clicks **Accept**, appending it directly to their literature review working document.

---

### 5. Success Criteria

The application is working if the following are true:

* A literature review that previously required several hours of manual reading can be completed meaningfully faster, with the researcher spending time on judgment rather than extraction.
* The glossary covers the vast majority of domain-specific terms encountered across uploaded papers, with accurate definitions, so researchers rarely need to look terms up externally.
* Generated research gaps are rated as plausible and grounded by the researcher, meaning they reflect real limitations stated in the papers rather than invented content.
* All insights and hypotheses are traceable to a specific source paper and passage, with zero unsupported or hallucinated claims.
* Researchers feel that the final output reflects their own judgment, since every item requires their explicit approval before it is included.

---

### 6. Tech Stack

*  **Frontend & Dashboard:** [Streamlit](https://streamlit.io/) (v1.x) for an interactive, web-based researcher interface.
*  **Large Language Models (LLMs):**
*  **Inference & Extraction:** [Groq](https://groq.com/) (Llama 3.3) and [Ollama](https://ollama.com/) (Llama 3.1).
   * **Why Groq?** Groq’s LPU architecture provides incredibly fast inference speeds, which is crucial for smoothly processing multiple dense research PDFs at once without leaving the researcher waiting.
   * **Authentication:** Accessing the API requires a **Groq API Key** which will be securely loaded via environment variables (`.env`).
   * **Local Fallback:** Ollama provides an alternative for fully local processing when data privacy standards require that documents do not leave the machine.
*  **Data Processing:**
*  **PDF Extraction:** PyMuPDF (`fitz`), `pdfplumber`, and `PyPDF2`.
*  **OCR:**  `pytesseract` (Tesseract OCR) for scanned document processing.
*  **Utilities:**  `pandas` and `numpy` for data management; `pydantic` for structured data validation.
*  **Environment:** Python 3.1 with a virtual environment (`venv`).

---

### 7. Design

*  **Interactive Dashboard UI:** A clean, dark-themed interface built with Streamlit, using custom CSS for refined visual aesthetics and a premium researcher experience.
*  **Automated Ingestion Workflow:** Streamlines the literature review process by automatically extracting text and technical terms upon PDF upload, reducing manual data entry.
*  **Knowledge-Centric Workspace:** Features a persistent, searchable Glossary Table that links terms to their original PDF sources, fostering rapid domain mastery.
*  **Traceability:** Every extracted term and definition is linked back to its source paper to ensure accuracy and permit easy verification by the researcher.

---

### 8. Project Structure

```text
medical-literature-assistant/
│
├── .env                    # Stores the GROQ_API_KEY (not committed to version control)
├── app.py                  # Main Streamlit application entry point
├── requirements.txt        # Python dependency list
│
├── utils/
│   ├── pdf_processor.py    # Logic for extracting text and metadata from PDFs
│   ├── llm_inference.py    # Groq API calls and Ollama local integration
│   └── insight_engine.py   # Functions to extract gaps, limitations, and hypotheses
│
├── static/
│   └── style.css           # Custom CSS for the dashboard aesthetic
│
└── data/                   # Optional local storage for uploaded PDFs and working outputs
```