@echo off
setlocal
title Kotoba - Show My Site URL
cd /d "%~dp0"

echo.
echo ==================================================
echo   Looking up your Kotoba site URL...
echo ==================================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo   [ERROR] Node.js not found.
  echo           Open https://app.netlify.com in your browser instead.
  pause & exit /b
)

if not exist ".netlify\state.json" (
  echo   [ERROR] This folder is not linked to a site yet.
  echo           Run the SETUP .bat file first.
  pause & exit /b
)

call netlify status

echo.
echo ==================================================
echo   Look above for the line:   URL:  https://....
echo   That is your Kotoba address.
echo   Paste it into  site-url.txt  so you do not lose it.
echo ==================================================
echo.
pause
call netlify open:site
