#!/bin/bash

FOLDER_NAME=$1
CART_NAME=$2
LANG=$3
CART_TEMPLATE=${4:-default}  # 设置默认值为default

# 检查环境是否已经就绪
if [ ! -f ".environment_ready" ]; then
    echo "Environment not ready. Running setup.sh..."
    ./setup.sh
    if [ $? -ne 0 ]; then
        echo "Setup failed. Exiting."
        exit 1
    fi
else
    echo "Environment is ready."
fi

# 检查p8.png文件是否存在
if [ ! -f "carts/pico8pixelbomb/${FOLDER_NAME}/${CART_NAME}.${LANG}.p8.png" ]; then
    echo "p8.png file not found. Exiting."
    exit 1
fi

mv carts/pico8pixelbomb/${FOLDER_NAME}/${CART_NAME}.${LANG}.p8.png carts/pico8pixelbomb/${FOLDER_NAME}/${CART_NAME}.${LANG}.orig.p8.png

source venv/bin/activate

# 首先提取cart中_t()的调用
python tools/pico8i18n/gen_tpl.py $FOLDER_NAME $CART_NAME $LANG

# 再根据翻译文件，创建压缩字符串
python tools/pico8i18n/gen_lua.py $FOLDER_NAME $CART_NAME $LANG

# 调用tools/customcart/gen_cartimage.py
echo "Generating cart image..."
python3 tools/customcart/gen_cartimage.py  \
    carts/pico8pixelbomb/$FOLDER_NAME \
    $CART_NAME \
    $LANG \
    $CART_TEMPLATE

echo "Build complete."