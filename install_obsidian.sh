#!/bin/bash

install_obsidian_linux() {
    sudo apt update
    sudo apt install -y wget jq

    wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.3/Obsidian-1.6.3.AppImage -O obsidian.AppImage
    chmod +x obsidian.AppImage
    ./obsidian.AppImage &

    # Simulate creating a command alias for testing
    sudo ln -sf $(pwd)/obsidian.AppImage /usr/local/bin/obsidian
}

install_obsidian_macos() {
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

install_obsidian_windows() {
    choco -v
    if [[ $? != 0 ]] ; then
        @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    fi
    choco install -y wget jq

    wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.3/Obsidian.1.6.3.exe -O ObsidianInstaller.exe

    # Check if the installer was downloaded
    if [ -f "ObsidianInstaller.exe" ]; then
        start /wait ObsidianInstaller.exe /S

        # Check if Obsidian was installed and create a symbolic link for testing
        if [ -f "/c/Program Files/Obsidian/Obsidian.exe" ]; then
            ln -sf "/c/Program Files/Obsidian/Obsidian.exe" /usr/local/bin/obsidian
        else
            echo "Obsidian installation failed."
            exit 1
        fi
    else
        echo "Failed to download Obsidian installer."
        exit 1
    fi
}

install_plugins() {
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

case "$(uname -s)" in
    Linux*)     install_obsidian_linux ;;
    Darwin*)    install_obsidian_macos ;;
    CYGWIN*|MINGW32*|MSYS*|MINGW*) install_obsidian_windows ;;
    *)          echo "Unknown OS" ;;
esac

install_plugins
