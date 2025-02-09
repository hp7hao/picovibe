#!/bin/bash

# 检查参数数量
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <lang> <cartname>"
    exit 1
fi

# 获取参数
lang=$1
cart_name=$2

# 调用Python脚本
python tools/pico8i18n/gen_lua.py $lang $cart_name