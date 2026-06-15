⭐ **[2026-1 Final-term Project - INDEX](../2026-1_Final-term_Project.md)**

<h1 align="center">Final-Term Project: Director's Report</h1>

<div align="right">
DongYun Cho  

02323054
</div>

---

## 1. FitPick
Choosing **OOTD** (outfit of the day) is a repetitive yet highly difficult decision, as users must account for their preferences. 
Most existing AI solutions either provide generic recommendations without understanding the user's constraints, or act as simple chatbots lacking structured verification. This often leads to impractical suggestions that the user must blindly accept or discard.
**FitPick** solves this by providing a tailored AI outfit recommendation within an active **human-in-the-loop** workflow. It functions as a decision-support system that presents styling risks before finalization, ensuring the user stays in control and does not blindly accept AI output.

FitPick is built on a single LLM configured with two distinct personas: a Stylist agent (Model A) and a Risk Analyst agent (Model B). 
Model A acts as a fashion coordinator: given the user’s body traits, face shape, personal color, mood, season, and TPO (Time, Place, Occasion), it proposes an outfit and explains why this combination is appropriate. 
Model B adopts a different epistemic taste and evaluates the same outfit along three dimensions—Color Match, Silhouette, and Formality—using numeric risk scores and textual critique. 
Finally, users can accept, locally edit, or reject their deicisons.

---

## 2. Architecture & Design Decisions

This project focuses on four themes from the course: a multi‑agent pipeline, self‑reflection, HITL, and an audit log for evaluation and memory.

### 2.1 Multi‑agent pipeline

FitPick follows a **pipeline‑style multi‑agent pattern** in which the app orchestrates calls from the Stylist agent to the Risk Analyst agent in a fixed order.

1. The user submits a profile and clicks **“Generate OOTD”**.  
2. The app calls the **Stylist agent (Model A)**, which produces an outfit description together with a rationale explaining why this OOTD was selected.  
3. When the user proceeds to verification, the app calls the **Risk Analyst agent (Model B)** to generate a structured Styling Risk Report with scores for Color, Silhouette, and Formality.

This separation allows each persona to encode a different interpretation of “good” clothing. 
Model A prioritizes style alignment with user preference, whereas Model B emphasizes risk and mismatch. 
In course terms, the system deliberately **diversifies epistemic taste** instead of relying on a single viewpoint.

### 2.2 Self‑reflection

Self‑reflection is implemented as a **single optional revision loop** that is invoked only when the user requests an adjustment after seeing the critique.

- The Risk Analyst surfaces risk scores and improvement points for the current outfit.  
- If the user selects **Adjust Color Only** or **Adjust Formality**, the system logs `trigger_self_reflection` and passes these improvement points back to the Stylist.

Example gate event:

```json
{
  "actor": "System (Approval Gate)",
  "action": "trigger_self_reflection",
  "input": { "user_choice": "Adjust Color Only" },
  "decision": {
    "outcome": "Triggered self-reflection revision",
    "improvement_points": "[RECOMMENDATIONS:]"
  }
}
```

The Stylist then generates a revised outfit (for example, `"Urban Fresh Balance"` → `"Essential Balance Summer"`) that attempts to address the flagged issues. 
This yields a self‑reflection pattern: **Model A generates, Model B critiques, and Model A revises once, conditioned on user request**.

### 2.3 HITL and checkpoint placement

The UI is organized around HITL checkpoints:

- **Architect Input (before AI)** – The user specifies their profile and TPO before any model call.  
- **Stylist → Verification transition** – After reading Model A’s explanation, the user must click **“Proceed to Verification.”** 
- **Verification Panel (Human Fail‑safe)** – After reviewing the risk report, the user chooses among **Accept & Finalize**, **Adjust Color Only**, **Adjust Formality**, or **Cancel & Restart Session**.


### 2.4 Audit log as evaluation and memory

Each session is recorded in an **audit log** that supports both evaluation and lightweight memory. The log contains:

- session‑level timing (`start_time`, `final_time`, `decision_duration_seconds`),  
- the `user_profile`, and  
- a chronological `audit_trail` with `actor`, `action`, `input`, `output`, and `decision`.

Example excerpt:

```json
{
  "session_id": "8de01957-e5bf-48c0-8d6f-af51c3550fc1",
  "decision_duration_seconds": 163.36,
  "user_profile": {
    "gender": "Male",
    "height": 185,
    "personal_color": "Summer Cool",
    "season": "Summer",
    "situation": "Daily / Casual Outing"
  },
  "audit_trail": [
    "generate_initial_outfit",
    "output_initial_outfit",
    "critique_initial_outfit",
    "trigger_self_reflection",
    "generate_revised_outfit",
    "output_revised_outfit",
    "critique_revised_outfit",
    "accept_and_finalize",
    "submit_feedback"
  ]
}
```

This structure lets me reconstruct how the system behaved under each profile, and later analyze patterns such as decision time, number of revisions, and typical risk scores.

---

## 3. Where the Humans Are in the Loop

### 3.1 Automatic actions

Once triggered, the following actions are automatic:

- The **Stylist agent** consumes the user profile and generates an outfit with description.  
- The **Risk Analyst agent** computes risk scores and accompanying explanations.  
- The **revision generation** runs only when the user has requested an adjustment via the HITL interface.  
- **Timing and logging** run in the background, recording `start_time`, `final_time`, `decision_duration_seconds`, and per‑event timestamps.

### 3.2 Actions requiring human approval

Human decisions appear at several key points:

- **Profile definition** – The user manually enters gender, height, weight, face shape, personal color, mood, season, and situation in the Architect Input panel.  
- **Transition to verification** – The user clicks **“Proceed to Verification”** after reading the Stylist’s explanation.  
- **Final decision at the Verification Panel** – The user selects one of:
  - `accept_and_finalize`,  
  - `request_adjustment_color_only`,  
  - `request_adjustment_formality`, or  
  - `cancel_and_restart_session`.  
- **Feedback** – At the end, the user answers Q1 (overall satisfaction) and Q2 (risk helpfulness) via `submit_feedback`.

Example user decisions:

```json
{
  "actor": "User",
  "action": "proceed_to_verification",
  "decision": { "selection_reason": "Best mood match" }
},
{
  "actor": "User",
  "action": "accept_and_finalize",
  "input": { "outfit_title": "Essential Balance Summer" }
},
{
  "actor": "User",
  "action": "submit_feedback",
  "decision": { "q1_satisfaction": 4, "q2_risk_helpfulness": 4 }
}
```

These checkpoints ensure that HITL is not merely symbolic: the system cannot finalize an OOTD or adjust it without user approval.

---

## 4. Failures and Lessons

### 4.1 Failures and lessons

**a. Image generation**

Initially, I assumed Gemini could generate mannequin images directly. 
In practice, the free‑tier API key with `gemini-3.5-flash` quickly exceeded quota or token limits.
The main lesson was to design FitPick in a way that it doesn't consume too many tokens per session.

**b. Shared blind spots between agents**

Both Stylist and Risk Analyst are built on the same LLM stack. 
Despite distinct prompts, they sometimes exhibited similar **alignment drift** and blind spots—for example, repeatedly recommending “safe” navy‑and‑white palettes and occasionally using phrasing about body shape that could be socially uncomfortable. 
This showed that a multi‑agent setup does not automatically guarantee diverse epistemic taste.
True diversity requires different model families or explicit disagreement mechanisms.

**c. Over‑editing**

In early versions, “Adjust Color Only” and “Adjust Formality” often triggered full regeneration instead of local edits. 
Audit logs revealed multiple outfit titles and silhouettes after a single adjustment request, which conflicted with the intended semantics of controlled editing. 
This highlighted the need for tighter structural constraints so that adjustment actions alter only the relevant dimensions rather than redrawing the entire outfit.

### 4.2 Audit trail and the 5 W’s
The audit log provides a clear answer to the 5 W’s:

- **Who** – one of `Stylist Agent`, `Risk Analyst Agent`, `System (Approval Gate)`, or `User`.  
- **When** – `start_time`, `final_time`, `decision_duration_seconds`, plus per‑event `time` (for example, `2026-06-11 21:29:10` to `21:31:53`, 163.36 seconds).  
- **What** – `action` together with `input` and `output`, including:
  - `generate_initial_outfit`,  
  - `output_initial_outfit`,  
  - `critique_initial_outfit`,  
  - `output_initial_critique`,  
  - `trigger_self_reflection`,  
  - `generate_revised_outfit`,  
  - `output_revised_outfit`,  
  - `critique_revised_outfit`,  
  - `accept_and_finalize`,  
  - `submit_feedback`.  
- **Why** – `decision` fields such as the gate outcome (`"Triggered self-reflection revision"`), user selection reasons (`"Best mood match"`), and satisfaction / risk‑helpfulness scores.  
- **Outcome** – the final accepted outfit title (for example, `"Essential Balance Summer"`) and feedback scores (`q1_satisfaction: 4`, `q2_risk_helpfulness: 4`).

This structure turns what would otherwise be anecdotal impressions into traceable evidence of how the system behaves.
(Please refer to example log file.)

---

## 5. Critical Reflection on Management

### 5.1 Leading an AI workflow vs writing a program

Compared to my usual programming tasks, leading this AI workflow felt like **directing a team of semi‑reliable collaborators**. I had to:

- Define clear roles (Stylist vs Risk Analyst),  
- Specify interfaces (JSON schemas, risk categories), and  
- Manage expectations (local edits vs fresh generations).

I also needed to place checkpoints to manage hallucination and alignment drift, not just runtime errors. 
In other words, rather than only writing correct code, I was **managing behaviours**: monitoring, steering, and correcting models that will never be perfectly predictable.

### 5.2 Where I would add or remove agents

In hindsight, I would retain the two‑agent pipeline (Stylist + Risk Analyst) because it is conceptually simple and clearly demonstrates the multi‑agent pattern. 
If resources were very tight, I would simplify the self‑reflection loop and rely more heavily on human verification at the Verification Panel, since that is where the most important judgment actually occurs. 
For future extensions, I might introduce lightweight agents for explanation rewriting or preference learning, but only if they provide clear additional value.

### 5.3 Irreplaceable human skills

Two human contributions remain essential in FitPick:

- **Final judgment of the OOTD** – Only the user can determine whether an outfit fits their preferences. Agents can propose and warn, but they cannot experience embarrassment or confidence.  
- **Setting the profile and preferences** – At the Architect Input step, users define their own identity, preferences, and risk appetite. The system treats this as ground truth rather than inferring it from passive data.


---

## 6. Future Work

Going forward, I plan to:

- Add basic **MCP server** for persistent profile data and weather context,  
- Explore different models for the Stylist and Risk Analyst to reduce shared blind spots
- Further constrain adjustment actions so that color or formality edits the generated outfit, instead of regenerating the entire outfit.

Overall, the project reinforced that the hard part of working with agents is not simply calling an LLM, but **designing and managing a workflow** with clear roles, checkpoints, and audit trails, so that human judgment remains central and the system’s epistemic behaviour stays understandable and correctable.