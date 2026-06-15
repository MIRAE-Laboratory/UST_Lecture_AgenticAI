# 🛠️ 1.13 연습문제 수식 검은색 렌더링 오류 수정 과정 기록

본 문서는 Hoffman 교재 38~43쪽 번역 및 재구성 과정에서 발생한 **"1.13 연습문제 공식이 검은색 raw LaTeX 텍스트로 나타나는 오류"**의 원인 분석 및 해결 과정을 기록한 문서입니다.

---

## 1. 🔍 문제 현상 (Problem Statement)
* **현상**: Hoffman 38~43쪽 작업 완료 후 생성된 재구성 PDF(`HoffmannCFD_rebuilt.pdf`)에서, 39페이지에 위치한 1.13 연습문제의 개별 문항(1.1 ~ 1.8) 수식들이 원본의 깔끔한 수학 기호가 아니라, `1.1 $$ 3\frac{\partial^2\phi}{\partial x^2} + ... = 0 $$`과 같은 raw LaTeX 소스 코드가 검은색 일반 텍스트로 흉하게 렌더링되어 출력되었습니다.
* **기대 결과**: 수식 영역의 배경은 원본 이미지/벡터 수식의 고해상도 그래픽이 그대로 유지되고, 그 위에 마우스 드래그 및 복사(`Ctrl+C`)가 가능한 무색투명한 LaTeX 텍스트 레이어가 오버레이되어야 합니다.

---

## 2. 🗃️ 원인 분석 (Root Cause Analysis)
1. **레이아웃 블록 분류 오류**:
   * `temp/HoffmannCFD_ws/json/page_0039_blocks_translated.json`을 분석한 결과, 문제 번호(예: `1.1`)와 공식(`$$ ... $$`)이 하나의 BBox 내에 묶여 있어 OCR 엔진에서 해당 블록의 타입을 `"equation"`이 아닌 `"exercise"`로 분류했습니다.
   * 반면, 41페이지의 1.13 본문 문제는 문맥과 공식 영역이 서로 분리되어 있어 `"exercise"`와 `"equation"`이 별도의 블록으로 올바르게 분리 및 분류되어 있었습니다.

2. **재구성 엔진(`md_to_pdf.py`)의 렌더링 분기 규칙**:
   * `md_to_pdf.py`의 `reconstruct_single_page_job`에서는 블록의 타입(`type`)을 기준으로 다음과 같이 렌더링을 처리합니다.
     * **`type == "equation"`**: Pass 1에서 흰색 마스킹 사각형을 그리지 않고 건너뜁니다(원본 수식 그림 보존). Pass 2에서 `render_mode=3`을 사용하여 무색투명한 텍스트로 LaTeX 문자열을 오버레이합니다.
     * **`type == "exercise"` 또는 `"paragraph"` 등**: Pass 1에서 해당 BBox 영역을 흰색으로 완전히 덮어씌웁니다(마스킹). Pass 2에서 `insert_textbox`를 통해 번역된 텍스트를 검은색 폰트로 인쇄합니다.
   * 이로 인해 `"type": "exercise"`로 분류된 1.1 ~ 1.8 문항들은 원본 수식 그림이 흰색으로 지워진 뒤, `1.1 $$ ... $$` 텍스트 전체가 검은색 일반 문자열로 인쇄되어 나타났던 것입니다.

---

## 3. 🛠️ 해결 방안 및 구현 (Solution & Implementation)
이 문제를 해결하기 위해, OCR JSON 데이터를 직접 수정하는 대신 **복원 시점에서 동적으로 블록 타입을 재분류(Override)하는 예외 처리 필터**를 구현했습니다.

### 📐 알고리즘적 필터 조건
블록의 타입이 `"equation"`이 아니더라도 다음 조건을 만족하면 복원 엔진이 동적으로 `"equation"`으로 취급하도록 수정합니다.
1. 텍스트 내에 LaTeX 수식 기호인 `$$`가 포함되어 있어야 합니다.
2. 수식(`$$ ... $$`)을 제외한 나머지 텍스트 영역(예: `1.1`, `(a)` 등)이 매우 짧거나(15자 미만) 숫자, 마침표, 괄호, 공백 등으로만 구성되어 있어야 합니다.

### 💻 코드 수정 (`PDFConvert/md_to_pdf.py`)
`reconstruct_single_page_job` 함수 내부에 블록 레이아웃 데이터를 로드한 직후, 위 필터 조건을 적용하는 동적 오버라이드 코드를 추가했습니다.

```python
# md_to_pdf.py (Line 320 ~ 340)

        blocks = []
        if os.path.exists(translated_json_path):
            with open(translated_json_path, "r", encoding="utf-8") as f:
                blocks = json.load(f)
        elif os.path.exists(layout_json_path):
            with open(layout_json_path, "r", encoding="utf-8") as f:
                blocks = json.load(f)
                
        if not blocks:
            # Save the unmodified single page
            doc.save(temp_output_path, garbage=3, deflate=True)
            doc.close()
            return page_num, temp_output_path
            
        # [신규 추가] 공식이 포함된 exercise/paragraph 블록을 equation으로 동적 재분류
        for b in blocks:
            btype = b.get("type", "paragraph")
            text = b.get("text_translated", b.get("text", "")).strip()
            if btype != "equation" and "$$" in text:
                import re
                text_no_formulas = re.sub(r'\$\$.*?\$\$', '', text, flags=re.DOTALL).strip()
                if not text_no_formulas or (re.match(r'^[0-9\.\(\)\s\-a-zA-Z,]+$', text_no_formulas) and len(text_no_formulas) < 15):
                    b["type"] = "equation"
                    
        # Merge adjacent blocks first to consolidate split paragraph parts
        blocks = merge_layout_blocks(blocks)
```

---

## 4. 🧪 결과 검증 (Verification)
1. **재구성 수행**: 수정된 `md_to_pdf.py`를 기반으로 38~43페이지에 대해 로컬 재구성 스크립트를 재구동했습니다.
2. **블록 매핑 확인**: 39페이지의 `p39_b4` ~ `p39_b12` 블록들이 런타임에 성공적으로 `"equation"` 타입으로 승격되어 처리되었습니다.
3. **렌더링 결과**:
   * 원본 PDF의 1.13 연습문제 수식 영역이 흰색 사각형으로 가려지지 않고 온전히 보존되었습니다.
   * 그 위에 투명하게 올라간 LaTeX 오버레이 덕분에 수학 기호들을 마우스 드래그하여 정상적으로 복사(`Ctrl+C`)할 수 있게 되었습니다.
