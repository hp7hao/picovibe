@echo off
setlocal EnableDelayedExpansion

REM ###########################################
REM Parameter Parsing Functions
REM ###########################################

REM Default values
set "P8PATH="
set "CART_TEMPLATE="
set "QRCODE_MODE="
set "SHOULD_MINIFY=false"

REM Function to display usage
:show_usage
echo Usage: %~nx0 [options]
echo Options:
echo   --cart ^<path^>          Path to the PICO-8 cart file (required)
echo   --template ^<path^>      Path to custom cart template image (optional)
echo   --qrcode ^<mode^>        QR code mode for cart image (optional)
echo   --minify               Enable code minification (optional, default: disabled)
echo   --help                 Show this help message
echo.
echo Example:
echo   %~nx0 --cart game.p8 --template custom.png --qrcode qrcode --minify
exit /b 1

REM Function to parse named parameters
:parse_parameters
if "%~1"=="" goto show_usage

:parse_loop
if "%~1"=="" goto parse_done

if "%~1"=="--cart" (
    set "P8PATH=%~2"
    shift
    shift
    goto parse_loop
)
if "%~1"=="--template" (
    set "CART_TEMPLATE=%~2"
    shift
    shift
    goto parse_loop
)
if "%~1"=="--qrcode" (
    set "QRCODE_MODE=%~2"
    shift
    shift
    goto parse_loop
)
if "%~1"=="--minify" (
    set "SHOULD_MINIFY=true"
    shift
    goto parse_loop
)
if "%~1"=="--help" (
    goto show_usage
)

echo Unknown parameter: %~1
goto show_usage

:parse_done
REM Validate required parameters
if "%P8PATH%"=="" (
    echo Error: --cart parameter is required
    goto show_usage
)
goto :eof

REM ###########################################
REM System Tool Check Functions
REM ###########################################

REM Function to check if a command exists
:check_command
where %~1 >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Required command '%~1' is not installed.
    echo Please install it and add it to your PATH.
    echo For example:
    echo   - Install Python from https://python.org
    echo   - Make sure python3 is in your PATH
    exit /b 1
)
exit /b 0

REM Function to check all required system tools
:check_required_tools
echo Checking required tools...

call :check_command python3
if %errorlevel% neq 0 (
    REM Try python if python3 is not available
    call :check_command python
    if %errorlevel% neq 0 (
        echo Error: Python is not installed or not in PATH
        exit /b 1
    ) else (
        echo Warning: Using 'python' instead of 'python3'
        set "PYTHON_CMD=python"
    )
) else (
    set "PYTHON_CMD=python3"
)

echo All required tools are available.
goto :eof

REM Function to get list of configured languages
:get_configured_langs
set "cart_folder=%~1"
set "cart_name=%~2"
set "lang_list="
set "lang_count=0"

for %%f in ("%cart_folder%\%cart_name%.meta.*.json") do (
    if exist "%%f" (
        set "filename=%%~nf"
        REM Extract language code from filename
        for /f "tokens=3 delims=." %%a in ("!filename!") do (
            set /a lang_count+=1
            if "!lang_list!"=="" (
                set "lang_list=%%a"
            ) else (
                set "lang_list=!lang_list! %%a"
            )
        )
    )
)

set "CONFIGURED_LANGS=!lang_list!"
goto :eof

REM ###########################################
REM Environment Setup Functions
REM ###########################################

REM Function to check and setup environment
:setup_environment
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

call venv\Scripts\activate
goto :eof

REM ###########################################
REM File Generation Functions
REM ###########################################

REM Function to generate template and lua files
:generate_files
set "p8path=%~1"
set "lang=%~2"
set "cart_folder=%~3"
set "cart_name=%~4"
set "meta_file=%cart_folder%\%cart_name%.meta.%lang%.json"

REM Skip if meta file doesn't exist
if not exist "%meta_file%" (
    echo Skipping language %lang% - meta file does not exist
    goto :eof
)

echo Generating files for language: %lang%
%PYTHON_CMD% tools\pico8i18n\gen_tpl.py "%p8path%" "%lang%"
%PYTHON_CMD% tools\pico8i18n\gen_lua.py "%p8path%" "%lang%"
goto :eof

REM Function to update p8 file with language settings
:update_p8_language
set "p8path=%~1"
set "lang=%~2"
set "p8name=%~3"

echo Setting language to %lang%...

REM Create a temporary PowerShell script for regex replacement
echo $content = Get-Content "%p8path%" -Raw > temp_replace.ps1
echo $content = $content -replace 'i18n\.lang="[^"]*"', 'i18n.lang="%lang%"' >> temp_replace.ps1
echo $content = $content -replace '#include \.\/%p8name%\.texts\.[^\.]*\.lua', '#include ./%p8name%.texts.%lang%.lua' >> temp_replace.ps1
echo $content ^| Set-Content "%p8path%" -NoNewline >> temp_replace.ps1

powershell -ExecutionPolicy Bypass -File temp_replace.ps1
del temp_replace.ps1
goto :eof

REM ###########################################
REM Main Build Functions
REM ###########################################

REM Function to generate cart PNG using shrinko8
:generate_cart_png
set "p8folder=%~1"
set "p8name=%~2"
set "should_minify=%~3"

echo Generating cart PNG using shrinko8...
set "input_path=%p8folder%\%p8name%.p8"
set "output_path=%p8folder%\%p8name%.p8.png"

REM Run shrinko8 to generate PNG
if "%should_minify%"=="true" (
    %PYTHON_CMD% deps\shrinko8\shrinko8.py "%input_path%" "%output_path%" --minify-safe-only
) else (
    %PYTHON_CMD% deps\shrinko8\shrinko8.py "%input_path%" "%output_path%"
)

REM Check if the file was generated successfully
if not exist "%output_path%" (
    echo Error: Failed to generate cart PNG using shrinko8
    exit /b 1
)

echo Successfully generated cart PNG at: %output_path%
goto :eof

REM Function to generate cart image
:generate_cart_image
set "p8folder=%~1"
set "p8name=%~2"
set "lang=%~3"
set "template=%~4"
set "qrcode_mode=%~5"

echo Generating cart image for %lang%...

REM Build the command with the new argparse interface
set "cmd=%PYTHON_CMD% tools\customcart\gen_cartimage.py "%p8folder%" "%p8name%" "%lang%""

REM Add template if provided
if not "%template%"=="" (
    set "cmd=!cmd! --template "%template%""
)

REM Add qrcode mode if provided
if not "%qrcode_mode%"=="" (
    set "cmd=!cmd! --qrcode "%qrcode_mode%""
)

REM Execute the command
!cmd!
goto :eof

REM Function to build cart for a specific language
:build_cart_for_language
set "lang=%~1"
set "should_minify=%~2"

echo Building for language: %lang%

REM Generate template and lua files
call :generate_files "%P8PATH%" "%lang%" "%P8FOLDER%" "%P8NAME%"

REM Update p8 file with language settings
call :update_p8_language "%P8PATH%" "%lang%" "%P8NAME%"

REM Generate cart PNG using shrinko8
call :generate_cart_png "%P8FOLDER%" "%P8NAME%" "%should_minify%"

REM Generate cart image
call :generate_cart_image "%P8FOLDER%" "%P8NAME%" "%lang%" "%CART_TEMPLATE%" "%QRCODE_MODE%"
goto :eof

REM ###########################################
REM Main Workflow
REM ###########################################

REM Parse command line parameters
call :parse_parameters %*

REM Check for required tools before proceeding
call :check_required_tools
if %errorlevel% neq 0 exit /b 1

echo Input P8PATH: %P8PATH%
echo Template: %CART_TEMPLATE%
echo QR Code Mode: %QRCODE_MODE%
echo Minification enabled: %SHOULD_MINIFY%

REM Extract folder and name more robustly
for %%F in ("%P8PATH%") do (
    set "P8FOLDER=%%~dpF"
    set "P8NAME=%%~nF"
)

REM Remove trailing backslash from folder if present
if "!P8FOLDER:~-1!"=="\" set "P8FOLDER=!P8FOLDER:~0,-1!"

echo Extracted values:
echo   P8FOLDER: !P8FOLDER!
echo   P8NAME: !P8NAME!

REM Setup environment
call :setup_environment
if %errorlevel% neq 0 exit /b 1

REM Get list of configured languages
call :get_configured_langs "!P8FOLDER!" "!P8NAME!"
echo Building cart for languages: !CONFIGURED_LANGS!

REM Build for each language
for %%L in (!CONFIGURED_LANGS!) do (
    call :build_cart_for_language "%%L" "%SHOULD_MINIFY%"
)

echo Build complete for all languages.