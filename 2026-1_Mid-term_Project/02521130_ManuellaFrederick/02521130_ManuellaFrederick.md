⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

# MF VERITAS-AI: An Agentic Thesis Review Assistant  
**Enhancing Academic Integrity and Research Quality**  
**Your Intelligent Research Audit Companion**

**Student:** Manuella Frederick  
**Course:** A Multi-Agent Framework for Scientific Discovery and Optimization  
**Lecturer:** Professor Hogeon Seo  
**Institution:** UST-KIOST  
**Date:** April 2026  

---

## 1. Overview

MF VERITAS-AI is an agentic artificial intelligence system designed to support academic thesis review. The system enhances research quality by identifying inconsistencies, strengthening argument coherence, and enabling iterative refinement through human–AI collaboration.

It functions as an intelligent research audit assistant capable of analyzing multiple documents and generating structured, high-level academic insights.

---

## 2. Problem Statement

Manual thesis review is both time-consuming and cognitively demanding. Researchers frequently encounter challenges such as:

- Difficulty detecting inconsistencies across chapters  
- Weak or fragmented argument structures  
- Repetitive manual review processes that reduce efficiency  
- Limited tools for cross-chapter coherence analysis  
- Insufficient support for integrated, thesis-level evaluation  

These limitations negatively impact the overall quality, clarity, and integrity of academic research.

---

## 3. Objectives

The primary objectives of MF VERITAS-AI are to:

- Develop an intelligent agent to support comprehensive thesis review  
- Enhance cross-chapter coherence and structural alignment  
- Track and strengthen argument continuity throughout the document  
- Improve overall research quality while maintaining academic integrity  

---

## 4. Solution Overview

MF VERITAS-AI introduces an AI-powered research audit assistant with the following capabilities:

- Multi-document (multi-PDF) analysis  
- Integrated thesis-level evaluation  
- Interactive, prompt-driven user engagement  
- Argument continuity tracking  
- Iterative refinement of analytical outputs  

The system transforms traditional static analysis into a dynamic, interactive, and user-guided process.

---

## 5. System Architecture

### 5.1 High-Level Workflow

1. User uploads multiple thesis documents (PDF format)  
2. Text is extracted and preprocessed  
3. User selects relevant sections for analysis  
4. Prompts are constructed (preset or custom)  
5. The LLM processes input and generates structured insights  
6. Outputs are displayed and stored  
7. User iteratively refines results through follow-up interaction  

---

### 5.2 Architecture Components

- **User Interface:** Streamlit-based interactive environment  
- **PDF Processing Module:** Extracts and structures document text  
- **Prompt Manager:** Handles predefined and custom prompts  
- **LLM Engine:** Performs analysis and generates insights  
- **Session Memory:** Maintains context for iterative refinement  
- **History System:** Logs and tracks previous analyses  

---

## 6. Core Features

- **Multi-Document Analysis:** Simultaneous evaluation of multiple thesis sections  
- **Consistency & Fact Checking:** Identification of contradictions and misalignments  
- **Coherence Architect:** Enhancement of logical flow across chapters  
- **Argument Line Tracker:** Evaluation of argument strength and continuity  
- **Iterative Interaction:** Continuous refinement through user feedback  

---

## 7. Agentic AI Characteristics

MF VERITAS-AI demonstrates agentic intelligence through:

- Autonomous analysis of structured and unstructured academic data  
- Context-aware reasoning using session memory (`st.session_state`)  
- Goal-directed output improvement  
- Iterative refinement based on user input  
- Human-in-the-loop integration  

Unlike conventional AI tools, the system supports adaptive reasoning and continuous interaction, positioning it as an active research collaborator.

---

## 8. Human-in-the-Loop Design

The system incorporates human oversight through two key roles:

### Architect Role
- Select documents  
- Define analysis scope  
- Choose or design prompts  

### Fail-Safe Role
- Evaluate outputs  
- Validate analytical accuracy  
- Refine and guide system responses  

This dual-role structure ensures that AI augments, rather than replaces, human expertise.

---

## 9. Error Handling & Recovery

To ensure robustness and reliability, the system includes:

- Retry mechanisms for API or processing failures  
- Flexible prompt adjustment  
- Context switching between document selections  
- Iterative correction through follow-up interaction  
- Transparent analytical outputs for user verification  

---

## 10. Comparative Advantage

| Conventional Tools | MF VERITAS-AI |
|-------------------|--------------|
| Surface-level feedback | Deep, structured analysis |
| Section-based evaluation | Multi-layer (section + thesis-level) |
| Static outputs | Iterative refinement loop |
| Limited customization | User-driven analytical control |

The system prioritizes **interactive intelligence** over passive content generation.

---

## 11. Impact and Success Criteria

MF VERITAS-AI aims to:

- Reduce thesis review time from hours to minutes  
- Improve academic writing clarity and coherence  
- Strengthen argumentation across entire documents  
- Support academic integrity and quality assurance  
- Enable production of publication-ready research  

---

## 12. Future Improvements

- Fully integrated conversational interface  
- Deployment with local LLMs (e.g., Ollama)  
- Export functionality to Word and PDF formats  
- Section-specific editing and feedback tools  
- Enhanced transparency in reasoning processes  

---

## 13. Conclusion

MF VERITAS-AI represents a transition from traditional AI tools to **agentic research systems**.

Rather than simply analyzing text, the system actively supports the research process through iterative reasoning, contextual awareness, and human collaboration.

**It positions AI not as a replacement, but as a strategic research partner.**

---

## 14. Application Interface and Workflow

This section presents the system workflow, user interface, and representative outputs generated by MF VERITAS-AI.

**Figure 1: Application Workflow**  
![Workflow](images/workflow.png)

**Figure 2: App Interface (Main Screen)**  
![Interface 1](images/interface1.png)

**Figure 3: App Interface (Analysis View)**  
![Interface 2](images/interface2.png)

**Figure 4: Test Run Output 1**  
![Test Run 1](images/testrun1.png)

**Figure 5: Test Run Output 2**  
![Test Run 2](images/testrun2.png)