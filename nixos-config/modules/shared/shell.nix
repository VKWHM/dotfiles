{config, lib, pkgs, user, ...}:
let
  rootDir = ../../../.;
  ln = path: {
    source = "${rootDir}/${path}";
  };
in {
  ## Programs
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
    settings = builtins.fromTOML (builtins.unsafeDiscardStringContext (builtins.readFile ../../../shell/starship.toml));
  };
  programs.neovim = {
    enable = true;
    vimdiffAlias = true;
    withPython3 = true;
    withNodeJs = true;
    withRuby = true;
  };
  # home.file.".config/nvim" = ln ../editor/nvim;
  home.file.".config/wezterm" = ln "terminal/wezterm";
  home.file.".vimrc" = ln "editor/vimrc";
  home.file.".wezterm.lua" = ln "terminal/wezterm/wezterm.lua";
  home.file.".tmux.conf" = ln "terminal/tmux.conf";
  programs.fd.enable = true;
  programs.git.enable = true;
  programs.eza.enable = true;
  programs.zoxide.enable = true;
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    tmux btop
    go cargo # for neovim
  ];
}
