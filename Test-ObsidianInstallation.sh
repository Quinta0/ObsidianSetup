#!/bin/bash

function test_os_selection {
    echo "Testing OS selection..."
    echo "L" | ./install_obsidian.sh
    echo "M" | ./install_obsidian.sh
    echo "W" | ./install_obsidian.sh
}

function test_dependencies_installation {
    echo "Simulating environment without wget and jq..."
    sudo apt remove -y wget jq

    echo "Installing dependencies..."
    sudo apt update
    sudo apt install -y wget jq

    if ! command -v wget &> /dev/null || ! command -v jq &> /dev/null; then
        echo "Failed to install dependencies."
    else
        echo "Dependencies installed successfully."
    fi
}

function test_obsidian_download_failure {
    echo "Simulating download failure..."
    sudo iptables -A OUTPUT -p tcp --dport 443 -j REJECT

    echo "Downloading Obsidian..."
    wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.3/Obsidian-1.6.3.AppImage -O obsidian.AppImage
    if [ ! -f obsidian.AppImage ]; then
        echo "Download failed as expected."
    else
        echo "Download succeeded unexpectedly."
    fi

    # Clean up iptables rule
    sudo iptables -D OUTPUT -p tcp --dport 443 -j REJECT
}

# Create an invalid plugins.json file
echo '{
  "core_plugins": ["plugin1", "plugin2"]
  "community_plugins": ["plugin3", "plugin4"]
' > invalid_plugins.json

function test_invalid_plugins_config {
    echo "Testing with invalid plugins.json..."
    if jq . invalid_plugins.json; then
        echo "Invalid plugins.json parsed unexpectedly."
    else
        echo "Caught error parsing invalid plugins.json as expected."
    fi
}

# Run tests
test_os_selection
test_dependencies_installation
test_obsidian_download_failure
test_invalid_plugins_config
