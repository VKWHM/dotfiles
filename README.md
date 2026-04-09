# WHM Shell - Advanced Nix-Powered Development Environment

<!--toc:start-->
- [WHM Shell - Advanced Nix-Powered Development Environment](#whm-shell-advanced-nix-powered-development-environment)
  - [🌟 Key Features](#🌟-key-features)
  - [📁 Project Structure](#📁-project-structure)
  - [🚀 Quick Start](#🚀-quick-start)
  - [⚙️ Configuration](#️-configuration)
  - [🛠 Development & Customization](#-development--customization)
  - [🤝 Contributing](#🤝-contributing)
  - [📄 License](#📄-license)
  - [🙏 Acknowledgements](#🙏-acknowledgements)
<!--toc:end-->

A comprehensive, Nix-powered development environment that streamlines system configuration and enhances productivity across macOS (Darwin) and Linux (NixOS). This repository leverages **Nix Flakes** and **Home Manager** for declarative, reproducible system management with a carefully crafted ecosystem of tools, editors, and shell configurations.

## 🌟 Key Features

### **Declarative System Management**

- **NixOS & nix-darwin**: Full system configuration for Linux and macOS
- **Home Manager**: Declarative user environment and dotfiles management
- **Nix Flakes**: Reproducible, version-locked configurations
- **Multi-architecture**: Support for x86_64 and aarch64 platforms

### **Advanced Editor (Neovim)**

- **LazyVim-based**: Modern Lua configuration with lazy-loading plugins
- **AI Integration**: Copilot for intelligent code completion and commit message generation
- **LSP Support**: Nixd, yamlls, and comprehensive language server ecosystem
- **Custom Plugins**: cowboy.nvim (development utilities), opencode.nvim (CLI integration), smear-cursor (smooth visual cursor)
- **Completion**: Blink.cmp for advanced fuzzy completion
- **Enhanced Debugging**: Integrated debugging tools and enhanced markdown support

### **Terminal & Shell Excellence**

- **WezTerm**: Modern terminal emulator with dynamic theming and persistent sessions
- **Tmux Integration**: 
  - FZF-powered search (URLs, Base64, file paths, Docker IDs, IPs, etc.)
  - Enhanced buffer management with PCRE regex support
  - floax plugin for floating windows
- **Starship Prompt**: Beautiful, modular shell prompt with Catppuccin theme variants
- **Zsh**: Oh-My-Zsh integration with custom aliases, functions, and enhanced workflows
- **Advanced FZF**: Customizable preview commands and search integration

### **Dynamic Theme Management**

- **AppearanceWatcher**: Swift-based utility for macOS system appearance changes
- **GnomeWatcher**: C-based utility for GNOME theme monitoring
- **Catppuccin Integration**: Latte (light) and Mocha (dark) theme variants
- **Real-time Syncing**: Automatic theme updates across Neovim, Zsh, and all terminal applications
- **Signal-based**: Uses SIGUSR1/SIGUSR2 for fast, responsive theme switching

### **Development Tools & CLI Integration**

- **FZF**: Advanced fuzzy finder with preview capabilities
- **Bat**: Syntax highlighting with theme synchronization
- **Btop**: System resource monitoring with dynamic theming
- **Sesh**: Session manager for shell environments
- **Gemini CLI**: Integration for AI-powered development assistance
- **Git**: Enhanced workflow with custom aliases and utilities
- **OpenCode**: Terminal-integrated development environment with agents and commands

## 📁 Project Structure

```plaintext
whm_shell/
├── nixos-config/                 # Core Nix configuration system
│   ├── flake.nix                # Flake entry point with inputs and outputs
│   ├── flake.lock               # Dependency lock file
│   ├── hosts/                   # Host-specific configurations
│   │   ├── darwin/              # macOS (nix-darwin) configuration
│   │   └── nixos/               # NixOS system configuration
│   ├── modules/                 # Reusable Nix modules
│   │   ├── darwin/              # macOS-specific modules (apps, brews, casks, home-manager)
│   │   ├── nixos/               # NixOS-specific modules (polybar, rofi, disk-config, packages)
│   │   └── shared/              # Cross-platform modules
│   │       ├── programs/        # Program configs (bat, btop, fzf, opencode, sesh, starship, tmux, zsh)
│   │       └── utils/           # Utility modules (Catppuccin theming, theme management)
│   ├── apps/                    # Flake apps (apply, build-switch scripts)
│   └── overlays/                # Custom Nix package overlays
├── editor/                      # Editor configurations
│   ├── nvim/                   # Neovim configuration (LazyVim-based)
│   │   ├── init.lua            # Neovim entry point
│   │   ├── lua/
│   │   │   ├── config/         # Core configuration (keymaps, options, utils)
│   │   │   └── plugins/        # Plugin specifications (copilot, completion, lsp, ui, etc.)
│   │   ├── lsp/                # Language server configurations
│   │   └── lazyvim.json        # LazyVim preferences
│   ├── nvim-plugins/           # Custom Neovim plugins
│   │   └── cowboy.nvim/        # Development workflow enhancements
│   └── vimrc                   # Vim configuration (fallback/alternative)
├── scripts/                     # Custom utility tools
│   ├── AppearanceWatcher/       # Swift tool for macOS appearance detection
│   └── GnomeWatcher/            # C tool for GNOME theme monitoring
├── shell/                       # Shell configuration files
│   ├── aliases.sh              # Zsh aliases (keyboard layouts, config editing, ls/cd enhancements, etc.)
│   ├── config.sh               # Core Zsh configuration
│   ├── functions.sh            # Custom shell functions
│   ├── p10k.zsh                # Powerlevel10k prompt configuration
│   ├── starship_latte.toml     # Starship config (light theme)
│   └── starship_mocha.toml     # Starship config (dark theme)
├── terminal/                    # Terminal emulator configurations
│   ├── tmux.conf               # Tmux configuration (vi mode, mouse, key bindings)
│   ├── wezterm/                # WezTerm configuration (events, keymaps, plugins, themes)
│   └── opencode/               # OpenCode configuration (agents, commands, themes)
├── flake.nix                    # Main Nix flake configuration
├── install.sh                   # Bootstrap installer script (non-Nix systems)
└── AGENTS.md                    # Project guide and coding standards
```

## 🚀 Quick Start

### Prerequisites

- **Nix**: Install with flakes support (`nix --version` and `nix flake --help`)
- **Git**: For repository management and version control

### Installation

#### Option 1: Clone to ~/.whm_shell (Recommended)

```bash
git clone https://github.com/vkwhm/whm_shell.git ~/.whm_shell
cd ~/.whm_shell
```

#### Option 2: Clone to Custom Location

```bash
git clone https://github.com/vkwhm/whm_shell.git /path/to/location
cd /path/to/location
# Update paths in your host configuration accordingly
```

### Applying Configuration

**For macOS (Darwin):**

```bash
nix run .#build-switch
```

**For NixOS:**

```bash
home-manager switch --flake .#x86_64-linux     # x86_64 headless
home-manager switch --flake .#aarch64-linux    # ARM64 headless
home-manager switch --flake .#x86_64-linux-desktop    # x86_64 with GUI
home-manager switch --flake .#aarch64-linux-desktop   # ARM64 with GUI
```

**For Generic Linux (without Home Manager):**

```bash
./install.sh -a  # Install all tools and link configs
```

### Verification

```bash
# Verify Nix configuration
nix flake check

# Test Neovim configuration
nvim --version && nvim +checkhealth

# Test shell configuration
zsh -i -c 'echo "Shell initialized successfully"'
```

## ⚙️ Configuration

### Core Configuration Options

The main configuration is managed through `nixos-config/modules/shared/whmconfig.nix` with the following options:

```nix
home.whmConfig = {
  enable = true;                  # Enable WHM configuration
  dotDir = ".whm_shell";          # Directory name (relative to home)
  repo = "vkwhm/whm_shell";       # GitHub repository
  link = {
    nvim = true;                  # Link Neovim config
    vim = true;                   # Link Vim config
    tmux = true;                  # Link Tmux config
    wezterm = true;               # Link WezTerm config
  };
};
```

### Platform-Specific Customization

**macOS (Darwin):**
- Edit `nixos-config/hosts/darwin/default.nix` for system settings
- Customize applications in `nixos-config/modules/darwin/apps.nix`
- Add Homebrew packages in `nixos-config/modules/darwin/brews.nix`

**NixOS:**
- Edit `nixos-config/hosts/nixos/default.nix` for NixOS settings
- Configure system services in `nixos-config/modules/nixos/`
- Customize desktop environment in `nixos-config/modules/nixos/config/`

**All Platforms:**
- Configure programs in `nixos-config/modules/shared/programs/` (bat, fzf, tmux, starship, zsh, etc.)
- Customize theme settings in `nixos-config/modules/shared/utils/theme.nix`

### Enabling/Disabling Features

Most tools can be toggled by setting them to `false` in your host configuration:

```nix
programs.fzf.enable = false;        # Disable FZF
programs.bat.enable = false;        # Disable Bat
programs.starship.enable = false;   # Disable Starship
programs.tmux.enable = false;       # Disable Tmux
```

### Neovim Plugin Configuration

Edit `editor/nvim/lua/plugins/` to enable/disable plugins:

```lua
-- In editor/nvim/lua/plugins/main.lua
{
  "plugin/name",
  enabled = true,  -- Set to false to disable
  opts = { ... },
}
```

## 🛠 Development & Customization

### Building & Testing

```bash
# Check Nix flake for errors
nix flake check

# Build derivation without applying
nix build .#homeManagerConfigurations.x86_64-linux.activationPackage

# Test Neovim plugins
busted editor/nvim-plugins/cowboy.nvim/tests/

# Build theme watchers
cd scripts/GnomeWatcher && make build
cd scripts/AppearanceWatcher && make build
```

### Common Workflows

**Rebuild after configuration changes:**
```bash
# macOS
nix run .#build-switch

# Linux
home-manager switch --flake .#x86_64-linux
```

**Update dependencies:**
```bash
nix flake update
```

**Rollback to previous configuration:**
```bash
# On macOS, configurations are kept in /nix/var/nix/profiles/per-user/$USER/home-manager*
home-manager generations
home-manager --switch-generation N
```

### Theme Customization

**Switch themes dynamically:**
- macOS: System Appearance settings (AppearanceWatcher handles sync)
- Linux GNOME: Settings > Appearance (GnomeWatcher handles sync)

**Modify theme colors:**
1. Edit `nixos-config/modules/shared/utils/catppuccin.nix` for Catppuccin integration
2. Adjust colors in shell configs: `shell/starship_*.toml`
3. Customize Neovim theme in `editor/nvim/lua/config/options.lua`

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/your-amazing-feature`
3. **Test** your changes:
   ```bash
   nix flake check
   # Test on your platform before committing
   ```
4. **Commit** using conventional commits:
   ```bash
   git commit -m "feat(module): add your amazing feature"
   # Include a descriptive commit body
   ```
5. **Push** to your fork and create a pull request

### Coding Standards

- **Nix**: 2-space indentation, lowercase attribute names with hyphens
- **Lua**: Tab indentation (4-space equivalent), snake_case naming
- **Shell**: Double quotes for variables, single quotes for literals
- See `AGENTS.md` for detailed conventions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

- **NixOS Community**: Powerful declarative package management and system configuration
- **LazyVim**: Excellent Neovim configuration framework and plugin ecosystem
- **Catppuccin**: Beautiful, accessible color scheme with thoughtful theming
- **Home Manager**: Making dotfiles and user environment management declarative
- **Open Source Community**: Countless tools and frameworks that make this possible

---

**Note**: This project has evolved from a simple dotfiles collection into a comprehensive, Nix-powered development environment with reproducible configurations, modular architecture, and cross-platform consistency. The architecture prioritizes maintainability, extensibility, and seamless user experience across macOS and Linux platforms.
