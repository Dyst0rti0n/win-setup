# Windows Setup
Automates the installation and configuration of a fresh Windows environment, including WSL2 with Kali Linux and essential development tools.

## Features

- **WSL2 with Kali Linux**: Installs and sets up WSL2 with Kali Linux.
- **Development Tools**: Installs essential development tools such as Git, Node.js, Python, Ruby, Go, Docker, and more.
- **Software Installation**: Installs popular software including Google Chrome, Firefox, Brave, VS Code, Docker Desktop, Slack, Postman, and Obsidian.
- **Environment Configuration**: Sets up environment variables and configures Docker, Git, and VS Code extensions.
- **Oh My Zsh**: Installs and configures Oh My Zsh with Powerlevel10k theme and useful plugins.
- **Backup and Restore**: Creates scripts for backing up and restoring your WSL environment.

## Installation

### Prerequisites

- A Windows installation (fresh is preferred) with administrative privileges.
- Internet connection.

### Steps

1. **Install Git and run script**:
This is a oneliner that installs git, then proceeds to run bootstrap.ps1 which runs win-setup.sh from it.
**Must be Administrator** - `Ctrl + r` then type `cmd` and `Ctrl + shift + enter`

   ```cmd
   @echo off & powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; if (-not (Get-Command git -ErrorAction SilentlyContinue)) { iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); choco install git -y; refreshenv }; if (Test-Path $env:USERPROFILE\Documents\windows-setup-files\win-setup) { Remove-Item -Recurse -Force $env:USERPROFILE\Documents\windows-setup-files\win-setup }; git clone https://github.com/Dyst0rti0n/win-setup.git $env:USERPROFILE\Documents\windows-setup-files\win-setup; Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File %USERPROFILE%\Documents\windows-setup-files\win-setup\bootstrap.ps1' -Verb RunAs -Wait"
   ```

2. Finished


## Optional

**Configuring Windows Terminal**
The script generates a windows-terminal-settings.json file with the configuration for Kali Linux. You need to add the contents of this file to your existing Windows Terminal settings.

Open Windows Terminal.
Go to Settings.
Copy the contents of windows-terminal-settings.json and paste it into the appropriate section of your settings.

## Contributing
Feel free to open issues or submit pull requests for improvements and bug fixes.

## License
This project is licensed under the MIT License.