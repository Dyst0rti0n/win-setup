# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "You need to run this script as an Administrator." -ForegroundColor Red
    exit 1
}

Write-Host "Installing Git if not already installed..." -ForegroundColor Green
# Install Git if not already installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed. Installing Git..." -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco install git -y
} else {
    Write-Host "Git is already installed." -ForegroundColor Green
}

# Clone the repository
$repoUrl = "https://github.com/Dyst0rti0n/win-setup.git"
$cloneDir = "$env:USERPROFILE\win-setup"

if (Test-Path $cloneDir) {
    Write-Host "Repository already cloned." -ForegroundColor Green
} else {
    Write-Host "Cloning the repository..." -ForegroundColor Green
    git clone $repoUrl $cloneDir
}

# Run the setup script
$setupScript = "$cloneDir\win-setup.sh"
Write-Host "Running the setup script..." -ForegroundColor Green
& $setupScript

Write-Host "Setup script completed." -ForegroundColor Green
Write-Host "Press any key to exit..."
[System.Console]::ReadKey() | Out-Null
