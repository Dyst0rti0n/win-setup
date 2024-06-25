#!/bin/bash

# Color variables
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
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

# Function to show progress bar
show_progress_bar() {
  local duration=$1
  local increment=$((duration / 50))
  echo -ne "${GREEN}["
  for ((i=0; i<50; i++)); do
    echo -ne "#"
    sleep $increment
  done
  echo -e "]${NC}"
}

# Function to print messages with color
print_message() {
  local message=$1
  local color=$2
  echo -e "${color}${message}${NC}"
}

prompt_user() {
  read -p "$(print_message "$1" "$CYAN") (y/n): " choice
  case "$choice" in 
    y|Y ) return 0;;
    n|N ) return 1;;
    * ) print_message "Invalid input" "$RED"; prompt_user "$1";;
  esac
}

# Function to prompt for text input
prompt_text() {
  read -p "$(print_message "$1" "$CYAN"): " input
  echo "$input"
}

# Function to check if WSL is installed
check_wsl_installed() {
  wsl --list &> /dev/null
  return $?
}

# Function to prompt user for WSL reset
prompt_wsl_reset() {
  print_message "WSL is already installed on your system." "$YELLOW"
  if prompt_user "Do you want to reset WSL for a fresh installation? All existing WSL data will be deleted."; then
    print_message "Warning: This will delete all your WSL data!" "$RED"
    if prompt_user "Are you sure you want to proceed?"; then
      for distro in $(wsl --list --quiet); do
        wsl --unregister $distro
      done
    else
      print_message "Aborted WSL reset." "$YELLOW"
      exit 1
    fi
  else
    print_message "Keeping existing WSL installation." "$YELLOW"
    return 1
  fi
}

# Function to enable WSL and install WSL2 and Kali Linux
install_wsl2_kali() {
  print_message "Enabling WSL and installing WSL2 and Kali Linux..." "$GREEN"
  powershell -Command "Start-Process powershell -ArgumentList 'dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart' -Verb RunAs"
  powershell -Command "Start-Process powershell -ArgumentList 'dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart' -Verb RunAs"
  powershell -Command "wsl --set-default-version 2"
  powershell -Command "wsl --install -d kali-linux"

  print_message "Setting up WSL username and password..." "$GREEN"
  local username=$(prompt_text "Enter your preferred WSL username")
  local password=$(prompt_text "Enter your preferred WSL password (input hidden)")

  print_message "Applying user configurations..." "$GREEN"
  wsl -d kali-linux -u root -- bash -c "
    apt update && apt install -y sudo;
    useradd -m -s /bin/bash $username;
    echo '$username:$password' | chpasswd;
    usermod -aG sudo $username;
    echo 'export PATH=\$PATH:/usr/local/go/bin' >> /home/$username/.profile
  "

  print_message "Username and password setup complete." "$GREEN"
}

install_chocolatey_and_software() {
  print_message "Installing Chocolatey..." "$GREEN"
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"

  print_message "Installing common software..." "$GREEN"
  choco install -y googlechrome firefox brave vscode git nodejs python 7zip winzip notepadplusplus docker-desktop slack postman cmake ruby go mongodb mysql sqlite awscli terraform ansible obsidian sysinternals treesize winscp putty wireshark nmap burpsuite netcat

  print_message "Setting up environment variables..." "$GREEN"
  env_vars=(
    'JAVA_HOME=C:\Program Files\OpenJDK\openjdk-17'
    'Path=$env:Path;C:\Program Files\OpenJDK\openjdk-17\bin'
    'Path=$env:Path;C:\Program Files\Git\cmd'
    'Path=$env:Path;C:\Program Files\nodejs'
    'Path=$env:Path;C:\Program Files\Python39\Scripts'
    'Path=$env:Path;C:\Program Files\Python39'
    'Path=$env:Path;C:\Program Files (x86)\CMake\bin'
    'Path=$env:Path;C:\Program Files\Docker\Docker\resources\bin'
    'Path=$env:Path;C:\Program Files\Postman'
    'Path=$env:Path;C:\Program Files\Go\bin'
    'Path=$env:Path;C:\Ruby30-x64\bin'
  )

  for env_var in "${env_vars[@]}"; do
    powershell -Command "[System.Environment]::SetEnvironmentVariable('$(echo $env_var | cut -d'=' -f1)', '$(echo $env_var | cut -d'=' -f2)', 'Machine')" || print_message "Failed to set environment variable: $env_var" "$RED"
  done
}

configure_git_and_ssh() {
  print_message "Configuring Git..." "$YELLOW"
  git_user=$(prompt_text "Enter your GitHub username")
  git_email=$(prompt_text "Enter your GitHub email")
  git config --global user.name "$git_user"
  git config --global user.email "$git_email"
  git config --global core.editor "code --wait"
  git config --global merge.tool "code --wait"
  git config --global diff.tool "code --wait"
  git config --global --add safe.directory "$env:USERPROFILE\Documents\windows-setup-files\win-setup"

  print_message "Setting up SSH keys for GitHub..." "$YELLOW"
  ssh-keygen -t rsa -b 4096 -C "$git_email" -f ~/.ssh/id_rsa -N ""
  powershell -Command "Start-Process powershell -ArgumentList 'Get-Content ~/.ssh/id_rsa.pub | clip' -Verb RunAs"
  print_message "SSH key has been copied to the clipboard. Add it to your GitHub account." "$GREEN"
}

install_vscode_extensions() {
  print_message "Installing VS Code extensions..." "$GREEN"
  code --install-extension ms-python.python
  code --install-extension ms-vscode.cpptools
  code --install-extension ms-azuretools.vscode-docker
  code --install-extension ms-vscode.go
  code --install-extension redhat.java
  code --install-extension eamodio.gitlens
  code --install-extension esbenp.prettier-vscode
}

configure_docker_windows() {
  print_message "Configuring Docker for Windows..." "$GREEN"
  mkdir -p ~/.docker
  echo '{
    "experimental": "enabled",
    "features": {
      "buildkit": true
    }
  }' > ~/.docker/config.json
}

configure_windows_terminal() {
  print_message "Configuring Windows Terminal..." "$GREEN"
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
  print_message "Add the contents of windows-terminal-settings.json to your Windows Terminal settings file." "$CYAN"
}

# Function to create backup and restore scripts
create_backup_restore_scripts() {
  print_message "Creating backup and restore scripts..." "$GREEN"
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
  print_message "Installing Oh My Zsh..." "$GREEN"
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  chsh -s $(which zsh)

  print_message "Installing Powerlevel10k theme..." "$GREEN"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

  print_message "Installing Zsh plugins..." "$GREEN"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc
}

# Function to set up Kali Linux environment
setup_kali_environment() {
  print_message "Setting up Kali Linux environment..." "$GREEN"

  # Function to install essential Linux packages
  install_linux_packages() {
    print_message "Installing essential Linux packages..." "$GREEN"
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y build-essential git curl wget zsh vim htop nmap dirbuster
  }

  # Function to install Node Version Manager (nvm)
  install_nvm() {
    print_message "Installing Node Version Manager (nvm)..." "$GREEN"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
  }

  # Function to install Python and virtualenv
  install_python_virtualenv() {
    print_message "Installing Python and virtualenv..." "$GREEN"
    sudo apt install -y python3 python3-pip python3-venv
  }

  # Function to clone and apply custom dotfiles
  apply_dotfiles() {
    print_message "Cloning and applying custom dotfiles..." "$GREEN"
    git clone https://github.com/Dyst0rti0n/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    ./install.sh
  }

  # Function to set up development environments
  setup_development_environments() {
    print_message "Setting up development environments..." "$GREEN"

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

# Function to remove pre-installed Windows tools
function Remove-PreInstalledApps {
    param (
        [string]$AppName
    )
    try {
        Get-AppxPackage -Name $AppName | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $AppName } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        Log-Message "$AppName removed successfully." "SUCCESS"
    } catch {
        Log-Message "Failed to remove $AppName. Error: $_" "ERROR"
    }
}

# Main function to execute all tasks
main() {
  print_welcome_message

  # Check for WSL installation and prompt for reset if installed
  if check_wsl_installed; then
    if ! prompt_wsl_reset; then
      print_message "Keeping existing WSL installation." "$YELLOW"
      setup_kali_environment
    fi
  else
    if prompt_user "Do you want to enable WSL and install WSL2 and Kali Linux?"; then
      install_wsl2_kali
    fi
  fi

  # Install Chocolatey and common software
  install_chocolatey_and_software
  configure_docker_windows
  install_vscode_extensions
  configure_windows_terminal
  configure_git_and_ssh

  # Remove pre-installed Windows tools
  appsToRemove=(
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

  for app in "${appsToRemove[@]}"; do
    Remove-PreInstalledApps -AppName $app
  done

  # Run the setup script inside WSL
  if [ "$(grep -Ei 'microsoft|wsl' /proc/version &> /dev/null; echo $?)" -eq 0 ]; then
    setup_kali_environment
  fi

  # Final report
  print_message "==================== Installation Report ====================" "$CYAN"
  cat $logFilePath
  print_message "============================================================" "$CYAN"
  print_message "Press any key to exit..." "$CYAN"
  read -n 1 -s
}

# Run the main function
main
