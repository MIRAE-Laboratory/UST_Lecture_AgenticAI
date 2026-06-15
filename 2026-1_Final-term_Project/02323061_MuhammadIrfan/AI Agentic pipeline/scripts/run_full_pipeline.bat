@echo off
REM ============================================================
REM  run_full_pipeline.bat -- full 8-stage R2R pipeline
REM  Usage:  run_full_pipeline.bat "<PROJECT_ROOT>"
REM  Example:
REM    run_full_pipeline.bat "C:/Users/KIMM/Desktop/PNT_Project_Data_and_reports/Claude code testing_2026.05.27_Irfan"
REM
REM  Stages 0-4 : r2r_pipeline_frozen.py (byte-identical, SHA-256 manifests)
REM  Stage  5   : r2r_ml_pipeline.py filter     (byte-identical, SHA-256)
REM  Stage  7   : r2r_ml_pipeline.py inputselect (same-machine reproducible)
REM  Stage  8   : r2r_ml_pipeline.py model       (same-machine reproducible)
REM ============================================================
setlocal

if "%~1"=="" (
  echo.
  echo  ERROR: missing project root. Usage: run_full_pipeline.bat "^<PROJECT_ROOT^>"
  exit /b 1
)

set "ROOT=%~1"
set "SCRIPT_DIR=%~dp0"

REM -- Optional: activate venv if present -----------------------------------------
if exist "%SCRIPT_DIR%venv\Scripts\activate.bat" (
  echo [SETUP] Activating venv at %SCRIPT_DIR%venv
  call "%SCRIPT_DIR%venv\Scripts\activate.bat"
)

echo.
echo ================================================================
echo   R2R FULL PIPELINE  --  ALL 8 STAGES
echo   Root: %ROOT%
echo ================================================================

REM -- STAGES 0-4: frozen deterministic pipeline ----------------------------------
echo.
echo [PIPELINE] Running stages 0-4 (transform / sync / partition / fusion) ...
python "%SCRIPT_DIR%..\pipeline\r2r_pipeline_frozen.py" all --root "%ROOT%" --check
if errorlevel 1 goto fail04
echo [PIPELINE] Stages 0-4 complete.

REM -- STAGE 5: hard filter -------------------------------------------------------
echo.
echo [PIPELINE] Running stage 5 (filter) ...
python "%SCRIPT_DIR%..\pipeline\r2r_ml_pipeline.py" filter --root "%ROOT%" --check
if errorlevel 1 goto fail05
echo [PIPELINE] Stage 5 complete.

REM -- STAGE 7: input selection ----------------------------------------------------
echo.
echo [PIPELINE] Running stage 7 (inputselect) ...
python "%SCRIPT_DIR%..\pipeline\r2r_ml_pipeline.py" inputselect --root "%ROOT%" --check
if errorlevel 1 goto fail07
echo [PIPELINE] Stage 7 complete.

REM -- STAGE 8: model -------------------------------------------------------------
echo.
echo [PIPELINE] Running stage 8 (model) -- this takes 60-90 minutes ...
python "%SCRIPT_DIR%..\pipeline\r2r_ml_pipeline.py" model --root "%ROOT%" --check
if errorlevel 1 goto fail08
echo [PIPELINE] Stage 8 complete.

REM -- Summary --------------------------------------------------------------------
echo.
echo ================================================================
echo   ALL 8 STAGES COMPLETE
echo   Outputs:
echo     Stages 0-4 : 1.Rawdata/ 2.Synchronize/ 3.Partitioning/ 4.Fusioning/
echo     Stage 5    : 6.Filtering/ai_driven/
echo     Stage 7    : 5.InputSelection/ai_driven/
echo     Stage 8    : 7.Ai modeling/ai_driven/
echo     Reports    : 8.Report/
echo   ML summary  : %ROOT%/8.Report/AGENTIC_SUMMARY.txt
echo ================================================================
exit /b 0

:fail04
echo.
echo ================================================================
echo   STAGE 0-4 FAILED -- see output above
echo ================================================================
exit /b 1

:fail05
echo.
echo ================================================================
echo   STAGE 5 (filter) FAILED -- see output above
echo ================================================================
exit /b 1

:fail07
echo.
echo ================================================================
echo   STAGE 7 (inputselect) FAILED -- see output above
echo ================================================================
exit /b 1

:fail08
echo.
echo ================================================================
echo   STAGE 8 (model) FAILED -- see output above
echo ================================================================
exit /b 1
