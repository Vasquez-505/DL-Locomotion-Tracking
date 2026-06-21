@echo off
cd /d "%~dp0"

for %%C in ("%USERPROFILE%\anaconda3" "%USERPROFILE%\miniconda3" "C:\ProgramData\anaconda3" "C:\ProgramData\miniconda3") do (
    if exist "%%~C\Scripts\activate.bat" (
        call "%%~C\Scripts\activate.bat" flytrack
        goto :launch
    )
)

echo Could not find a conda installation ^(anaconda3 or miniconda3^) under %USERPROFILE% or C:\ProgramData.
echo Activate the flytrack environment manually, then run: streamlit run gui\app.py
pause
exit /b 1

:launch
streamlit run gui\app.py
pause
