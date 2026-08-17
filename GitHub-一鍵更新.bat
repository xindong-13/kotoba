@echo off
setlocal enabledelayedexpansion
title Kotoba - GitHub Pages Update
cd /d "%~dp0"

echo.
echo ==================================================
echo   Kotoba  -  push the latest version
echo   GitHub Pages has no monthly deploy limit.
echo ==================================================
echo.

if not exist "index.html" ( echo   [ERROR] index.html not found. & pause & exit /b )
where git >nul 2>nul
if errorlevel 1 ( echo   [ERROR] Git not found. Run the SETUP .bat first. & pause & exit /b )
if not exist ".git" ( echo   [ERROR] Not set up yet. Run the SETUP .bat first. & pause & exit /b )

echo   [1/3] Bumping service worker version...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0bump-version.ps1"
echo.

echo   [2/3] Committing...
git add -A >nul
git commit -m "update" >nul 2>nul
if errorlevel 1 echo         ^(nothing changed since last time - pushing anyway^)
echo.

echo   [3/3] Pushing to GitHub...
git push
if errorlevel 1 goto FAIL

echo.
echo ==================================================
echo   DONE.
echo   GitHub rebuilds the site in about 1 minute.
echo.
echo   Then on your iPhone: open the app, tap the blue
echo   update bar at the bottom. If it does not appear,
echo   swipe the app fully closed and reopen it.
echo ==================================================
echo.
if exist github-url.txt type github-url.txt
echo.
pause
exit /b

:FAIL
echo.
echo   [ERROR] Push failed.
echo           Check your connection, or run:  gh auth login
echo.
pause & exit /b
