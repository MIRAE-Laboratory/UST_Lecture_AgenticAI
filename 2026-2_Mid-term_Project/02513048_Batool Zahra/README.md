Nematode 18S & 28S Primer Scout

 Project Description

Nematode 18S & 28S Primer Scout is a Python Streamlit application that helps researchers identify potential PCR primer sequences from scientific PDF articles related to nematode molecular research.

The application combines rule-based primer extraction with optional Gemini AI-assisted analysis to help researchers interpret possible 18S and 28S ribosomal DNA primer candidates.

Features

- Upload scientific PDF documents.
- Extract text from research papers using PyMuPDF.
- Search for 18S, 28S, SSU, LSU, and PCR primer information.
- Identify possible DNA primer sequences using regular expressions.
- Display possible 18S and 28S rRNA targets.
- Show PDF page numbers and surrounding text for manual verification.
- Analyze detected candidates using Google Gemini AI.
- Provide AI-assisted reasoning about target genes, evidence, uncertainties, and verification requirements.
- Handle missing API keys, unavailable candidates, and AI service errors.

## Requirements

- Python 3
- Streamlit
- PyMuPDF
- google-genai
- python-dotenv
- A Google Gemini API key for optional AI analysis

## Installation

Open the project folder in VS Code and run:

```bash
python -m pip install -r requirements.txt
```

## Gemini API Configuration

Create a file named `.env` in the project folder and add:

```env
GEMINI_API_KEY=your_api_key_here
```

Replace `your_api_key_here` with your own Gemini API key.

Security: Never share your real API key or include the `.env` file in your submission ZIP.

The basic PDF extraction and primer detection features can work without a Gemini API key. The optional AI analysis requires a valid key and access to a supported Gemini model.

## How to Run

Run the following command in the VS Code terminal:

```bash
python -m streamlit run app.py
```

The application will open in your web browser.

 How to Use

1. Upload a scientific PDF article related to nematode molecular research.
2. Review the extracted text and primer-related passages.
3. Examine the detected DNA primer sequences.
4. Check their possible 18S or 28S classifications and source PDF pages.
5. Click Analyze Primers with Gemini to request AI-assisted interpretation.
6. Review Gemini's explanations, uncertainty assessments, and verification suggestions.
7. Verify every candidate against the original research article before laboratory use.

 Technical Approach

The application uses Python, Streamlit, PyMuPDF, and regular expressions for initial PDF processing and primer candidate extraction.

Google Gemini provides an optional second-stage analysis of the extracted candidate sequences and their surrounding text. The system is a human-in-the-loop AI-assisted research workflow, not a fully autonomous experimental validation system.

Limitations

- Scanned PDFs without searchable text may require OCR.
- PDF formatting may cause incorrect or incomplete sequence extraction.
- DNA-like sequences may be incorrectly identified as primers.
- Rule-based 18S and 28S classifications may be ambiguous.
- Gemini may make incorrect or unsupported interpretations.
- Gemini analysis requires internet access, a valid API key, and model availability.
- The application does not experimentally validate primer specificity, amplification efficiency, or PCR suitability.

All results require manual verification against the original publication before laboratory use.

 Future Improvements

Future versions could integrate biological sequence databases, primer validation tools, improved table extraction, and structured result export.