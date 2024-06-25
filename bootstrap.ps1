# Function to log messages
function Write-Log {
    param (
        [string]$Message,
        [string]$Status
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $Status - $Message"
    Add-Content -Path $logFilePath -Value $logMessage
    Write-Host "$logMessage"
}

# Function to remove pre-installed Windows tools
function Remove-PreInstalledApps {
    param (
        [string]$AppName
    )
    try {
        Get-AppxPackage -Name $AppName | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $AppName | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        Write-Log "$AppName removed successfully." "SUCCESS"
    } catch {
        Write-Log "Failed to remove $AppName. Error: $_" "ERROR"
    }
}

# Set up paths
$setupDir = "$env:USERPROFILE\Documents\windows-setup-files"
$logFilePath = "$setupDir\installation.log"
$repoUrl = "https://github.com/Dyst0rti0n/win-setup.git"
$cloneDir = "$setupDir\win-setup"

# Ensure setup directory exists
if (-not (Test-Path $setupDir)) {
    New-Item -Path $setupDir -ItemType Directory
}

# Initialize log file
if (Test-Path $logFilePath) {
    Remove-Item -Path $logFilePath -Force
}
New-Item -Path $logFilePath -ItemType File

# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Log "You need to run this script as an Administrator." "ERROR"
    exit 1
}

Write-Log "Installing Git if not already installed..." "INFO"
# Install Git if not already installed
try {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Log "Git is not installed. Installing Git..." "INFO"
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        choco install git -y
        refreshenv
        Write-Log "Git installed successfully." "SUCCESS"
    } else {
        Write-Log "Git is already installed." "SUCCESS"
    }
} catch {
    Write-Log "Failed to install Git. Error: $_" "ERROR"
}

# Clone the repository
try {
    if (Test-Path $cloneDir) {
        Remove-Item -Recurse -Force $cloneDir
    }
    Write-Log "Cloning the repository..." "INFO"
    git clone $repoUrl $cloneDir
    Write-Log "Repository cloned successfully." "SUCCESS"
} catch {
    Write-Log "Failed to clone the repository. Error: $_" "ERROR"
}

# Remove pre-installed Windows tools
$appsToRemove = @(
    "Microsoft.549981C3F5F10" # Cortana
    "Microsoft.MicrosoftEdge" # Edge
    "Microsoft.MixedReality.Portal" # Mixed Reality Portal
    "Microsoft.WindowsFeedbackHub" # Feedback Hub (News)
    "Microsoft.SkypeApp" # Skype
    "Microsoft.MicrosoftSolitaireCollection" # Solitaire and Games
    "Microsoft.XboxApp" # Xbox
    "Microsoft.Xbox.TCUI" # Xbox TCUI
    "Microsoft.XboxGameOverlay" # Xbox Game Overlay
    "Microsoft.XboxGamingOverlay" # Xbox Gaming Overlay
    "Microsoft.XboxIdentityProvider" # Xbox Identity Provider
    "Microsoft.XboxSpeechToTextOverlay" # Xbox Speech To Text Overlay
    "Microsoft.People" # People
    "Microsoft.ZuneMusic" # Zune Music
    "Microsoft.ZuneVideo" # Zune Video
)

foreach ($app in $appsToRemove) {
    Remove-PreInstalledApps -AppName $app
}

# Run the setup script
$setupScript = "$cloneDir\win-setup.sh"
try {
    Write-Log "Running the setup script..." "INFO"
    & $setupScript
    Write-Log "Setup script completed successfully." "SUCCESS"
} catch {
    Write-Log "Failed to run the setup script. Error: $_" "ERROR"
}

# Final report
Write-Host "==================== Installation Report ===================="
Get-Content -Path $logFilePath
Write-Host "============================================================"
Write-Host "Press any key to exit..."
[System.Console]::ReadKey() | Out-Null
