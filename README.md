# win-setup
Windows Setup script! This script automates the installation and configuration of a fresh Windows environment, including WSL2 with Kali Linux and essential development tools.

## Features

- **WSL2 with Kali Linux**: Installs and sets up WSL2 with Kali Linux.
- **Development Tools**: Installs essential development tools such as Git, Node.js, Python, Ruby, Go, Docker, and more.
- **Software Installation**: Installs popular software including Google Chrome, Firefox, Brave, VS Code, Docker Desktop, Slack, Postman, and Obsidian.
- **Environment Configuration**: Sets up environment variables and configures Docker, Git, and VS Code extensions.
- **Oh My Zsh**: Installs and configures Oh My Zsh with Powerlevel10k theme and useful plugins.
- **Backup and Restore**: Creates scripts for backing up and restoring your WSL environment.

## Installation

### Prerequisites

- A fresh Windows installation with administrative privileges.
- Internet connection.

### Steps

1. **Download the Bootstrap Script**:
   Save the `bootstrap.ps1` script to your local machine.

2. **Run the Bootstrap Script**:
   Open a PowerShell terminal with administrative privileges and run the bootstrap script:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\bootstrap.ps1
   ```

3. **Follow the Prompts**:
The script will guide you through the installation process, prompting you for necessary inputs.

4. **Complete the Kali Linux Setup**:
After the script completes, open Kali Linux from your Windows Terminal and re-run the same script to complete the Kali Linux environment setup:

```bash
bash ~/ultimate-windows-setup/setup-windows-wsl.sh
```

5. **Configuring Windows Terminal**
The script generates a windows-terminal-settings.json file with the configuration for Kali Linux. You need to add the contents of this file to your existing Windows Terminal settings.

Open Windows Terminal.
Go to Settings.
Copy the contents of windows-terminal-settings.json and paste it into the appropriate section of your settings.
Contributing
Feel free to open issues or submit pull requests for improvements and bug fixes.

License
This project is licensed under the MIT License.