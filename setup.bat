@echo off

:: 获取force参数，默认为false
:: Get the force parameter, default is false
set force=false
if "%1"=="true" set force=true

:: 检查并下载submodule
:: Check and download submodules
if exist ".git" (
    echo Checking for submodules...
    git submodule update --init --recursive
) else (
    echo This script should be run from the root of the git repository.
    exit /b 1
)

:: 检查并创建或重新创建虚拟环境
:: Check and create or recreate virtual environment
if "%force%"=="true" (
    echo Force flag detected. Removing existing virtual environment...
    rmdir /s /q venv
)

if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
) else (
    echo Virtual environment already exists.
)

:: 激活虚拟环境
:: Activate virtual environment
call venv\Scripts\activate.bat

:: 安装依赖
:: Install dependencies
if exist "requirements.txt" (
    echo Installing dependencies...
    pip install -r requirements.txt
) else (
    echo requirements.txt not found.
    exit /b 1
)

echo Setup complete.
echo. > .environment_ready