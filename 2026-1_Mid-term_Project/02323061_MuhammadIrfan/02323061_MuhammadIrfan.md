⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

# Rewinder Control AI Agent and Autonomous Operation Workflow

This document explains the main software components developed for the rewinder tension control system. The implementation is divided into three connected stages: 
**Step 2 feature extraction with LLM-assisted decision support**, **dashboard generation for visualization**, and **Step 3 MLOps training before and after model training**. The overall objective is to move from raw machine response data toward intelligent monitoring, evaluation, and future autonomous operation.

The attached implementation includes a main feature-extraction and LLM-integration script, an extended dashboard-generation version of the same pipeline, and a separate MLOps training script for the predictive models. 

## 1. Main Code for Feature Extraction and LLM Integration

The first script is the main operational code used for **step-response feature extraction** and **LLM-based engineering interpretation**. It is designed to work in both **online** and **offline** modes. In online mode, the script continuously monitors newly generated machine files, while in offline mode it processes previously recorded experimental data in batch form. The mode is selected by the user at runtime. 

The system reads step-response data from `Data_*.csv` files and pairs each data file with its corresponding `Report_Data_*.csv` metadata file. From the report file, it extracts important operating parameters such as **film width**, **rewinder Kp**, **rewinder Ki**, **web speed**, and **rewinder roll diameter**. This allows each extracted response feature to be connected with the exact machine condition under which it was generated. 

### 1.1 Operational Modes

The script begins by asking whether it should run in **ONLINE** or **OFFLINE** mode. In online mode, it monitors the daily report folder and searches for new even-numbered `Data_*.csv` files. These even-numbered files correspond to the step-response experiments that are relevant for analysis. In offline mode, it scans the selected validation folder and processes all valid files sequentially. This structure makes the same code usable for both real-time machine operation and post-experiment analysis. 

### 1.2 Data Cleaning and File Handling

Several utility functions are used to standardize the incoming data. Column names are cleaned to remove hidden spaces and formatting inconsistencies, duplicate columns are merged when necessary, and file-stability checks are applied to avoid reading files that are still being written by the machine. The script also contains helper functions to locate the newest subfolder, collect valid step-response files, and match each data file with its exact metadata report. 

### 1.3 Feature Extraction Logic

The main objective of this code is to extract dynamic response features from the rewinder tension step response. For each valid response, the script computes:

- **tau (s)**: the 63.2% time constant with respect to the target setpoint,
- **t90 (s)**: the time required to reach 90% of the final transition,
- **Tp (s)**: the time to peak,
- **Settling Time (s)**: the time required for the signal to remain within the defined tolerance band,
- **Peak (kg) [0–5s]**: the peak response during the first 5 seconds,
- **Overshoot (kg) [0–5s signed]**: the signed overshoot with respect to the setpoint. 

The script uses the `Date` column to compute elapsed time when available. If timestamp parsing fails, it falls back to index-based timing. This makes the implementation robust to different data-recording conditions. The settling-time calculation uses a ±3.5% band around the final stabilized value, which is consistent with the rewinder response-analysis framework used in the project. 

### 1.4 Engineering Logic for Peak and Overshoot

The feature extractor includes special handling for overshoot interpretation. If the signed overshoot is negative, the system treats the effective overshoot as zero for decision purposes and flags the interpretation accordingly. This prevents negative overshoot from being incorrectly treated as a favorable positive peak. In addition, the peak within the first 5 seconds is corrected to the setpoint when the calculated signed overshoot is negative. This ensures consistent engineering interpretation before further reasoning is applied. 

### 1.5 RAG-Based LLM Integration

The same script integrates a local **Phi-4 model through Ollama** for engineering-language reasoning. The implementation loads three knowledge bases in JSONL format:

- `system_behavior_kb.jsonl`,
- `adaptive_validation_kb.jsonl`,
- `engineering_rules_kb.jsonl`. 

These knowledge bases are used in a retrieval-augmented generation workflow. For each new experiment, the script retrieves the most relevant previous cases based on similarity in **web speed**, **diameter**, **Kp**, and **Ki**. A weighted retrieval distance is computed so that the current case can be compared against the most relevant fixed-gain and adaptive-gain reference cases.

### 1.6 Python-Based Decision Logic Before LLM Narration

A strong design feature of this code is that the **hard numeric logic is not delegated to the LLM**. Instead, Python handles the following tasks directly:

- effective overshoot calculation,
- threshold-based decision logic,
- comparison with retrieved baseline cases,
- determination of whether the response should be classified as `PROCEED`, `REVIEW`, or `REJECT`. fileciteturn0file0

The script classifies the response according to effective overshoot percentage:

- **PROCEED** when effective overshoot is within the optimal range,
- **REVIEW** when performance is suboptimal or uncertain,
- **REJECT** when overshoot exceeds the acceptable range or violates a safety limit. 

This design is important because it keeps mathematical calculations and safety rules deterministic, while the LLM is used only for concise engineering narration.

### 1.7 LLM as Engineering Narrator

After Python completes the calculations, Phi-4 receives the already computed comparison facts and writes short engineering assessments. The LLM is instructed not to recalculate values or invent numbers. Instead, it produces short statements for:

- overshoot assessment,
- tau assessment,
- t90 assessment,
- physics reasoning,
- conclusion versus fixed-gain baselines,
- conclusion versus adaptive baselines. 

In this design, the LLM acts as an **engineering-language supervisor**, not as a numerical decision engine. This is a suitable structure for future autonomous operation because it separates **reliable control logic** from **human-readable interpretation**.

### 1.8 Plot Generation and Output Files

For every processed experiment, the script generates a step-response plot showing the measured tension signal, tolerance band, and dynamic markers such as tau, t90, and Tp. These plots are saved into an `_outputs/plots` folder beside the processed data. At the same time, the extracted numerical results are collected into `StepResponse_Summary.csv`, and selected rows are appended to the master dataset used later for model training. 

### 1.9 Final Role of the First Script

In summary, the first script acts as the **main intelligent feature-extraction layer** of the rewinder system. It receives raw step-response data, extracts meaningful dynamic features, compares the current machine condition with prior knowledge, applies deterministic decision rules, and produces engineering interpretations that can support operator understanding and future autonomous action.

## 2. Second Code for the Dashboard

The second script extends the first pipeline by adding a **dashboard-generation layer**. Its purpose is not only to extract and evaluate the features, but also to convert the summary data into a visual reporting interface that can be opened automatically in a browser. 

### 2.1 Relationship to the First Script

Most of the core logic in the second script remains the same as in the feature-extraction pipeline. It still supports online and offline operation, still performs the same step-response feature extraction, and still uses the Phi-4 RAG-based supervisor. The main addition is that the results are converted into a structured HTML dashboard after summary generation. 

### 2.2 Dashboard Template and Output

The script defines two dashboard paths:

- `index_template.html` as the HTML template,
- `index_report.html` as the generated dashboard report. 

After the summary CSV is produced, the script reads the summary data, converts it to JSON records, and injects those records into the HTML template at the placeholder `__DASHBOARD_DATA__`. The completed report is then saved as an HTML file and opened automatically in the browser. This means the dashboard can serve as a lightweight visualization layer for experiment results without requiring a separate server application. 

### 2.3 Improvements Added in the Dashboard Version

Compared with the first script, this version introduces some practical workflow improvements:

- it creates a **Source File Key** for each processed file,
- it supports **resuming from an existing summary CSV**,
- it prevents duplicate reprocessing in offline mode,
- it estimates processing time and remaining runtime during batch execution,
- it attempts safer summary saving through retry logic when the file is open elsewhere. 

These additions are especially useful when the system is used repeatedly in industrial experiments, where processing may be interrupted and resumed later.

### 2.4 Role of the Dashboard in the Rewinder System

The dashboard script turns raw analytical output into an operator-facing visualization layer. In practice, this is useful because the machine-side or digital twin-side interface can read the saved figures and summary values and present them in a form that is much easier to interpret than CSV files alone. Therefore, the dashboard version can be considered the **reporting and visualization layer** of the overall pipeline. 

## 3. Step 3 Code Before Training and After Training

The third script is the **MLOps training code** used after feature extraction and dataset preparation are complete. Its job is to train predictive models for key rewinder response metrics and save those models in a reproducible, versioned form for later deployment in the digital twin system. 

### 3.1 Purpose of the Training Script

This training script is designed for industrial use rather than only notebook-level experimentation. It performs the full machine-learning pipeline:

- loading the dataset from Excel,
- filtering and cleaning the data,
- scaling the input features,
- splitting the dataset into train, validation, and test sets,
- training three separate PyTorch regressors,
- evaluating the models,
- saving models, scalers, reports, and configuration files into versioned folders. 

### 3.2 Inputs and Target Variables

The training pipeline uses four main input features:

- **Web Speed (mm/s)**,
- **Kp**,
- **Ki**,
- **Rewinder roll diameter (mm)**. 

It trains three separate models to predict the following outputs:

- **Overshoot (Peak 0–5s)**,
- **t90 (s)**,
- **tau (s)**. 

This structure aligns directly with the feature-extraction pipeline, where these targets were previously calculated from the raw machine data.

### 3.3 Dataset Filtering Before Training

Before training begins, the script filters the dataset using practical engineering constraints. In the provided code, the active filtering conditions are:

- diameter between **110 mm and 200 mm**,
- `t90 <= 6.0 s`. 

Rows with missing values in the modeling columns are removed, and the filtered dataset snapshot is saved to disk for reproducibility. This means the training stage always documents exactly which data was used in each model run. 

### 3.4 Dataset Audit Before Training

Before actual training, the script can call Phi-4 to perform a **dataset audit**. The model is asked to examine dataset coverage, balance, risk of bias, outlier behavior, and overall suitability for machine learning. If the dataset is judged as poor quality, the pipeline can stop before wasting time on unreliable training. 

This is useful because it adds an additional quality-control layer before the expensive training process begins.

### 3.5 Data Splitting and Scaling

The script uses a **70/15/15 split** for train, validation, and test data. A `StandardScaler` is fitted only on the training set and then applied to validation and test sets. The scaler itself is saved as a reusable artifact so that future inference can follow the exact same preprocessing steps. 

### 3.6 PyTorch Model Architecture

The training code defines an `MLPRegressor` consisting of several fully connected layers with ReLU activation and dropout regularization. Separate models are trained for each target variable rather than using a single multi-output model. This makes the system simpler to interpret and easier to replace or improve target by target. 

Early stopping is included, and training is controlled by configurable parameters such as epoch count, learning rate, batch size, patience, and minimum improvement threshold. This is consistent with an industrial MLOps design where model stability and reproducibility are important. 

### 3.7 Evaluation After Training

After training, each model is evaluated on train, validation, and test sets using:

- **R²**,
- **MAE**,
- **RMSE**. 

The script also generates **predicted-versus-actual plots** for the test set and saves those figures in the report folder. These visualizations help confirm whether the models are learning the response trends correctly and whether the predictions remain close to the ideal diagonal relationship. 

### 3.8 Versioning and Artifact Saving

A major strength of this training script is its version-control structure. Each run creates a new folder such as `vN_timestamp`, and inside that folder the system stores:

- model weights,
- scaler,
- filtered dataset snapshot,
- configuration file,
- coverage report,
- JSON training summary,
- comparison report with the previous run,
- training plots,
- run log. 

The script also updates a `LATEST_RUN.txt` pointer so the newest model version can be found easily by the deployment pipeline. 

### 3.9 LLM Support After Training

The same training code uses Phi-4 again after model training to interpret the training outcome. The LLM is asked to comment on:

- overall model quality,
- overfitting risk,
- weak targets,
- recommendations for improvement. 

This means the LLM is not only used at the feature-extraction stage, but also at the training stage as a support layer for interpreting ML performance.

### 3.10 Deployment Decision After Training

Finally, the script includes a **training decision gate** that determines whether each model should be:

- **DEPLOY**,
- **IMPROVE**, or
- **RETRAIN**. 

This decision is based on model performance metrics such as test R², generalization gap, MAE, and RMSE. Therefore, the training script does not simply output models; it also helps decide whether those models are ready for practical integration into the rewinder digital twin.

## 4. Overall Software Meaning in the Rewinder Project

Taken together, these three scripts form a connected pipeline for rewinder intelligent control research and future autonomous operation.

In the first stage, the system reads machine response files and extracts physically meaningful features such as tau, t90, overshoot, and settling time. It then uses deterministic logic plus LLM-assisted engineering narration to decide whether the observed response is acceptable. 

In the second stage, the same results are transformed into an HTML dashboard so that the extracted features and decision results can be visualized more easily for operators, researchers, or software integration into the digital twin interface.

In the third stage, the accumulated dataset is used for machine-learning model training. The trained models become the predictive layer of the digital twin, allowing future rewinder performance to be estimated in advance under new operating conditions. The MLOps design ensures that every run is versioned, evaluated, documented, and compared with earlier runs.

## 5. Conclusion

This software structure shows a clear transition from **raw machine data** toward **AI-assisted monitoring**, **visual reporting**, and **predictive model training**. The first code provides intelligent feature extraction and LLM-supported engineering reasoning. The second code extends that pipeline into a dashboard-oriented reporting system. The third code builds the predictive MLOps layer that can support model deployment in the rewinder digital twin environment. Together, they represent a strong foundation for future AI-agent-driven and semi-autonomous rewinder operation. 
