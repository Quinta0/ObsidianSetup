#!/bin/bash

install_obsidian_linux() {
    echo "Installing Obsidian for Linux..."
    sudo apt update
    sudo apt install -y wget jq

    wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.3/Obsidian-1.6.3.AppImage -O obsidian.AppImage
    chmod +x obsidian.AppImage
    ./obsidian.AppImage &

    # Simulate creating a command alias for testing
    sudo ln -sf $(pwd)/obsidian.AppImage /usr/local/bin/obsidian
}

install_obsidian_macos() {
    echo "Installing Obsidian for macOS..."
    which -s brew
    if [[ $? != 0 ]] ; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install wget jq

    wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.3/Obsidian-1.6.3-universal.dmg -O Obsidian.dmg
    hdiutil attach Obsidian.dmg
    cp -r /Volumes/Obsidian/Obsidian.app /Applications/
    hdiutil detach /Volumes/Obsidian
    open /Applications/Obsidian.app &

    # Simulate creating a command alias for testing
    sudo ln -sf /Applications/Obsidian.app/Contents/MacOS/Obsidian /usr/local/bin/obsidian
}

install_plugins() {
    echo "Installing plugins..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        pkill Obsidian
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        pkill Obsidian
    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        taskkill /IM Obsidian.exe /F
    fi

    if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "darwin"* ]]; then
        mkdir -p ~/.config/obsidian/plugins
    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        mkdir -p "$APPDATA\obsidian\plugins"
    fi

    PLUGINS_FILE=plugins.json
    CORE_PLUGINS=$(jq -r '.core_plugins[]' $PLUGINS_FILE)
    COMMUNITY_PLUGINS=$(jq -r '.community_plugins[]' $PLUGINS_FILE)

    for plugin in $CORE_PLUGINS; do
        echo "Enabling core plugin: $plugin"
        # Simulate enabling core plugin by creating a file
        touch "$HOME/.config/obsidian/plugins/$plugin"
    done

    for plugin in $COMMUNITY_PLUGINS; do
        echo "Installing community plugin: $plugin"
        # Simulate installing community plugin by creating a directory
        mkdir -p "$HOME/.config/obsidian/plugins/$plugin"
    done

    echo "Plugins installed successfully!"
}

echo "Please select your operating system:"
echo "L) Linux"
echo "M) macOS"
echo "W) Windows"

read -p "Enter your choice: " os_choice

case "$os_choice" in
    [Ll]) install_obsidian_linux ;;
    [Mm]) install_obsidian_macos ;;
    [Ww]) echo "Please run the script install_obsidian.ps1 in PowerShell for Windows installation." ;;
    *) echo "Invalid choice. Exiting." ;;
esac

install_plugins
