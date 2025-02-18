@echo off
setlocal

REM 设置参数
set FOLDER_NAME=%1
set CART_NAME=%2
set LANG=%3
set CART_TEMPLATE=%4
if "%CART_TEMPLATE%"=="" set CART_TEMPLATE=default

REM 检查环境是否已经就绪
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

REM 检查p8.png文件是否存在
if not exist "carts\pico8pixelbomb\%FOLDER_NAME%\%CART_NAME%.%LANG%.p8.png" (
    echo p8.png file not found. Exiting.
    exit /b 1
)

REM 重命名文件
move "carts\pico8pixelbomb\%FOLDER_NAME%\%CART_NAME%.%LANG%.p8.png" "carts\pico8pixelbomb\%FOLDER_NAME%\%CART_NAME%.%LANG%.orig.p8.png"

REM 激活虚拟环境
call venv\Scripts\activate

REM 首先提取cart中_t()的调用
python tools\pico8i18n\gen_tpl.py %FOLDER_NAME% %CART_NAME% %LANG%

REM 再根据翻译文件，创建压缩字符串
python tools\pico8i18n\gen_lua.py %FOLDER_NAME% %CART_NAME% %LANG%

REM 调用tools\customcart\gen_cartimage.py
echo Generating cart image...
python tools\customcart\gen_cartimage.py ^
    carts\pico8pixelbomb\%FOLDER_NAME% ^
    %CART_NAME% ^
    %LANG% ^
    %CART_TEMPLATE%

echo Build complete.