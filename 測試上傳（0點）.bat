@echo off
setlocal
title Kotoba - Draft Deploy (FREE, no credits)
cd /d "%~dp0"

echo.
echo ==================================================
echo   Kotoba - DRAFT deploy
echo.
echo   This uploads to a TEMPORARY preview URL.
echo   Netlify does NOT charge credits for draft
echo   deploys - only for production deploys.
echo.
echo   Use this to check a change before spending
echo   one of your ~20 monthly production deploys.
echo ==================================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo   [ERROR] Node.js not found. Run the SETUP .bat first.
  pause & exit /b
)
if not exist ".netlify\state.json" (
  echo   [ERROR] Not linked to a site yet. Run the SETUP .bat first.
  pause & exit /b
)

echo   Preparing files...
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
echo   Done.
echo.

call netlify deploy --dir=".deploy"
if errorlevel 1 goto FAIL

echo.
echo ==================================================
echo   DONE - draft deploy uploaded. 0 credits used.
echo.
echo   Look above for:   Website Draft URL:
echo   Open THAT link to check your changes.
echo.
echo   Your real app address is NOT affected.
echo   When the change looks good, run:
echo      the UPDATE .bat file   (costs 15 credits)
echo ==================================================
echo.
pause
exit /b

:FAIL
echo.
echo   [ERROR] Upload failed. Check your connection or run: netlify login
echo.
pause & exit /b
