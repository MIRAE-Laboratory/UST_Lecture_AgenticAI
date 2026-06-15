<h1 align="center">FitPick Architecture</h1>

This document describes the **system architecture** of FitPick.

---

## 1. High-Level Overview

FitPick is structured as a **single LLM with two personas** orchestrated by the app:

- **Stylist Agent (Model A)** – proposes an outfit and explains why it fits the user’s profile and situation.
- **Risk Analyst Agent (Model B)** – critiques the same outfit with structured risk scores (Color Match, Silhouette, Formality).

The human user occupies both the **Architect** role (defining constraints up front) and the **Fail‑safe** role (approving or editing the final decision). The app coordinates the interaction between user and agents, and records each session in an audit log.

The overall interaction is summarized in the architecture diagram:

![FitPick architecture](./fitpick_updated.png)

---

## 2. Components

### 2.1 User (Architect & Fail-safe)

The user provides all high‑level constraints and makes final decisions:

- Enters **profile**: body traits (height, weight), face shape, personal color.
- Selects **preferences**: desired mood, season, and TPO (Time, Place, Occasion).
- Chooses **actions** at key checkpoints: Proceed to Verification, Accept & Finalize, Adjust Color Only, Adjust Formality, or Cancel & Restart.

The user’s inputs define the problem instance that the agents must solve; the system never infers these constraints implicitly.

### 2.2 FitPick App (Orchestrator)

The app is the orchestration layer that:

- Validates and packages the user profile into a structured request.
- Calls Model A and Model B in sequence according to the pipeline.
- Implements **checkpoint placement** logic (when to ask the human, when to trigger self‑reflection).
- Renders screens (Architect Input, Stylist Recommendation, Verification Panel, Final Screen).
- Writes a structured **audit log** with session metadata and a chronological audit_trail.

The app does not generate content itself; it manages control flow and state.

### 2.3 Stylist Agent (Model A)

The Stylist is a persona of the underlying LLM configured for **outfit synthesis**:

- **Input**: user profile (traits, personal color, mood, season, TPO) and, when editing, improvement points from the Risk Analyst.
- **Output**:
  - Outfit JSON (top, bottom, shoes, color palette, formality score).
  - Natural‑language rationale explaining why this outfit suits the profile and situation.

Model A is used in two modes:

1. **Initial generation** – given only the user profile.  
2. **Self‑reflection revision** – given the original outfit plus improvement points when the user requests **Adjust Color Only** or **Adjust Formality**.

### 2.4 Risk Analyst Agent (Model B)

The Risk Analyst is a second persona of the same LLM configured for **evaluation**:

- **Input**: the outfit JSON produced by Model A and the user profile.
- **Output**:
  - A **Styling Risk Report** with:
    - Color Match risk score and explanation.
    - Silhouette risk score and explanation.
    - Formality risk score and explanation.

Model B encodes a different **epistemic taste**, focusing on mismatch and potential failure modes rather than creativity.

### 2.5 Audit Log

Each session produces a JSON audit log with:

- `session_id`, `start_time`, `final_time`, `decision_duration_seconds`.
- `user_profile` summary (non‑sensitive traits and TPO).
- `audit_trail`: ordered events with fields:
  - `actor` (User, Stylist Agent, Risk Analyst Agent, System (Approval Gate)),
  - `action` (e.g., `generate_initial_outfit`, `critique_initial_outfit`, `trigger_self_reflection`, `accept_and_finalize`),
  - `input`, `output`, and optional `decision` (why the action occurred).

This serves as both an evaluation trace and a memory of how decisions were made.

