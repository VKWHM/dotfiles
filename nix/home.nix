{config, lib, pkgs, user, ...}:
with user; {
  home.username = username;
  home.homeDirectory = home;
  home.stateVersion = "24.11";

  ## Programs
  # ZSH
  programs.zsh = let 
    makeFeature = names: builtins.foldl' (acc: name: acc // {${name} = true;}) {} names;
    zsh_feature_list = [
      "autocd"
    ];
    aliasColor = "#7287fd";
    in {
    enable = true;
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
        function zvm_after_init() {
          eval $__PLUGINS
          eval $__PLUGIN_HSS
        }
      '')
      (lib.mkOrder 2001 ''
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
    ];
    localVariables = {
# Alias Finder
      ZSH_ALIAS_FINDER_SUFFIX = "%F{${aliasColor}}";
      ZSH_ALIAS_FINDER_IGNORED = "man";
# vi-mode 
      ZVM_LAZY_KEYBINDINGS = "false";
    };
  } // makeFeature zsh_feature_list;
  programs.fzf.enable = true;
  programs.fd.enable = true;
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    cowsay
  ];
}
