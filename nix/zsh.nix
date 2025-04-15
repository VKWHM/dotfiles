{ lib, pkgs, ...}:
let 
  sourceFiles = [
    ../shell/functions.sh
    (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/b05d8c3be65091153b4d37cbde9d2ee46f9cba2e/plugins/common-aliases/common-aliases.plugin.zsh";
      sha256 = "c62006db9c1026461c33dfae9c33646f12f034fef1e46e1998d20ea988e232bb";
    })
    ../shell/aliases.sh
  ];
  aliasColor = "#7287fd";
in
{
  enable = true;
  autocd = true;
  dotDir = ".config/zsh.hm";
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

      if [[ -f ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh ]]; then
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      fi
    '')
    (lib.mkOrder 2002 # Sourcing custom functions and aliases
      (lib.concatStrings
        (builtins.map
          (file: ''
            if [[ -f ${file} ]]; then
              source ${file}
            fi
          '') sourceFiles
        )
      )
    )
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
    ZVM_VI_INSERT_ESCAPE_BINDKEY= "jk";
  };
  sessionVariables = let
      nvimConf = "${pkgs.neovim}/bin/nvim -u ${../editor/nvim/whoami-init.lua}";
    in {
    WHMCONFIG = ../.;
    WHMSHELLCONFIG = ../shell;
    EDITOR = nvimConf;
    ZVM_VI_EDITOR = nvimConf;
  };
}
