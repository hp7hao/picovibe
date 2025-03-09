@echo off
setlocal EnableDelayedExpansion

REM Set parameters
set P8PATH=%1
set LANG=%2
set CART_TEMPLATE=%3
if "%CART_TEMPLATE%"=="" set CART_TEMPLATE=default

REM Extract folder and filename from the path
for %%F in ("%P8PATH%") do (
    set P8FOLDER=%%~dpF
    set P8NAME=%%~nF
)

REM Remove trailing backslash from folder if present
if "!P8FOLDER:~-1!"=="\" set P8FOLDER=!P8FOLDER:~0,-1!

REM Check if environment is ready
if not exist ".environment_ready" (
    echo Environment not ready. Running setup.bat...
    call setup.bat
    if %errorlevel% neq 0 (
        echo Setup failed. Exiting.
        exit /b 1
    )
) else (
    echo Environment is ready.
)

REM Activate virtual environment
call venv\Scripts\activate

REM Generate translation template from the cart
python tools\pico8i18n\gen_tpl.py %P8PATH% %LANG%

REM Generate compressed strings based on translation file
python tools\pico8i18n\gen_lua.py %P8PATH% %LANG%

REM Check if p8.png file exists
if not exist "%P8PATH%.png" (
    echo p8.png file not found. Exiting.
    exit /b 1
)

REM Generate custom cart image
echo Generating cart image...
python tools\customcart\gen_cartimage.py %P8PATH%.png %LANG% %CART_TEMPLATE%

echo Build complete.