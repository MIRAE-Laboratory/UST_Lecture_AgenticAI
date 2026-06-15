@echo off
REM ============================================================
REM  run_pipeline.bat — frozen R2R pipeline (stages 0-4)
REM  Usage:  run_pipeline.bat <stage> "<PROJECT_ROOT>"
REM    <stage> = transform | sync | partition | fusion | all
REM  PROJECT_ROOT = folder that contains 0.Transforming/, 1.Rawdata/, etc.
REM  Example:
REM    run_pipeline.bat all "C:/Users/KIMM/Desktop/PNT_Project_Data_and_reports/Claude code testing_2026.05.27_Irfan"
REM
REM  Transform input: InfluxDB Flux long-format *-plc.csv in 0.Transforming/Target/
REM    (row 0 must be #group,false,... NOT D305xxx column names)
REM ============================================================
setlocal
if "%~1"=="" (
  echo ERROR: missing stage. Use transform^|sync^|partition^|fusion^|all
  exit /b 1
)
if "%~2"=="" (
  echo ERROR: missing project root path.
  exit /b 1
)
set SCRIPT_DIR=%~dp0
python "%SCRIPT_DIR%..\pipeline\r2r_pipeline_frozen.py" %~1 --root "%~2" --check
exit /b %errorlevel%
