{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.home.whmConfig;
in
  mkIf (cfg.enable && cfg.link.pi) {
    programs.pi-coding-agent = {
      enable = true;
    };
  }

