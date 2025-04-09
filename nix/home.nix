{config, lib, pkgs, user, ...}:
with user; {
  home.username = username;
  home.homeDirectory = home;
  home.stateVersion = "24.11";

  ## Programs
  # ZSH
  programs.zsh = {
    enable = true;
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
    };
  };
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    cowsay
  ];
}
