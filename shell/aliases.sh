# Change keyboard layout
alias trkb="setxkbmap tr"
alias uskb="setxkbmap us"

# Edit WHM Shell Configuration
alias shellconfig="cd ~/.whm_shell/ && nvim && cd -"

# Hard Reload shell
alias reload='exec "$SHELL"'
#
# Configure bat 
alias bat='bat --theme="$(is_dark && echo Catppuccin Mocha || echo Catppuccin Latte)"'

# Make help menu more readable
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
alias -g -- -help='-h 2>&1 | bat --language=help --style=plain'

# Make ls better
alias ls='eza --icons=always --git --octal-permissions'

# Make cd better
alias cd='z'
