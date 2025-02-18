#!/bin/bash

# 获取force参数，默认为false
# Get the force parameter, default is false
force=false
if [ "$1" == "true" ]; then
    force=true
fi

# 检查并下载submodule
# Check and download submodules
if [ -d ".git" ]; then
    echo "Checking for submodules..."
    git submodule update --init --recursive
else
    echo "This script should be run from the root of the git repository."
    exit 1
fi

# 检查并创建或重新创建虚拟环境
# Check and create or recreate virtual environment
if [ "$force" == "true" ]; then
    echo "Force flag detected. Removing existing virtual environment..."
    rm -rf venv
fi

if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
else
    echo "Virtual environment already exists."
fi

# 激活虚拟环境
# Activate virtual environment
source venv/bin/activate

# 安装依赖
# Install dependencies
if [ -f "requirements.txt" ]; then
    echo "Installing dependencies..."
    pip install -r requirements.txt
else
    echo "requirements.txt not found."
    exit 1
fi

echo "Setup complete."
touch .environment_ready
