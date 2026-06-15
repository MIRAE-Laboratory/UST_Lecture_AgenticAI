⭐ **[2026-1 Final-term Project - INDEX](../2026-1_Final-term_Project.md)**

# Director's Report: Quality-Control AI Agent for Imitation Learning

## 1. What I Built
I built an automated, **real-time** quality-assurance workflow to govern teleoperation data collection for a highly precise Peg-in-Hole robotic task. The intent was not simply to filter bad data after the fact, but to manage the behavioral consistency of a human workforce during live teleoperation. By streaming live trajectory and force data directly from the simulation into a real-time Streamlit dashboard, I established a system that monitors and flags anomalies *on the fly*, preventing contaminated data from entering the training pipeline and protecting our Imitation Learning models.

## 2. Architecture & Design Decisions
The architecture operates as a hybrid real-time local-AI pipeline. I utilized the **MCP (Model Context Protocol)** and inter-process communication (IPC) to allow the AI agent and dashboard to directly interface with our simulation environment (`mujoco_teleop.py`) in real time. 

For the analysis layer, I separated the workflow into two synchronized streams:
* **Real-time Live Monitor (Streamlit):** A local Python dashboard receives streaming telemetry (joint kinematics, end-effector forces/torques) from MuJoCo and dynamically plots them. It uses lightweight heuristics to detect sudden spikes or threshold breaches in real time.
* **LLM Reasoner (Gemini 3.1 Pro):** When a live anomaly (e.g., a force spike) is detected, the LLM receives a structured JSON snapshot of the recent time-window. It acts as an evaluator agent, providing rapid human-readable insights and a Consistency Score for that specific event.

I explicitly avoided a fully autonomous end-to-end setup. Instead, I designed the system around a **Human-in-the-Loop (HITL)** pattern, ensuring the AI acts as an over-the-shoulder advisor during data collection rather than a final decision-maker.

## 3. Where the Humans Are in the Loop
The **checkpoint placement** was the most critical design decision in this workflow. 
* **Automatic Actions:** Real-time data streaming, dynamic plotting, live anomaly detection, and the generation of the Consistency Score are fully automated. The agent automatically pulls the kinematic states from `mujoco_teleop.py` as they happen.
* **Human Checkpoint:** The final decision to [KEEP] or [DISCARD] the flagged episode or data segment is strictly manual. 

I defended this checkpoint placement because an AI evaluating numerical variance lacks the physical intuition required for contact-rich tasks. A sudden spike in the Z-axis torque might trigger a live anomaly alert, but a human operator knows it is a necessary contact force to overcome friction during the peg insertion. The human is placed at the end of the loop to exercise their **epistemic taste**—making qualitative judgments that pure statistics cannot.

## 4. The Failures I Saw — And the Lessons
During development, the most prominent issue was **alignment drift** between the AI's objective function and the actual task requirements. Initially, the AI agent became overly stringent, penalizing any live episode that didn't perfectly match the expected smooth trajectory. 

**Excerpt from Live Audit Log:**
> `[14:22:01] Agent:` Anomaly Flagged in live stream. Consistency Score: 45/100. Reason: 1.5N force spike detected at Z-axis. Recommendation: DISCARD Segment.
> `[14:22:30] Human:` OVERRIDE -> KEEP. Note: Spike is legitimate insertion contact force, not an operator error.

The lesson here was profound: the AI was optimizing for *mathematical uniformity*, while the human was optimizing for *task success*. This drift required me to adjust the prompt weighting, instructing the LLM to be more tolerant of force spikes occurring specifically when the Z-position indicates the insertion phase.

## 5. Critical Reflection on Management
Managing an Agentic AI workflow is fundamentally different from writing deterministic software. When writing a program, an error throws an exception. When managing an AI, an error often looks like a very confident, plausible, yet entirely wrong recommendation during a live session. 

In hindsight, I should have implemented a **Memory** component. Because the current live agent is stateless across anomaly events, it kept flagging the same valid contact forces across different teleoperation runs, forcing the human to repeatedly overrule it. 

The irreplaceable human skill in this project is physical reasoning. The AI can calculate that a joint moved 5 degrees too fast in real time, but only a human researcher understands *why* the operator made that micro-adjustment in response to the MuJoCo environment's friction.

## 6. What I Would Do Differently / Next
If I were to iterate on this, my immediate next step would be implementing a real-time feedback loop. Currently, when a human clicks [KEEP] against the AI's [DISCARD] recommendation on the dashboard, that insight is lost. The AI does not learn from the human's epistemic taste. 

I would add a "Self-Reflection" agent that reviews the session logs, compares its live recommendations against the human overrides, and dynamically updates its evaluation criteria for the next session. This would transition the system from a static live-monitor into a continuously aligning, true AI teammate.
