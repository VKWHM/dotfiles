{user, ...}: 
{
  imports = [
    ./shell.nix
  ];

  home.username = user.username;
  home.homeDirectory = user.home;
  home.stateVersion = "24.11";
}

