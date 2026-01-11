# AGENTS.md - Project Guide & Coding Standards

## Project Overview

**whm_shell** is a comprehensive, hybrid configuration repository (dotfiles) for macOS (Darwin) and Linux (NixOS & Generic Linux). It leverages **Nix Flakes** and **Home Manager** for declarative system management while providing a shell-based installer (`install.sh`) for bootstrapping and usage on non-Nix systems.

**Key Components:**
- **System Management:** NixOS and nix-darwin configurations defined in `flake.nix`.
- **User Environment:** Home Manager for managing user packages and dotfiles.
- **Editor:** Highly configured Neovim (LazyVim based).
- **Terminal:** WezTerm and Tmux configurations.
- **Theme Integration:** Custom "Watcher" tools (`AppearanceWatcher` for macOS, `GnomeWatcher` for Linux) to synchronize system themes (Dark/Light) with running applications like Neovim and Zsh in real-time.

## Directory Structure

- **`nixos-config/`**: The core Nix configuration.
    - `hosts/`: Entry points for specific machines (e.g., `darwin`, `nixos`).
    - `modules/`: Reusable Nix modules (split by `darwin`, `linux`, `nixos`, `shared`).
    - `apps/`: Scripts exposed as flake apps (e.g., `apply`, `build-switch`).
- **`editor/`**: Editor configurations.
    - `nvim/`: Neovim config (Lua), following LazyVim structure.
    - `nvim-plugins/`: Custom plugins (e.g., `cowboy.nvim`).
- **`shell/`**: Shell configuration files (Zsh aliases, Starship prompt configs).
- **`terminal/`**: Terminal emulator configs (`wezterm`, `tmux.conf`).
- **`scripts/`**: Custom source code for utility tools.
    - `AppearanceWatcher/`: Swift project for macOS theme monitoring.
    - `GnomeWatcher/`: C project for GNOME theme monitoring.
- **`install.sh`**: Universal bootstrap script for installing tools and linking configs manually.

## Workflows & Commands

### Nix / System Management
- **Apply Changes**: `nix run .#apply` (Generic wrapper)
- **Build & Switch (macOS)**: `nix run .#build-switch`
- **Build & Switch (Linux)**: `home-manager switch --flake .#x86_64-linux`
- **Nix flake check**: `nix flake check`

### Testing & Linting
- **Lua tests (cowboy.nvim)**: `busted editor/nvim-plugins/cowboy.nvim/tests/`
- **Single Lua test**: `busted editor/nvim-plugins/cowboy.nvim/tests/cowboy_spec.lua`
- **GnomeWatcher build**: `cd scripts/GnomeWatcher && make build`
- **GnomeWatcher clean**: `cd scripts/GnomeWatcher && make clean`

### Legacy/Manual Installer
- **Usage**: `./install.sh [flags]`
- **Flags**: `-a` (all), `-t` (tools only), `-c` (config link only)

## Development Conventions

### Architecture Patterns
- **Nix Modules**: Modularized in `nixos-config/modules`. Feature toggles (e.g., `link.nvim`) are managed via `nixos-config/modules/shared/whmconfig.nix`.
- **Theme Watchers**:
    - **Swift (`AppearanceWatcher`)**: Listens for `AppleInterfaceThemeChangedNotification`.
    - **Signals**: Watchers send `SIGUSR1` (Dark) or `SIGUSR2` (Light) to target processes (`zsh`, `nvim`).
    - **Neovim**: `utils.lua` handles dynamic theme switching signals.

### Code Style Guidelines

#### Lua Code
- **Indentation**: Use tabs (4 spaces equivalent)
- **Naming**: Use `snake_case` for variables/functions (e.g., `configure_key`, `map_keys`)
- **Module structure**: Use `local M = {}` pattern; return at end of file
- **Type annotations**: Use `---@type` comments for LSDoc-style annotations
- **Imports**: Use `local X = require("module.path")` at top; abbreviate long names (`local keymap = vim.keymap`)
- **Tables**: Use single quotes for string keys in table literals; tabs for indentation
- **Functions**: Use `local function name()` for internal functions; describe in comments
- **Error handling**: Use `assert()` for critical errors; handle gracefully for optional operations

#### Nix Code
- **Indentation**: Use 2 spaces
- **Naming**: Use lowercase with hyphens for attribute names (e.g., `home-manager`, `nix-homebrew`)
- **Module structure**: Use standard Nix module format with `config`, `options`, `imports`
- **Imports**: Use explicit paths; leverage `inputs` for flake dependencies
- **Comments**: Use `#` for comments; explain complex logic

#### Shell Scripts (Bash/Zsh)
- **Naming**: Use lowercase with underscores (e.g., `build_switch`)
- **Quotes**: Use double quotes for variable expansion; single quotes for literals
- **Functions**: Use `function_name() {}` syntax

#### General
- **No comments** unless essential for clarity
- **DRY principle**: Avoid repetition; extract common patterns
- **Error handling**: Always check command exit codes where critical
- **Consistency**: Match existing code patterns in the same directory/file
