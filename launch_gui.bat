@echo off
cd /d "%~dp0"

rem Look in every common conda install (a PC can have both anaconda3 and miniconda3).
rem Preference: a known project env in any install, then any env with Streamlit, then base.
set "ROOTS="%USERPROFILE%\anaconda3" "%USERPROFILE%\miniconda3" "C:\ProgramData\anaconda3" "C:\ProgramData\miniconda3""
set "CONDA_ROOT="
set "ENV_NAME="

for %%N in (flytrack sleap_new sleap) do if not defined ENV_NAME for %%R in (%ROOTS%) do if not defined ENV_NAME if exist "%%~R\envs\%%N\Scripts\streamlit.exe" if exist "%%~R\Scripts\activate.bat" (set "CONDA_ROOT=%%~R" & set "ENV_NAME=%%N")
if not defined ENV_NAME for %%R in (%ROOTS%) do if exist "%%~R\Scripts\activate.bat" for /d %%E in ("%%~R\envs\*") do if not defined ENV_NAME if exist "%%E\Scripts\streamlit.exe" (set "CONDA_ROOT=%%~R" & set "ENV_NAME=%%~nxE")
if not defined ENV_NAME for %%R in (%ROOTS%) do if not defined ENV_NAME if exist "%%~R\Scripts\streamlit.exe" if exist "%%~R\Scripts\activate.bat" (set "CONDA_ROOT=%%~R" & set "ENV_NAME=base")

if not defined ENV_NAME goto :no_env

echo Using conda environment "%ENV_NAME%" from %CONDA_ROOT%
call "%CONDA_ROOT%\Scripts\activate.bat" %ENV_NAME%
streamlit run gui\app.py
pause
exit /b 0

:no_env
echo Could not find a conda environment with Streamlit installed
echo (searched anaconda3 / miniconda3 under %USERPROFILE% and C:\ProgramData).
echo Activate the environment with Streamlit + sleap-nn manually, then run: streamlit run gui\app.py
pause
exit /b 1
