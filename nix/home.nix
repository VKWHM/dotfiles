{config, lib, pkgs, user, ...}:
with user; {
  home.username = username;
  home.homeDirectory = home;
  home.stateVersion = "24.11";

  ## Programs
  # ZSH
  programs.zsh = import ./zsh.nix pkgs;
  programs.fzf = import ./fzf.nix  pkgs;
  programs.bat = import ./bat.nix pkgs;
  programs.fd.enable = true;
  programs.git.enable = true;
  programs.ripgrep.enable = true;
  programs.eza.enable = true;
  programs.home-manager.enable = true;
  # home.packages = with pkgs; [
  #   fzf
  # ];
}
