{
  pkgs,
  lib,
  config,
  ...
}: let
  appearance = config.utils.theme.appearance;
  opencode = ../../../../terminal/opencode;
in {
  config = {
    # home.file.".config/opencode/oh-my-opencode.json" = {
    #   source = opencode + /oh-my-opencode.json;
    # };
    programs.opencode = {
      enable = true;
      package = pkgs.hello; # dummy package to avoid HM module evaluation error with null package

      commands = {
        readme = opencode + /command/readme.md;
        commit = opencode + /command/commit.md;
        tdd = opencode + /command/tdd.md;
      };
      agents = {
        code-mentor = opencode + /agents/code-mentor.md;
      };
      tui = {
        theme = "catppuccin";
      };
      settings = {
        # model = "github-copilot/claude-opus-4.5";
        autoshare = false;
        autoupdate = false;
        plugin = [
          "@mohak34/opencode-notifier@latest"
          "envsitter-guard"
          "opentmux"
          "oh-my-opencode@latest"
          # "${rootDir}/scripts/opencode-theme-watcher"
        ];
      };
    };
  };
}
