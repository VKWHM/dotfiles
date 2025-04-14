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
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case" 
      "--max-columns-preview"
    ];
  };
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.unsafeDiscardStringContext (builtins.readFile ../shell/starship.toml));
  };
  programs.fd.enable = true;
  programs.git.enable = true;
  programs.eza.enable = true;
  programs.zoxide.enable = true;
  programs.home-manager.enable = true;
  # home.packages = with pkgs; [
  #   fzf
  # ];
}
