#!/bin/bash

install_obsidian_linux() {
    echo "Installing Obsidian for Linux..."
    sudo apt update
    sudo apt install -y wget jq

    wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.3/Obsidian-1.6.3.AppImage -O obsidian.AppImage
    chmod +x obsidian.AppImage
    ./obsidian.AppImage &

    # Wait a bit to ensure Obsidian initializes its config
    sleep 10
    pkill -f obsidian.AppImage

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

    # Wait a bit to ensure Obsidian initializes its config
    sleep 10
    pkill Obsidian

    # Simulate creating a command alias for testing
    sudo ln -sf /Applications/Obsidian.app/Contents/MacOS/Obsidian /usr/local/bin/obsidian
}

install_plugins() {
    echo "Installing plugins..."

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        pkill -f obsidian.AppImage
        CONFIG_DIR="$HOME/.config/obsidian"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        pkill Obsidian
        CONFIG_DIR="$HOME/Library/Application Support/obsidian"
    fi

    mkdir -p "$CONFIG_DIR/plugins"

    PLUGINS_FILE=plugins.json
    CORE_PLUGINS=$(jq -r '.core_plugins[]' $PLUGINS_FILE)
    COMMUNITY_PLUGINS=$(jq -r '.community_plugins[]' $PLUGINS_FILE)

    # Enable core plugins
    CONFIG_FILE="$CONFIG_DIR/config"
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "{}" > "$CONFIG_FILE"
    fi

    for plugin in $CORE_PLUGINS; do
        echo "Enabling core plugin: $plugin"
        jq ". + {\"plugin:$plugin\": true}" "$CONFIG_FILE" > tmp.json && mv tmp.json "$CONFIG_FILE"
    done

    # Install community plugins
    for plugin in $COMMUNITY_PLUGINS; do
        echo "Installing community plugin: $plugin"
        PLUGIN_NAME=$(echo $plugin | sed 's/\//-/g')
        PLUGIN_URL="https://github.com/$plugin/releases/latest/download/main.js"
        PLUGIN_DIR="$CONFIG_DIR/plugins/$PLUGIN_NAME"
        mkdir -p "$PLUGIN_DIR"
        wget "$PLUGIN_URL" -O "$PLUGIN_DIR/main.js" || echo "Failed to download plugin $plugin"
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
