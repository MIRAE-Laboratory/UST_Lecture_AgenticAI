# PDF Reconstructor — Agentic AI 기반 향상 방안 (wayofenhance.md)

> 이 문서는 현재 구현된 PDF OCR · 번역 · 재조판 앱(`reconstructed1.md` 기준)을  
> Agentic AI 강의(miraelab.ai/UST_Lecture_AgenticAI)에서 설명한 방법론으로  
> 어떻게 향상시킬 수 있는지를 정리한 설계 가이드입니다.

---

## 1. 현재 시스템의 한계 (As-Is)

현재 구현된 시스템은 Streamlit 기반의 단일 모놀리식 앱으로, 사용자가  
탭을 순서대로 누르거나 All-in-One 파이프라인 버튼을 클릭하는 **정적 워크플로우(Static Workflow)**  
방식으로 동작한다. 각 단계(추출 → 번역 → 재조판)는 미리 정해진 순서로  
실행되며, 중간 결과를 LLM이 스스로 평가하거나 경로를 재결정하는 기능이 없다.

핵심 한계:
- 추출 오류가 발생해도 자동 재시도 또는 전략 전환이 없음
- 번역 품질을 자체 평가하고 재번역하는 루프가 없음
- Q&A 어시스턴트가 단일 LLM 호출로 답변을 생성하며, 근거 검증 단계가 없음
- 각 단계가 독립 도구로 호출되지 않고 순차 함수 호출 방식으로 결합됨

---

## 2. Agentic AI 강의에서 제시하는 핵심 패턴

강의(UST Lecture: AgenticAI)에서 설명된 방식을 이 앱에 적용 가능한 패턴으로 정리한다.

### 2.1 Reflection (자기 반성 루프)

에이전트가 자신의 출력 결과를 스스로 평가하고, 기준을 충족하지 못하면  
전략을 수정하여 재시도하는 패턴이다.

**현재 앱 적용 지점:**
- **OCR/추출 단계**: 추출된 Markdown 블록의 신뢰도(confidence)를 평가 LLM으로 검사.  
  누락 블록, 깨진 수식, 불완전한 캡션이 감지되면 해당 페이지만 Gemini Vision으로  
  재추출 요청 → 로컬 추출 실패 시 자동 fallback.
- **번역 단계**: 번역 완료 후 별도의 "Translation QC Agent"가 원문과 번역문을 비교하여  
  전문용어 오역, 용어집 위반 여부, 길이 팽창 과도 여부를 체크.  
  기준 미달 시 해당 블록만 재번역 프롬프트 호출.

```python
# 예시: Reflection 루프 구조
def translate_with_reflection(block, glossary, max_retries=3):
    for attempt in range(max_retries):
        translated = llm_translate(block, glossary)
        score = translation_qc_agent(block["text"], translated)
        if score["pass"]:
            return translated
        # 피드백을 다음 번역 프롬프트에 주입
        block["feedback"] = score["issues"]
    return translated  # 최대 재시도 후 최선의 결과 반환
```

---

### 2.2 Tool Calling (도구 호출 에이전트)

LLM이 직접 함수(도구)를 선택하고 호출하는 패턴으로,  
파이프라인 각 단계를 **명시적 도구(Tool)**로 등록하고  
오케스트레이터 에이전트가 상황에 맞는 도구를 선택하도록 한다.

**현재 앱 적용 지점:**

현재 All-in-One 파이프라인은 함수를 순서대로 호출하는 방식이다.  
이를 Tool Calling 방식으로 전환하면, 각 처리 단계가 독립 도구가 되고  
중앙 오케스트레이터가 문서 유형과 오류 상태를 보고 어떤 도구를 호출할지 결정한다.

```python
tools = [
    {"name": "local_text_extractor",   "when": "born-digital PDF"},
    {"name": "gemini_vision_ocr",      "when": "scanned PDF or low confidence"},
    {"name": "equation_ocr_tool",      "when": "equation block detected"},
    {"name": "glossary_translator",    "when": "translation block"},
    {"name": "qc_reflection_agent",    "when": "after translation"},
    {"name": "pdf_overlay_composer",   "when": "reconstruction step"},
]

# 오케스트레이터가 문서 상태를 보고 다음 도구를 동적 선택
orchestrator_agent.decide_next_tool(doc_state, tools)
```

**기대 효과:**  
- 스캔 PDF와 텍스트 PDF를 별도 조건문으로 분기하는 코드를 제거하고,  
  에이전트가 런타임에 최적 추출 도구를 자동 선택.
- 수식 블록 감지 시에만 equation OCR 도구를 호출하여 API 비용 절감.

---

### 2.3 Planning (계획 수립 에이전트)

복잡한 문서를 처리하기 전에 에이전트가 먼저 문서 구조를 분석하고  
최적의 처리 계획(Plan)을 수립한 뒤 실행하는 패턴이다.

**현재 앱 적용 지점:**
- 문서 업로드 직후, **Document Planner Agent**가 PDF를 스캔하여  
  "이 문서는 수식이 많은 수학 논문이므로 equation OCR 우선 적용" 또는  
  "이 문서는 2단 레이아웃이므로 column-aware reading order 적용"과 같이  
  페이지별 처리 전략을 JSON 플랜으로 생성.
- 플랜을 사용자에게 보여주고 승인 후 파이프라인 실행 → 반자동 검수 UI 구현.

```json
{
  "doc_type": "scanned_academic_paper",
  "layout": "two_column",
  "has_equations": true,
  "plan": [
    {"page": 1, "strategy": "gemini_vision_ocr", "equation_ocr": true},
    {"page": 2, "strategy": "local_pymupdf", "equation_ocr": false}
  ]
}
```

---

### 2.4 Agentic RAG (에이전틱 검색 증강 생성)

현재 Q&A 어시스턴트는 마크다운 컨텍스트를 LLM에 직접 주입하는 단순  
컨텍스트 주입 방식이다. 이를 **Agentic RAG**로 업그레이드하면 다음이 가능해진다.

- **반복 검색(Iterative Retrieval)**: 첫 검색 결과가 불충분하면 에이전트가  
  쿼리를 재작성하고 재검색을 자동 수행.
- **근거 검증(Grounding Verification)**: 생성된 답변을 Answer Verifier Agent가  
  문서 블록 ID와 대조하여 hallucination 여부 점검.
- **FAISS/벡터 인덱스 복원**: 설계서(`TotalPDF_reconstruct_WF.md`)에서 제안된  
  `embeddings/chunks.faiss` 구조를 실제 구현하여 대용량 문서에서의  
  검색 정확도 대폭 향상.

```python
# Agentic RAG 루프
def agentic_qa(user_query, vector_index, max_iterations=3):
    for i in range(max_iterations):
        rewritten_query = query_rewriter_agent(user_query, chat_history)
        retrieved_chunks = vector_index.search(rewritten_query, top_k=5)
        answer = llm_answer_agent(retrieved_chunks, user_query)
        verification = answer_verifier_agent(answer, retrieved_chunks)
        if verification["grounded"]:
            return answer
        user_query = verification["refined_query"]  # 다음 반복을 위한 쿼리 개선
    return answer
```

---

### 2.5 Multi-Agent 협업 구조

강의에서 강조된 **Supervisor + Specialist Agent** 패턴을 PDF 파이프라인에 적용한다.
[SupervisorAgent]
├── [IngestAgent] ← PDF 유형 판별 + 추출 전략 결정
├── [OCRAgent] ← 텍스트/수식/그림 추출 전문
├── [TranslationAgent] ← 용어집 반영 번역 + QC 반성 루프
├── [QAAgent] ← Agentic RAG 기반 질의응답
└── [ReconstructAgent] ← 레이아웃 복원 + PDF 출력

text

Supervisor가 각 전문 에이전트의 완료 상태와 신뢰도 점수를 취합하여  
다음 단계 실행 여부, 재시도 여부, 사람 검수 요청 여부를 결정한다.

**현재 Streamlit 앱에 단계적 적용 방법:**
1. 각 탭의 실행 함수를 독립 Agent 클래스로 래핑  
2. `SupervisorAgent`를 별도 모듈(`supervisor.py`)로 구현  
3. Streamlit 세션 상태(`st.session_state`)에 에이전트 상태를 JSON으로 유지  
4. 장기적으로 LangGraph 또는 AutoGen으로 오케스트레이션 프레임워크 전환

---

### 2.6 메모리 계층 분리 (Memory Architecture)

강의에서 제시한 **3종 메모리 분리** 구조를 현재 앱의 Q&A 어시스턴트에 적용한다.

| 메모리 유형 | 현재 앱 상태 | 개선 방안 |
|:---|:---|:---|
| **대화 메모리** | 마크다운 문자열로 누적 관리 | 최근 N turns만 슬라이딩 윈도우로 유지 |
| **문서 메모리** | 전체 MD를 컨텍스트로 주입 | FAISS 인덱스 + 섹션별 메타데이터 분리 저장 |
| **작업 메모리** | glossary.json으로 관리 | 번역 전략(직역/의역), 제외 규칙을 별도 `task_config.json`으로 관리 |

---

## 3. 단계별 구현 로드맵

### Phase A (단기: 현재 Streamlit 앱 내 적용)
- [x] 번역 단계에 Reflection 루프 추가 (QC Agent)
- [x] OCR 추출 신뢰도 점수 UI 표시 및 저신뢰 블록 재추출 버튼 추가
- [x] FAISS 벡터 인덱스 실제 구현 (`embedding_indexer` 모듈)

### Phase B (중기: Tool Calling 전환)
- [ ] 각 파이프라인 단계를 Tool 스키마로 등록
- [ ] 중앙 오케스트레이터 에이전트 구현 (`supervisor.py`)
- [ ] Agentic RAG 반복 검색 루프 Q&A에 적용

### Phase C (장기: Multi-Agent 프레임워크)
- [ ] LangGraph 또는 AutoGen 기반 멀티에이전트 전환
- [ ] Document Planner Agent 추가 (업로드 즉시 처리 전략 수립)
- [ ] Answer Verifier Agent로 hallucination 자동 검출
- [ ] 사람 검수 개입 지점(Human-in-the-Loop) 설계

---

## 4. 기대 효과 요약

| 향상 패턴 | 현재 한계 | 적용 후 기대 효과 |
|:---|:---|:---|
| Reflection Loop | 오역/추출 오류 수동 발견 | 자동 품질 검증 + 재처리 |
| Tool Calling | 고정 순서 파이프라인 | 문서 상태 기반 동적 도구 선택 |
| Planning Agent | 모든 문서에 동일 처리 | 문서 유형별 최적 전략 자동 수립 |
| Agentic RAG | 단순 컨텍스트 주입 | 반복 검색 + hallucination 검증 |
| Multi-Agent | 단일 앱 모놀리식 | 전문 에이전트 협업 + 병렬 처리 |
| Memory 분리 | 마크다운 일괄 주입 | 효율적 컨텍스트 관리 + 비용 절감 |

---

*작성일: 2026-06-12*  
*참고: TotalPDF_reconstruct_WF-2.md, reconstructed1.md, UST Lecture AgenticAI*