#!/bin/bash

# Color variables
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_welcome_message() {
  echo -e "${CYAN}"
  echo "*********************************************"
  echo "*                                           *"
  echo "*  Welcome to the Ultimate Setup Script!    *"
  echo "*                                           *"
  echo "*********************************************"
  echo -e "${NC}"
}

prompt_user() {
  read -p "$1 (y/n): " choice
  case "$choice" in 
    y|Y ) return 0;;
    n|N ) return 1;;
    * ) echo "Invalid input"; prompt_user "$1";;
  esac
}

install_wsl2_kali() {
  echo -e "${GREEN}Enabling WSL and installing WSL2 and Kali Linux...${NC}"
  echo "powershell -Command 'Start-Process powershell -ArgumentList \"dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart\" -Verb RunAs'"
  echo "powershell -Command 'Start-Process powershell -ArgumentList \"dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart\" -Verb RunAs'"
  echo "powershell -Command 'wsl --set-default-version 2'"
  echo "powershell -Command 'wsl --install -d kali-linux'"
}

install_chocolatey_and_software() {
  echo -e "${GREEN}Installing Chocolatey...${NC}"
  echo "powershell -NoProfile -ExecutionPolicy Bypass -Command 'Set-ExecutionPolicy Bypass -Scope Process; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(\"https://chocolatey.org/install.ps1\"))'"

  echo -e "${GREEN}Installing common software...${NC}"
  echo "choco install -y googlechrome firefox vscode git nodejs python 7zip notepadplusplus docker-desktop slack postman cmake ruby go mongodb openjdk17 maven"

  echo -e "${GREEN}Setting up environment variables...${NC}"
  echo "powershell -Command '[Environment]::SetEnvironmentVariable(\"JAVA_HOME\", \"C:\\Program Files\\OpenJDK\\openjdk-17\", \"Machine\")'"
  echo "powershell -Command '[Environment]::SetEnvironmentVariable(\"Path\", $env:Path + \";C:\\Program Files\\OpenJDK\\openjdk-17\\bin\", \"Machine\")'"
  echo "powershell -Command '[Environment]::SetEnvironmentVariable(\"Path\", $env:Path + \";C:\\Program Files\\Git\\cmd\", \"Machine\")'"
  echo "powershell -Command '[Environment]::SetEnvironmentVariable(\"Path\", $env:Path + \";C:\\Program Files\\nodejs\", \"Machine\")'"
  echo "powershell -Command '[Environment]::SetEnvironmentVariable(\"Path\", $env:Path + \";C:\\Program Files\\Python39\\Scripts\", \"Machine\")'"
  echo "powershell -Command '[Environment]::SetEnvironmentVariable(\"Path\", $env:Path + \";C:\\Program Files\\Python39\", \"Machine\")'"
  echo "powershell -Command '[Environment]::SetEnvironmentVariable(\"Path\", $env:Path + \";C:\\Program Files (x86)\\CMake\\bin\", \"Machine\")'"
  echo "powershell -Command '[Environment]::SetEnvironmentVariable(\"Path\", $env:Path + \";C:\\Program Files\\Docker\\Docker\\resources\\bin\", \"Machine\")'"
  echo "powershell -Command '[Environment]::SetEnvironmentVariable(\"Path\", $env:Path + \";C:\\Program Files\\Postman\", \"Machine\")'"
  echo "powershell -Command '[Environment]::SetEnvironmentVariable(\"Path\", $env:Path + \";C:\\Program Files\\Go\\bin\", \"Machine\")'"
  echo "powershell -Command '[Environment]::SetEnvironmentVariable(\"Path\", $env:Path + \";C:\\Ruby30-x64\\bin\", \"Machine\")'"
}

configure_git_and_ssh() {
  echo -e "${YELLOW}Configuring Git...${NC}"
  echo "git config --global user.name 'Your Name'"
  echo "git config --global user.email 'you@example.com'"
  echo "git config --global core.editor 'code --wait'"
  echo "git config --global merge.tool 'code --wait'"
  echo "git config --global diff.tool 'code --wait'"

  echo -e "${YELLOW}Setting up SSH keys for GitHub...${NC}"
  echo "ssh-keygen -t rsa -b 4096 -C 'you@example.com' -f ~/.ssh/id_rsa -N ''"
  echo "powershell -Command 'Start-Process powershell -ArgumentList \"Get-Content ~/.ssh/id_rsa.pub | clip\" -Verb RunAs'"
  echo -e "${GREEN}SSH key has been copied to the clipboard. Add it to your GitHub account.${NC}"
}

install_vscode_extensions() {
  echo -e "${GREEN}Installing VS Code extensions...${NC}"
  echo "code --install-extension ms-python.python"
  echo "code --install-extension ms-vscode.cpptools"
  echo "code --install-extension ms-azuretools.vscode-docker"
  echo "code --install-extension ms-vscode.go"
  echo "code --install-extension redhat.java"
  echo "code --install-extension eamodio.gitlens"
  echo "code --install-extension esbenp.prettier-vscode"
}

configure_docker_windows() {
  echo -e "${GREEN}Configuring Docker for Windows...${NC}"
  echo "mkdir -p ~/.docker"
  echo "echo '{\"experimental\": \"enabled\", \"features\": {\"buildkit\": true}}' > ~/.docker/config.json"
}

configure_windows_terminal() {
  echo -e "${GREEN}Configuring Windows Terminal...${NC}"
  echo "cp ~/setup-scripts/assets/background.jpg ~/"
  echo '{
    "guid": "{your-wsl-guid}",
    "name": "Kali Linux",
    "source": "Windows.Terminal.Wsl",
    "backgroundImage": "file:///mnt/c/Users/your-username/background.jpg",
    "backgroundImageOpacity": 0.5
  }' > windows-terminal-settings.json
  echo -e "${CYAN}Add the contents of windows-terminal-settings.json to your Windows Terminal settings file.${NC}"
}

create_backup_restore_scripts() {
  echo -e "${GREEN}Creating backup and restore scripts...${NC}"
  echo "mkdir -p ~/scripts"
  echo "echo '#!/bin/bash\ntar -cvzf ~/wsl-backup.tar.gz ~/' > ~/scripts/backup.sh"
  echo "chmod +x ~/scripts/backup.sh"

  echo "echo '#!/bin/bash\ntar -xvzf ~/wsl-backup.tar.gz -C ~/' > ~/scripts/restore.sh"
  echo "chmod +x ~/scripts/restore.sh"
}

install_oh_my_zsh() {
  echo -e "${GREEN}Installing Oh My Zsh...${NC}"
  echo "sh -c \"$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
  echo "chsh -s $(which zsh)"

  echo -e "${GREEN}Installing Powerlevel10k theme...${NC}"
  echo "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  echo "sed -i 's/ZSH_THEME=\".*\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/' ~/.zshrc"

  echo -e "${GREEN}Installing Zsh plugins...${NC}"
  echo "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
  echo "git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
  echo "sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc"
}

setup_kali_environment() {
  echo -e "${GREEN}Setting up Kali Linux environment...${NC}"

  echo -e "${GREEN}Installing essential Linux packages...${NC}"
  echo "sudo apt update"
  echo "sudo apt upgrade -y"
  echo "sudo apt install -y build-essential git curl wget zsh vim htop"

  echo -e "${GREEN}Installing Node Version Manager (nvm)...${NC}"
  echo "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash"
  echo "export NVM_DIR=\"$HOME/.nvm\""
  echo "[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\""
  echo "nvm install --lts"

  echo -e "${GREEN}Installing Python and virtualenv...${NC}"
  echo "sudo apt install -y python3 python3-pip python3-venv"

  echo -e "${GREEN}Cloning and applying custom dotfiles...${NC}"
  echo "git clone https://github.com/your-username/dotfiles.git ~/dotfiles"
  echo "cd ~/dotfiles"
  echo "./install.sh"

  echo -e "${GREEN}Setting up development environments...${NC}"
  echo "sudo apt install -y openjdk-11-jdk"
  echo "sudo apt install -y ruby-full"
  echo "wget https://golang.org/dl/go1.17.6.linux-amd64.tar.gz"
  echo "sudo tar -C /usr/local -xzf go1.17.6.linux-amd64.tar.gz"
  echo "echo 'export PATH=\$PATH:/usr/local/go/bin' >> ~/.profile"
  echo "source ~/.profile"

  create_backup_restore_scripts
  install_oh_my_zsh
}

main() {
  print_welcome_message

  if prompt_user "Do you want to enable WSL and install WSL2 and Kali Linux?"; then
    install_wsl2_kali
  fi

  install_chocolatey_and_software
  configure_docker_windows
  install_vscode_extensions
  configure_windows_terminal
  configure_git_and_ssh

  echo -e "${GREEN}Setup complete. Please open Kali Linux from your Windows Terminal and run the following command to complete the setup:${NC}"
  echo -e "${CYAN}bash ~/setup-scripts/setup-kali.sh${NC}"
}

main
