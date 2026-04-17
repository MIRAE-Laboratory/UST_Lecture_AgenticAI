⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

# app.py (sidebar section)
import streamlit as st
from pdf_utils import extract_text_from_pdf, get_combined_context
from llm_client import get_client, chat_with_pdfs
from prompt_manager import load_presets, load_saved, save_prompt, delete_prompt

st.set_page_config(page_title="Multi-PDF Research Assistant", page_icon="📚", layout="wide")

# Session state
if "messages" not in st.session_state:
    st.session_state.messages = []
if "pdf_texts" not in st.session_state:
    st.session_state.pdf_texts = {}
if "selected_pdfs" not in st.session_state:
    st.session_state.selected_pdfs = []

# --- Sidebar ---
st.sidebar.title("⚙️ Settings")
provider = st.sidebar.radio("LLM Provider", ["Gemini", "Ollama", "OpenAI"])
client, model = get_client(provider)

st.sidebar.subheader("📄 Upload PDFs")
uploaded = st.sidebar.file_uploader("PDFs", type="pdf", accept_multiple_files=True)
if uploaded:
    for f in uploaded:
        if f.name not in st.session_state.pdf_texts:
            st.session_state.pdf_texts[f.name] = extract_text_from_pdf(f)

# Per-PDF checkboxes
if st.session_state.pdf_texts:
    st.sidebar.subheader("☑️ Select PDFs for Context")
    selected = [n for n in st.session_state.pdf_texts
                if st.sidebar.checkbox(n, value=True, key=f"pdf_{n}")]
    st.session_state.selected_pdfs = selected
    # app.py (chat section)

# Display chat history
for msg in st.session_state.messages:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])

# Get prompt (from preset click or chat input)
prompt = st.session_state.get("pending_prompt")
st.session_state.pending_prompt = None
if prompt is None:
    prompt = st.chat_input("Ask about your PDFs...")

if prompt and client:
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # Build PDF context from selected PDFs
    pdf_context = get_combined_context(
        st.session_state.pdf_texts, st.session_state.selected_pdfs)

    # Build history for LLM
    history = [{"role": m["role"], "content": m["content"]}
               for m in st.session_state.messages[:-1]]

    # Stream response
    with st.chat_message("assistant"):
        placeholder = st.empty()
        full_response = ""
        stream = chat_with_pdfs(client, model, pdf_context, prompt, history)
        for chunk in stream:
            if chunk.choices[0].delta.content:
                full_response += chunk.choices[0].delta.content
                placeholder.markdown(full_response + "▌")
        placeholder.markdown(full_response)
        st.session_state.messages.append(
            {"role": "assistant", "content": full_response})
            # llm_client.py
import os
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

SYSTEM_PROMPT = """You are a research paper analysis assistant.
You help researchers understand, compare, and synthesize academic papers.
When answering, always reference which paper(s) your answer is based on.
If the provided papers do not contain enough information, say so clearly.
Be precise, use academic language, and structure your responses with headings."""

def get_client(provider: str):
    if provider == "Gemini":
        return OpenAI(
            api_key=os.getenv("GOOGLE_API_KEY"),
            base_url="https://generativelanguage.googleapis.com/v1beta/openai/"
        ), os.getenv("GEMINI_MODEL", "gemini-2.0-flash")
    elif provider == "Ollama":
        return OpenAI(base_url="http://localhost:11434/v1",
                      api_key="ollama"), os.getenv("OLLAMA_MODEL", "qwen3:1.7b")
    else:
        return OpenAI(api_key=os.getenv("OPENAI_API_KEY")
                      ), os.getenv("OPENAI_MODEL", "gpt-4o-mini")

def chat_with_pdfs(client, model, pdf_context, user_message, history):
    """Send a message with PDF context injected into the system prompt."""
    system_msg = SYSTEM_PROMPT
    if pdf_context:
        system_msg += f"\n\n# Selected Papers Content\n\n{pdf_context}"
    messages = [{"role": "system", "content": system_msg}]
    messages.extend(history)
    messages.append({"role": "user", "content": user_message})
    return client.chat.completions.create(model=model, messages=messages, stream=True)
    GOOGLE_API_KEY=AIzaSyCY8hzqdKPQkaphQpd1qsDMBwDk6miypyM
GEMINI_MODEL=gemini-3.1-flash-lite-preview
import os
from dotenv import load_dotenv
import google.generativeai as genai

# Load API key from .env
load_dotenv()
genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

# Create model and send a prompt
model = genai.GenerativeModel(os.getenv("GEMINI_MODEL"))
response = model.generate_content(
    "Explain what a Transformer is in 3 sentences."
)
print(response.text)
import os
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

# Works with OpenAI, and also with Ollama (change base_url)
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "What is a Transformer in AI?"}
    ]
)
print(response.choices[0].message.content)
# pdf_utils.py
from PyPDF2 import PdfReader

MAX_CHARS_PER_PDF = 15000  # Truncate to fit context limits

def extract_text_from_pdf(uploaded_file) -> str:
    """Extract text from a Streamlit UploadedFile (PDF)."""
    reader = PdfReader(uploaded_file)
    pages = []
    for page in reader.pages:
        text = page.extract_text()
        if text:
            pages.append(text)
    full_text = "\n".join(pages)
    if len(full_text) > MAX_CHARS_PER_PDF:
        full_text = full_text[:MAX_CHARS_PER_PDF] + "\n\n[... truncated ...]"
    return full_text

def get_combined_context(pdf_texts: dict, selected: list) -> str:
    """Combine text from selected PDFs into a single context string."""
    parts = []
    for name in selected:
        if name in pdf_texts:
            parts.append(f"### {name}\n{pdf_texts[name]}")
    return "\n\n---\n\n".join(parts)
    # app.py (main area — preset buttons)
st.title("📚 Multi-PDF Research Assistant")

presets = load_presets()
saved = load_saved()

if st.session_state.pdf_texts:
    st.subheader("⚡ Quick Prompts")

    # Built-in presets
    cols = st.columns(min(len(presets), 5))
    for i, preset in enumerate(presets):
        with cols[i % len(cols)]:
            if st.button(f"📌 {preset['name']}", key=f"preset_{i}",
                         use_container_width=True):
                st.session_state.pending_prompt = preset["template"]
                st.rerun()

    # Saved custom prompts with delete button
    if saved:
        st.caption("Your saved prompts:")
        for i, sp in enumerate(saved):
            c1, c2 = st.columns([5, 1])
            with c1:
                if st.button(f"💾 {sp['name']}", key=f"saved_{i}"):
                    st.session_state.pending_prompt = sp["template"]
                    st.rerun()
            with c2:
                if st.button("✕", key=f"del_{i}"):
                    delete_prompt(sp["name"])
                    st.rerun()

    # Save new custom prompt
    with st.expander("➕ Save a New Custom Prompt"):
        new_name = st.text_input("Prompt name")
        new_template = st.text_area("Prompt template")
        if st.button("💾 Save") and new_name and new_template:
            save_prompt(new_name, new_template)
            st.rerun()
            # prompt_manager.py
import json, os

PRESETS_PATH = os.path.join(os.path.dirname(__file__), "presets.json")
SAVED_PATH = os.path.join(os.path.dirname(__file__), "saved_prompts.json")

def load_presets(path=PRESETS_PATH):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def load_saved(path=SAVED_PATH):
    if not os.path.exists(path):
        with open(path, "w", encoding="utf-8") as f:
            json.dump([], f)
        return []
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def save_prompt(name, template, path=SAVED_PATH):
    prompts = load_saved(path)
    prompts.append({"name": name, "template": template})
    with open(path, "w", encoding="utf-8") as f:
        json.dump(prompts, f, indent=2, ensure_ascii=False)

def delete_prompt(name, path=SAVED_PATH):
    prompts = load_saved(path)
    prompts = [p for p in prompts if p["name"] != name]
    with open(path, "w", encoding="utf-8") as f:
        json.dump(prompts, f, indent=2, ensure_ascii=False)
        # presets.json — 5 default presets
[
  {"name": "Compare Papers", "template": "Compare the following papers..."},
  {"name": "Find Contradictions", "template": "Identify contradicting claims..."},
  {"name": "Generate Fusion Ideas", "template": "Propose 3-5 novel ideas..."},
  {"name": "Summarize Each", "template": "Structured summary of each paper..."},
  {"name": "Extract Methods", "template": "List research methods used..."}
]