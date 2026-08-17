@echo off
setlocal
title Kotoba - First Time Setup
cd /d "%~dp0"

echo.
echo ==================================================
echo   Kotoba  -  First Time Setup
echo   (Chinese guide: read the .md file in this folder)
echo ==================================================
echo.

if not exist "index.html" (
  echo   [ERROR] index.html not found.
  echo           Keep this .bat inside the Kotoba folder.
  echo.
  pause & exit /b
)

rem ---------- Step 1: Node.js ----------
where node >nul 2>nul
if errorlevel 1 goto NONODE
echo   [1/4] Node.js found:
node -v
echo.

rem ---------- Step 2: Netlify CLI ----------
echo   [2/4] Installing upload tool (Netlify CLI)...
echo         If you already did this for your other app, it will be quick.
echo.
call npm install -g netlify-cli --loglevel=error
if errorlevel 1 goto NPMFAIL
echo         Done.
echo.

rem ---------- Step 3: login ----------
echo   [3/4] Login to Netlify
echo         A browser window opens. Log in, then click Authorize.
echo         If you are already logged in, it just says so - that is fine.
echo.
call netlify login
echo.

rem ---------- Step 4: build + deploy ----------
echo   [4/4] Preparing files...
call :BUILD
echo         Done.
echo.
echo --------------------------------------------------
echo   IMPORTANT - you will be asked some questions.
echo.
echo   Q: What would you like to do?
echo        choose   [+]  Create ^& configure a new site
echo.
echo      ** DO NOT pick your Echo or Daily Quest site. **
echo      ** Kotoba must be its OWN separate site,      **
echo      ** otherwise you will overwrite the other app.**
echo.
echo   Q: Team        -^>  just press Enter
echo   Q: Site name   -^>  short lowercase name, e.g.  jerry-kotoba
echo --------------------------------------------------
echo.
pause

call netlify deploy --prod --dir=".deploy"
if errorlevel 1 goto DEPLOYFAIL

echo.
echo ==================================================
echo   SUCCESS
echo.
echo   Look above for the line:   Website URL:
echo   That https://... address is your Kotoba app.
echo.
echo   1. Copy it (drag-select the text, then press Enter)
echo   2. Paste it into  site-url.txt  in this folder
echo   3. Open it on your iPhone using SAFARI
echo      then Share -^> Add to Home Screen
echo.
echo   From now on you only need the UPDATE .bat file.
echo ==================================================
echo.
pause
exit /b


:BUILD
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
exit /b


:NONODE
echo   [ERROR] Node.js is not installed.
echo.
echo     1. A browser will open at https://nodejs.org
echo     2. Download the green LTS button
echo     3. Install (Next on everything)
echo     4. RESTART YOUR COMPUTER
echo     5. Run this .bat again
echo.
pause
start "" https://nodejs.org
exit /b

:NPMFAIL
echo.
echo   [ERROR] Could not install Netlify CLI.
echo           Try: right-click this file -^> Run as administrator
echo.
pause & exit /b

:DEPLOYFAIL
echo.
echo   [ERROR] Upload failed.
echo           Check your internet connection and try again.
echo           If it says you are logged out, run:  netlify login
echo.
pause & exit /b
