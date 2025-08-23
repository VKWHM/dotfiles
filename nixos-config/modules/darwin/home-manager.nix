{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  user = "whoami";
  fontsFiles = import ../shared/fonts.nix pkgs;
in
{
  system.primaryUser = user;
  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };
  fonts.packages = fontsFiles;
  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};
    brews = pkgs.callPackage ./brews.nix {};
    onActivation = {
     cleanup = "uninstall";
     autoUpdate = true;
    };

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)
    masApps = {
      # "1password" = 1333542190;
      # "wireguard" = 1451685025;
      # "micorosoft-word" = 462054704;
      # "xcode" = 497799835;
      "bitwarden" = 1352778147;
      "nextdns" = 1464122853;
      "whatsapp" = 310633997;
      "telegram" = 747648890;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      user = {
        name = user;
        home = "/Users/${user}";
      };
    };
    backupFileExtension = "hmbck";
    users.${user} = {
      pkgs,
      config,
      lib,
      ...
    }: {
      imports = [
        ./apps.nix
        # Shared
        ../shared/whmconfig.nix
        ../shared/shell.nix
        ../shared/utils/theme.nix
      ];
      home.stateVersion = "24.11";
      home.whmConfig = {
        enable = true;
        link.nvim = true;
        link.vim = true;
        link.tmux = true;
        link.wezterm = false;
      };
      utils.theme.appearance = "auto";
      # programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };

      # # Marked broken Oct 20, 2022 check later to remove this
      # # https://github.com/nix-community/home-manager/issues/3344
      # manual.manpages.enable = false;
    };
  };
}
