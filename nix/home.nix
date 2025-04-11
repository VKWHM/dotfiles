{config, lib, pkgs, user, ...}:
with user; {
  home.username = username;
  home.homeDirectory = home;
  home.stateVersion = "24.11";

  ## Programs
  # ZSH
  programs.zsh = let 
    aliasColor = "#7287fd";
    in {
    enable = true;
    autocd = true;
    initContent = lib.mkMerge [ # Hack for wrap plugins inside zvm_after_init function :p
# Wrap plugins 
      (lib.mkOrder 899 ''
        read -r -d "" __PLUGINS <<"# History options should be set in .zshrc and after oh-my-zsh sourcing."
      '')
# Wrap historySubstringSearch
      (lib.mkOrder 1249 ''
        read -r -d "" __PLUGIN_HSS <<EOF
      '')
      (lib.mkOrder 1251 ''
        EOF
      '')
      (lib.mkOrder 2000 ''
        zstyle ':fzf-tab:*' fzf-flags $(echo $FZF_DEFAULT_OPTS) --height 40%
        function zvm_after_init() {
          zvm_bindkey viins "^R" fzf-history-widget
          eval $__PLUGIN_HSS
          eval $__PLUGINS
        }
      '')
      (lib.mkOrder 2001 ''
        if [ -e /home/vkwhm/.nix-profile/etc/profile.d/nix.sh ]; then . /home/vkwhm/.nix-profile/etc/profile.d/nix.sh; fi
        if [ -e $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
          unset __HM_SESS_VARS_SOURCED
          source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh;
        fi

        if [[ -f ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh ]]; then
          source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        fi
      '')
    ];
    history = {
      size = 100000;
      share = true;
      findNoDups = true;
      extended = true; # timestamp
      ignorePatterns = [
        "whoami"
        "clear"
        "history"
        "ls" "ls -l" "ls -la"
        "cd" "cd ~" "cd .." "cd ..." "cd ...."
        ".." "..." "...."
      ];
      ignoreSpace = true;
    };
    syntaxHighlighting = {
      enable = true;
      styles = {
        alias = "fg=${aliasColor}";
        unknown-token = "fg=red";
      };
      patterns = let
        dangerous = "fg=black,bold,bg=red";
        in {
        "rm -rf \*" = dangerous;
        "rm -rf /\*" = dangerous;
        "git push origin --force" = dangerous;
      };
    };
    historySubstringSearch = {
      enable = true;
      searchUpKey = ["^[[A" "^P"];
      searchDownKey = ["^[[B" "^N"];
    };
    plugins = [
      {
        name = "zsh-alias-finder";
        file = "zsh-alias-finder.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "akash329d";
          repo = "zsh-alias-finder";
          rev = "ef6451c";
          sha256 = "sha256-aB5kI+Jt7TVQMCeLcvpAmoMaGxRF1xqw1tioQxbJOzE=";
        };
      }
      {
        name = "zsh-autopair";
        file = "autopair.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "v1.0";
          sha256 = "sha256-wd/6x2p5QOSFqWYgQ1BTYBUGNR06Pr2viGjV/JqoG8A=";
        };
      }
      {
        name = "fzf-tab-completion";
        file = "fzf-tab.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "v1.2.0";
          sha256 = "sha256-q26XVS/LcyZPRqDNwKKA9exgBByE0muyuNb0Bbar2lY=";
        };
      }
      {
        name = "forgit";
        file = "forgit.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "wfxr";
          repo = "forgit";
          rev = "25.02.0";
          sha256 = "sha256-vVsJe/MycQrwHLJOlBFLCuKuVDwQfQSMp56Y7beEUyg=";
        };
      }
    ];
    localVariables = {
# Alias Finder
      ZSH_ALIAS_FINDER_SUFFIX = "%F{${aliasColor}}";
      ZSH_ALIAS_FINDER_IGNORED = "run-help";
# vi-mode
      ZVM_LAZY_KEYBINDINGS = "false";
    };
  } ;
  programs.fzf = let
    fileOrDir = "if [ -d {} ]; then eza --tree --color=always {} | head -300; else bat --theme=\\\"\\$([[ \\\"\\$WHM_APPEARANCE\\\" == \\\"Dark\\\"* ]] && echo Catppuccin Mocha || echo Catppuccin Latte)\\\" -n --color=always --line-range :500 {}; fi";
    defaultCmd = "fd --hidden --strip-cwd-prefix --exclude .git";
     in {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height=80%"
      "--layout=reverse"
      "--border"
      "--color bg:#24273A,bg+:#1E2030,fg:#D9E0EE,fg+:#A5ADCB,hl:#89B4FA,hl+:#89B4FA,info:#F9E2AF,marker:#D9E0EE,pointer:#D9E0EE,prompt:#F9E2AF,spinner:#F9E2AF"
    ];
    defaultCommand = defaultCmd;
    changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
    changeDirWidgetOptions = [ "--preview='eza --tree --color=always {} | head -500'" ];
    fileWidgetCommand = defaultCmd;
    fileWidgetOptions = ["--preview='${fileOrDir}'"];
    tmux.enableShellIntegration = true;
  };
  programs.fd.enable = true;
  programs.bat.enable = true;
  programs.git.enable = true;
  programs.ripgrep.enable = true;
  programs.eza.enable = true;
  programs.home-manager.enable = true;
  # home.packages = with pkgs; [
  #   fzf
  # ];
}
