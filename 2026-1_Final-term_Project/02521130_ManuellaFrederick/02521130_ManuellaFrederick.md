⭐ **[2026-1 Final-term Project - INDEX](../2026-1_Final-term_Project.md)**

# MF VERITAS-AI Director's Report

**Student:** Manuella Frederick
**Course:** Agentic AI Systems
**Project:** MF VERITAS-AI – An Agentic Thesis Review and Research Support System

---

# What I Built

MF VERITAS-AI is an agentic thesis analysis and research support system designed to assist postgraduate students and researchers throughout the academic writing process. Rather than functioning as a simple chatbot, the system integrates multiple agentic AI patterns explored throughout the course, including retrieval-augmented generation (RAG), evaluation loops, self-reflection, multi-agent collaboration, memory, and Human-in-the-Loop (HITL) oversight.

The project evolved progressively throughout the semester. Early stages focused on building foundational conversational and retrieval capabilities, while later stages introduced structured evaluation, thesis scoring, self-improvement mechanisms, and multi-agent collaboration. The final result is a digital research workforce capable of reviewing thesis chapters, identifying weaknesses, retrieving supporting evidence, proposing improvements, evaluating quality, and supporting human decision-making during research development.

Rather than generating answers alone, MF VERITAS-AI coordinates specialized agents that perform distinct cognitive roles within a structured workflow.

---

# Architecture & Design Decisions

The architecture reflects a cumulative integration of concepts developed throughout the semester rather than a single design decision.

## Retrieval-Augmented Generation (RAG)

One of the earliest challenges identified during development was the tendency of large language models to provide generic responses disconnected from the user's research materials. To address this, RAG capabilities were introduced to allow the system to retrieve information from thesis-related content before generating responses.

The RAG Thesis Chat module enables users to query their research while grounding responses in available contextual information. This reduced hallucination risk and improved relevance by connecting generation to retrieved evidence.

![RAG Thesis Chat](Screenshots/RagThesisChat_1.png)

*Figure 1. RAG Thesis Chat interface used for grounded thesis discussion.*

![RAG Thesis Chat](Screenshots/RagThesisChat_2.png)

*Figure 2. Retrieval-supported interaction within the RAG environment.*

![RAG Thesis Chat](Screenshots/RagThesisChat_3.png)

*Figure 3. Example of contextualized thesis support generated through retrieval.*

---

## Evaluation and Measurement

A major lesson from the course was that generation alone does not guarantee quality. Inspired by the Evaluation Lab concepts, I introduced mechanisms that evaluate outputs against academic standards.

The system assesses chapter quality using criteria such as coherence, structure, evidence usage, argument strength, and clarity. This transformed the project from a text generator into a measurable decision-support system.

![Evaluation Lab](Screenshots/EvaluationLab_1.png)

*Figure 4. Evaluation framework interface.*

![Evaluation Lab](Screenshots/EvaluationLab_2.png)

*Figure 5. Assessment workflow for academic writing quality.*

![Evaluation Lab](Screenshots/EvaluationLab_3.png)

*Figure 6. Evaluation output used for decision support.*

![Evaluation Lab](Screenshots/EvaluationLab_4.png)

*Figure 7. Comparative evaluation results.*

The most important lesson from this stage was that evaluation creates accountability. Without evaluation, systems generate content but possess no mechanism for judging quality.

---

## Thesis Examination Agent

To simulate the role of an academic reviewer, I implemented a Thesis Examiner Agent. This agent critiques thesis sections, identifies weaknesses, highlights unsupported claims, and recommends improvements.

The examiner performs a role similar to a dissertation committee member, helping researchers identify weaknesses before formal submission.

![Thesis Examiner](Screenshots/ThesisExaminer_1.png)

*Figure 8. Thesis Examiner interface.*

![Thesis Examiner](Screenshots/ThesisExaminer_2.png)

*Figure 9. Example critique produced by the examiner.*

![Thesis Examiner](Screenshots/ThesisExaminer_3.png)

*Figure 10. Identification of weaknesses and evidence gaps.*

![Thesis Examiner](Screenshots/ThesisExaminer_4.png)

*Figure 11. Structured examiner feedback.*

This stage introduced the concept of epistemic taste. The system no longer simply generated content; it evaluated whether claims were persuasive, supported, and academically defensible.

---

## Thesis Strengthening Agent

The Thesis Strengthening Agent was developed to move beyond criticism and provide constructive revision guidance.

Rather than simply identifying flaws, the agent proposes ways to strengthen arguments, improve transitions, increase clarity, and enhance academic rigor.

![Thesis Strengthening Agent](Screenshots/ThesisstrengtheningAgent_1.png)

*Figure 12. Thesis Strengthening Agent generating recommendations.*

This shifted the system from passive evaluation toward active improvement.

---

## Auto Chapter Scoring

To provide rapid feedback across larger documents, an Auto Chapter Scoring system was introduced.

The system assigns structured scores across evaluation categories and provides a comparative assessment of chapter quality.

![Auto Chapter Scoring](Screenshots/AutoChapterScoring_1.png)

*Figure 13. Automatic chapter scoring process.*

![Auto Chapter Scoring](Screenshots/Autochapterscoring_2.png)

*Figure 14. Chapter comparison results.*

![Auto Chapter Scoring](Screenshots/AutoChapterScoring_3.png)

*Figure 15. Scoring output used for thesis benchmarking.*

This functionality introduced quantitative measurement into the workflow and allowed progress tracking across revisions.

---

# Where the Humans Are in the Loop

## Human Approval Gate (HITL)

One of the most important architectural decisions involved the placement of a Human-in-the-Loop checkpoint within the multi-agent research workflow.

The Research Team + HITL module simulates a digital research team composed of specialized agents performing different cognitive functions.

The workflow begins with a Hypothesis Proposer agent generating an initial research hypothesis based on a user-defined topic. A Methodologist agent then critiques the proposal by identifying methodological weaknesses, unsupported assumptions, evidence gaps, and threats to validity.

Rather than automatically revising the proposal, the workflow intentionally pauses and enters a **WAITING_FOR_HUMAN** state. At this stage, a human must decide whether to approve, reject, or terminate the workflow.

This checkpoint placement was inspired directly by Week 14 discussions on governance, oversight, and alignment. The design ensures that important research decisions remain under human supervision rather than being delegated entirely to autonomous agents.

This mechanism helps prevent alignment drift while preserving human accountability for high-impact decisions.

### Workflow Demonstration

![Research Team Workflow](Screenshots/ResearchTeamandHumanApproval_1.png)

*Figure 16. Research Team + HITL workflow initialized.*

![Research Team Workflow](Screenshots/ResearchTeamandHumanApproval_2.png)

*Figure 17. Initial hypothesis generated by the Proposer agent.*

![Research Team Workflow](Screenshots/ResearchTeamandHumanApproval_3.png)

*Figure 18. Methodologist critique generated.*

![Research Team Workflow](Screenshots/ResearchTeamandHumanApproval_4.png)

*Figure 19. Workflow enters WAITING_FOR_HUMAN state.*

![Research Team Workflow](Screenshots/ResearchTeamandHumanApproval_5.png)

*Figure 20. Human approval checkpoint activated.*

![Research Team Workflow](Screenshots/ResearchTeamandHumanApproval_6.png)

*Figure 21. Revised hypothesis generated after approval.*

![Research Team Workflow](Screenshots/ResearchTeamandHumanApproval_7.png)

*Figure 22. Audit log showing workflow traceability.*

---

# The Failures I Saw — And the Lessons

The development process revealed several limitations and failure modes.

The most common issue involved hallucination and unsupported recommendations when retrieval mechanisms were absent. This reinforced the value of RAG and evidence-grounded generation.

Another challenge was evaluation inconsistency. Early scoring systems occasionally rewarded well-written text even when substantive weaknesses remained. This highlighted the difference between fluency and quality.

The multi-agent workflow also demonstrated the risk of alignment drift. Agents sometimes generated recommendations that appeared reasonable but deviated from the user's original objective. The HITL checkpoint was introduced specifically to address this problem.

Audit logs became an essential governance mechanism because they created visibility into how decisions were made, which agents participated, and when human intervention occurred.

---

# Critical Reflection on Management

The most important lesson from this project was that managing an AI workforce is fundamentally different from writing traditional software.

In conventional programming, the developer specifies deterministic instructions. In agentic systems, the developer becomes a director responsible for coordinating multiple semi-autonomous agents that possess different strengths, weaknesses, and objectives.

I learned that success depends less on prompt engineering and more on workflow design, evaluation criteria, checkpoint placement, and governance mechanisms.

In hindsight, I would likely introduce additional specialist agents focused on citation verification and literature synthesis. At the same time, I would avoid excessive agent proliferation because too many agents increase coordination complexity and create additional opportunities for alignment drift.

The most irreplaceable human skill in this project remains judgment. While agents can generate hypotheses, critiques, and recommendations, they cannot assume responsibility for determining whether a research direction is appropriate, ethical, or strategically valuable.

---

# What I Would Do Differently Next

If development continued, I would expand the memory subsystem to support long-term thesis tracking across multiple research sessions.

I would also integrate citation verification tools and more sophisticated evaluation metrics capable of assessing evidence quality rather than writing quality alone.

Future versions could incorporate stronger audit capabilities, richer workflow visualizations, and more advanced human approval policies.

Most importantly, I would continue strengthening the balance between autonomy and oversight. The semester demonstrated that the goal is not to remove humans from the process but to create systems where humans and agents collaborate effectively while maintaining accountability and transparency.

---

# Final Reflection

MF VERITAS-AI represents the culmination of concepts developed throughout the semester, including retrieval, evaluation, reflection, multi-agent collaboration, memory, auditability, and human oversight.

The project demonstrated that effective agentic systems are not defined by the intelligence of individual agents alone but by the quality of the workflow that coordinates them. Through structured evaluation, transparent audit trails, and carefully placed human checkpoints, the system evolved from a collection of AI tools into a managed digital research workforce.

As Research Director, the most important lesson I learned is that successful AI systems require governance as much as intelligence. The future of agentic AI lies not in fully autonomous decision-making but in thoughtfully designed partnerships between humans and intelligent agents.
