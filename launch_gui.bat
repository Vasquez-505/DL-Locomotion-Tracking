@echo off
cd /d "%~dp0"

set "CONDA_ROOT="
if exist "%USERPROFILE%\anaconda3\Scripts\activate.bat" set "CONDA_ROOT=%USERPROFILE%\anaconda3"
if not defined CONDA_ROOT if exist "%USERPROFILE%\miniconda3\Scripts\activate.bat" set "CONDA_ROOT=%USERPROFILE%\miniconda3"
if not defined CONDA_ROOT if exist "C:\ProgramData\anaconda3\Scripts\activate.bat" set "CONDA_ROOT=C:\ProgramData\anaconda3"
if not defined CONDA_ROOT if exist "C:\ProgramData\miniconda3\Scripts\activate.bat" set "CONDA_ROOT=C:\ProgramData\miniconda3"
if not defined CONDA_ROOT goto :no_conda

rem Prefer a dedicated project env over base - try known names first, then any env, then base last.
set "ENV_NAME="
if exist "%CONDA_ROOT%\envs\flytrack\Scripts\streamlit.exe" set "ENV_NAME=flytrack"
if not defined ENV_NAME if exist "%CONDA_ROOT%\envs\sleap_new\Scripts\streamlit.exe" set "ENV_NAME=sleap_new"
if not defined ENV_NAME if exist "%CONDA_ROOT%\envs\sleap\Scripts\streamlit.exe" set "ENV_NAME=sleap"
if not defined ENV_NAME for /d %%E in ("%CONDA_ROOT%\envs\*") do if not defined ENV_NAME if exist "%%E\Scripts\streamlit.exe" set "ENV_NAME=%%~nxE"
if not defined ENV_NAME if exist "%CONDA_ROOT%\Scripts\streamlit.exe" set "ENV_NAME=base"
if not defined ENV_NAME goto :no_env

call "%CONDA_ROOT%\Scripts\activate.bat" %ENV_NAME%
streamlit run gui\app.py
pause
exit /b 0

:no_conda
echo Could not find a conda installation (anaconda3 or miniconda3) under %USERPROFILE% or C:\ProgramData.
echo Activate the environment with Streamlit + sleap-nn manually, then run: streamlit run gui\app.py
pause
exit /b 1

:no_env
echo Could not find a conda environment with Streamlit installed under "%CONDA_ROOT%".
echo See NOVA_PC_SETUP_GUIDE.md to create one, then run this launcher again.
pause
exit /b 1
