# Test-ObsidianInstallation.ps1

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
    Start-Sleep -Seconds 5

    Write-Output "Downloading Obsidian installer..."
    wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.3/Obsidian.1.6.3.exe -OutFile ObsidianInstaller.exe

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
        $pluginsConfig = Get-Content -Raw -Path "invalid_plugins.json" | ConvertFrom-Json
    } catch {
        Write-Output "Caught error parsing invalid plugins.json as expected: $_"
    }
}

# Run tests
Test-AdminPrivilege
Test-ChocolateyInstallation
Test-ObsidianDownload
Test-InvalidPluginConfig
