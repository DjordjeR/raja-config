#!/bin/bash

# -----------------------------------
# CONFIGURATION
# -----------------------------------

VERSION="0.2.0"
WORKING_DIR="$(realpath "$(dirname "$0")/..")"
SCRIPT_DIR="$WORKING_DIR/bin"
SCRIPTS_TARGET_DIR="$HOME/.local/bin"

echo "Installing bin from: $SCRIPT_DIR"
echo "Linking to: $SCRIPTS_TARGET_DIR"

mkdir -p "$SCRIPTS_TARGET_DIR"

# Process each .sh script in bin/
for script in "$SCRIPT_DIR"/*.sh; do
    script_name="$(basename "$script" .sh)"
    target_link="$SCRIPTS_TARGET_DIR/$script_name"

    chmod +x "$script"

    # Remove existing symlink or file
    if [[ -e "$target_link" || -L "$target_link" ]]; then
        echo "Removing existing file/link: $target_link"
        rm -f "$target_link"
    fi

    ln -s "$script" "$target_link"
    echo "Linked $script_name -> $target_link"
done
