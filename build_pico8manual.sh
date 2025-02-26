#!/bin/bash

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

python3 tools/buildpico8manual.py docs/pico8manual v0.2.6c_rev0 docs/pico8manual