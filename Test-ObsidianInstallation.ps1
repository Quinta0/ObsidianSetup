# Define Test-Administrator function
function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-AdminPrivilege {
    if (-Not (Test-Administrator)) {
        Write-Output "Running as non-admin user for testing admin check..."
    } else {
        Write-Output "Running as admin user for testing admin check..."
    }
}

function Test-ChocolateyInstallation {
    Write-Output "Simulating environment without Chocolatey..."
    Remove-Item -Path "C:\ProgramData\chocolatey" -Recurse -Force -ErrorAction SilentlyContinue

    if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Output "Chocolatey is not installed. Proceeding with installation..."
    } else {
        Write-Output "Chocolatey is already installed."
    }
}

function Test-ObsidianDownload {
    Write-Output "Simulating download failure..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyEnable" -Value 1
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyServer" -Value "127.0.0.1:8080"
    Start-Sleep -Seconds 10 # Ensure proxy settings take effect

    Write-Output "Downloading Obsidian installer..."
    try {
        Invoke-WebRequest -Uri "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.3/Obsidian.1.6.3.exe" -OutFile "ObsidianInstaller.exe" -ErrorAction Stop
    } catch {
        Write-Output "Download failed as expected."
    }

    if (Test-Path "ObsidianInstaller.exe") {
        Write-Output "Download succeeded unexpectedly."
    } else {
        Write-Output "Download failed as expected."
    }

    # Clean up proxy settings
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyEnable" -Value 0
}

# Simulate invalid plugins.json file
Set-Content -Path "invalid_plugins.json" -Value @"
{
  "core_plugins": ["plugin1", "plugin2"]
  "community_plugins": ["plugin3", "plugin4"]
}
"@

function Test-InvalidPluginConfig {
    Write-Output "Testing with invalid plugins.json..."
    try {
        $null = Get-Content -Raw -Path "invalid_plugins.json" | ConvertFrom-Json
    } catch {
        Write-Output "Caught error parsing invalid plugins.json as expected: $_"
    }
}

function Test-ObsidianInstallation {
    Write-Output "Testing Obsidian installation..."

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

# Run tests
Test-AdminPrivilege
Test-ChocolateyInstallation
Test-ObsidianDownload
Test-InvalidPluginConfig
Test-ObsidianInstallation
