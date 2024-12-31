#!/bin/bash

# Globals
USER=${USER:-$(id -u -n)}
HOME="${HOME:-$(getent passwd "$USER" 2>/dev/null | cut -d: -f6)}"
HOME="${HOME:-$(eval echo ~$USER)}"
WHMCONFIG="$HOME/.whm_shell"

# Function to check if a path exists in the current PATH
is_path_in_env() {
  local path="$1"
  if [[ ":$PATH:" == *":$path:"* ]]; then
    return 0
  else
    return 1
  fi
}

# Function to add a path to PATH if it isn't already present
add_to_path() {
  local path="$1"
  if ! is_path_in_env "$path"; then
    export PATH="$path:$PATH"
    printf "Added '%s' to PATH\n" "$path"
  else
    printf "'%s' is already in PATH\n" "$path"
  fi
}

# Function to persist PATH changes to .bashrc
persist_path() {
  local path="$1"
  if ! grep -q "export PATH=.*$path" "$HOME/.zshrc"; then
    printf "\n# Added by script\nexport PATH=%s:\$PATH\n" "$path" >>"$HOME/.zshrc"
    printf "Persisted '%s' to %s\n" "$path" "$HOME/.zshrc"
  fi
}

check_file_exist() {
  test -e "$1"
  return $?
}

check_program_exist() {
  local program="$(command -v $1)"
  test -x "$program"
  return $?
}

ensure() {
  if ! check_program_exist "$1"; then
    echo "[-] Error: $1 is not installed." >&2
    return 1
  fi
  return 0
}

ensure-all() {
  for program in "$@"; do
    if ! ensure $program; then
      return 1
    fi
  done
}

# Utility functions

lnif() {
  local target="${@: -1}"
  if ! [[ -e "$target" ]]; then
    ln "$@"
  fi
}

link_config() {
  local src="$1"
  local dest="$2"
  lnif -s "$src" "$dest" && echo "[+] Linked: $src -> $dest"
}

check_file_exist() {
  [[ -e "$1" ]]
}

check_program_exist() {
  local program
  program=$(command -v "$1" 2>/dev/null)
  [[ -x "$program" ]]
}

download() {
  local url="$1"
  local dest="${2:-$(mktemp -p "$TEMP_DIR")}"
  curl -fsSL -o "$dest" "$url" || {
    echo "[-] Failed to download $url" >&2
    return 1
  }
  echo "$dest"
}

confirm() {
  read -rp "$1 (y/n): " choice
  case "$choice" in
  [Nn]*)
    echo "Operation cancelled." >&2
    return 1
    ;;
  *) return 0 ;;
  esac
}

install_package() {
  local package="$1"

  case "$OSTYPE" in
  "linux-gnu"*)
    if check_program_exist apt; then
      sudo apt update && sudo apt install -y "$package"
    elif check_program_exist yum; then
      sudo yum install -y "$package"
    elif check_program_exist dnf; then
      sudo dnf install -y "$package"
    elif check_program_exist pacman; then
      sudo pacman -Syu --noconfirm "$package"
    else
      echo "No supported package manager found. Unable to install $package."
    fi
    ;;
  "darwin"*)
    if check_program_exist brew; then
      brew install "$package"
    else
      echo "Homebrew is not installed. Please install Homebrew to use this function on macOS"
      return 1
    fi
    ;;
  *)
    echo "Unsupported OS: $OSTYPE"
    return 1
    ;;
  esac
  return $?
}

install_zsh() {
  echo "[*] Installing zsh..."
  install_package zsh || echo "[-] Failed to install zsh."
}

install_fzf() {
  echo "[*] Installing fzf..."
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    yes n | ~/.fzf/install
    [[ "$SHELL" == *"zsh" ]] && source ~/.fzf.zsh || source ~/.fzf.bash
  else
    install_package fzf || echo "[-] Failed to install fzf."
  fi
}

install_zoxide() {
  echo "[*] Installing zoxide..."
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  if ! is_path_in_env "$HOME/.local/bin"; then
    add_to_path "$HOME/.local/bin"
    persist_path "$HOME/.local/bin"
  fi
}

install_fd() {
  echo "[*] Installing fd..."
  install_package fd || {
    install_package fd-find && sudo ln -sf "$(which fdfind)" "$(dirname "$(which fdfind)")/fd"
  } || echo "[-] Failed to install fd."
}

install_eza() {
  echo "[*] Installing eza..."
  if [[ "$OSTYPE" == "linux-gnu"* && $(check_program_exist apt) ]]; then
    sudo apt update
    sudo apt install -y gpg
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
  else
    install_package eza || echo "[-] Failed to install eza."
  fi
}

install_superfile() {
  echo "[*] Installing superfile..."
  bash -c "$(curl -sLo- https://superfile.netlify.app/install.sh)"
}

install_bat() {
  echo "[*] Installing bat..."
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if bat_package=$(download https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-musl_0.24.0_amd64.deb); then
      sudo dpkg -i "$bat_package"
      rm "$bat_package"
    else
      echo "[-] Error when installing bat!"
    fi
  else
    install_package bat || echo "[-] Failed to install bat."
  fi

  lnif -s "$WHMCONFIG/bat-cache" "$HOME/.cache/bat"
  lnif -s "$WHMCONFIG/bat-config" "$HOME/.config/bat"
}

install_neovim() {
  echo "[*] Installing Neovim..."
  if ! check_program_exist nvim; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      if neovim_archive=$(download https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz); then
        sudo rm -rf /opt/nvim-linux64
        sudo tar -C /opt -xzf "$neovim_archive"
        sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/bin/nvim
        rm "$neovim_archive"
      else
        echo "[-] Error when installing Neovim!"
      fi
    else
      install_package neovim || echo "[-] Failed to install Neovim."
    fi
  fi
}

install_common_tools() {
  install_package vim || echo "[-] Failed to install vim."
  install_package tmux || echo "[-] Failed to install tmux."
  if [[ ! -d ~/.tmux/plugins/tpm ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
  [[ "$OSTYPE" == "darwin"* ]] && install_package wezterm || echo "[-] Failed to install wezterm."
}

install_tools() {
  install_zsh
  install_fzf
  install_zoxide
  install_fd
  install_eza
  install_bat
  install_package ripgrep || echo "[-] Failed to install ripgrep."
  install_neovim
  install_common_tools
}

install_configs() {
  if [["$OSTYPE" == "darwin"* ]]; then
    echo "[*] Installing JetBrains Mono Nerd Font..."
    brew install font-jetbrains-mono-nerd-font
  fi
  # Linking configuration files
  link_config "$WHMCONFIG/vimrc" "$HOME/.vimrc"
  link_config "$WHMCONFIG/nvim" "$HOME/.config/nvim"
  link_config "$WHMCONFIG/tmux.conf" "$HOME/.tmux.conf"
  link_config "$WHMCONFIG/wezterm" "$HOME/.config/wezterm"
  link_config "$WHMCONFIG/wezterm/wezterm.lua" "$HOME/.wezterm.lua"
  link_config "$WHMCONFIG/p10k.zsh" "$HOME/.p10k.zsh"
}

setup_zsh_plugins() {
  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  local theme_url="https://github.com/romkatv/powerlevel10k.git"

  if ! [[ -d "$HOME/.oh-my-zsh" ]]; then
    local ohmyzsh_installer
    ohmyzsh_installer=$(download https://install.ohmyz.sh/)
    chmod +x "$ohmyzsh_installer"
    "$ohmyzsh_installer" --keep-zshrc --skip-chsh --unattended
    rm -f "$ohmyzsh_installer"
  fi

  [[ -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting"
  [[ -d "$zsh_custom/plugins/zsh-autosuggestions" ]] || git clone https://github.com/zsh-users/zsh-autosuggestions.git "$zsh_custom/plugins/zsh-autosuggestions"
  [[ -d "$zsh_custom/plugins/zsh-vi-mode" ]] || git clone https://github.com/jeffreytse/zsh-vi-mode.git "$zsh_custom/plugins/zsh-vi-mode"
  [[ -d "$zsh_custom/themes/powerlevel10k" ]] || git clone --depth=1 "$theme_url" "$zsh_custom/themes/powerlevel10k"
}

finalize_zsh_config() {
  confirm "Do you want to add WHM configuration to .zshrc?" || return 0
  cat <<'EOF' >>"$HOME/.zshrc"
# oh-my-zsh plugins settings
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-vi-mode
 )
# WHM Shell Config
[[ -d "$HOME/.whm_shell" ]] && source "$HOME/.whm_shell/shell/config.sh"
EOF
  echo "[+] WHM configuration added to .zshrc."
}

usage() {
  echo "Usage: $0 [-a] [-t] [-c] [-p] [--zsh] [--fzf] [--zoxide] [--fd] [--eza] [--superfile] [--bat] [--neovim]"
  echo "  -a            Install all tools and configurations"
  echo "  -t            Install tools"
  echo "  -c            Install configurations"
  echo "  -p            Setup zsh plugins"
  echo "  --zsh         Install zsh"
  echo "  --fzf         Install fzf"
  echo "  --zoxide      Install zoxide"
  echo "  --fd          Install fd"
  echo "  --eza         Install eza"
  echo "  --superfile   Install superfile"
  echo "  --bat         Install bat"
  echo "  --neovim      Install Neovim"
  exit 1
}

main() {
  local OPTIND
  local install_all=false
  local install_tools=false
  local install_configs=false
  local setup_plugins=false
  local install_zsh=false
  local install_fzf=false
  local install_zoxide=false
  local install_fd=false
  local install_eza=false
  local install_superfile=false
  local install_bat=false
  local install_neovim=false

  while getopts "hatcp-:" opt; do
    case $opt in
    a)
      install_all=true
      break
      ;;
    t)
      install_tools=true
      ;;
    c)
      install_configs=true
      ;;
    p)
      setup_plugins=true
      ;;
    -)
      case "${OPTARG}" in
      zsh)
        install_zsh=true
        ;;
      fzf)
        install_fzf=true
        ;;
      zoxide)
        install_zoxide=true
        ;;
      fd)
        install_fd=true
        ;;
      eza)
        install_eza=true
        ;;
      superfile)
        install_superfile=true
        ;;
      bat)
        install_bat=true
        ;;
      neovim)
        install_neovim=true
        ;;
      *)
        usage
        ;;
      esac
      ;;
    *)
      usage
      ;;
    esac
  done

  if ! $install_all; then
    if $install_tools; then
      install_tools
    fi
    if $install_configs; then
      install_configs
    fi
    if $setup_plugins; then
      setup_zsh_plugins
      finalize_zsh_config
    fi
    if $install_zsh; then
      install_zsh
    fi
    if $install_fzf; then
      install_fzf
    fi
    if $install_zoxide; then
      install_zoxide
    fi
    if $install_fd; then
      install_fd
    fi
    if $install_eza; then
      install_eza
    fi
    if $install_superfile; then
      install_superfile
    fi
    if $install_bat; then
      install_bat
    fi
    if $install_neovim; then
      install_neovim
    fi
  else
    install_tools
    install_configs
    setup_zsh_plugins
    finalize_zsh_config
  fi
}

main "$@"
