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
    programs.opencode = {
      enable = true;
      package = null;

      commands = {
        readme = opencode + /command/readme.md;
        codereview = opencode + /command/codereview.md;
        commit = opencode + /command/commit.md;
      };
      agents = {
        code-mentor = opencode + /agents/code-mentor.md;
      };
      settings = {
        theme = "catppuccin";
        model = "github-copilot/claude-opus-4-5";
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
