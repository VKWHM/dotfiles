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

# package installition and removing aliases
case "$OSTYPE" in
  "darwin"*)
    if command -v brew 2>&1 >/dev/null; then
      yep_alias="brew install"
      nope_alias="brew remove"
    fi
    ;;

  "linux-gnu"*)
    if command -v dnf 2>&1 >/dev/null; then
      yep_alias="sudo dnf install"
      nope_alias="sudo dnf remove"
    elif command -v apt 2>&1 >/dev/null; then
      yep_alias="sudo apt install"
      nope_alias="sudo apt remove"
    fi
    ;;
esac

[[ -z "{yep_alias}" ]] || alias yep="$yep_alias"
[[ -z "{nope_alias}" ]] || alias nope="$nope_alias"
