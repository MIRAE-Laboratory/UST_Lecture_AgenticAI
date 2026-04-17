⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

GEMINI_MODEL=gemini-2.5-flash-lite
import streamlit as st
import pandas as pd
from io import BytesIO
import tempfile
import os

# Title
st.title("🧪 LabBuddy R&D Agent")
st.markdown("**AI-powered literature & experiment organizer for researchers**")

# Sidebar for instructions
with st.sidebar:
    st.header("📋 How to use")
    st.markdown("""
    1. Upload papers (PDF), notes (TXT), data (CSV/Excel)
    2. AI extracts key info
    3. Review summaries
    4. Generate reports/tables
    """)
    model_choice = st.selectbox("LLM Model", ["Gemini", "OpenAI", "Ollama"])

# File uploaders
pdf_files = st.file_uploader("📄 Upload PDF papers", type="pdf", accept_multiple_files=True)
note_files = st.file_uploader("📝 Upload experiment notes", type=["txt", "md"])
data_files = st.file_uploader("📊 Upload data (CSV/Excel)", type=["csv", "xlsx"], accept_multiple_files=True)

# Process button
if st.button("🚀 Analyze & Summarize", type="primary"):
    if not (pdf_files or note_files or data_files):
        st.warning("Please upload at least one file!")
    else:
        with st.spinner("AI processing your research materials..."):
            # Placeholder for PDF/text extraction (use pymupdf in real app)
            summaries = []
            for pdf in pdf_files:
                summaries.append(f"**{pdf.name}:**\nObjective: Adsorption performance analysis\nMethods: Porous carbon synthesis\nResults: High Xe/Kr selectivity")
            
            for note in note_files:
                summaries.append(f"**{note.name}:**\nExtracted conditions: Temp 500-750°C, Samples: PVDF-derived")
            
            # Data preview
            if data_files:
                for data in data_files:
                    df = pd.read_excel(data) if data.name.endswith('xlsx') else pd.read_csv(data)
                    st.dataframe(df.head())
            
            st.success("✅ Analysis complete!")
            
            # Display summaries
            for summary in summaries:
                st.markdown(summary)

# Comparison table section
st.header("🔍 Comparative Analysis")
col1, col2 = st.columns(2)
with col1:
    if st.button("Generate Comparison Table"):
        comparison_data = {
            "Sample": ["PVDF-500", "PVDF-750", "Mullite"],
            "Xe Adsorption (mmol/g)": [2.1, 3.5, 1.8],
            "Kr Selectivity": [15, 22, 12],
            "Temp (°C)": [500, 750, 1000]
        }
        df_comp = pd.DataFrame(comparison_data)
        st.dataframe(df_comp, use_container_width=True)

# Report generation
st.header("📄 Generate Report Draft")
report_prompt = st.text_area("Enter report focus (e.g., 'Xe adsorption comparison')", 
                            "Summarize adsorption performance across samples")
if st.button("Create Draft"):
    st.markdown("""
    ### Executive Summary
    The analysis shows PVDF-750°C sample exhibits superior Xe/Kr adsorption (3.5 mmol/g) 
    with 22 selectivity ratio, outperforming baseline mullite.
    
    **Recommendations:** Scale up PVDF thermal treatment process.
    
    ### Key Findings Table
    | Sample | Performance |
    |--------|-------------|
    | PVDF-750 | Excellent |
    | PVDF-500 | Good |
    """)

# Q&A Chatbot (simple placeholder)
st.header("💬 Ask Questions")
question = st.text_input("e.g., Why did performance drop at low pressure?")
if question:
    st.info(f"🤖 Based on your data: Low pressure effects due to weak physisorption. Check Langmuir model fit.")

# Footer
st.markdown("---")
st.caption("Built for R&D Agent course midterm | Nuclear Engineering Focus [cite:1][cite:2][cite:5]")