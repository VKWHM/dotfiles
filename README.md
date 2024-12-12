# Dotfiles

A collection of configuration files and scripts to streamline development and system setup. These dotfiles enhance productivity and provide a consistent environment across systems.

## Features

- **Neovim Configuration**: Custom Lua setup for Neovim to boost editing efficiency.
- **Shell Enhancements**: Zsh with `p10k` (Powerlevel10k) theme for a visually appealing and functional terminal.
- **WezTerm Config**: Custom settings for WezTerm, a modern terminal emulator.
- **Tmux Setup**: Configuration for tmux to manage terminal multiplexing.
- **Vim Config**: `.vimrc` for traditional Vim setups.
- **Installation Script**: Automates dotfiles setup for seamless deployment.

## File Structure

```plaintext
.
├── nvim/           # Neovim configuration
├── shell/          # Shell scripts and configurations
├── wezterm/        # WezTerm settings
├── install.sh      # Installation script
├── p10k.zsh        # Powerlevel10k theme configuration
├── tmux.conf       # Tmux configuration
└── vimrc           # Vim configuration
```

## Installation

To set up these dotfiles on your system:

1. Clone the repository:

```bash
git clone https://github.com/vkwhm/dotfiles.git cd dotfiles
```

2. Run the installation script:

```bash
./install.sh
```

3. Follow on-screen prompts to customize settings as needed.

4. Download and install your favorite [Nerd Font](https://www.nerdfonts.com/)

## Requirements

- **Neovim**: Latest version for optimal Lua support.
- **Zsh**: Preferred shell, with Oh-My-Zsh installed.
- **WezTerm**: A modern terminal emulator.
- **Tmux**: Terminal multiplexer for session management.

## Usage

- **Neovim**: Open `nvim` for an enhanced coding experience.
- **Shell**: Enjoy custom shell prompt and utilities with Zsh + Powerlevel10k.
- **WezTerm**: Leverage pre-configured terminal settings.
- **Tmux**: Use `tmux` for multitasking in the terminal.

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch:

   `git checkout -b feature-branch`

3. Make changes and commit:

   `git commit -m "Add your message here"`

4. Push and create a pull request.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Acknowledgements

Special thanks to the open-source community for tools and inspirations that make these configurations possible.
