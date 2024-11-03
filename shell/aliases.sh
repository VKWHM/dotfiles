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

# Make mount command output more readable
alias mount="mount | column -t"

# Print current PATH variable
alias path='echo -e ${PATH//:/\\n}'

# Show current time
alias now='date +"%d.%m.%Y - %T"'

# Show open ports
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias ports='netstat -an | grep LISTEN'
else
  alias ports='netstat -tulnvp'
fi

# prompt if deleting more than 3 files at a time 
alias rm='rm -I'
 
# confirmation 
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

if [[ "$OSYPE" == "linux-gnu"* ]]; then
  # Parenting changing perms on / 
  alias chown='chown --preserve-root'
  alias chmod='chmod --preserve-root'
  alias chgrp='chgrp --preserve-root'
fi

# pass options to free (only linux systems)
[[ "$OSTYPE" == "darwin"* ]] || alias meminfo='free -ltmh'
 
# get top process eating memory
alias psmem='ps aux | sort -nr -k 4 | less'
 
# get top process eating cpu
alias pscpu='ps aux | sort -nr -k 3 | less'

# searchable process table
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
 
# get GPU ram on device
[[ ! -e /var/log/Xorg.0.log ]] || alias gpumeminfo='grep -i --color memory /var/log/Xorg.0.log'

# Display sizes of files and directories inside cwd
alias lsize='du -sh * | sort -rh'

# Show command usage statistics
alias hs='history | awk "{CMD[\$2]++; count++;} END {for (a in CMD) print CMD[a] \" \" CMD[a]/count*100 \"% \" a;}" | grep -vE "^[%.0-9 ]+./" | column -c3 -s " " -t | sort -nr | nl | head -20'

# Show last logins
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  alias lastlog="lastlog | grep -v 'Never logged in'"
fi
