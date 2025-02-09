@echo off

:: 检查参数数量
if "%~2"=="" (
    echo Usage: %0 ^<lang^> ^<cartname^>
    exit /b 1
)

:: 获取参数
set lang=%~1
set cart_name=%~2

:: 构建文件路径
set cart_path=carts\pico8pixelbomb\%cart_name%\%cart_name%.p8

:: 调用Python脚本
python tools\pico8i18n\gen_lua.py %lang% %cart_name%