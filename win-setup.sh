#!/bin/bash

# Color variables
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print a welcome message with colors
print_welcome_message() {
  echo -e "${CYAN}"
  echo "*********************************************"
  echo "*                                           *"
  echo "*  Welcome to Dystortions Windows Setup!    *"
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

# Function to prompt for text input
prompt_text() {
  read -p "$1: " input
  echo "$input"
}

# Function to check if WSL is installed
check_wsl_installed() {
  wsl --list &> /dev/null
  return $?
}

# Function to prompt user for WSL reset
prompt_wsl_reset() {
  echo -e "${RED}WSL is already installed on your system.${NC}"
  if prompt_user "Do you want to reset WSL for a fresh installation? All existing WSL data will be deleted."; then
    echo -e "${RED}Warning: This will delete all your WSL data!${NC}"
    if prompt_user "Are you sure you want to proceed?"; then
      wsl --unregister $(wsl --list --quiet)
    else
      echo -e "${YELLOW}Aborted WSL reset.${NC}"
      exit 1
    fi
  else
    echo -e "${YELLOW}Keeping existing WSL installation.${NC}"
    return 1
  fi
}

# Function to enable WSL and install WSL2 and Kali Linux
install_wsl2_kali() {
  echo -e "${GREEN}Enabling WSL and installing WSL2 and Kali Linux...${NC}"
  powershell -Command "Start-Process powershell -ArgumentList 'dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart' -Verb RunAs"
  powershell -Command "Start-Process powershell -ArgumentList 'dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart' -Verb RunAs"
  powershell -Command "wsl --set-default-version 2"
  powershell -Command "wsl --install -d kali-linux"

  echo -e "${GREEN}Setting up WSL username and password...${NC}"
  local username=$(prompt_text "Enter your preferred WSL username")
  local password=$(prompt_text "Enter your preferred WSL password (input hidden)")

  echo -e "${GREEN}Applying user configurations...${NC}"
  wsl -d kali-linux -u root -- bash -c "
    useradd -m -s /bin/bash $username;
    echo '$username:$password' | chpasswd;
    usermod -aG sudo $username;
    echo 'export PATH=\$PATH:/usr/local/go/bin' >> /home/$username/.profile
  "

  echo -e "${GREEN}Username and password setup complete.${NC}"
}

install_chocolatey_and_software() {
  echo -e "${GREEN}Installing Chocolatey...${NC}"
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"

  echo -e "${GREEN}Installing common software...${NC}"
  choco install -y googlechrome firefox brave vscode git nodejs python 7zip notepadplusplus docker-desktop slack postman cmake ruby go mongodb openjdk17 maven obsidian

  echo -e "${GREEN}Setting up environment variables...${NC}"
  powershell -Command "[Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Program Files\OpenJDK\openjdk-17', 'Machine')"
  powershell -Command "[Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\Program Files\OpenJDK\openjdk-17\bin', 'Machine')"
  powershell -Command "[Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\Program Files\Git\cmd', 'Machine')"
  powershell -Command "[Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\Program Files\nodejs', 'Machine')"
  powershell -Command "[Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\Program Files\Python39\Scripts', 'Machine')"
  powershell -Command "[Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\Program Files\Python39', 'Machine')"
  powershell -Command "[Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\Program Files (x86)\CMake\bin', 'Machine')"
  powershell -Command "[Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\Program Files\Docker\Docker\resources\bin', 'Machine')"
  powershell -Command "[Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\Program Files\Postman', 'Machine')"
  powershell -Command "[Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\Program Files\Go\bin', 'Machine')"
  powershell -Command "[Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\Ruby30-x64\bin', 'Machine')"
}

configure_git_and_ssh() {
  echo -e "${YELLOW}Configuring Git...${NC}"
  git config --global user.name "Your Name"
  git config --global user.email "you@example.com"
  git config --global core.editor "code --wait"
  git config --global merge.tool "code --wait"
  git config --global diff.tool "code --wait"

  echo -e "${YELLOW}Setting up SSH keys for GitHub...${NC}"
  ssh-keygen -t rsa -b 4096 -C "you@example.com" -f ~/.ssh/id_rsa -N ""
  powershell -Command "Start-Process powershell -ArgumentList 'Get-Content ~/.ssh/id_rsa.pub | clip' -Verb RunAs"
  echo -e "${GREEN}SSH key has been copied to the clipboard. Add it to your GitHub account.${NC}"
}

install_vscode_extensions() {
  echo -e "${GREEN}Installing VS Code extensions...${NC}"
  code --install-extension ms-python.python
  code --install-extension ms-vscode.cpptools
  code --install-extension ms-azuretools.vscode-docker
  code --install-extension ms-vscode.go
  code --install-extension redhat.java
  code --install-extension eamodio.gitlens
  code --install-extension esbenp.prettier-vscode
}

configure_docker_windows() {
  echo -e "${GREEN}Configuring Docker for Windows...${NC}"
  mkdir -p ~/.docker
  echo '{
    "experimental": "enabled",
    "features": {
      "buildkit": true
    }
  }' > ~/.docker/config.json
}

configure_windows_terminal() {
  echo -e "${GREEN}Configuring Windows Terminal...${NC}"
  cp ~/win-setup/assets/background.jpg ~/
  echo '{
    "guid": "{your-wsl-guid}",
    "name": "Kali Linux",
    "source": "Windows.Terminal.Wsl",
    "hidden": false,
    "startingDirectory": "//wsl$/Kali-Linux/home/your-username",
    "backgroundImage": "file:///mnt/c/Users/your-username/background.jpg",
    "backgroundImageOpacity": 0.5,
    "colorScheme": "Campbell",
    "fontFace": "Cascadia Code PL",
    "fontSize": 12,
    "acrylicOpacity": 0.8,
    "useAcrylic": true,
    "cursorShape": "bar",
    "cursorColor": "#FFFFFF",
    "foreground": "#FFFFFF",
    "background": "#0C0C0C",
    "selectionBackground": "#FFFFFF"
  }' > windows-terminal-settings.json
  echo -e "${CYAN}Add the contents of windows-terminal-settings.json to your Windows Terminal settings file.${NC}"
}

# Function to create backup and restore scripts
create_backup_restore_scripts() {
  echo -e "${GREEN}Creating backup and restore scripts...${NC}"
  mkdir -p ~/scripts
  echo '#!/bin/bash
  tar -cvzf ~/wsl-backup.tar.gz ~/' > ~/scripts/backup.sh
  chmod +x ~/scripts/backup.sh

  echo '#!/bin/bash
  tar -xvzf ~/wsl-backup.tar.gz -C ~/' > ~/scripts/restore.sh
  chmod +x ~/scripts/restore.sh
}

# Function to install and configure Oh My Zsh
install_oh_my_zsh() {
  echo -e "${GREEN}Installing Oh My Zsh...${NC}"
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  chsh -s $(which zsh)

  echo -e "${GREEN}Installing Powerlevel10k theme...${NC}"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

  echo -e "${GREEN}Installing Zsh plugins...${NC}"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc
}

# Function to set up Kali Linux environment
setup_kali_environment() {
  echo -e "${GREEN}Setting up Kali Linux environment...${NC}"

  # Function to install essential Linux packages
  install_linux_packages() {
    echo -e "${GREEN}Installing essential Linux packages...${NC}"
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y build-essential git curl wget zsh vim htop nmap dirbuster
  }

  # Function to install Node Version Manager (nvm)
  install_nvm() {
    echo -e "${GREEN}Installing Node Version Manager (nvm)...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
  }

  # Function to install Python and virtualenv
  install_python_virtualenv() {
    echo -e "${GREEN}Installing Python and virtualenv...${NC}"
    sudo apt install -y python3 python3-pip python3-venv
  }

  # Function to clone and apply custom dotfiles
  apply_dotfiles() {
    echo -e "${GREEN}Cloning and applying custom dotfiles...${NC}"
    git clone https://github.com/your-username/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    ./install.sh
  }

  # Function to set up development environments
  setup_development_environments() {
    echo -e "${GREEN}Setting up development environments...${NC}"

    # Install Java
    sudo apt install -y openjdk-11-jdk

    # Install Ruby
    sudo apt install -y ruby-full

    # Install Go
    wget https://golang.org/dl/go1.17.6.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.17.6.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
    source ~/.profile
  }

  install_linux_packages
  install_nvm
  install_python_virtualenv
  apply_dotfiles
  setup_development_environments
  create_backup_restore_scripts
  install_oh_my_zsh
}

# Main function to execute all tasks
main() {
  print_welcome_message

  if check_wsl_installed; then
    if ! prompt_wsl_reset; then
      echo -e "${YELLOW}Keeping existing WSL installation.${NC}"
      setup_kali_environment
    fi
  else
    if prompt_user "Do you want to enable WSL and install WSL2 and Kali Linux?"; then
      install_wsl2_kali
    fi
  fi

  if [ "$(grep -Ei 'microsoft|wsl' /proc/version &> /dev/null; echo $?)" -eq 0 ]; then
    setup_kali_environment
  else
    install_chocolatey_and_software
    configure_docker_windows
    install_vscode_extensions
    configure_windows_terminal
    configure_git_and_ssh

    echo -e "${GREEN}Setup complete. Please open Kali Linux from your Windows Terminal and re-run this script inside Kali Linux to complete the setup.${NC}"
  fi
}

# Run the main function
main
