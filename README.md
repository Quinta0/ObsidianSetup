# Obsidian Setup Script

This repository contains scripts to automatically install Obsidian and configure it with your desired plugins on Linux, macOS, and Windows.

## Files

- `install_obsidian.sh`: Script to install Obsidian and configure plugins on Linux and macOS.
- `install_obsidian.ps1`: Script to install Obsidian and configure plugins on Windows.
- `test_install_obsidian.sh`: Script to test if Obsidian and the plugins are installed correctly.
- `plugins.json`: Configuration file listing the core and community plugins to be installed.

## Prerequisites

### Windows

- Git Bash: [Download and install Git for Windows](https://gitforwindows.org/)
- PowerShell with administrative privileges

### Linux

- wget
- jq

### macOS

- Homebrew: [Install Homebrew](https://brew.sh/)

## Usage

### 1. Clone the Repository

Open your terminal or Git Bash and clone the repository:

```bash
git clone git@github.com:Quinta0/ObsidianSetup.git
cd ObsidianSetup
```

### 2. For Windows
1) Open PowerShell as Administrator.

2) Navigate to the repository directory:
```bash
cd ObsidianSetup
```

3) Run the PowerShell script:
```bash
.\install_obsidian.ps1
```

### 3. For Linux and macOS
1) Open your terminal.

2) Navigate to the repository directory:
```bash
cd ObsidianSetup
```

3) Run the Bash script:
```bash
./install_obsidian.sh
```
4) Follow the prompts to select your operating system.

## Configuration
`plugins.json`
This file lists the core and community plugins to be installed. Modify this file to add or remove plugins as needed.
```json
{
  "core_plugins": [
    "core-plugin-id-1",
    "core-plugin-id-2"
  ],
  "community_plugins": [
    "community-plugin-id-1",
    "community-plugin-id-2"
  ]
}
```

## Troubleshooting
### Obsidian Installation Failed
If the installation script fails to install Obsidian, check the following:

- Ensure you have the required dependencies installed.
- Check the output of the script for any error messages.
- Verify that the download URL for Obsidian is correct.
### Plugins Not Enabled/Installed
If the plugins are not enabled or installed:

- Ensure the plugins.json file is correctly formatted and the plugin IDs are correct.
- Check the output of the script for any error messages.
- Verify the plugin files/directories are created in the appropriate location.

## License
This project is licensed under the MIT License.
