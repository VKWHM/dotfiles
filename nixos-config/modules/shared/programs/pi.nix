{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.home.whmConfig;
in
  mkIf (cfg.enable) {
    programs.pi-coding-agent = {
      enable = true;
      settings = {
        packages = [
          "git:github.com/otahontas/pi-coding-agent-catppuccin"
          "npm:pi-auto-theme"
          "npm:pi-diet-ripgrep"
          "npm:pi-nvim"
        ];
      };
    };
  }
