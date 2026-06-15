@echo off
chcp 65001 > nul
cd /d "%~dp0"
python -m streamlit run final_thermofluid_ai_app_DEMO_SAFE.py
pause
