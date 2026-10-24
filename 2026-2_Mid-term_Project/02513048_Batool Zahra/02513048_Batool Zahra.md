Nematode 18S & 28S Primer Scout

 An AI-Assisted Research Tool for PCR Primer Identification from Scientific Literature

Student Name: Batool Zahra  
Student ID:02513048  
Course: Agentic AI  
Assignment: Mid-term Project (2026-2)  
Institution: University of Science and Technology (UST)

-

 1. Problem Statement

1.1 What problem does this project solve?

In nematode molecular research, PCR primers are essential for species identification, molecular characterization, and phylogenetic analysis. Two commonly used genetic markers are the 18S ribosomal RNA gene (small subunit, SSU) and the 28S ribosomal RNA gene (large subunit, LSU).

Researchers often need to find previously published primer sequences before planning molecular experiments. However, these sequences are usually located within scientific articles, particularly in the Materials and Methods sections.

Finding the relevant information can require reading multiple PDF documents and manually identifying:

- Primer names and nucleotide sequences.
- Forward and reverse primer information.
- Target genes such as 18S or 28S rRNA.
- The original article and page containing the information.
- Evidence supporting the proposed target gene.

This process can be time-consuming and may lead to transcription mistakes or confusion when different authors use terminology such as SSU, LSU, 18S, and 28S.

 1.2 Why does this problem matter?

As a researcher working with nematode literature, I wanted to reduce the repetitive work involved in locating PCR primer information.

I developed Nematode 18S & 28S Primer Scout, a Streamlit-based application that combines automated PDF text extraction, rule-based primer detection, and Gemini AI-assisted interpretation.

The application is intended to help researchers locate potential primer sequences more efficiently while preserving human responsibility for scientific verification.

 1.3 Proposed solution

The application allows a researcher to upload a scientific PDF article.

It automatically extracts text, searches for molecular biology keywords, identifies DNA-like sequences near primer-related passages, and suggests possible 18S or 28S targets.

The researcher can then activate the **Gemini AI Primer Analyst** to receive additional explanations of the candidate sequences, including supporting evidence, uncertainties, and potential extraction errors.

The application does not claim to experimentally validate PCR primers. Its purpose is to support literature searching and preliminary interpretation.



 2. Target Users

2.1 Primary users

The application is designed for:

- Graduate students working in nematology or molecular biology.
- Researchers studying nematode taxonomy and phylogenetics.
- Scientists searching published literature for PCR primers.
- Laboratory researchers reviewing 18S and 28S primer information.

 2.2 User context

The intended users regularly work with scientific PDF articles, molecular protocols, nucleotide sequences, and published primer information.

They may not have programming experience.

Therefore, the application uses a simple browser-based Streamlit interface that allows researchers to upload a document and inspect results without writing code.

2.3 User needs

The users need a tool that can:

1. Reduce the time spent searching scientific articles.
2. Identify candidate primer sequences automatically.
3. Suggest whether a candidate targets 18S or 28S rRNA.
4. Explain why a target gene was suggested.
5. Display the original PDF page and supporting text.
6. Clearly indicate uncertainty rather than presenting guesses as confirmed facts.

Feature	                                         Description	                                                                                                       Priority
PDF Upload	                                Upload a scientific research article in PDF format	                                                                        Must-have
PDF Text Extraction	                        Extract readable text using PyMuPDF	                                                                                        Must-have
Keyword Search	                            Search for 18S, 28S, SSU, LSU, PCR, and primer-related terminology	                                                        Must-have
Primer Sequence Detection	                Identify potential nucleotide sequences using regular expressions                                                           Must-have
Preliminary Target Classification	        Suggest 18S, 28S, or Unclear using known sequences and nearby text	                                                        Must-have
Source Traceability                     	Display PDF page numbers and surrounding passages	                                                                        Must-have
Gemini AI Primer Analyst	                Provide optional AI-assisted interpretation of detected candidates	                                                        Implemented
Uncertainty Reporting	                    Identify ambiguous classifications and possible extraction problems                                                      	Must-have
API Error Handling                      	Display messages when the API key is missing or Gemini analysis fails	                                                    Implemented
Database Verification	                    Compare candidates with external biological databases	                                                                    Future improvement
Export Results	                            save extracted information as CSV or Excel	                                                                                Future improvement

 3.1 PDF upload and processing

The user uploads a scientific PDF article through the Streamlit interface.

The application processes the document using PyMuPDF and extracts readable text from its pages.

The extracted text can be reviewed directly in the application.

 3.2 Primer information search

The application searches the extracted text for important molecular biology terms, including:

- 18S and 28S.
- SSU and LSU.
- PCR and primer.
- Forward and reverse primer terminology.

The application displays relevant passages and reports where matching information appears.

This allows the researcher to locate primer-related sections more quickly.

 3.3 Candidate primer sequence detection

Python regular expressions are used to identify DNA-like sequences that resemble PCR primers.

The application searches primer-related passages for nucleotide sequences within a defined length range.

For each detected candidate, it displays the sequence and the surrounding text.

These are candidate sequences, not automatically validated PCR primers.

3.4 Preliminary target gene classification

The application uses rule-based classification to suggest a possible target gene.

The classification considers known primer sequences and nearby references to 18S, 28S, SSU, and LSU.

The output may be:

- 18S rRNA (SSU) — evidence suggests a small-subunit target.
- 28S rRNA (LSU) — evidence suggests a large-subunit target.
- Unclear — available evidence is insufficient or ambiguous.

The Unclear label is important because it prevents the application from forcing an unsupported classification.

 3.5 Gemini AI Primer Analyst

The application includes an optional second-stage analysis powered by Google Gemini.

After the initial primer detection process, the researcher can click **Analyze Primers with Gemini**.

The application sends candidate information to the Gemini model, including:

- Candidate nucleotide sequence.
- PDF page number.
- Preliminary rule-based target classification.
- Surrounding source text.

Gemini is instructed to analyze the available evidence and provide:

1. A suggested 18S, 28S, or unclear target.
2. An explanation based on the provided PDF context.
3. Identification of possible extraction errors or missing information.
4. A verification status.
5. Warnings against treating the sequences as experimentally validated primers.

This feature adds contextual AI interpretation to the rule-based extraction process.

However, Gemini can make mistakes. Its analysis must be checked against the original publication.

 3.6 Source information and verification

The application displays the PDF page number, candidate sequence, preliminary classification, and nearby source text.

These details allow researchers to locate the information in the original article.

This is an important design decision because scientific evidence must remain traceable.

---

 4. Human–Computer Interaction Flow

 4.1 Application workflow
The application follows an AI-assisted, human-in-the-loop workflow.

Step 1: Upload a scientific PDF

The researcher opens the Streamlit application and uploads a research article related to nematode molecular biology.

Step 2: Extract document text

PyMuPDF extracts readable text from the uploaded PDF.

Step 3: Search for primer-related information

The application identifies relevant terms such as 18S, 28S, SSU, LSU, PCR, and primer.

Step 4: Detect candidate sequences

Regular expressions identify DNA-like sequences within primer-related passages.

Step 5: Apply preliminary classification

Rule-based analysis suggests whether candidates are associated with 18S, 28S, or an unclear target.

Step 6: Display evidence

The application displays the sequences, possible targets, PDF page numbers, and surrounding text.

Step 7: Request Gemini analysis

The researcher can optionally click Analyze Primers with Gemini to request contextual AI interpretation.

Step 8: Review the AI response

Gemini provides explanations, potential target classifications, uncertainty assessments, and verification guidance.

Step 9: Perform human verification

The researcher compares the extracted sequences and AI interpretations with the original scientific article before making laboratory decisions.

4.2 Human-in-the-loop design

The researcher remains responsible for selecting appropriate publications, evaluating candidate sequences, confirming target genes, and determining whether a primer is suitable for experimental use.

The AI does not independently approve primers for laboratory experiments.

The human researcher retains final decision-making authority.

 4.3 Why this interaction design was selected

The workflow separates automated detection from AI-assisted interpretation.

Rule-based extraction provides an initial structured list of candidates, while Gemini offers additional contextual reasoning when requested.

This approach allows researchers to use the basic extraction features without depending on an AI service for every step.

It also provides an opportunity to compare rule-based suggestions with AI interpretations.

---

 5. Technical Approach and System Architecture

 5.1 Technologies used

 Technology                       Purpose

 Python                       Main programming language 
 Streamlit                    Browser-based application interface 
 PyMuPDF                      Scientific PDF text extraction 
 Regular expressions          Candidate DNA primer detection 
 Rule-based classification    Preliminary 18S and 28S target suggestions 
 Google Gemini API            AI-assisted interpretation of candidate primers 
 google-genai                 Python package for accessing Gemini 
 python-dotenv                Loading API configuration from a local environment file 

 5.2 System architecture

The application consists of five main components.

Component 1: User Interface

Streamlit provides the interface for PDF uploading, result display, and the Gemini analysis button.

Component 2: PDF Processing

PyMuPDF reads the uploaded PDF and extracts text from individual pages.

Component 3: Primer Detection

Python searches the extracted text for relevant keywords and candidate nucleotide sequences.

Component 4: Preliminary Classification

Rule-based logic evaluates known sequences and surrounding terminology to suggest possible target genes.

Component 5: Gemini AI Analysis

When requested by the user, the application sends candidate sequences and source context to Gemini.

Gemini generates a text-based interpretation that is displayed in the application.

5.3 Agentic AI relevance

This prototype demonstrates an AI-assisted research workflow rather than a fully autonomous agent.

It combines deterministic extraction with an optional language-model analysis stage.

The researcher controls when AI analysis is performed and remains responsible for verifying the results.

The current application does not independently search external databases, conduct experiments, or autonomously validate primer specificity.

A future version could introduce more agentic capabilities through database retrieval, evidence comparison, and iterative verification.

 6.1 Scientific limitations

The application does not perform laboratory experiments or computational specificity validation.

It cannot guarantee:

- Correct amplification of the intended target.
- Primer specificity.
- Appropriate melting temperature.
- Absence of primer dimers.
- Successful PCR conditions.
- Correct identification of every primer in a publication.

AI-generated explanations are based on the information supplied to the model and may contain unsupported claims.

Therefore, extracted sequences and AI interpretations must be independently verified.


6. Success Criteria

The project is considered successful when:

1. The Streamlit application launches and operates using the documented installation instructions.
2. A researcher can upload a real scientific PDF article.
3. The application extracts readable text and identifies primer-related terminology.
4. Candidate DNA primer sequences are detected and displayed.
5. The application provides preliminary 18S, 28S, or Unclear classifications.
6. Each candidate includes its PDF page number and surrounding source text.
7. The user can request Gemini AI-assisted analysis using a button.
8. Gemini provides contextual explanations when the API service is available.
9. Missing API keys and AI service failures produce understandable error messages.
10. The workflow preserves human verification rather than presenting AI results as experimentally confirmed facts.

 7.1 Demonstration using real research data

The prototype was tested with a scientific PDF article related to nematode molecular research.

The application detected candidate sequences associated with 28S rRNA, including primers described in the article as D2A and D3B.

It also detected additional candidates that the rule-based method initially labeled Unclear.

During Gemini analysis, the model provided additional interpretations of the candidate sequences based on the extracted source context.

This demonstrated the value of combining automated extraction with contextual AI assistance.

The demonstration also showed that AI interpretation is not equivalent to scientific validation and that the original source must remain available for checking.

---

 7. Future Improvements

The current application provides a functional prototype, but several improvements could increase its usefulness and reliability.

7.1 Biological database integration

Future versions could compare extracted candidate sequences with trusted biological sequence databases.

This would help researchers check whether a sequence matches previously published primer information.

7.2 Improved PDF processing

OCR could be introduced to process scanned articles.

Improved table extraction could help detect primer sequences stored in complex PDF tables.

7.3 More advanced agentic workflow


8. Conclusion

Nematode 18S & 28S Primer Scout was developed to address a practical challenge in nematode molecular research: locating and interpreting published PCR primer information within scientific articles.

The application combines PDF text extraction, keyword searching, regular-expression-based sequence detection, preliminary target classification, and optional Gemini AI-assisted interpretation.

Its main contribution is a focused research workflow that connects automated information extraction with explainable, source-based review.

The inclusion of PDF page numbers, surrounding text, uncertainty labels, and human verification makes the system more useful for scientific literature analysis.

Although the prototype does not autonomously validate primers, it demonstrates how AI-assisted tools can reduce repetitive research tasks while keeping scientific judgment and final decisions under human control.