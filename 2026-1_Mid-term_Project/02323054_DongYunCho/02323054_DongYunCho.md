
⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

# Specification Document: FitPick (Human-in-the-Loop AI Fashion Coordinator)

## 1. Problem
Choosing a daily or situational outfit is a repetitive yet highly uncertain decision, as users must account for their specific body traits, seasonal appropriateness, and TPO (Time, Place, Occasion). Most existing AI solutions either provide generic recommendations without understanding the user's constraints, or act as simple chatbots lacking structured verification. This often leads to impractical suggestions that the user must blindly accept or discard.
**FitPick** solves this by providing a tailored AI outfit recommendation within an active **human-in-the-loop** workflow. It functions as a decision-support system that presents styling risks before finalization, ensuring the user stays in control and does not blindly accept AI output.

---

## 2. Users
- **Primary Users:** Individuals preparing for specific situations (e.g., Casual Outing, Office Presentation, Date, Interview, Wedding Guest).
- **Secondary Users:** People uncertain about fashion who need structured AI guidance tailored to their physical traits (height, weight, face shape, personal color) to minimize fashion faux pas.

---

## 3. Core Features
1. **Architect Input System (User Control):** Users act as the "Architect" by explicitly defining their physical traits, desired mood, situation, and preferred LLM Provider (Gemini/Ollama) before any generation occurs.
2. **Context-Aware AI Generation & Red-Zone:** Generates a highly specific outfit recommendation (using LLMs). Every output explicitly highlights a **Red-Zone Warning** (potential styling risks or downsides based on the user's body shape or tone) alongside a photorealistic mannequin image.
3. **Explicit Risk Analysis (Fail-safe Verification):**  
After the outfit is generated, the system analyzes it and returns a structured list of potential risks, including:
- color mismatch with personal tone  
- inappropriate formality for the situation  
- silhouette issues based on body shape  
This step forces the user to review potential flaws before finalizing.
4. **Structured Recovery Options:**  
If the generated outfit is unsatisfactory or risky, the user can recover without starting from scratch. Available recovery paths include:
- **Adjust Color Only**
- **Adjust Formality**
- **Cancel & Return to Review**
- **Randomize & Regenerate**

---

## 4. Interaction Flow
The diagram below shows the full human-AI interaction loop, where the user first defines inputs (Architect), then reviews and verifies the output before finalizing (Fail-safe).

![poster](./fitpick_architecture.png)

---

## 5. Success Criteria

The system is considered successful if:
- **Time Efficiency:**  
Users can generate and review an outfit within 2 minutes.
- **User Understanding:**  
Users can clearly explain:
  - why the outfit was recommended  
  - what risks (red-zone) exist  
- **Active Verification:**  
Users do not accept outputs blindly and interact with the risk analysis before finalizing.
- **Recovery Usage:**  
Users can successfully regenerate or adjust outputs without abandoning the app.
- **Reduced Cognitive Load:**  
Compared to manual outfit selection, users spend less time and effort making decisions.

---

## 6. Verification and Red Zone
### Verification
The system enforces a verification step by presenting a structured risk analysis before finalization.  
The user must review these risks before accepting the result.

### Red Zone
The red-zone highlights concrete risks such as:
- mismatch with situation (too casual/formal)
- color incompatibility with personal tone
- silhouette issues based on body shape

This prevents blind acceptance of AI outputs.

---

## 7. Recovery Options
If the user encounters a bad output or reconsiders their choice after risk analysis, they are not forced to accept it. The system provides multiple recovery paths:

- **Randomize & Regenerate:** Completely generate a new outfit recommendation when the current result is unsuitable.
- **Adjust Color Only:** Keep the overall outfit concept but modify the palette to reduce tone mismatch.
- **Adjust Formality:** Keep the overall outfit concept but shift it toward a more casual or more formal version.
- **Cancel & Return to Review:** Exit the current verification step and return to the review stage without finalizing.