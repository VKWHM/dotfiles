{config, lib, pkgs, user, ...}:
let
  rootDir = ../../../.;
  ln = path: {
    source = "${rootDir}/${path}";
  };
in {
  ## Programs
  imports = [
    programs/tmux.nix
  ];
  # ZSH
  programs.zsh = import programs/zsh.nix pkgs;
  programs.fzf = import programs/fzf.nix  pkgs;
  programs.bat = import programs/bat.nix pkgs;
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case" 
      "--max-columns-preview"
    ];
  };
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.unsafeDiscardStringContext (builtins.readFile "${rootDir}/shell/starship.toml"));
  };
  programs.neovim = {
    enable = true;
    vimdiffAlias = true;
    withPython3 = true;
    withNodeJs = true;
    withRuby = true;
  };
  programs.fd.enable = true;
  # programs.git.enable = true;
  programs.eza.enable = true;
  programs.zoxide.enable = true;
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    btop lazygit
    go cargo # for neovim
    gh git
  ];
  # Tmux search keybindings
  programs.tmux.searchKeys = [
    {
      name = "URL";
      key = "C-u";
      regex = "(https?://|git@|git://|ssh://|ftp://|file:///)[[:alnum:]?=%/_.:,;~@!#$&()*+-]*";
    }
    {
      name = "Number";
      key = "C-d";
      regex = "[[:digit:]]+";
    }
    {
      name = "File";
      key = "C-f";
      regex = "(^|^\\.|[[:space:]]|[[:space:]]\\.|[[:space:]]\\.\\.|^\\.\\.)[[:alnum:]~_-]*/[][[:alnum:]_.#$%&+=/@-]*";
    }
    {
      name = "Base64";
      key = "M-b";
      regex = "([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?";
    }
    {
      name = "UUID";
      key = "M-u";
      regex = "[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}";
    }
    {
      name = "Docker ID";
      key = "M-d";
      regex = "[0-9a-f]{12}";
    }
    {
      name = "MAC Address";
      key = "M-m";
      regex = "([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})";
    }
    {
      name = "Hash/SHA";
      key = "M-h";
      regex = "\\b([0-9a-f]{7,40}|[[:alnum:]]{52}|[0-9a-f]{64})\\b";
    }
    {
      name = "IP Address";
      key = "M-i";
      regex = "[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}";
    }
    {
      name = "Email Address";
      key = "M-e";
      regex = "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}\\b";
    }
  ];
}
