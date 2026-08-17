@echo off
setlocal
title Kotoba - Update Phone Version
cd /d "%~dp0"

echo.
echo ==================================================
echo   Kotoba  -  push the latest version to your phone
echo ==================================================
echo.

if not exist "index.html" (
  echo   [ERROR] index.html not found in this folder.
  pause & exit /b
)

where node >nul 2>nul
if errorlevel 1 (
  echo   [ERROR] Node.js not found. Run the SETUP .bat first.
  pause & exit /b
)

if not exist ".netlify\state.json" (
  echo   [ERROR] This folder is not linked to a site yet.
  echo           Run the SETUP .bat file first.
  pause & exit /b
)

echo   [1/3] Bumping service worker version...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0bump-version.ps1"
echo.

echo   [2/3] Preparing files...
if exist ".deploy" rmdir /s /q ".deploy"
mkdir ".deploy" >nul 2>nul
copy /y "index.html"           ".deploy\" >nul
copy /y "bank-vocab.js"        ".deploy\" >nul
copy /y "bank-verb.js"         ".deploy\" >nul
copy /y "bank-grammar.js"      ".deploy\" >nul
copy /y "bank-sentence.js"     ".deploy\" >nul
copy /y "bank-course.js"       ".deploy\" >nul
copy /y "bank-kana.js"         ".deploy\" >nul
copy /y "sw.js"                ".deploy\" >nul
copy /y "manifest.webmanifest" ".deploy\" >nul
copy /y "icon-192.png"         ".deploy\" >nul
copy /y "icon-512.png"         ".deploy\" >nul
echo         Done.
echo.

echo   [3/3] Uploading...
call netlify deploy --prod --dir=".deploy"
if errorlevel 1 goto FAIL

echo.
echo ==================================================
echo   DONE - uploaded.
echo.
echo   On your iPhone: open Kotoba, a blue bar saying
echo   "NEW VERSION" appears at the bottom - tap it.
echo.
echo   Not showing? Swipe the app fully closed and reopen.
echo ==================================================
echo.
pause
exit /b

:FAIL
echo.
echo   [ERROR] Upload failed.
echo           Network problem, or your login expired.
echo           If logged out, run:   netlify login
echo.
pause & exit /b
