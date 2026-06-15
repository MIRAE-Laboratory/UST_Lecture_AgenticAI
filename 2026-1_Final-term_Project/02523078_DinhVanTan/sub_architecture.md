⭐ **[2026-1 Final-term Project - INDEX](../2026-1_Final-term_Project.md)**

# ResearchPilot Architecture Notes

## System Overview

ResearchPilot is an AI-assisted scientific graph digitization platform designed to recover numerical data from graph images.

The system combines AI agents, computer vision techniques, human review checkpoints, and audit logging to improve extraction reliability.

---

# High-Level Workflow

```text
Graph Image
      │
      ▼
Vision Calibration Agent
      │
      ▼
Vision-to-Data Agent
      │
      ▼
Human Review Checkpoint
      │
      ▼
Scientific Critic Agent
      │
      ▼
Export CSV
      │
      ▼
Audit Trail
```

---

# Agent Responsibilities

## Vision Calibration Agent

Responsibilities:

* Analyze graph structure
* Detect plot boundaries
* Identify graph regions
* Assist calibration

Outputs:

* Plot boundary candidates
* Calibration suggestions

---

## Vision-to-Data Agent

Responsibilities:

* Detect graph curves
* Extract coordinate points
* Convert image coordinates into numerical values

Outputs:

* Numerical dataset
* Reconstructed graph

---

## Scientific Critic Agent

Responsibilities:

* Review extraction quality
* Identify potential extraction risks
* Recommend additional human verification

Examples:

* Boundary detection issues
* Missing curve segments
* Axis calibration concerns

---

## Audit Agent

Responsibilities:

* Record all important actions
* Maintain workflow transparency
* Support traceability

Examples:

* Image upload
* Calibration updates
* Human approvals
* Data exports

---

# Human-in-the-Loop Design

ResearchPilot intentionally requires human review before final export.

Human checkpoints exist because:

* Graph calibration errors can propagate through the workflow.
* Scientific figures often contain ambiguities.
* Human judgment remains necessary for final validation.

Review stages include:

1. Boundary calibration
2. Point verification
3. Export approval

---

# Design Philosophy

The goal of ResearchPilot is not to maximize automation.

Instead, the goal is to balance:

* AI assistance
* Human judgment
* Transparency
* Accountability

This design reduces the risk of blindly trusting automatically extracted data while still benefiting from AI-assisted analysis.

```
```
