# WHM Shell - Advanced Development Environment

A comprehensive, Nix-powered development environment that streamlines system configuration and enhances productivity across multiple platforms. This repository provides a unified approach to managing dotfiles, system configurations, and development tools through Nix and Home Manager.

## 🌟 Key Features

### **Nix-Based Configuration Management**

- **NixOS/Darwin Integration**: Full system configuration management for both Linux and macOS
- **Home Manager**: Declarative user environment configuration
- **Flake-based Setup**: Reproducible and version-locked configurations
- **Multi-platform Support**: Unified configurations for x86_64 and aarch64 architectures

### **Advanced Editor Configuration**

- **Neovim with LazyVim**: Modern Lua-based configuration with LSP support
- **Nixd LSP Integration**: Advanced Nix language server support
- **Copilot Integration**: AI-powered coding assistance with custom commit generation
- **Custom Plugins**: Including smear-cursor, opencode.nvim, and enhanced debugging tools

### **Enhanced Terminal Experience**

- **Tmux with Advanced Features**: FZF-powered search for URL, Base64, File Paths, Docker IDs, IP,... etc, improved buffer management, and regex
- **WezTerm Configuration**: Modern terminal emulator with dynamic theming
- **Starship Prompt**: Customizable shell prompt with Catppuccin theme variants
- **ZSH with Oh-My-Zsh**: Enhanced shell with custom aliases and functions

### **Dynamic Theme Management**

- **AppearanceWatcher**: Swift-based utility for macOS appearance detection
- **GnomeWatcher**: C-based utility for GNOME theme monitoring
- **Automatic Theme Switching**: Seamless light/dark mode transitions across applications
- **Catppuccin Integration**: Consistent theming across all applications

### **Development Tools Integration**

- **FZF Enhanced**: Advanced fuzzy finding with custom preview commands
- **Bat**: Syntax highlighting with theme synchronization
- **Btop**: System monitoring with dynamic theme updates
- **Git Integration**: Enhanced aliases and workflow improvements

## 📁 Project Structure

```plaintext
├── nixos-config/           # Nix configuration management
│   ├── hosts/             # Host-specific configurations
│   │   ├── darwin/        # macOS system configurations
│   │   └── nixos/         # NixOS system configurations
│   ├── modules/           # Modular configuration components
│   │   ├── darwin/        # macOS-specific modules
│   │   ├── nixos/         # NixOS-specific modules
│   │   └── shared/        # Cross-platform modules
│   └── overlays/          # Nix package overlays
├── editor/                # Editor configurations
│   ├── nvim/             # Neovim configuration
│   │   ├── lua/          # Lua configuration files
│   │   └── lsp/          # Language server configurations
│   └── nvim-plugins/     # Custom Neovim plugins
├── scripts/               # System utilities
│   ├── AppearanceWatcher/ # macOS appearance monitoring
│   └── GnomeWatcher/     # GNOME theme detection
├── shell/                 # Shell configurations
├── terminal/              # Terminal configurations
└── apps/                  # Platform-specific build scripts
```

## 🚀 Quick Start

### Prerequisites

- **Nix**: Install Nix package manager with flakes enabled
- **Git**: For repository management

### Installation

1. **Clone the repository:**

```bash
git clone https://github.com/vkwhm/whm_shell.git ~/.whm_shell
cd ~/.whm_shell
```

2. **Choose your platform and run the appropriate build script:**

**For macOS:**

```bash
nix run .#build-switch
```

**For Linux:**

install [home-manager](https://nix-community.github.io/home-manager) if not exist.

```bash
home-manager switch --flake .#x86_64-linux # For x86_64 only shell
home-manager switch --flake .#aarch64-linux # For aarch64 only shell
home-manager switch --flake .#x86_64-linux-desktop # For x86_64 with GUI tools
home-manager switch --flake .#aarch64-linux-desktop # For aarch64 with GUI tools

```

## 🛠 Major Updates Since Fork

### **Nix Infrastructure (82 commits)**

- Complete migration from traditional dotfiles to Nix/Home Manager
- Multi-platform support for Darwin and NixOS systems
- Flake-based configuration with reproducible builds
- Modular architecture for easy customization

### **Theme System Overhaul**

- Dynamic appearance detection for both macOS and Linux
- Automatic theme switching across all applications
- Catppuccin theme integration with Latte/Mocha variants
- Custom utilities for system appearance monitoring

### **Advanced Tmux Integration**

- FZF-powered search and navigation
- Enhanced buffer management and copy functionality
- PCRE regex support for advanced pattern matching

### **Editor Enhancements**

- LazyVim configuration with extensive plugin ecosystem
- Copilot integration with custom commit message generation
- LSP support for Nix development
- Custom plugins for improved development workflow

### **Shell Improvements**

- Enhanced FZF integration with customizable preview commands
- Improved Git workflow with advanced aliases
- Dynamic environment configuration based on system state
- Performance optimizations for shell startup

## 📋 Configuration Options

### **Enabling Features**

The configuration uses a modular approach. Key toggles include:

```nix
# In your host configuration
whmconfig = {
  enable = true;
  linkConfigs = {
    nvim = true;
    tmux = true;
    starship = true;
    wezterm = true;
  };
};
```

### **Platform-Specific Settings**

Each platform has its own configuration module:

- `modules/darwin/` - macOS system and application settings
- `modules/nixos/` - NixOS system configuration
- `modules/shared/` - Cross-platform user configurations

## 🔧 Development Utilities

### **Theme Management**

- `AppearanceWatcher`: Monitors macOS system appearance changes
- `GnomeWatcher`: Tracks GNOME theme modifications
- Automatic configuration updates across all applications

### **Build Scripts**

- Platform-specific build and deployment scripts
- Automated rollback capabilities
- Key management for secure deployments

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and test across platforms
4. Commit using conventional commits: `git commit -m "feat: add amazing feature"`
5. Push and create a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

- **NixOS Community**: For the powerful package management system
- **LazyVim**: For the excellent Neovim configuration framework
- **Catppuccin**: For the beautiful and consistent color scheme
- **Open Source Community**: For the countless tools that make this possible

---

**Note**: This configuration has evolved significantly from a simple dotfiles collection to a comprehensive, Nix-powered development environment. The 82+ commits since the main branch represent a complete architectural overhaul focused on reproducibility, modularity, and cross-platform consistency.

