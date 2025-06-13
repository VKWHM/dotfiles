{pkgs, lib, config, ...}: let
  inherit (lib) mkIf mkMerge;
  catppuccin = import ./catppuccin.nix;
  inherit (catppuccin) latte mocha;
  cfg = config.utils.theme;

  themeIs = light: dark: "\\$([[ \\$WHM_APPEARANCE == 'Light'* ]] && echo '${light}' || echo '${dark}')";
in
{
  options = {
    utils.theme = {
      appearance = lib.mkOption {
        type = lib.types.str;
        default = "dark";
        description = ''
          The appearance theme for the system.
          It can be "dark", "light" or "auto".
          Default is "dark".
        '';
      };
    };
  };
  config = {
    programs.fzf = mkIf config.programs.fzf.enable (let 
      colorPalette = if cfg.appearance == "dark" then mocha else latte;
      fileOrDir = "if [ -d {} ]; then eza --tree --color=always {} | head -300; else ${pkgs.bat}/bin/bat --theme=\\\"${themeIs "Catppuccin Latte" "Catppuccin Mocha"}\\\" -n --color=always --line-range :500 {}; fi";
    in {
      colors = {
        "bg+" = colorPalette.surface0;
        bg = colorPalette.base;
        spinner = colorPalette.rosewater;
        hl = colorPalette.red;
        fg = colorPalette.text;
        header = colorPalette.red;
        info = colorPalette.mauve;
        pointer = colorPalette.rosewater;
        marker = colorPalette.lavender;
        "fg+" = colorPalette.text;
        prompt = colorPalette.mauve;
        "hl+" = colorPalette.red;
        "selected-bg" = colorPalette.surface1;
        border = colorPalette.surface0;
        label = colorPalette.text;
      };
      fileWidgetOptions = ["--preview='${fileOrDir}'"];
    });
  };
}
