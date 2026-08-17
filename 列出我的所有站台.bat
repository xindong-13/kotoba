@echo off
setlocal
title Kotoba - List All My Netlify Sites
cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
  echo   [ERROR] Node.js not found.
  pause & exit /b
)

echo.
echo   Your Netlify sites:
echo.
call netlify sites:list
echo.
echo   Kotoba should be its own site, separate from
echo   your Echo and Daily Quest sites.
echo.
pause
