# AI-Assisted Acoustic Anomaly Screening for Railway Interior Noise

**Student:** Young-gyu Lee  
**Affiliation:** Korea Railroad Research Institute (KRRI) / University of Science and Technology (UST)  
**Research Field:** Railway Noise and Vibration  
**Project Type:** AI-Assisted Research Support Application

---

## 1. Problem

Railway vehicles generate various types of noise during operation. In addition to normal rolling noise, abnormal or characteristic noise events such as **corrugation-related noise** and **wheel squeal** may occur only at specific locations or under specific operating conditions.

These events are important because they can produce strong tonal components, increase interior noise, and cause passenger discomfort. However, they usually do not occur continuously along the entire railway line.

In railway interior-noise measurements, researchers therefore often record the entire train operation as a long-duration WAV file and identify important sections afterward.

For example, one complete measurement along **Incheon Metro Line 2** may produce a long audio recording, while only a small portion of the recording may contain abnormal noise that requires detailed analysis.

The current workflow requires researchers to:

1. listen to long WAV recordings,
2. inspect waveforms and spectrograms,
3. manually search for unusual sections,
4. cut the corresponding audio segments,
5. compare the events with train operating locations,
6. and finally interpret the physical cause of each event.

This process becomes increasingly repetitive and time-consuming when multiple train runs are measured.

### Main research need

The main problem addressed by this project is:

> **Can long railway interior-noise recordings be automatically screened so that researchers only need to review candidate sections that may contain abnormal noise?**

The goal is not to allow AI to make the final diagnosis. Instead, the system is intended to reduce repetitive screening work and support researchers in finding important acoustic events more efficiently.

---

## 2. Users

### Primary users

The main users are:

- railway noise and vibration researchers,
- engineers conducting railway interior-noise measurements,
- researchers developing acoustic monitoring or condition-monitoring methods.

### User needs

These users need to:

- process long-duration acoustic recordings efficiently,
- find unusual noise events without listening to the entire file,
- compare events across repeated train runs,
- relate detected events to train position,
- review waveform and spectrogram information,
- and keep the final scientific judgment under human control.

The application is initially designed for railway interior-noise research, but the same workflow may also be useful for other research fields that require screening of long-duration acoustic recordings.

---

## 3. Core Features

### F1. Railway Line Information Registration

The user can register basic railway-line information such as:

- station names,
- station order,
- inter-station distances,
- and other information required for position estimation.

This allows the same application structure to be applied to different railway lines.

---

### F2. WAV File Import

The user uploads a long-duration railway interior-noise WAV file.

The application reads the recording and prepares it for acoustic analysis.

The current project uses actual interior-noise recordings measured on **Incheon Metro Line 2** as the main demonstration dataset.

---

### F3. Train Position Estimation Using Station-Related Sound Events

To estimate train position using only acoustic information, the current version uses sound events related to train arrival and departure.

Examples include:

- train-door opening after arrival at a station,
- departure announcements before the train leaves the station.

The user currently enters the timestamps of these events manually.

Using these timestamps and known inter-station distances, the system estimates the train position along the railway line.

#### Future development

This manual process will later be expanded using **AI-based sound-event detection** so that station-related events can be detected automatically.

---

### F4. Acoustic Preprocessing and Feature Extraction

The application divides the WAV signal into shorter analysis segments and calculates acoustic features.

Possible features include:

- sound level,
- spectral characteristics,
- tonal components,
- time-domain characteristics,
- and other acoustic indicators used for abnormal-noise screening.

The numerical acoustic values are calculated using deterministic signal-processing algorithms rather than generated directly by an LLM.

---

### F5. Abnormal-Noise Candidate Screening

The system analyzes acoustic features and identifies segments that differ from typical running-noise characteristics.

These sections are presented as **candidate abnormal-noise events**.

The objective is not to automatically determine the exact physical cause.

Instead, the system performs the first screening step and recommends sections that should be checked by a researcher.

---

### F6. Event Visualization and Audio Playback

For each candidate event, the application allows the researcher to:

- listen to the corresponding audio segment,
- inspect waveform information,
- inspect spectrogram information,
- and review the detected start and end times.

This allows the researcher to verify whether the detected section is actually relevant.

---

### F7. Human Correction and Approval

The researcher remains responsible for the final decision.

The user can:

- approve a candidate event,
- reject a false detection,
- modify the event start and end times,
- assign an event type or label,
- and add a manual description or note.

Examples of possible user-defined labels include:

- squeal-related noise,
- corrugation-related noise,
- impact noise,
- announcement,
- passenger noise,
- unknown event.

The system never automatically confirms a noise event as a specific physical fault without human verification.

---

### F8. Spatial Visualization of Approved Events

Approved candidate events can be mapped to their estimated positions along the railway line.

This allows the user to identify where abnormal-noise events were detected during train operation.

The current application is designed to show the relationship between:

- event time,
- estimated train position,
- and approved abnormal-noise segments.

---

### F9. Event Export

The user can extract and download individual event audio segments for further analysis.

Approved event information can also be retained for comparison with future measurements.

---

### Failure States and Recovery

The application is designed to handle several possible failure states.

#### Failure State 1: False abnormal-noise detection

Example:

Passenger speech, announcements, or door sounds may be incorrectly detected as abnormal noise.

**Recovery:**  
The researcher can listen to the event and select **Reject**.

---

#### Failure State 2: Incorrect event boundaries

The automatically detected segment may be too long or too short.

**Recovery:**  
The researcher can manually modify the start and end times before approving the event.

---

#### Failure State 3: Uncertain event type

The researcher may confirm that the sound is unusual but may not know whether it is squeal, corrugation-related noise, or another source.

**Recovery:**  
The event can be saved as **Unknown** or assigned a manual note without forcing an automatic diagnosis.

---

#### Failure State 4: Incorrect train-position estimation

Station-event timestamps may be entered incorrectly or station-related sounds may be unclear.

**Recovery:**  
The user can manually correct the station-event timestamps and recalculate the position.

---

#### Failure State 5: Different characteristics across railway lines or measurements

Acoustic characteristics may vary depending on:

- railway line,
- train type,
- measurement equipment,
- vehicle position,
- and operating conditions.

**Recovery:**  
The application allows users to adjust screening parameters rather than assuming one fixed detection criterion for all measurements.

---

## 4. Human–AI Interaction Flow

The proposed interaction flow is:

```text
Railway line information
        ↓
Long-duration WAV input
        ↓
Station-related event timestamps
        ↓
Train position estimation
        ↓
Signal preprocessing
        ↓
Acoustic feature extraction
        ↓
Abnormal-noise candidate screening
        ↓
Candidate event visualization
        ↓
Audio playback + waveform/spectrogram review
        ↓
Human decision
   ┌───────────────┬────────────────┬────────────────┐
   ↓               ↓                ↓
Approve          Reject           Adjust
                                    ↓
                        modify event boundaries
                        / label / description
   └───────────────┴────────────────┴────────────────┘
                    ↓
             Approved event list
                    ↓
        Railway location visualization
                    ↓
          Event export / future comparison
```

### Role separation

#### AI / algorithm responsibilities

- signal preprocessing,
- acoustic-feature calculation,
- candidate-event screening,
- train-position estimation support,
- visualization support,
- result organization.

#### Researcher responsibilities

- define the analysis purpose,
- verify detected events by listening,
- inspect waveform and spectrogram information,
- correct event boundaries,
- reject irrelevant events,
- assign the final label,
- interpret the physical meaning,
- and make the final scientific judgment.

### Design principle

> **AI proposes; the researcher decides.**

The system is designed as a research-support tool rather than an autonomous diagnostic system.

---

## 5. Success Criteria

The project will be considered successful if the prototype satisfies the following criteria.

### 5.1. Functional Success

The application should successfully perform the complete workflow:

```text
WAV input
→ acoustic analysis
→ candidate detection
→ playback
→ human review
→ approved event output
```

using actual railway interior-noise data.

---

### 5.2. Real-Data Applicability

The system should operate on actual field-measured interior-noise recordings, including data from Incheon Metro Line 2.

The prototype should not depend only on synthetic or dummy datasets.

---

### 5.3. Screening Efficiency

The application should reduce the amount of audio that a researcher must manually inspect.

Instead of checking an entire long-duration recording, the researcher should be able to focus primarily on automatically selected candidate sections.

A future quantitative evaluation will compare:

- total recording duration,
- total candidate-event duration,
- and manual review time.

---

### 5.4. Human Control

The researcher must be able to:

- listen to each candidate event,
- approve or reject it,
- modify its boundaries,
- add labels or descriptions,
- and override the automated result.

No event should be automatically accepted as a final abnormal-noise diagnosis without human confirmation.

---

### 5.5. Recovery from Detection Errors

The application should remain usable even when the automatic screening result is incorrect.

False detections, boundary errors, and uncertain classifications must be recoverable through user interaction.

---

### 5.6. Reusability for Repeated Measurements

Approved events should be stored in a structured form so that future measurements can be compared with previous runs.

This will provide the basis for future functions such as:

- repeated-event comparison,
- location-based analysis,
- event-type classification,
- and event-database construction.

---

## Future Development

The current mid-term prototype focuses on:

> **Long WAV input → candidate-event screening → human verification**

Future development will include:

1. automatic detection of station-related sound events,
2. improved train-position estimation,
3. abnormal-noise event categorization,
4. comparison of repeated measurements,
5. identification of locations where abnormal noise repeatedly occurs,
6. event database construction,
7. AI-assisted comparison and summarization,
8. and research-report support.

The long-term objective is to develop an **Acoustic Research Assistant** that helps researchers efficiently identify important acoustic data while keeping final interpretation and scientific responsibility in human hands.