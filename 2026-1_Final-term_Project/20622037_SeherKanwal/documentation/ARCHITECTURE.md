# FinanceMentor AI — System Architecture

> A collection of architecture diagrams covering the full system design of the FinanceMentor AI platform.

---

## Table of Contents

1. [High-Level System Overview](#1-high-level-system-overview)
2. [Component Architecture](#2-component-architecture)
3. [Module Dependency Map](#3-module-dependency-map)
4. [AI Inference Pipeline](#4-ai-inference-pipeline)
5. [Data Flow — User Request Lifecycle](#5-data-flow--user-request-lifecycle)
6. [Data Storage Architecture](#6-data-storage-architecture)
7. [User Session State Model](#7-user-session-state-model)
8. [Market Data Pipeline](#8-market-data-pipeline)
9. [Portfolio Intelligence Flow](#9-portfolio-intelligence-flow)
10. [Adaptive Mode Architecture](#10-adaptive-mode-architecture)
11. [Cross-Module Navigation Graph](#11-cross-module-navigation-graph)
12. [Deployment Architecture](#12-deployment-architecture)

---

## 1. High-Level System Overview

The platform is organized into three distinct layers. The **Presentation Layer** handles all user-facing pages and the persistent sidebar. The **Intelligence Layer** manages AI reasoning, user profiling, and contextual explanation generation. The **Data Layer** handles both live external market feeds and local file persistence.

```mermaid
graph TB
    subgraph USER["👤 User Interface"]
        BROWSER["Web Browser\nlocalhost:8501"]
    end

    subgraph PRESENTATION["🖥️ Presentation Layer"]
        SHELL["Application Shell\nGlobal CSS · Navigation · Page Router"]
        SIDEBAR["AI Mentor Sidebar\nPersistent · Context-aware · Chatbot"]
        PAGES["11 Feature Pages\nDashboard · Learning · Roleplay · Tutor\nMarkets · News · Trading · Coach\nCrisis · Profile · Portfolio"]
    end

    subgraph INTELLIGENCE["🧠 Intelligence Layer"]
        MENTOR_ENGINE["AI Mentor Engine\nState management · Behavior tracking\nExplanation generation · Chat routing"]
        LLM_INTERFACE["LLM Interface\nPrompt formatting · Connection health\nSingle-turn & multi-turn modes"]
    end

    subgraph DATA["💾 Data Layer"]
        OLLAMA["Local Ollama\nlocalhost:11434\nLLM Inference Engine"]
        YFINANCE["Yahoo Finance\nLive prices · OHLCV history\nNews articles"]
        PERSIST["Local JSON Files\nuser_state.json · portfolio.json"]
        SESSION["Browser Session State\nVirtual balances · Chat histories\nQuiz state · Checklist"]
    end

    BROWSER <--> SHELL
    SHELL --> SIDEBAR
    SHELL --> PAGES
    PAGES --> MENTOR_ENGINE
    SIDEBAR --> MENTOR_ENGINE
    MENTOR_ENGINE --> LLM_INTERFACE
    LLM_INTERFACE --> OLLAMA
    PAGES --> YFINANCE
    MENTOR_ENGINE --> PERSIST
    PAGES --> SESSION

    style USER fill:#0f172a,color:#94a3b8
    style PRESENTATION fill:#0f2a1a,color:#6ee7b7
    style INTELLIGENCE fill:#1a0f2a,color:#c4b5fd
    style DATA fill:#2a1a0f,color:#fcd34d
```

---

## 2. Component Architecture

A detailed breakdown of every component in the system, grouped by layer, and showing how they relate to one another.

```mermaid
graph TD
    subgraph SHELL_COMP["Application Shell — main.py"]
        NAV["Page Router\n(11 registered pages)"]
        GCSS["Global CSS Injector\nDark theme · Button styles · Card classes"]
        MENTOR_MOUNT["Mentor Sidebar Mount\n(called once — renders on all pages)"]
    end

    subgraph UTIL_COMP["Utility Layer"]
        subgraph MENTOR_MOD["AI Mentor Engine"]
            STATE_MGR["User State Manager\nLoad · Default · Save"]
            BEHAVIOR["Behavior Tracker\nTimestamped action log (max 100)"]
            EXPLAINER["Explanation Generator\nContext + Data → AI prose + popover"]
            SIDEBAR_UI["Sidebar Renderer\nMode toggle · Chat window · Clear"]
            HEADER_UI["Page Header Component\nStandard dark-gradient header"]
        end

        subgraph LLM_MOD["LLM Interface"]
            HEALTH["Connection Health Check\nPing Ollama before every call"]
            SINGLE["Single-Turn Query\nPrompt + system prompt → response"]
            MULTI["Multi-Turn Chat\nMessage history → formatted prompt → response"]
        end
    end

    subgraph PAGE_COMP["Feature Pages"]
        P_DASH["Dashboard"]
        P_LEARN["Learning Paths"]
        P_ROLE["Roleplay Engine"]
        P_TUT["Personal Tutor"]
        P_MKT["Live Market Terminal"]
        P_NEWS["News Intelligence"]
        P_TRADE["Paper Trading"]
        P_COACH["Decision Coach"]
        P_CRISIS["Crisis Simulator"]
        P_PROF["My Mastery Profile"]
        P_PORT["Portfolio Tracker"]
    end

    NAV --> PAGE_COMP
    MENTOR_MOUNT --> SIDEBAR_UI
    PAGE_COMP --> STATE_MGR
    PAGE_COMP --> BEHAVIOR
    PAGE_COMP --> EXPLAINER
    PAGE_COMP --> HEADER_UI
    EXPLAINER --> SINGLE
    SIDEBAR_UI --> MULTI
    SINGLE --> HEALTH
    MULTI --> HEALTH
```

---

## 3. Module Dependency Map

Shows which shared resources and services each feature module depends on.

```mermaid
graph LR
    subgraph SHARED["Shared Services"]
        MS["AI Mentor Engine"]
        LLM["LLM Interface"]
        YF["Yahoo Finance"]
        PF["portfolio.json"]
        US["user_state.json"]
    end

    DASH["Dashboard"] --> MS & YF & PF
    LEARN["Learning Paths"] --> MS & LLM & US
    ROLE["Roleplay Engine"] --> MS & LLM & US
    TUT["Personal Tutor"] --> LLM
    MKT["Live Market Terminal"] --> MS & YF & PF
    NEWS["News Intelligence"] --> MS & LLM & YF & PF
    TRADE["Paper Trading"] --> YF
    COACH["Decision Coach"] --> MS & LLM
    CRISIS["Crisis Simulator"] --> LLM
    PROF["My Mastery Profile"] --> MS & LLM & YF & PF & US
    PORT["Portfolio Tracker"] --> MS & LLM & YF & PF & US
```

---

## 4. AI Inference Pipeline

Detailed view of how a prompt travels from a user action to an AI response and back to the UI.

```mermaid
sequenceDiagram
    box Presentation Layer
        participant U as 👤 User
        participant PAGE as Feature Page
    end
    box Intelligence Layer
        participant ME as Mentor Engine
        participant LLM as LLM Interface
    end
    box External
        participant OL as Ollama (localhost:11434)
    end

    U->>PAGE: Triggers AI action\n(Explain / Quiz / Chat / Report)
    PAGE->>ME: Request with context_type + data_summary

    ME->>ME: Retrieve user mode (Beginner/Advanced)
    ME->>ME: Build structured prompt:\n• System persona\n• User mode\n• Page context\n• Data summary

    ME->>LLM: Forward prompt + system instruction
    LLM->>OL: Health check ping
    OL-->>LLM: 200 OK

    LLM->>OL: POST /api/generate\n{model, prompt, system, stream:false}
    OL-->>LLM: {response: "...text..."}

    LLM-->>ME: Raw response text
    ME->>ME: Append to sidebar chat history
    ME->>ME: Log behavior action

    ME-->>PAGE: Response text
    PAGE->>U: Render info box + popover chat window
    U->>PAGE: Types follow-up question
    PAGE->>LLM: chat_with_ollama(message history)
    LLM->>OL: POST /api/generate (formatted conversation)
    OL-->>LLM: Response
    LLM-->>PAGE: Reply text
    PAGE->>U: Render in popover chat
```

---

## 5. Data Flow — User Request Lifecycle

End-to-end flow from opening the app to a fully rendered, AI-enriched page.

```mermaid
flowchart TD
    A(["User opens app"]) --> B["Application Shell loads\nInjects global CSS\nRegisters 11 pages"]
    B --> C["Mentor Engine initializes\nChecks user_state.json"]

    C --> D{First launch?}
    D -->|Yes| E["Create default user_state.json\nSeed portfolio.json with 8 defaults"]
    D -->|No| F["Load saved state\n(name, mode, risk, history)"]
    E --> G
    F --> G

    G["Render Dashboard\n(default page)"] --> H["Fetch live prices\nYahoo Finance — 8 watchlist assets"]
    H --> I["Load portfolio.json\nCalculate P&L metrics"]

    I --> J{First briefing today?}
    J -->|Yes| K["AI generates daily briefing\nOllama single-turn query"]
    J -->|No| L["Show completion message"]
    K --> M
    L --> M

    M["Render full dashboard UI\nPulse cards · Portfolio Intel\nMentor Recommendation · Alerts"]
    M --> N(["User interacts with page"])
    N --> O{Action type?}
    O -->|Explain button| P["AI explanation + popover"]
    O -->|Navigation| Q["Load new page\nContext updates in Mentor Engine"]
    O -->|Chat input| R["Multi-turn AI response\nIn sidebar or popover"]
    O -->|Data action| S["Save to JSON / session state\nPage rerenders"]
```

---

## 6. Data Storage Architecture

The system uses a two-tier storage model: persistent file-based storage (survives browser refresh) and session state (in-memory, resets on refresh).

```mermaid
graph TD
    subgraph DISK["💾 Persistent — data/ folder"]
        US["user_state.json"]
        PF["portfolio.json"]
        ND["news_db.json\n(reserved)"]

        US --> US_FIELDS["Fields:\nuser_name\napp_mode\nrisk_profile\nlearning_progress\ncompleted_lessons\nbehavior_history\nlast_daily_briefing"]

        PF --> PF_FIELDS["Each holding:\nticker (symbol)\nqty (units held)\nbuy_price (avg cost)\nadded (date string)"]
    end

    subgraph MEMORY["🔁 Session State — browser memory"]
        BAL["portfolio_balance\n($10,000 virtual)"]
        HOLD["portfolio_holdings\n{ticker → qty dict}"]
        TCHAT["tutor_messages\n(Personal Tutor history)"]
        RPHIST["rp_history\n(Roleplay conversation)"]
        MCHAT["mentor_chat\n(Sidebar chat window)"]
        CONCEPTS["learned_concepts\n(Checklist selections)"]
        QUIZ["quiz_active\n(Active quiz per lesson)"]
        CTX["current_context\n(Active page context)"]
    end

    subgraph WRITERS["📝 Who writes to storage"]
        ME_W["Mentor Engine\n→ user_state.json"]
        PROF_W["My Mastery Profile\n→ portfolio.json"]
        PORT_W["Portfolio Tracker\n→ portfolio.json"]
        TRADE_W["Paper Trading\n→ session state only"]
    end

    ME_W --> US
    PROF_W --> PF
    PORT_W --> PF
    TRADE_W --> BAL & HOLD
```

---

## 7. User Session State Model

How user identity and progress is initialized, updated, and persisted throughout the application lifecycle.

```mermaid
stateDiagram-v2
    [*] --> AppStart

    AppStart: App opens in browser
    AppStart --> CheckState

    CheckState: Check user_state.json
    CheckState --> NewUser: File not found
    CheckState --> ReturningUser: File found

    NewUser: Create default profile
    NewUser --> SessionReady

    ReturningUser: Load saved profile into session
    ReturningUser --> SessionReady

    SessionReady: Session initialized\n(state, mode, chat windows, context)

    SessionReady --> ActiveSession

    state ActiveSession {
        [*] --> Idle
        Idle --> BehaviorLog: User takes action
        BehaviorLog: Action timestamped and appended
        BehaviorLog --> StateSave: Save to disk
        StateSave --> Idle

        Idle --> ProfileUpdate: User changes name / risk
        ProfileUpdate --> StateSave

        Idle --> ProgressUpdate: Lesson mastered / concept checked
        ProgressUpdate --> StateSave

        Idle --> ModeToggle: Beginner ↔ Advanced
        ModeToggle --> StateSave
        StateSave --> PageReload: Rerun for immediate effect
        PageReload --> Idle
    }

    ActiveSession --> [*]: Browser closed / refreshed\nPersisted state survives\nSession state resets
```

---

## 8. Market Data Pipeline

How real-time market data moves from Yahoo Finance into the application UI and AI context.

```mermaid
flowchart LR
    subgraph SOURCE["🌐 Yahoo Finance"]
        PRICE["Price API\nCurrent price · OHLCV history"]
        NEWS_API["News API\nLatest headlines per ticker"]
    end

    subgraph CACHE["⚡ Cache Layer"]
        C1["Price data cache\nTTL: 60–90 seconds"]
        C2["News summary cache\nTTL: 120 seconds"]
        C3["AI news summary cache\nTTL: 300 seconds per headline"]
    end

    subgraph CONSUMERS["📄 Consuming Modules"]
        DASH_C["Dashboard\nWatchlist pulse cards"]
        MKT_C["Live Market Terminal\nFull OHLCV chart data"]
        NEWS_C["News Intelligence\nArticle cards + AI summaries"]
        PORT_C["Portfolio Tracker\nP&L calculations"]
        PROF_C["My Mastery Profile\nPortfolio news feed"]
        TRADE_C["Paper Trading\nLive execution price"]
    end

    PRICE --> C1
    NEWS_API --> C2
    C2 --> C3

    C1 --> DASH_C
    C1 --> MKT_C
    C1 --> PORT_C
    C1 --> TRADE_C
    C2 --> NEWS_C
    C2 --> PROF_C
    C3 --> NEWS_C
    C3 --> PROF_C
```

---

## 9. Portfolio Intelligence Flow

How a user's portfolio holdings connect to live data, risk analysis, AI insights, and cross-module features.

```mermaid
graph TD
    PF["portfolio.json\n(source of truth)"]

    PF --> READ1["Dashboard\nSummary metrics + alerts"]
    PF --> READ2["Live Market Terminal\nMy Holdings tab charts"]
    PF --> READ3["Portfolio Tracker\nFull P&L + risk charts"]
    PF --> READ4["My Mastery Profile\nNews feed + AI briefing"]
    PF --> READ5["News Intelligence\nPortfolio News tab"]

    READ1 --> YF1["Fetch live prices\nfor each holding"]
    READ2 --> YF1
    READ3 --> YF1
    READ4 --> YF2["Fetch latest news\nper ticker"]
    READ5 --> YF2

    YF1 --> CALC["Calculate:\n• Current value\n• P&L ($ and %)\n• Day change %"]
    YF2 --> AISUM["AI summarizes\neach headline"]

    CALC --> ALERT["Auto-alerts\n> 3% day move → flag on dashboard\n> 40% concentration → warning\n> 60% tech exposure → warning"]
    CALC --> CHARTS["Risk charts\nSector donut · Concentration bar"]
    AISUM --> BRIEF["AI Portfolio Briefing\nSentiment · Highlights\nAction points · Discipline note"]

    WRITE1["Portfolio Tracker ➕"] --> PF
    WRITE2["My Mastery Profile ➕"] --> PF
```

---

## 10. Adaptive Mode Architecture

How the single Beginner / Advanced mode toggle propagates changes across the entire application simultaneously.

```mermaid
graph TD
    TOGGLE["🔄 Mode Toggle\n(Sidebar — persisted to user_state.json)"]

    TOGGLE --> PERSIST["Saved to disk\nSurvives across sessions"]
    TOGGLE --> RERUN["Page reloads immediately\nAll components re-evaluate mode"]

    RERUN --> CHARTS["📈 Chart Rendering\nBeginner → filled line chart\nAdvanced → candlestick + MA20 + volume"]

    RERUN --> TIPS["💡 Mentor Tip Banners\nBeginner → shown on chart pages\nAdvanced → hidden (assumed knowledge)"]

    RERUN --> AI_PROMPT["🧠 AI Prompt Content\nBeginner → analogies + simple bullets\nAdvanced → technical terms + metrics"]

    RERUN --> HEADER["📄 Page Headers\nDisplay current mode label\nReassures user of their context"]

    RERUN --> MENTOR_TONE["🦉 Sidebar Mentor Tone\nBeginner → educational + reassuring\nAdvanced → analytical + concise"]
```

---

## 11. Cross-Module Navigation Graph

Shows how each module connects to other modules through navigation shortcuts and action buttons.

```mermaid
graph LR
    DASH["📊 Dashboard"]
    LEARN["📚 Learning Paths"]
    ROLE["🎭 Finance Roleplay"]
    TUT["📘 Personal Tutor"]
    MKT["📈 Live Terminal"]
    NEWS["📰 News Intelligence"]
    TRADE["🏦 Paper Trading"]
    COACH["🧠 Decision Coach"]
    CRISIS["🔥 Crisis Simulator"]
    PROF["👤 My Mastery Profile"]
    PORT["💼 Portfolio Tracker"]

    DASH -->|"📚 Start Learning"| LEARN
    DASH -->|"🎭 High-Risk Roleplay"| ROLE
    DASH -->|"📈 Market Terminal"| MKT
    DASH -->|"🧠 Decision Coach"| COACH
    DASH -->|"Analyze [ticker]"| NEWS

    LEARN -->|"5+ concepts mastered"| ROLE

    NEWS -->|"🎭 Simulate Reaction"| ROLE
    NEWS -->|"⚖️ Check Exposure"| PORT

    PROF -->|"➕ Go to Portfolio Tracker"| PORT

    DASH -->|"📊 Return"| DASH

    style DASH fill:#10b981,color:#fff
    style ROLE fill:#7c3aed,color:#fff
    style LEARN fill:#1d4ed8,color:#fff
    style PORT fill:#b45309,color:#fff
    style NEWS fill:#0e7490,color:#fff
```

---

## 12. Deployment Architecture

How the application runs locally and what services must be active for full functionality.

```mermaid
graph TD
    subgraph DEV_MACHINE["💻 Local Machine"]
        subgraph STREAMLIT_PROC["Streamlit Process\npython -m streamlit run main.py"]
            APP["FinanceMentor AI\nlocalhost:8501"]
        end

        subgraph OLLAMA_PROC["Ollama Process\nollama run aya"]
            OL_SRV["Ollama Server\nlocalhost:11434"]
            MODEL["LLM Model\n(aya by default)"]
            OL_SRV --> MODEL
        end

        subgraph FILE_SYSTEM["File System"]
            VENV["myenv/\nPython virtual environment"]
            DATA["data/\nuser_state.json\nportfolio.json\nnews_db.json"]
            PAGES_DIR["pages/\n11 page modules"]
            UTILS_DIR["utils/\nmentory.py · llm_agent.py"]
        end
    end

    subgraph INTERNET["🌐 Internet (read-only)"]
        YF_EXT["Yahoo Finance API\nPrices + News"]
    end

    BROWSER["🌍 Web Browser"] --> APP
    APP --> OL_SRV
    APP --> YF_EXT
    APP --> DATA
    VENV --> APP

    subgraph STARTUP["▶️ Startup Sequence"]
        S1["1. Activate virtual environment\nmyenv\\Scripts\\activate"]
        S2["2. Start Ollama with model\nollama run aya"]
        S3["3. Launch Streamlit\npython -m streamlit run main.py"]
        S4["4. Open browser\nlocalhost:8501"]
        S1 --> S2 --> S3 --> S4
    end

    subgraph HEALTH["🟢 Required Services"]
        H1["✅ Streamlit — localhost:8501\nCore app process"]
        H2["✅ Ollama — localhost:11434\nRequired for all AI features"]
        H3["✅ Internet — Yahoo Finance\nRequired for live prices and news"]
        H4["✅ data/ folder\nAuto-created on first launch"]
    end
```

---

*FinanceMentor AI — Architecture Document — Version 1.0 — April 2026*
