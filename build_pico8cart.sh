#!/bin/bash

set -e

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

# Function to handle PICO-8 automation
handle_pico8_automation() {
    local p8folder=$1
    local p8name=$2
    
    # Start PICO-8
    echo "Starting PICO-8..."
    /home/hp/apps/pico-8/pico8 -root_path . &

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

# Main execution
setup_environment

# Get list of configured languages
langs=($(get_configured_langs "$P8FOLDER" "$P8NAME"))
echo "Building cart for languages: ${langs[*]}"

# Build for each language
for lang in "${langs[@]}"; do
    build_cart_for_language "$lang"
done

echo "Build complete for all languages."