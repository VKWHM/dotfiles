{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  rootDir = ../../../.;
  ln = path: {
    source = "${rootDir}/${path}";
  };
in {
  ## Programs
  imports = [
    programs/tmux.nix
    programs/zsh.nix
    programs/fzf.nix
    programs/bat.nix
    programs/starship.nix
    programs/btop.nix
  ];
  # ZSH
  programs.zsh.enable = true;
  programs.fzf.enable = true;
  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case"
      "--max-columns-preview"
    ];
  };
  programs.neovim = {
    enable = true;
    vimdiffAlias = true;
    withPython3 = true;
    withNodeJs = true;
    withRuby = true;
    extraPackages =
      (with pkgs; [
        # LSPs
        nixd
        # Dependencies
        python3
        lua51Packages.lua
        luajitPackages.luarocks
        zulu
        php
        php84Packages.composer
        unzip
        imagemagick
        sqlite
      ])
      ++ (
        if (builtins.elemAt (builtins.match ".+-(.+)" pkgs.system) 0) == "darwin"
        then []
        else [pkgs.julia]
      );
  };
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    silent = true;
  };
  programs.fd.enable = true;
  # programs.git.enable = true;
  programs.eza.enable = true;
  programs.zoxide.enable = true;
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    lazygit
    go
    cargo # for neovim
    gh
    git
  ];
  # Tmux search keybindings
  programs.tmux.searchKeys = [
    ### PCRE
    {
      name = "URL";
      key = "C-u";
      onceKey = "M-u";
      pcre = true;
      fzf = true;
      fzfPreview = ''echo "$" {2} | tr -d '' | tr -d '' | bat --style=grid --language=zsh --color=always && echo {1} | bat --style=plain --language=url --color=always'';
      preProcessor = "${pkgs.coreutils}/bin/tac";
      regex = ''(?i)\b(?:https?|ftps?|file|wss?|ssh|git):///?(?:\w+?:.+@)?(?:(?:(?:25[0-5]|(?:2[0-4]|1\d|[1-9]|)\d)\.?\b){4}|(?:(?:xn--)?[a-z0-9-]{1,63}\.)+(?:[a-z]{2,63})|[a-z0-9-]{1,63})(?::\d{2,5})?(?:/(?:[a-z0-9._~!$&'()*+,;=:@%/-]|%[0-9a-f]{2}|)*)?(?:\?(?:[a-z0-9._~!$&'()*+,;=:@%/?-]|%[0-9a-f]{2})*)?(?:\#(?:[A-Za-z0-9._~!$&'()*+,;=:@%/?-]|%[0-9A-Fa-f]{2})*)?(?<![)\]}'".,;:!?])'';
    }

    # {
    #   name  = "Number";
    #   key   = "C-d";
    #   regex = qr/\b\d+\b/;
    # }

    # {
    #   name  = "File";    # Unix-ish path with at least one slash; supports ./../~/absolute
    #   key   = "C-f";
    #   regex = qr{
    #     (?<=^|\s|["'`])                    # reasonable left boundary
    #     (?:
    #       (?:\.{1,2}/|~/?|/)?              # ./  ../  ~/  or absolute /
    #       (?:[A-Za-z0-9~_.-]+/)+           # at least one dir/
    #       [A-Za-z0-9._\[\]#$%&+=@-]*       # filename (may be empty)
    #     )
    #   }x;
    # }

    # {
    #   name  = "Base64";  # strict blocks with correct padding
    #   key   = "M-b";
    #   regex = qr/\b(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=)?\b/;
    # }

    # {
    #   name  = "UUID";    # RFC 4122 variant with version & variant checks
    #   key   = "M-u";
    #   regex = qr/\b[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[1-5][0-9A-Fa-f]{3}-[89ABab][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}\b/;
    # }

    # {
    #   name  = "Docker ID";  # short (12) or full (64) hex; use {12} to force short only
    #   key   = "M-d";
    #   regex = qr/\b[a-f0-9]{12}(?:[a-f0-9]{52})?\b/;
    # }

    # {
    #   name  = "MAC Address";  # 00:11:22:33:44:55 or 00-11-22-33-44-55
    #   key   = "M-m";
    #   regex = qr/\b(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\b/;
    #   # If you also want Cisco-style dotted (xxxx.xxxx.xxxx), use:
    #   # qr/\b(?:(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}|[0-9A-Fa-f]{4}(?:\.[0-9A-Fa-f]{4}){2})\b/
    # }

    # {
    #   name  = "Hash/SHA"; # git short/full, sha256; optional base58-ish 52 for some keys
    #   key   = "M-h";
    #   regex = qr/
    #     \b(?:[0-9a-f]{7,40})\b                         # git short/full (hex)
    #     |
    #     \b(?:[0-9a-f]{64})\b                           # sha256 (hex)
    #     |
    #     \b(?:[1-9A-HJ-NP-Za-km-z]{52})\b               # base58-like 52-char (no 0OIl)
    #   /x;
    # }

    # {
    #   name  = "IP Address";   # IPv4 0–255 strict
    #   key   = "M-i";
    #   regex = qr/\b(?:(?:25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(?:25[0-5]|2[0-4]\d|1?\d?\d)\b/;
    # }

    # {
    #   name  = "Email Address";  # practical, avoids hyphens at label ends
    #   key   = "M-e";
    #   regex = qr/
    #     \b
    #     [A-Za-z0-9._%+-]+
    #     @
    #     (?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+
    #     [A-Za-z]{2,63}
    #     \b
    #   /x;
    # }

    ### ERE
    # {
    #   name = "URL";
    #   key = "C-u";
    #   regex = "(https?://|git@|git://|ssh://|ftp://|file:///)[[:alnum:]?=%/_.:,;~@!#$&()*+-]*";
    # }
    # {
    #   name = "Number";
    #   key = "C-d";
    #   regex = "[[:digit:]]+";
    # }
    # {
    #   name = "File";
    #   key = "C-f";
    #   regex = "(^|^\\.|[[:space:]]|[[:space:]]\\.|[[:space:]]\\.\\.|^\\.\\.)[[:alnum:]~_-]*/[][[:alnum:]_.#$%&+=/@-]*";
    # }
    # {
    #   name = "Base64";
    #   key = "M-b";
    #   regex = "([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?";
    # }
    # {
    #   name = "UUID";
    #   key = "M-u";
    #   regex = "[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}";
    # }
    # {
    #   name = "Docker ID";
    #   key = "M-d";
    #   regex = "[0-9a-f]{12}";
    # }
    # {
    #   name = "MAC Address";
    #   key = "M-m";
    #   regex = "([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})";
    # }
    # {
    #   name = "Hash/SHA";
    #   key = "M-h";
    #   regex = "([0-9a-f]{7,40}|[[:alnum:]]{52}|[0-9a-f]{64})";
    # }
    # {
    #   name = "IP Address";
    #   key = "M-i";
    #   regex = "[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}";
    # }
    # {
    #   name = "Email Address";
    #   key = "M-e";
    #   regex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}";
    # }
  ];
}
