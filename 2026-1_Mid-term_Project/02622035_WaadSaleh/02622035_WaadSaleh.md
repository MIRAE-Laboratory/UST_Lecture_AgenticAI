⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

# Scholar Matchmaker AI – Technical Specification

---

## 1. Problem Statement

Graduate students applying for Master’s or PhD programs face a complex and time-consuming process when identifying suitable research opportunities.

They typically spend **15–30+ hours** on:

- Searching for relevant research areas and supervisors  
- Reading dense research papers to identify research gaps  
- Evaluating whether their CV aligns with current research needs  
- Writing personalized emails that avoid appearing generic  

### The Pain

- **Fragmented Workflow:** Switching between Google Scholar, PDFs, and email platforms  
- **High Cognitive Load:** Manually identifying research gaps in long papers  
- **Generic Outreach:** Low response rates due to non-specific emails  

---

## 2. Target Users

### Primary Users
- Prospective Master’s and PhD students  
- Particularly in engineering and nuclear-related fields  

### Secondary Users
- Early-stage researchers seeking collaborations  

### Technical Level
- Moderate  
- Comfortable with web applications but require structured AI assistance  

---

## 3. Core Features (Implemented)

| Feature | Description | Priority |
|--------|------------|----------|
| Discovery | Suggest supervisors based on research field and country | Must-have |
| Paper Analysis | Upload and analyze research paper (summary + gaps) | Must-have |
| CV Upload | Extract skills and experience from CV (PDF) | Must-have |
| Matching | Compare CV with research gaps and identify alignment | Must-have |
| Email Generation | Generate personalized email to supervisor | Must-have |
| Persona Selection | Choose tone of email (technical, formal, enthusiastic) | Nice-to-have |
| Model Switching | Select between Gemini (cloud) and Ollama (local) | Nice-to-have |
| Agent Logs | Show AI reasoning steps for transparency | Nice-to-have |

---

## 4. Human-AI Interaction Flow (HITL)

### Step 1: Discovery & Profile

**User Input:**
- Research field (e.g., SMR Safety)  
- Target country  

**User Action:**
- Upload CV (PDF)  

**Agent Action:**
- Extract CV content  
- Suggest relevant supervisors and their latest research  

---

### Step 2: Interactive Analysis (User as “Director”)

**User Control:**
- Select a specific professor  

**User Action:**
- Upload research paper (PDF)  

**AI Tools (User-triggered):**

- 📝 **Summarize:**  
  Provides high-level overview of the paper  

- 🔍 **Find Gaps:**  
  Identifies research limitations and future work  

- 🤝 **Check Alignment:**  
  Matches research gaps with user CV skills  

---

### Step 3: Personalized Outreach

**User Choice:**
- Select email tone (persona):
  - Direct & Technical  
  - Formal Academic  
  - Enthusiastic  

**Agent Action:**
- Generate email draft including:
  - Specific research gap  
  - Matching user skill  

**User Action:**
- Review and finalize email  

---

## 5. Technical Approach

### Architecture

**Frontend:**
- Streamlit (Python-based web framework)

**Backend Components:**
- PyPDF2 (PDF text extraction)  
- Streamlit `session_state` (workflow memory]
---

### AI Backend (Model-Agnostic)

**Cloud Option:**
- Gemini API (fast and scalable)

**Local Option:**
- Ollama (Llama 3) for:
  - Privacy  
  - Unlimited usage (no quota)

---

### Current Status

- Functional prototype  
- Real-time PDF parsing  
- Logic-based matching system  
- Demo mode fallback for API limitations  

---

## 6. Success Criteria

### Efficiency
- Paper understanding time:  
  ~2 hours → < 5 minutes  

- Email writing time:  
  ~30 minutes → < 2 minutes  

---

### Quality
- Emails reference:
  - Specific research gaps  
  - Relevant user skills  
- Outputs are structured and personalized  

---

### Transparency
- Agent Reasoning Trace shows:
  - What the AI is doing  
  - Why decisions are made  

---

## 7. Limitations & Future Work

### Current Limitations
- Static (simulated) professor database  
- Limited real-time academic integration  

---

### Future Improvements

- **Live Data Integration:**  
  Connect to Google Scholar via APIs (e.g., SerpApi)

- **Critic Agent:**  
  Add validation layer to reduce hallucinations  

- **Vision Capabilities:**  
  Use advanced models (e.g., Gemini 1.5) to analyze:
  - Figures  
  - Tables  
  - Charts in PDFs  

---

## 8. Conclusion

Scholar Matchmaker AI transforms the user from a passive applicant into a **Research Director**.

By delegating:
- Paper reading  
- Gap identification  
- Skill matching  

to the AI system, the user can focus on:

- Strategic research alignment  
- High-quality communication  
- Building academic relationships  

👉 Result: A faster, smarter, and more effective application process.

