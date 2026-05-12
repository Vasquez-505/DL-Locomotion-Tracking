@echo off
cd /d "%~dp0.."
call "C:\Users\pepev\anaconda3\Scripts\activate.bat" sleap_new
streamlit run gui/app.py
pause
