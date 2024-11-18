# WHMShellConfig base dir
export WHMCONFIG="$HOME/.whm_shell"
export WHMSHELLCONFIG="$WHMCONFIG/shell"

# import functions
source "$WHMSHELLCONFIG/functions.sh"

# Load zsh-vi-mode plugin
function zvm_config() {
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
  ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
}

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

source $ZSH/oh-my-zsh.sh

export EDITOR='vim'

# Configure zoxide
eval "$(zoxide init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Setup Fuzzy Finder Tool
function fzf_init() {
  [[ ! -f ~/.fzf.zsh ]] || source ~/.fzf.zsh
  eval "$(fzf --zsh)"
}

zvm_after_init_commands+=(fzf_init)
export FZF_DEFAULT_OPTS="--height 80% --layout reverse --border"
# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

show_file_or_dir_preview='if [ -d {} ]; then eza --tree --color=always {} | head -300; else bat --theme="$(is_dark && echo Catppuccin Mocha || echo Catppuccin Latte)" -n --color=always --line-range :500 {}; fi'

# -- Use eza and bat for file preview
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -500'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -300' "$@" ;;
    export|unset) fzf --preview 'eval "echo $"{} \| fold -w $(($COLUMNS/2-6))'         "$@" ;;
    ssh)          fzf --preview 'eval "dig {}" \| fold -w $(($COLUMNS/2-6))'                   "$@" ;;
    *)            fzf --preview  "$show_file_or_dir_preview" "$@" ;;
  esac
}

_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# Import aliases
source "$WHMSHELLCONFIG/aliases.sh"
