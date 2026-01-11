# WHM Shell - Project Context

## Project Overview

**whm_shell** is a comprehensive, hybrid configuration repository (dotfiles) for macOS (Darwin) and Linux (NixOS & Generic Linux). It leverages **Nix Flakes** and **Home Manager** for declarative system management while providing a shell-based installer (`install.sh`) for bootstrapping and usage on non-Nix systems or for specific tool installations.

**Key Components:**
*   **System Management:** NixOS and nix-darwin configurations defined in `flake.nix`.
*   **User Environment:** Home Manager for managing user packages and dotfiles.
*   **Editor:** Highly configured Neovim (LazyVim based).
*   **Terminal:** WezTerm and Tmux configurations.
*   **Theme Integration:** Custom "Watcher" tools (`AppearanceWatcher` for macOS, `GnomeWatcher` for Linux) to synchronize system themes (Dark/Light) with running applications like Neovim and Zsh in real-time.

## Directory Structure

*   **`nixos-config/`**: The core Nix configuration.
    *   `hosts/`: Entry points for specific machines (e.g., `darwin`, `nixos`).
    *   `modules/`: Reusable Nix modules (split by `darwin`, `linux`, `nixos`, `shared`).
    *   `apps/`: Scripts exposed as flake apps (e.g., `apply`, `build-switch`).
*   **`editor/`**: Editor configurations.
    *   `nvim/`: Neovim config (Lua), following LazyVim structure.
*   **`shell/`**: Shell configuration files (Zsh aliases, Starship prompt configs).
*   **`terminal/`**: Terminal emulator configs (`wezterm`, `tmux.conf`).
*   **`scripts/`**: Custom source code for utility tools.
    *   `AppearanceWatcher/`: Swift project for macOS theme monitoring.
    *   `GnomeWatcher/`: C project for GNOME theme monitoring.
*   **`install.sh`**: Universal bootstrap script for installing tools and linking configs manually (without full Nix system management).

## Building and Running

### 1. Nix / NixOS / Darwin Method (Preferred)

The project uses Nix Flakes. The `flake.nix` defines several "apps" to manage the lifecycle.

**Common Commands:**
*   **Apply Changes:** `nix run .#apply` (Generic wrapper)
*   **Build & Switch (macOS):** `nix run .#build-switch`
*   **Build & Switch (Linux):** `home-manager switch --flake .#x86_64-linux` (or `aarch64` / `-desktop` variants)

**Apps defined in Flake:**
*   `build-switch`: Rebuilds the system/home configuration and activates it.
*   `copy-keys`, `create-keys`, `check-keys`: Helpers for managing secure keys/secrets.
*   `rollback`: Rolls back to the previous generation (Darwin).

### 2. Shell Installer Method (`install.sh`)

For systems where full Nix management is not desired or for initial bootstrapping.

*   **Usage:** `./install.sh [flags]`
*   **Flags:**
    *   `-a`: Install all tools and configurations.
    *   `-t`: Install tools only (zsh, fzf, etc.).
    *   `-c`: Link configuration files only.
    *   `--neovim`, `--zsh`, `--fzf`, etc.: Install specific tools.

## Development Conventions

*   **Nix:**
    *   Configurations are modularized in `nixos-config/modules`.
    *   The `whmconfig` module (`nixos-config/modules/shared/whmconfig.nix`) is used to toggle features (e.g., `link.nvim`, `link.tmux`).
*   **Neovim:**
    *   Follows LazyVim standards.
    *   Custom plugins and logic are in `editor/nvim/lua/`.
    *   `utils.lua` contains logic for handling the dynamic theme switching signals.
*   **Theme Watchers:**
    *   **Swift (`AppearanceWatcher`):** Uses `DistributedNotificationCenter` to listen for `AppleInterfaceThemeChangedNotification`. Sends `SIGUSR1` (Dark) or `SIGUSR2` (Light) to target processes (`zsh`, `nvim`).
    *   **WezTerm:** Configured to read the system appearance and adjust accordingly.

## Key Files to Reference

*   `flake.nix`: The root definition for all systems and apps.
*   `nixos-config/hosts/darwin/default.nix`: Main macOS system configuration.
*   `install.sh`: The procedural installation logic.
*   `editor/nvim/init.lua`: Neovim entry point.
*   `scripts/AppearanceWatcher/Sources/main.swift`: Logic for macOS theme synchronization.
