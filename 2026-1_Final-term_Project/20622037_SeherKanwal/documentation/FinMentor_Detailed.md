# FinMentor – AI-Powered Financial Learning Assistant

## 1. Motivation
Financial markets are increasingly accessible through mobile apps and online platforms. However, accessibility does not guarantee understanding.

- Beginners often lack financial literacy
- Investment decisions are influenced by hype and misinformation
- Lack of guidance leads to poor outcomes and financial loss

**Objective:**  
To create a system that makes financial learning:
- Simple
- Interactive
- Practical
- Decision-oriented

---

## 2. Problem Statement

Current financial ecosystems have major gaps:

- Users invest without understanding market dynamics
- Platforms focus on raw data instead of explanations
- Learning resources are separate from real-world trading tools

### Core Problem:
> Users have access to data, but lack understanding and guidance.

---

## 3. Proposed Solution: FinMentor

FinMentor is an AI-powered financial assistant designed to bridge this gap.

### Key Capabilities:
- Real-time data + AI explanations
- Integrated learning + decision support
- Scenario-based practice
- Personalized insights

---

## 4. System Architecture

```mermaid
flowchart TD
    User --> UI[Streamlit Web Interface]
    UI --> Market[Market Module]
    UI --> News[News Module]
    UI --> Portfolio[Portfolio Module]
    UI --> Learning[Learning Module]

    Market --> DataAPI[yfinance API]
    News --> DataAPI
    Portfolio --> DataAPI

    Market --> AI[LLM - Ollama + Qwen]
    News --> AI
    Portfolio --> AI
    Learning --> AI

    AI --> Output[Insights / Explanations / Feedback]
    Output --> UI
    UI --> User
```

---

## 5. Core Features

### 5.1 Market Analysis
- Real-time stock & crypto tracking
- AI explains trends
- Simplifies complex charts

```mermaid
flowchart LR
    MarketData --> Charts
    Charts --> AI
    AI --> Explanation
    Explanation --> User
```

---

### 5.2 News Analysis
- Summarizes financial news
- Detects sentiment
- Links news to market impact

```mermaid
flowchart LR
    NewsArticles --> NLP
    NLP --> Summary
    NLP --> Sentiment
    Summary --> User
    Sentiment --> User
```

---

### 5.3 Portfolio Analysis
- Tracks investments
- Identifies risks
- Links relevant news

```mermaid
flowchart LR
    PortfolioData --> AI
    AI --> RiskAnalysis
    AI --> NewsMapping
    RiskAnalysis --> User
    NewsMapping --> User
```

---

### 5.4 Interactive Learning
- Chat-based learning
- Step-by-step explanations
- Quiz generation

```mermaid
flowchart LR
    User --> Chat
    Chat --> AI
    AI --> Explanation
    AI --> Quiz
    Quiz --> User
```

---

### 5.5 Roleplay & Scenario-Based Learning
- Simulates real-world situations
- Trains decision-making

```mermaid
flowchart LR
    Scenario --> Decision
    Decision --> AI
    AI --> Feedback
    Feedback --> User
```

---

## 6. Implementation

- Streamlit (Frontend)
- yfinance API (Data)
- Plotly (Visualization)
- Ollama + Qwen (AI)

```mermaid
sequenceDiagram
    participant User
    participant UI
    participant API
    participant AI

    User->>UI: Request
    UI->>API: Fetch Data
    API->>UI: Return Data
    UI->>AI: Process Query
    AI->>UI: Insights
    UI->>User: Display Results
```

---

## 7. Conclusion

FinMentor integrates:
- Data
- Learning
- Decision-making

into a single intelligent platform.
