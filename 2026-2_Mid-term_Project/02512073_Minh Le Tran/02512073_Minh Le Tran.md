# App Name: MetaScreen-AI
**A Multi-Agent Assistant for Study Eligibility Screening and Data Extraction**  
**Midterm Project — Brief Specification Document**

## 1. Problem Statement
After searching databases such as PubMed, Embase, Cochrane Library, and CNKI, medical researchers must manually read many full-text articles, check study eligibility, and extract data for systematic reviews and meta-analyses. This takes time and is especially difficult with non-English papers.

**Goal:** Reduce manual workload by extracting study information and suggesting **Include / Exclude / Needs Discussion** decisions based on user-defined eligibility criteria. AI recommendations are **not final decisions**. This project does **not** assess risk of bias (e.g., RoB 2).

## 2. Target Users
Medical researchers and graduate students conducting systematic reviews or meta-analyses, including myself and my labmates. They can use a simple web app but may have little programming experience.

## 3. Core Features

| Feature | Description | Priority |
|---|---|---|
| Define eligibility criteria | Enter PICO (Population, Intervention, Comparison, Outcomes) and additional rules such as study design. | Must-have |
| Upload PDFs | Drag and drop full-text research articles. | Must-have |
| Extract study data | Extract study details, sample sizes, interventions, outcomes, and supporting text into an English-language table. | Must-have |
| Eligibility recommendation | Suggest **Include / Exclude / Needs Discussion**, with reasons and page/section evidence for human review. | Must-have |
| Multilingual support & export | Assist with non-English PDFs; export extraction tables and decisions to CSV (optional PDF-to-Markdown). | Nice-to-have |

## 4. Human-AI Interaction Flow
1. **Human:** Enters PICO and inclusion/exclusion criteria; uploads PDFs.
2. **AI agents:** Read documents, extract information, and check each criterion against evidence.
3. **AI agents:** Display extracted data, an eligibility recommendation, reasons, and source locations.
4. **Human:** Reviews or corrects the data; accepts, rejects, or discusses the recommendation. **Only the human confirms the final decision.**
5. **App:** Saves reviewed results for export.

## 5. Technical Approach
- **LLM:** Gemini or OpenAI API.
- **Interface:** Streamlit (Python web app).
- **Key libraries:** PyMuPDF for PDF text extraction; Pydantic for structured outputs; pandas for tables/CSV.
- **Multi-agent roles:** **Document Agent** (reads PDF), **Extraction Agent** (extracts data), **Eligibility Agent** (checks criteria), and **Verification Agent** (checks evidence and flags missing/uncertain information).
- **Data needed:** User-uploaded PDFs and user-defined eligibility criteria. A PDF with unreadable text is flagged for manual review rather than guessed.

## 6. Success Criteria
For a small pilot set of **10–20 papers** manually reviewed by researchers:
- The prototype can upload PDFs, extract key study fields, and display traceable eligibility recommendations.
- **100%** of Include/Exclude recommendations provide an explicit criterion and supporting evidence; uncertain cases are flagged for discussion.
- Target **at least 90% agreement** with researcher decisions, while manually checking **every potential false exclusion**.
- Target **at least 30% less review time** compared with the manual workflow (measured during the pilot).

**Expected outcome:** A working, human-supervised prototype that makes eligibility screening and data extraction faster and easier to verify—not an autonomous replacement for reviewers.

**For examples:** i am conducting a Meta Analysis for study: Acupuncture for Tremor in Parkinson's Disease
P (Population): Patients diagnosed with Idiopathic Parkinson’s DiseaseAdults ($18+$ years) diagnosed using standard clinical criteria (e.g., UK Brain Bank, MDS-PD Criteria) presenting with resting, postural, or action tremor.
I (Intervention):	Acupuncture Therapy	Manual Acupuncture (MA), Electroacupuncture (EA), or Scalp Acupuncture, delivered either as monotherapy or as an adjunctive therapy.
C (Comparator)	Control / Comparison Group	Usual Care (UC), Western Medicine (WM), or Sham/Placebo Acupuncture.
O (Outcomes)	Clinical & Neurophysiological Measures	Validated clinician-reported tremor scales, objective instrumental tremor assessments, overall motor function, quality of life, and adverse events.