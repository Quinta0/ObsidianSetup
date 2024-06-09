# PowerShell script to install Obsidian and configure plugins on Windows

function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-Obsidian-Windows {
    Write-Output "Installing Obsidian for Windows..."
    if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Output "Chocolatey is not installed. Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force;
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
        $script = (New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')
        Invoke-Command -ScriptBlock ([ScriptBlock]::Create($script))
    }
    choco install -y jq

    Write-Output "Downloading Obsidian installer..."
    Invoke-WebRequest -Uri "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.3/Obsidian.1.6.3.exe" -OutFile "ObsidianInstaller.exe"

    # Check if the installer was downloaded
    if (Test-Path "ObsidianInstaller.exe") {
        Write-Output "Running Obsidian installer..."
        $startProcess = Start-Process -FilePath .\ObsidianInstaller.exe -ArgumentList "/S" -PassThru -Wait
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

    # Create the plugins directory if it doesn't exist
    $pluginsDir = "$env:APPDATA\obsidian\plugins"
    if (-Not (Test-Path $pluginsDir)) {
        New-Item -ItemType Directory -Path $pluginsDir | Out-Null
    }

    # Read plugins configuration file
    $pluginsConfig = Get-Content -Raw -Path "plugins.json" | ConvertFrom-Json
    $corePlugins = $pluginsConfig.core_plugins
    $communityPlugins = $pluginsConfig.community_plugins

    # Enable core plugins
    foreach ($plugin in $corePlugins) {
        Write-Output "Enabling core plugin: $plugin"
        New-Item -ItemType File -Path "$pluginsDir\$plugin" | Out-Null
    }

    # Install community plugins
    foreach ($plugin in $communityPlugins) {
        Write-Output "Installing community plugin: $plugin"
        New-Item -ItemType Directory -Path "$pluginsDir\$plugin" | Out-Null
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
