{
  pkgs,
  lib,
  config,
  ...
}: let
  appearance = config.utils.theme.appearance;
  rootDir = ../../../../.;
in {
  config = {
    programs.opencode = {
      enable = true;
      package = null;
      commands = {
        readme = "${rootDir}/terminal/opencode/command/readme.md";
      };
      settings = {
        theme = "catppuccin";
        autoshare = false;
        autoupdate = false;
        plugin = [
          "opencode-gemini-auth@latest"
          "oh-my-opencode@latest"
          # "${rootDir}/scripts/opencode-theme-watcher"
        ];
      };
    };
  };
}
