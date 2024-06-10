# PowerShell script to install Obsidian and configure plugins on Windows

function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-Obsidian-Windows {
    Write-Output "Installing Obsidian for Windows..."
    if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Output "Chocolatey is not installed. Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        $script = (New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')
        Invoke-Command -ScriptBlock ([ScriptBlock]::Create($script))
    }
    choco install -y jq

    Write-Output "Downloading Obsidian installer..."
    $installerPath = "$env:TEMP\ObsidianInstaller.exe"
    Invoke-WebRequest -Uri "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.3/Obsidian.1.6.3.exe" -OutFile $installerPath

    # Check if the installer was downloaded
    if (Test-Path $installerPath) {
        Write-Output "Running Obsidian installer..."
        $startProcess = Start-Process -FilePath $installerPath -ArgumentList "/S" -PassThru -Wait
        Write-Output "Installer exit code: $($startProcess.ExitCode)"

        # Check for Obsidian executable in possible installation paths
        $obsidianPaths = @(
            "C:\Program Files\Obsidian\Obsidian.exe",
            "$env:LOCALAPPDATA\Programs\Obsidian\Obsidian.exe",
            "$env:LOCALAPPDATA\Obsidian\Obsidian.exe"
        )

        $obsidianInstalled = $false
        foreach ($path in $obsidianPaths) {
            if (Test-Path $path) {
                $obsidianInstalled = $true
                Write-Output "Obsidian found at $path"
                break
            }
        }

        if ($obsidianInstalled) {
            Write-Output "Obsidian installed successfully."
        } else {
            Write-Output "Obsidian installation failed."
            exit 1
        }
    } else {
        Write-Output "Failed to download Obsidian installer."
        exit 1
    }
}

function Install-Plugin {
    Write-Output "Installing plugins..."

    # Kill Obsidian process if running
    $obsidianProcess = Get-Process -Name "Obsidian" -ErrorAction SilentlyContinue
    if ($obsidianProcess) {
        Stop-Process -Name "Obsidian" -Force
    }

    # Define the vault path and plugins directory
    $vaultPath = "$env:USERPROFILE\Documents\ObsidianVault"  # Update this path as needed
    $pluginsDir = "$vaultPath\.obsidian\plugins"

    # Create the plugins directory if it doesn't exist
    if (-Not (Test-Path $pluginsDir)) {
        New-Item -ItemType Directory -Path $pluginsDir | Out-Null
    }

    # Read plugins configuration file
    $pluginsConfigPath = ".\plugins.json"  # Ensure this is the correct path to your plugins.json file
    if (-Not (Test-Path $pluginsConfigPath)) {
        Write-Output "plugins.json file not found."
        exit 1
    }

    $pluginsConfig = Get-Content -Raw -Path $pluginsConfigPath | ConvertFrom-Json
    $corePlugins = $pluginsConfig.core_plugins
    $communityPlugins = $pluginsConfig.community_plugins

    # Enable core plugins
    $configPath = "$vaultPath\.obsidian\config"
    if (-Not (Test-Path $configPath)) {
        Write-Output "Obsidian config not found. Ensure Obsidian has been started at least once with the vault."
        exit 1
    }

    $config = Get-Content -Raw -Path $configPath | ConvertFrom-Json
    foreach ($plugin in $corePlugins) {
        Write-Output "Enabling core plugin: $plugin"
        $config["plugin:$plugin"] = $true
    }
    $config | ConvertTo-Json -Compress | Set-Content -Path $configPath

    # Install community plugins
    foreach ($plugin in $communityPlugins) {
        Write-Output "Installing community plugin: $plugin"
        $pluginName = $plugin -replace '/','-'
        $pluginUrl = "https://github.com/$plugin/releases/latest/download/main.js"
        $pluginDir = "$pluginsDir\$pluginName"
        if (-Not (Test-Path $pluginDir)) {
            New-Item -ItemType Directory -Path $pluginDir | Out-Null
        }
        Invoke-WebRequest -Uri $pluginUrl -OutFile "$pluginDir\main.js"
    }

    Write-Output "Plugins installed successfully."
}

if (-Not (Test-Administrator)) {
    Write-Output "This script needs to be run as an administrator. Re-launching with elevated privileges..."
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Directly run Windows installation and plugin configuration
Install-Obsidian-Windows
Install-Plugin
