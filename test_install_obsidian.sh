#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Run the installation script
echo "Running installation script..."
./install_obsidian.sh

# Check if Obsidian is installed
echo "Checking Obsidian installation..."
if command_exists obsidian; then
    echo "Obsidian installation: PASSED"
else
    echo "Obsidian installation: FAILED"
    exit 1
fi

# Check if core plugins are enabled
echo "Checking core plugins..."
CORE_PLUGINS=("core-plugin-id-1" "core-plugin-id-2")
for plugin in "${CORE_PLUGINS[@]}"; do
    if [ -f "$HOME/.config/obsidian/plugins/$plugin" ]; then
        echo "Core plugin $plugin: ENABLED"
    else
        echo "Core plugin $plugin: NOT ENABLED"
    fi
done

# Check if community plugins are installed
echo "Checking community plugins..."
COMMUNITY_PLUGINS=("community-plugin-id-1" "community-plugin-id-2")
for plugin in "${COMMUNITY_PLUGINS[@]}"; do
    if [ -d "$HOME/.config/obsidian/plugins/$plugin" ]; then
        echo "Community plugin $plugin: INSTALLED"
    else
        echo "Community plugin $plugin: NOT INSTALLED"
    fi
done

echo "All tests completed."
