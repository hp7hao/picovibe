#!/bin/bash

set -e

P8PATH=$1
LANG=$2
CART_TEMPLATE=${3:-default}  # 设置默认值为default
P8FOLDER=${P8PATH%/*}
P8NAME=${P8PATH##*/}
P8NAME=${P8NAME%.p8}

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

source venv/bin/activate
python tools/pico8i18n/gen_tpl.py $P8PATH $LANG
python tools/pico8i18n/gen_lua.py $P8PATH $LANG

if [ ! -f "$P8PATH.png" ]; then
    echo "p8.png file not found. Exiting."
    exit 1
fi

# 调用tools/customcart/gen_cartimage.py
echo "Generating cart image..."
python3 tools/customcart/gen_cartimage.py  \
    $P8FOLDER \
    $P8NAME \
    $LANG \
    $CART_TEMPLATE

echo "Build complete."