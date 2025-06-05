#!/bin/bash

set -e

###########################################
# Parameter Parsing Functions
###########################################

# Default values
P8PATH=""
CART_TEMPLATE=""
QRCODE_MODE=""
SHOULD_MINIFY="false"

# Function to display usage
show_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --cart <path>          Path to the PICO-8 cart file (required)"
    echo "  --template <path>      Path to custom cart template image (optional)"
    echo "  --qrcode <mode>        QR code mode for cart image (optional)"
    echo "  --minify               Enable code minification (optional, default: disabled)"
    echo "  --help                 Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 --cart game.p8 --template custom.png --qrcode qrcode --minify"
    exit 1
}

# Function to parse named parameters
parse_parameters() {
    if [ $# -eq 0 ]; then
        show_usage
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            --cart)
                P8PATH="$2"
                shift 2
                ;;
            --template)
                CART_TEMPLATE="$2"
                shift 2
                ;;
            --qrcode)
                QRCODE_MODE="$2"
                shift 2
                ;;
            --minify)
                SHOULD_MINIFY="true"
                shift
                ;;
            --help)
                show_usage
                ;;
            *)
                echo "Unknown parameter: $1"
                show_usage
                ;;
        esac
    done

    # Validate required parameters
    if [ -z "$P8PATH" ]; then
        echo "Error: --cart parameter is required"
        show_usage
    fi
}

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
    for meta_file in "$cart_folder/$cart_name.meta."*".json"; do
        if [ -f "$meta_file" ]; then
            # Extract language code from filename (e.g., celestecn.meta.zhcn.json -> zhcn)
            lang=$(basename "$meta_file" | sed -n 's/.*\.meta\.\([^.]*\)\.json$/\1/p')
            
            # Only add if we got a valid language code
            if [ ! -z "$lang" ]; then
                langs+=("$lang")
            fi
        fi
    done
    
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
    local cart_folder=$(dirname "$p8path")
    local cart_name=$(basename "$p8path" .p8)
    local meta_file="$cart_folder/$cart_name.meta.$lang.json"
    
    # Skip if meta file doesn't exist
    if [ ! -f "$meta_file" ]; then
        echo "Skipping language $lang - meta file does not exist"
        return
    fi
    
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
# Main Build Functions
###########################################

# Function to generate cart PNG using shrinko8
generate_cart_png() {
    local p8folder=$1
    local p8name=$2
    local should_minify=$3
    
    echo "Generating cart PNG using shrinko8..."
    local input_path="$p8folder/$p8name.p8"
    local output_path="$p8folder/$p8name.p8.png"
    
    # Run shrinko8 to generate PNG
    if [ "$should_minify" = "true" ]; then
        python3 deps/shrinko8/shrinko8.py "$input_path" "$output_path" --minify-safe-only
    else
        python3 deps/shrinko8/shrinko8.py "$input_path" "$output_path"
    fi
    
    # Check if the file was generated successfully
    if [ ! -f "$output_path" ]; then
        echo "Error: Failed to generate cart PNG using shrinko8"
        exit 1
    fi
    
    echo "Successfully generated cart PNG at: $output_path"
}

# Function to generate cart image
generate_cart_image() {
    local p8folder=$1
    local p8name=$2
    local lang=$3
    local template=$4
    local qrcode_mode=$5
    
    echo "Generating cart image for $lang..."
    
    # Build the command with the new argparse interface
    local cmd="python3 tools/customcart/gen_cartimage.py \"$p8folder\" \"$p8name\" \"$lang\""
    
    # Add template if provided
    if [ -n "$template" ]; then
        cmd="$cmd --template \"$template\""
    fi
    
    # Add qrcode mode if provided
    if [ -n "$qrcode_mode" ]; then
        cmd="$cmd --qrcode \"$qrcode_mode\""
    fi
    
    # Execute the command
    eval "$cmd"
}

# Function to build cart for a specific language
build_cart_for_language() {
    local lang=$1
    local should_minify=$2
    
    echo "Building for language: $lang"
    
    # Generate template and lua files
    generate_files "$P8PATH" "$lang"
    
    # Update p8 file with language settings
    update_p8_language "$P8PATH" "$lang" "$P8NAME"
    
    # Generate cart PNG using shrinko8
    generate_cart_png "$P8FOLDER" "$P8NAME" "$should_minify"
    
    # Generate cart image
    generate_cart_image "$P8FOLDER" "$P8NAME" "$lang" "$CART_TEMPLATE" "$QRCODE_MODE"
}

###########################################
# Main Workflow
###########################################

# Parse command line parameters
parse_parameters "$@"

# Check for required tools before proceeding
check_required_tools

echo "Input P8PATH: $P8PATH"
echo "Template: $CART_TEMPLATE"
echo "QR Code Mode: $QRCODE_MODE"
echo "Minification enabled: $SHOULD_MINIFY"

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
    build_cart_for_language "$lang" "$SHOULD_MINIFY"
done

echo "Build complete for all languages."