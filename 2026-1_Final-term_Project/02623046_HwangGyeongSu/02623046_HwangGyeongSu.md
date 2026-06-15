⭐ **[2026-1 Final-term Project - INDEX](../2026-1_Final-term_Project.md)**

# Final-term Project Director's Report

**Project Title:** ThermoFluid AI Research Analyst  
**Student ID:** [Write your student ID]  
**Name:** [Write your name]  
**Course:** UST Agentic AI  
**Submission Date:** 2026-06-12

---

## 1. What I Built

I built **ThermoFluid AI Research Analyst**, a Streamlit-based AI application for analyzing thermal-fluid and CFD research papers. The user uploads a PDF paper, and the system extracts the text, organizes the paper into structured research categories, evaluates CFD methodology, runs a role-based critique debate, suggests future research directions, and supports paper-grounded Q&A.

The motivation for this project came from my own research workflow. CFD and thermal-fluid papers are time-consuming to review because important methodological details are scattered across the paper: turbulence model, grid design, boundary conditions, convergence criteria, validation data, assumptions, and limitations. A researcher often has to read the paper several times before getting a clear picture of whether the numerical method is trustworthy.

This system is designed to accelerate the **first-pass review** of a paper. It does not replace expert judgment. Instead, it gives the researcher a structured starting point for deeper reading and verification.

---

## 2. Architecture and Design Decisions

### 2.1 Overall Architecture

The system follows a simple but modular workflow:

```text
User uploads a CFD / thermal-fluid PDF
        ↓
PDF text is extracted with PyPDF2
        ↓
Streamlit stores paper text and workflow state
        ↓
User selects an analysis mode
        ↓
Role-specific LLM prompts analyze the paper
        ↓
The app displays structured results, critique, debate, Q&A, and downloadable reports
```

The main components are:

- **Streamlit UI** for PDF upload, tabs, buttons, chat history, and download outputs.
- **PyPDF2 text extraction** as the deterministic preprocessing step.
- **OpenAI-compatible API calls** to connect with different LLM providers.
- **Multi-provider fallback** so the app can switch between Groq, Gemini, OpenAI, or APIYI if one provider fails.
- **Role-specific prompts** for different analysis tasks.
- **Session state** for temporary memory, uploaded paper text, and Q&A history.
- **JSON-safe parsing** to handle imperfect structured output from the model.

I chose this structure because the project is not meant to be a single general chatbot. Each tab corresponds to a specific research task, so the user can direct the workflow instead of receiving one long unstructured answer.

### 2.2 Why Streamlit

I used Streamlit because it is fast for building interactive research tools. It supports file upload, tabs, markdown rendering, chat-style interaction, session state, and download buttons with minimal overhead. For this project, the priority was to demonstrate a working AI workflow, not to build a production-level web service.

### 2.3 Why Role-Specific Prompts

A general prompt such as “summarize this paper” is not enough for CFD review. I separated the analysis into different roles:

| Module | Intended Role |
|---|---|
| Paper Profiling | Metadata and method extraction |
| CFD Review | Strict CFD methodology reviewer |
| Blue Team | Lead author defending the paper |
| Red Team | Skeptical journal reviewer |
| Judge | Neutral senior evaluator |
| Q&A | Paper-grounded assistant |
| Research Directions | Senior research advisor |

This design makes the output more useful because each module has a specific responsibility. For example, the Red Team is asked to identify methodological weaknesses, while the Judge is asked to synthesize both sides and identify improvement priorities.

### 2.4 From Prototype to Final System

The earlier prototype was a basic research navigator. It could search or summarize papers and run a simple debate. The final version became a domain-specific CFD paper analysis system.

| Aspect | Prototype | Final System |
|---|---|---|
| Main purpose | Basic research navigation | CFD paper analysis and review support |
| PDF handling | Limited text extraction | Full PDF text extraction |
| Analysis | Simple title / method / finding extraction | Multi-section profiling and CFD review |
| Debate | Simple two-agent exchange | Author, reviewer, and judge workflow |
| Q&A | Limited | Paper-grounded Q&A with history |
| Report | Minimal | Downloadable markdown report |
| API handling | Single provider | Multi-provider fallback and `.env` keys |

---

## 3. Where the Human Is in the Loop

The app is intentionally not fully autonomous. The human researcher remains responsible for all important decisions.

### 3.1 Human Responsibilities

The user:

1. Chooses the paper to upload.
2. Selects which analysis mode to run.
3. Decides which CFD review category matters.
4. Enters or accepts the debate issue.
5. Reads the author-reviewer-judge output.
6. Asks follow-up questions.
7. Checks the AI output against the original paper.
8. Decides what is valid enough to use in research notes, presentations, or reports.

### 3.2 AI Responsibilities

The AI system:

1. Extracts structured information from the paper text.
2. Produces a first-pass CFD methodology critique.
3. Simulates author-reviewer disagreement.
4. Generates a neutral reflection through the judge role.
5. Suggests future research directions.
6. Answers questions using the uploaded paper context.
7. Creates a downloadable draft report.

### 3.3 Why This Design Matters

The app is meant to support the researcher, not replace the researcher. CFD methodology involves physical judgment: whether the boundary conditions are realistic, whether the turbulence model is appropriate, whether the validation range is sufficient, and whether the conclusions are justified. Those decisions still require human expertise.

---

## 4. Failures and Lessons

### 4.1 PDF Extraction Is Imperfect

PDF files are designed for visual reading, not reliable machine extraction. PyPDF2 can extract text from many papers, but it can miss or distort information from multi-column layouts, tables, equations, captions, and scanned pages.

**Lesson:** The app should treat PDF extraction as a useful but imperfect preprocessing step. The output should be used as a review aid, not as an unquestionable record of the paper.

### 4.2 Structured Output Is Not Always Clean

Even when the prompt asks for pure JSON, the model sometimes returns markdown fences, explanations, or malformed JSON.

**Response:** I added a safe JSON parser that removes common markdown wrappers and attempts to extract the first valid JSON object. If parsing fails, the app still displays the raw model output instead of crashing.

### 4.3 LLMs Can Overstate Claims

A model can produce confident CFD critique even when the paper does not explicitly support the claim. This is a serious issue because the output may sound technically plausible.

**Response:** The prompts instruct the model to say when information is not explicitly found in the paper. I also added the Red Team and Judge workflow to expose weak assumptions and avoid a single agreeable AI voice.

### 4.4 Long Papers Need Better Retrieval

Sending a long paper directly into every prompt is inefficient and may miss relevant sections. The current app uses shortened contexts for different tasks, which is enough for a first-pass demonstration but not ideal for a robust research system.

**Lesson:** A future version should use chunking, embeddings, vector retrieval, and source-level citations so each answer can be traced back to specific parts of the paper.

### 4.5 API Reliability Is a Practical Problem

During development, model provider issues were a real concern: quota limits, missing keys, wrong model names, and provider-specific errors can interrupt the workflow.

**Response:** I added multi-provider support so the user can choose Groq, Gemini, OpenAI, or APIYI, and I moved API keys into a local `.env` file instead of hardcoding them in the source code.

---

## 5. Critical Reflection on Management

### 5.1 What I Learned

The main difference between writing a normal program and building an AI workflow is uncertainty. In a normal program, most outputs are deterministic. In this project, the LLM output depends on the prompt, model, context length, and even provider behavior.

Because of that, the important design question was not only “What should the program do?” but also:

- What should be handled by deterministic code?
- What should be delegated to the LLM?
- Where can the model fail?
- Where should the human check the result?
- How should the app present uncertainty?

This made the project feel more like managing a research workflow than simply coding a chatbot.

### 5.2 Where More Agents Would Help

The multi-agent debate is useful because disagreement reveals assumptions that a single model may ignore. However, not every task needs multiple agents.

- Paper profiling is better as one careful extraction process.
- CFD methodology review benefits from specialist prompts.
- Debate benefits from multiple roles because criticism and defense are different tasks.
- Q&A should stay simple and grounded to avoid unnecessary complexity.

If I continued the project, I would add two additional components:

1. **Citation Checker:** checks whether each claim is directly supported by the uploaded paper.
2. **Numerical Consistency Checker:** checks whether values such as Reynolds number, Nusselt number, grid count, validation error, and boundary conditions are internally consistent.

### 5.3 Irreplaceable Human Skill

The irreplaceable human skill is scientific judgment. The app can summarize, organize, and critique, but it cannot take responsibility for whether a CFD model is physically valid or whether a conclusion is acceptable for real research.

The user still needs to understand heat transfer, fluid mechanics, numerical methods, and the specific research context.

---

## 6. What I Would Do Differently Next

### 6.1 Add Retrieval with Citations

The biggest improvement would be a retrieval pipeline:

```text
PDF → cleaned text / markdown → chunks → embeddings → vector DB → top-k retrieval → grounded answer with citations
```

This would make long-paper Q&A more reliable and allow the app to show which paper section supports each claim.

### 6.2 Extract Figures, Tables, and Equations

Many CFD papers contain key information in figures and tables, such as mesh independence tests, validation plots, residual histories, and boundary condition tables. The current text-only pipeline can miss this information.

A future version should include figure/table extraction and possibly OCR for scanned or image-heavy PDFs.

### 6.3 Add Formal Evaluation Scores

The current CFD review gives qualitative critique. A better version should include a scoring rubric for:

- evidence grounding,
- extraction accuracy,
- CFD expertise,
- usefulness of critique,
- hallucination risk,
- completeness.

### 6.4 Separate Tools More Cleanly

The current app contains the PDF parser, prompt logic, UI, and report generator in one Streamlit file. A more scalable version should separate these into independent modules or tool servers:

- PDF parser,
- citation checker,
- figure extractor,
- retrieval engine,
- report generator.

### 6.5 Add Audit Logs

For a more serious research workflow, the app should record user actions, selected analysis modes, model outputs, user approvals or rejections, and timestamps. This would make the workflow more reproducible and easier to review.

---

## 7. Demo Video Plan

The demo video should show the system working rather than only describing it.

Recommended sequence:

1. Introduce the problem: CFD papers are difficult to review systematically.
2. Open the Streamlit app.
3. Upload a thermal-fluid or CFD paper PDF.
4. Show the extracted page count and text count.
5. Run structured paper profiling.
6. Run one CFD review category, such as V&V or boundary condition validity.
7. Start a short multi-agent debate.
8. Ask one Q&A question.
9. Download the report.
10. Briefly mention limitations and the role of human validation.

---

## 8. Final Submission Checklist

Required files:

```text
StudentNumber_Name.zip
├── StudentNumber_Name.mp4
├── StudentNumber_Name.md
├── final_thermofluid_ai_app.py
├── requirements_final.txt
├── .env.example
└── optional screenshots or supporting files
```

The actual `.env` file should not be submitted because it contains private API keys.

Run command:

```bash
streamlit run final_thermofluid_ai_app.py
```

Example `.env` for local testing:

```text
GROQ_API_KEY=your_groq_api_key_here
GEMINI_API_KEY=your_gemini_api_key_here
OPENAI_API_KEY=your_openai_api_key_here
APIYI_API_KEY=your_apiyi_api_key_here
```

---

## 9. Conclusion

ThermoFluid AI Research Analyst is a domain-specific AI research assistant for CFD and thermal-fluid papers. It decomposes paper review into structured extraction, CFD methodology critique, role-based debate, reflection, Q&A, and report generation.

The most important design decision was to keep the human researcher in control. The system reduces the time needed for a first-pass review, but the researcher still chooses the paper, directs the analysis, verifies the output, and makes the final scientific judgment.
