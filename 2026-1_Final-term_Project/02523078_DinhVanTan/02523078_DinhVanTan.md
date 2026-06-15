⭐ **[2026-1 Final-term Project - INDEX](../2026-1_Final-term_Project.md)**

# ResearchPilot – Director's Report

## What I Built

I developed **ResearchPilot**, an AI-assisted scientific graph digitization system that converts graph images into numerical datasets. The system is designed for researchers and engineers who need to recover numerical data from published figures when the original raw data is unavailable.

The goal of the project is not simply to automate graph extraction, but to create a workflow where AI assists the user while maintaining transparency, traceability, and human oversight throughout the process.

---

# Architecture & Design Decisions

ResearchPilot was designed as an agentic workflow rather than a single monolithic application. Different responsibilities are assigned to different logical agents.

## Vision Calibration Agent

The Vision Calibration Agent analyzes uploaded graph images and identifies important visual structures such as:

* Plot boundaries
* Axes regions
* Curves
* Graph layout

This agent provides an initial interpretation of the figure before extraction begins.

## Vision-to-Data Agent

The Vision-to-Data Agent converts graphical information into numerical coordinates.

Its responsibilities include:

* Curve detection
* Point extraction
* Coordinate transformation
* Numerical dataset generation

The output of this stage is a structured dataset that can be exported as CSV.

## Scientific Critic Agent

The Critic Agent does not generate data.

Instead, it evaluates the extraction results and identifies potential problems such as:

* Incomplete curve extraction
* Incorrect boundary calibration
* Axis interpretation issues
* Suspicious data distributions

The purpose of the Critic Agent is to challenge the extraction result before export.

## Audit Agent

Every significant action performed by the system is recorded.

Examples include:

* Image upload
* Calibration actions
* Extraction events
* Human approvals
* Export operations

The audit trail improves transparency and makes it possible to review how a particular dataset was generated.

---

# Where the Humans Are in the Loop

ResearchPilot intentionally includes multiple human review checkpoints.

The system is not designed to operate as a fully autonomous pipeline.

Human involvement is required in the following stages:

## Boundary Calibration

The user reviews and adjusts detected graph boundaries when necessary.

## Point Verification

The user can inspect extracted data points and verify whether the reconstructed curve matches the original figure.

## Export Approval

No dataset is exported without explicit user approval.

I intentionally placed these checkpoints because errors in graph calibration can propagate through the entire extraction process. Human review therefore acts as a quality control mechanism.

This checkpoint placement reflects an important lesson from the course: automation should be applied selectively, while critical decisions remain under human supervision.

---

# The Failures I Saw — And the Lessons

Several failure modes appeared during development.

## Failure 1: Incorrect Boundary Detection

In some figures, the Vision Calibration Agent selected incorrect plot boundaries.

This occurred most frequently when:

* Multiple graphs appeared in the same image
* Decorative elements existed around the graph
* The graph had an unusual layout

### Mitigation

Manual boundary adjustment tools were added before extraction.

---

## Failure 2: Multi-Curve Separation Errors

Graphs containing multiple curves with similar colors occasionally caused incorrect curve separation.

### Mitigation

Additional curve grouping logic was introduced, and human verification remained available before export.

---

## Failure 3: Axis Interpretation Errors

Some scientific figures used uncommon axis layouts or dense tick labels.

Incorrect calibration could significantly distort the recovered dataset.

### Mitigation

Human-assisted calibration and review checkpoints were retained as part of the workflow.

---

## Failure 4: Overconfidence Risk

The system could successfully produce a dataset even when extraction quality was questionable.

This created a risk that users might trust the output without verification.

### Mitigation

The Critic Agent was introduced to highlight potential extraction issues and encourage user review.

---

# Critical Reflection on Management

This project taught me that managing an AI workflow is fundamentally different from writing traditional software.

In conventional software, the primary challenge is implementing correct logic.

In an agentic system, the primary challenge becomes managing uncertainty.

The most important design decisions were not related to algorithms but to:

* Where human review should occur
* Which decisions should be automated
* How potential errors should be surfaced
* How accountability should be maintained

I learned that adding more automation is not always the best solution. In several situations, a well-placed human checkpoint improved reliability more effectively than adding another AI component.

The most important human skill in this workflow is scientific judgment. AI can assist with extraction and analysis, but humans remain responsible for evaluating whether the final data is trustworthy and scientifically meaningful.

---

# What I Would Do Differently Next

At the beginning of the project, I considered supporting both:

1. Graph Image → Numerical Data
2. Raw Data → Graph Generation

However, I decided to focus exclusively on graph digitization.

Professional plotting tools such as Origin, MATLAB, Python, and Excel already provide excellent support for graph generation. In contrast, recovering numerical data from graph images remains a difficult and less-supported problem.

Future improvements would include:

* Automatic tick-value recognition
* Improved multi-curve separation
* Logarithmic axis detection
* Confidence scoring for extracted points
* Benchmark evaluation using reference datasets

---

# Conclusion

ResearchPilot demonstrates that successful AI systems require more than accurate extraction algorithms. Effective systems must also provide transparency, auditability, and appropriate human oversight.

The most valuable lesson from this project was learning how to manage uncertainty within an AI workflow. Rather than maximizing automation, the project focused on balancing AI assistance with human judgment through carefully placed checkpoints and review mechanisms.

This experience reinforced the importance of designing AI systems that are not only capable, but also trustworthy and accountable.
