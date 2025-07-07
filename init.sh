#!/bin/bash

# -----------------------------------
# CONFIGURATION
# -----------------------------------
VERSION="0.1.0"
SCRIPT_DIR="$(realpath "$(dirname "$0")/scripts")"
SCIRPTS_TARGET_DIR="$HOME/.local/bin"

# Ensure target bin directory exists
mkdir -p "$SCIRPTS_TARGET_DIR"

echo "Installing scripts from: $SCRIPT_DIR"
echo "Linking to: $SCIRPTS_TARGET_DIR"

# Process each .sh script in scripts/
for script in "$SCRIPT_DIR"/*.sh; do
    script_name="$(basename "$script" .sh)"
    target_link="$SCIRPTS_TARGET_DIR/$script_name"

    chmod +x "$script"

    # Remove existing symlink or file
    if [[ -e "$target_link" || -L "$target_link" ]]; then
        echo "Removing existing file/link: $target_link"
        rm -f "$target_link"
    fi

    ln -s "$script" "$target_link"
    echo "Linked $script_name -> $target_link"
done

# Check PATH contains ~/.local/bin
if [[ ":$PATH:" != *":$SCIRPTS_TARGET_DIR:"* ]]; then
    echo ""
    echo "Note: $SCIRPTS_TARGET_DIR is not in your PATH."
    echo "Add the following line to your shell config (~/.bashrc or ~/.zshrc):"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
else
    echo ""
    echo "All scripts are installed and available in your shell."
fi

# TODO: Change paths to the configure options 
# Apply saved configurations
ln -sf /home/raja/Projects/raja-config/configs/nvim ~/.config/nvimh
ln -sf /home/raja/Projects/raja-config/configs/zshrc ~/.config/zsh/.zshrc
ln -sf /home/raja/Projects/raja-config/sway/01-raja.conf /home/raja/.config/sway/config.d/01-raja.conf
