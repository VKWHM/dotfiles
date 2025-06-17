{pkgs, lib, config, ...}: let
  inherit (lib) mkIf mkMerge mkOrder mkOption;
  catppuccin = import ./catppuccin.nix;
  inherit (catppuccin) latte mocha;
  cfg = config.utils.theme;
in
{
  options = {
    utils.theme = {
      appearance = mkOption {
        type = lib.types.str;
        default = "dark";
        description = ''
          The appearance theme for the system.
          It can be "dark", "light" or "auto".
          Default is "dark".
        '';
      };
      autoconfig.light = mkOption {
        type = lib.types.lines;
        default = "";
        description = ''
          A configuration for light appearance.
          It can be used to set environment variables or run commands.
          Default is an empty string.
        '';
      };
      autoconfig.dark = mkOption {
        type = lib.types.lines;
        default = "";
        description = ''
          A configuration for dark appearance.
          It can be used to set environment variables or run commands.
          Default is an empty string.
        '';
      };
    };
  };
  config = {
    programs.zsh = mkIf config.programs.zsh.enable (let
      appearance = cfg.appearance;
      theme = if appearance == "dark" then "Catppuccin Mocha" else "Catppuccin Latte";
    in {
      initContent = mkMerge [
        (mkIf (appearance == "dark") ( mkOrder 2048 ''
          export WHM_APPEARANCE="Dark"
        ''))
        (mkIf (appearance == "light") ( mkOrder 2048 ''
          export WHM_APPEARANCE="Light"
        ''))
        (mkIf (appearance == "auto" && pkgs.hostPlatform.isLinux) ( mkOrder 2048 ''
          if command -v gsettings &> /dev/null && (gsettings get org.gnome.desktop.interface color-scheme | grep -iq light); then
            export WHM_APPEARANCE="Light"
            ${cfg.autoconfig.light}
          else
            export WHM_APPEARANCE="Dark"
            ${cfg.autoconfig.dark}
          fi
        ''))
        (mkIf (appearance == "auto" && pkgs.hostPlatform.isDarwin) ( mkOrder 2048 ''
          if [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == "Dark" ]]; then
            export WHM_APPEARANCE="Dark"
          else
            export WHM_APPEARANCE="Light"
          fi
        ''))

        (mkIf (appearance == "auto") ( mkOrder 2049 ''
          function _whm_appearance_change_dark_notifier() {
            export WHM_APPEARANCE="Dark"
            ${cfg.autoconfig.dark}
          }

          function _whm_appearance_change_light_notifier() {
            export WHM_APPEARANCE="Light"
            ${cfg.autoconfig.light}
          }

          trap '_whm_appearance_change_dark_notifier' USR1
          trap '_whm_appearance_change_light_notifier' USR2
        ''))
      ];
    });
    systemd.user = mkIf (cfg.appearance == "auto" && pkgs.hostPlatform.isLinux) {
      enable = true;
      startServices = "suggest";
      services."gnome-appearance-watcher" = {
        Unit = {
          Description = "Gnome Appearance Watcher";
          After = [ "graphical-session.target" ];
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.callPackage ../../../../scripts/GnomeWatcher {}}/bin/gwatch";
          Restart = "always";
          RestartSec = 5;

          # Environment variables required for GSettings to work
          Environment = [
            "DISPLAY=:0"
            "XDG_CURRENT_DESKTOP=GNOME"
            "GSETTINGS_BACKEND=dconf"
            "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/%U/bus"
            "XDG_RUNTIME_DIR=/run/user/%U"
          ];
        };
      };
    };
    # launchd = mkIf (cfg.appearance == "auto" && pkgs.hostPlatform.isLinux) {
    #   enable = true;
    #   agents."gnome-appearance-watcher" = {
    #     enable = true;
    #     config = {
    #       # ProgramArguments = [ "${pkgs.packageCall ../../../../scripts/GnomeWatcher {}}/bin/gwatch" ];
    #     }
    #   };
    # };
  };
}
