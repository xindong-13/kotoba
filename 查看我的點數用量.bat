@echo off
setlocal
title Kotoba - Check Netlify Credit Usage
cd /d "%~dp0"

echo.
echo ==================================================
echo   Netlify free plan = 300 credits per MONTH,
echo   shared by ALL sites on your account
echo   (Kotoba + Echo + Daily Quest together).
echo.
echo     Production deploy .... 15 credits each
echo     Draft deploy ......... 0  credits
echo     Bandwidth ............ 20 credits per GB
echo.
echo   300 / 15 = about 20 production deploys a month.
echo   If credits run out, ALL your sites are paused
echo   until the next billing cycle.
echo ==================================================
echo.
echo   Opening your billing page in the browser...
echo   Look for the credit usage bar.
echo.
start "" https://app.netlify.com
pause
