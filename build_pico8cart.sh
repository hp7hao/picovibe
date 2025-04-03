#!/bin/bash

set -e

###########################################
# System Tool Check Functions
###########################################

# Function to check if a command exists
check_command() {
    local cmd=$1
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: Required command '$cmd' is not installed."
        echo "Please install it using your system's package manager."
        echo "For example:"
        echo "  - On Ubuntu/Debian: sudo apt-get install $cmd"
        echo "  - On Fedora: sudo dnf install $cmd"
        echo "  - On Arch Linux: sudo pacman -S $cmd"
        return 1
    fi
    return 0
}

# Function to check all required system tools
check_required_tools() {
    local missing_tools=()
    
    # Check Python3
    if ! check_command "python3"; then
        missing_tools+=("python3")
    fi
    
    # Check xdotool
    if ! check_command "xdotool"; then
        missing_tools+=("xdotool")
    fi
    
    # Check sed
    if ! check_command "sed"; then
        missing_tools+=("sed")
    fi
    
    # If any tools are missing, exit
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo "The following required tools are missing: ${missing_tools[*]}"
        echo "Please install them and try again."
        exit 1
    fi
}

###########################################
# Configuration Functions
###########################################

# Function to read PICO-8 path from config file
get_pico8_path() {
    local config_file="pico8config.json"
    local example_file="pico8config.json.example"
    
    # Check if config file exists
    if [ ! -f "$config_file" ]; then
        # Check if example file exists
        if [ ! -f "$example_file" ]; then
            echo "Error: Neither $config_file nor $example_file found!"
            echo "Please create $config_file with your PICO-8 path configuration."
            exit 1
        fi
        
        # Copy example file to config file
        echo "Creating $config_file from example file..."
        cp "$example_file" "$config_file"
        
        echo "======================================================="
        echo "Please edit $config_file and set your PICO-8 path first!"
        echo "The file has been created from $example_file"
        echo "After setting the path, run this script again."
        echo "======================================================="
        exit 1
    fi
    
    # Read path from config file using Python
    local pico8_path=$(python3 -c "
import json
try:
    with open('$config_file', 'r') as f:
        config = json.load(f)
        path = config.get('pico8path')
        if not path or path == '<<your pico8 path>>':
            print('ERROR: PICO-8 path not properly configured in $config_file')
            exit(1)
        print(path)
except Exception as e:
    print(f'ERROR: Failed to read $config_file: {str(e)}')
    exit(1)
")
    
    # Check if we got an error message
    if [[ "$pico8_path" == ERROR:* ]]; then
        echo "$pico8_path"
        exit 1
    fi
    
    # Check if PICO-8 executable exists
    if [ ! -f "$pico8_path" ]; then
        echo "Error: PICO-8 executable not found at: $pico8_path"
        echo "Please check your PICO-8 installation and update the path in $config_file"
        echo "Make sure the path points to the actual PICO-8 executable file"
        exit 1
    fi
    
    # Check if the file is executable
    if [ ! -x "$pico8_path" ]; then
        echo "Error: PICO-8 executable is not executable: $pico8_path"
        echo "Please make sure the file has execute permissions:"
        echo "  chmod +x \"$pico8_path\""
        exit 1
    fi
    
    echo "$pico8_path"
}

# Function to get list of configured languages
get_configured_langs() {
    local cart_folder=$1
    local cart_name=$2
    local langs=()
    
    # Find meta files that match the exact pattern
    for meta_file in "$cart_folder/meta."*".json"; do
        if [ -f "$meta_file" ]; then
            # Extract language code from filename (e.g., meta.enus.json -> enus)
            lang=$(basename "$meta_file" | sed -n 's/meta\.\([^.]*\)\.json$/\1/p')
            
            # Only add if we got a valid language code
            if [ ! -z "$lang" ]; then
                langs+=("$lang")
            fi
        fi
    done
    
    # If no meta files found, use default languages
    if [ ${#langs[@]} -eq 0 ]; then
        langs=("enus" "zhcn")
    fi
    
    # Only output the language list, no debug messages
    printf "%s\n" "${langs[@]}"
}

###########################################
# Environment Setup Functions
###########################################

# Function to check and setup environment
setup_environment() {
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
}

###########################################
# File Generation Functions
###########################################

# Function to generate template and lua files
generate_files() {
    local p8path=$1
    local lang=$2
    
    echo "Generating files for language: $lang"
    python tools/pico8i18n/gen_tpl.py "$p8path" "$lang"
    python tools/pico8i18n/gen_lua.py "$p8path" "$lang"
}

# Function to update p8 file with language settings
update_p8_language() {
    local p8path=$1
    local lang=$2
    local p8name=$3
    
    echo "Setting language to $lang..."
    sed -i "s/i18n.lang=\"[^\"]*\"/i18n.lang=\"$lang\"/" "$p8path"
    sed -i "s/#include \.\/${p8name}\.texts\.[^\.]*\.lua/#include \.\/${p8name}\.texts\.$lang\.lua/" "$p8path"
}

###########################################
# PICO-8 Automation Functions
###########################################

# Function to handle PICO-8 automation
handle_pico8_automation() {
    local p8folder=$1
    local p8name=$2
    
    # Start PICO-8
    echo "Starting PICO-8..."
    "$PICO8_PATH" -root_path . &

    # Wait for PICO-8 window to appear
    echo "Waiting for PICO-8 window..."
    while ! xdotool search --name "PICO-8" >/dev/null; do
        sleep 0.5
    done
    sleep 1  # Additional wait to ensure window is fully ready

    # Focus PICO-8 window
    echo "Focusing PICO-8 window..."
    xdotool search --name "PICO-8" windowfocus
    sleep 2

    # Change to cart directory by splitting the path
    echo "Changing to cart directory..."
    # Split the path into components
    IFS='/' read -ra path_components <<< "$p8folder"
    
    # Navigate through each component
    for component in "${path_components[@]}"; do
        echo "cd $component"
        xdotool type "cd $component"
        xdotool key Return
        sleep 0.5 
    done
    sleep 1

    # Send load command and wait for it to complete
    echo "Loading cart..."
    xdotool type "load $p8name"
    xdotool key Return
    sleep 1

    # Check if p8.png file exists in the correct directory
    if [ -f "$p8folder/$p8name.p8.png" ]; then
        echo "p8.png file exists, will need confirmation..."
        NEED_CONFIRM=true
    else
        echo "No existing p8.png file, no confirmation needed..."
        NEED_CONFIRM=false
    fi

    # Send save command and wait for it to complete
    echo "Saving cart image..."
    xdotool type "save $p8name.p8.png"
    xdotool key Return
    sleep 0.5

    # Send confirmation only if needed
    if [ "$NEED_CONFIRM" = true ]; then
        echo "Sending confirmation..."
        xdotool type "y"
        xdotool key Return
    fi

    # Wait for save to complete by checking if the file exists
    echo "Waiting for save to complete..."
    TIMEOUT=30  # 30 seconds timeout
    COUNTER=0
    while [ ! -f "$p8folder/$p8name.p8.png" ]; do
        sleep 0.5
        COUNTER=$((COUNTER + 1))
        if [ $COUNTER -ge $TIMEOUT ]; then
            echo "Error: Save operation timed out after ${TIMEOUT} seconds"
            echo "Closing PICO-8..."
            xdotool key ctrl+q
            sleep 1
            exit 1
        fi
    done
    sleep 1  # Additional wait to ensure file is fully written

    # Close PICO-8
    echo "Closing PICO-8..."
    xdotool key ctrl+q
    sleep 1
}

# Function to generate cart image
generate_cart_image() {
    local p8folder=$1
    local p8name=$2
    local lang=$3
    local template=$4
    
    echo "Generating cart image for $lang..."
    if [ -z "$template" ]; then
        python3 tools/customcart/gen_cartimage.py \
            "$p8folder" \
            "$p8name" \
            "$lang"
    else
        python3 tools/customcart/gen_cartimage.py \
            "$p8folder" \
            "$p8name" \
            "$lang" \
            "$template"
    fi
}

###########################################
# Main Build Functions
###########################################

# Function to build cart for a specific language
build_cart_for_language() {
    local lang=$1
    
    echo "Building for language: $lang"
    
    # Generate template and lua files
    generate_files "$P8PATH" "$lang"
    
    # Update p8 file with language settings
    update_p8_language "$P8PATH" "$lang" "$P8NAME"
    
    # Handle PICO-8 automation
    handle_pico8_automation "$P8FOLDER" "$P8NAME"
    
    # Generate cart image
    generate_cart_image "$P8FOLDER" "$P8NAME" "$lang" "$CART_TEMPLATE"
}

###########################################
# Main Workflow
###########################################

# Check for required tools before proceeding
check_required_tools

# Global variables
P8PATH=$1
CART_TEMPLATE=${2:-""}  # Make it empty string by default instead of 'default'

echo "Input P8PATH: $P8PATH"

# Extract folder and name more robustly
P8FOLDER="${P8PATH%/*}"
P8NAME="${P8PATH##*/}"
P8NAME="${P8NAME%.p8}"

echo "Extracted values:"
echo "  P8FOLDER: $P8FOLDER"
echo "  P8NAME: $P8NAME"

# Get PICO-8 path from config
PICO8_PATH=$(get_pico8_path)
echo "Using PICO-8 path: $PICO8_PATH"

# Setup environment
setup_environment

# Get list of configured languages
langs=($(get_configured_langs "$P8FOLDER" "$P8NAME"))
echo "Building cart for languages: ${langs[*]}"

# Build for each language
for lang in "${langs[@]}"; do
    build_cart_for_language "$lang"
done

echo "Build complete for all languages."