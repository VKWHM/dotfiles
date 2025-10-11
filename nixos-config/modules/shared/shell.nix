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
        marksman
        # Dependencies
        python3
        lua51Packages.lua
        luajitPackages.luarocks
        luajitPackages.jsregexp
        zulu
        php
        php84Packages.composer
        unzip
        imagemagick
        sqlite
        # Plugin Dependencies
        ast-grep
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
  # Tmux search keys.primarybindings
  programs.tmux.searchKeys = [
    ### PCRE
    {
      name = "URL";
      keys = {
        primary = "C-u";
        once = "M-u";
      };
      search.pcre = true;
      fzf.enable = true;
      fzf.preview = ''echo "$" {2} | tr -d '' | tr -d '' | bat --style=grid --language=zsh --color=always && echo {1} | bat --style=plain --language=url --color=always'';
      processing.preProcessor = "${pkgs.coreutils}/bin/tac";
      search.regex = ''(?i)\b(?:https?|ftps?|file|wss?|ssh|git):///?(?:\w+?:.+@)?(?:(?:(?:25[0-5]|(?:2[0-4]|1\d|[1-9]|)\d)\.?\b){4}|(?:(?:xn--)?[a-z0-9-]{1,63}\.)+(?:[a-z]{2,63})|[a-z0-9-]{1,63})(?::\d{2,5})?(?:/(?:[a-z0-9._~!$&'()*+,;=:@%/-]|%[0-9a-f]{2}|)*)?(?:\?(?:[a-z0-9._~!$&'()*+,;=:@%/?-]|%[0-9a-f]{2})*)?(?:\#(?:[A-Za-z0-9._~!$&'()*+,;=:@%/?-]|%[0-9A-Fa-f]{2})*)?(?<![)\]}'".,;:!?])'';
    }

    {
      name = "Last-Command";
      keys.primary = "C-c";
      search.pcre = true;
      search.regex = ''(?sm)^.*^\h*\K.+?\h*$'';
      search.extraArgs = [
        "--multiline"
      ];
    }
    # {
    #   name  = "Number";
    #   keys.primary   = "C-d";
    #   search.regex = qr/\b\d+\b/;
    # }

    {
      name = "File"; # Unix-ish path with at least one slash; supports ./../~/absolute
      keys.primary = "C-f";
      keys.once = "f";
      search.pcre = true;
      fzf.enable = true;
      fzf.preview = ''echo {2} | bat --style=grid --language=nix --color=always'';
      processing.preProcessor = "${pkgs.coreutils}/bin/tac";
      search.regex = ''(?<=^|\s|["'\`])(?:\.{1,2}/|~/|/)?(?:[A-Za-z0-9~_.-]+(?:/))+[A-Za-z0-9._\[\]#$%&+=@-]*'';
    }

    # {
    #   name  = "Base64";  # strict blocks with correct padding
    #   keys.primary   = "M-b";
    #   search.regex = qr/\b(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=)?\b/;
    # }

    # {
    #   name  = "UUID";    # RFC 4122 variant with version & variant checks
    #   keys.primary   = "M-u";
    #   search.regex = qr/\b[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[1-5][0-9A-Fa-f]{3}-[89ABab][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}\b/;
    # }

    # {
    #   name  = "Docker ID";  # short (12) or full (64) hex; use {12} to force short only
    #   keys.primary   = "M-d";
    #   search.regex = qr/\b[a-f0-9]{12}(?:[a-f0-9]{52})?\b/;
    # }

    # {
    #   name  = "MAC Address";  # 00:11:22:33:44:55 or 00-11-22-33-44-55
    #   keys.primary   = "M-m";
    #   search.regex = qr/\b(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\b/;
    #   # If you also want Cisco-style dotted (xxxx.xxxx.xxxx), use:
    #   # qr/\b(?:(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}|[0-9A-Fa-f]{4}(?:\.[0-9A-Fa-f]{4}){2})\b/
    # }

    # {
    #   name  = "Hash/SHA"; # git short/full, sha256; optional base58-ish 52 for some keys.primarys
    #   keys.primary   = "M-h";
    #   search.regex = qr/
    #     \b(?:[0-9a-f]{7,40})\b                         # git short/full (hex)
    #     |
    #     \b(?:[0-9a-f]{64})\b                           # sha256 (hex)
    #     |
    #     \b(?:[1-9A-HJ-NP-Za-km-z]{52})\b               # base58-like 52-char (no 0OIl)
    #   /x;
    # }

    # {
    #   name  = "IP Address";   # IPv4 0–255 strict
    #   keys.primary   = "M-i";
    #   search.regex = qr/\b(?:(?:25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(?:25[0-5]|2[0-4]\d|1?\d?\d)\b/;
    # }

    # {
    #   name  = "Email Address";  # practical, avoids hyphens at label ends
    #   keys.primary   = "M-e";
    #   search.regex = qr/
    #     \b
    #     [A-Za-z0-9._%+-]+
    #     @
    #     (?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+
    #     [A-Za-z]{2,63}
    #     \b
    #   /x;
    # }

    {
      name = "Number";
      keys.primary = "C-d";
      search.regex = "[[:space:]][[:digit:]]{4,}[[:space:]]";
    }
    # {
    #   name = "Base64";
    #   keys.primary = "M-b";
    #   search.regex = "([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?";
    # }
    # {
    #   name = "UUID";
    #   keys.primary = "M-u";
    #   search.regex = "[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}";
    # }
    {
      name = "Docker ID";
      keys.primary = "M-d";
      search.regex = "[0-9a-f]{12}";
    }
    {
      name = "MAC Address";
      keys.primary = "M-m";
      search.regex = "([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})";
    }
    # {
    #   name = "Hash/SHA";
    #   keys.primary = "M-h";
    #   search.regex = "([0-9a-f]{7,40}|[[:alnum:]]{52}|[0-9a-f]{64})";
    # }
    {
      name = "IP Address";
      keys.primary = "M-i";
      search.regex = "[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}";
    }
    {
      name = "Email Address";
      keys.primary = "M-e";
      search.regex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}";
    }
  ];
}
