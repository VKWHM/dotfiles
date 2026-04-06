{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.sesh = {
    enable = true;
    enableAlias = true;
    enableTmuxIntegration = true;
    icons = true;
    tmuxKey = "S";
    settings = {
      blacklist = ["scratch"];
    };
  };
}
