{pkgs, lib, config, ...}:
let
  inherit (lib) mkIf;
  cfg = config.programs.fzf;
  defaultCmd = "fd --hidden --strip-cwd-prefix --exclude .git";
in {
    config = mkIf cfg.enable {
      programs.fzf = {
        enableZshIntegration = true;
        defaultOptions = [
          "--height=80%"
          "--layout=reverse"
          "--border"
          "--tmux=center,80%,90%"
          # "--color ${ctLatte}"
        ];
        defaultCommand = defaultCmd;
        changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
        changeDirWidgetOptions = [ "--preview='eza --tree --color=always {} | head -500'" ];
        fileWidgetCommand = defaultCmd;
        # fileWidgetOptions = ["--preview='${fileOrDir}'"];
        tmux = {
          enableShellIntegration = true;
          shellIntegrationOptions = [
            "-p 80%,70%"
          ];
        };
      };
      programs.zsh = {
        plugins = [
          {
            name = "fzf-tab-completion";
            file = "fzf-tab.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "Aloxaf";
              repo = "fzf-tab";
              rev = "v1.2.0";
              sha256 = "sha256-q26XVS/LcyZPRqDNwKKA9exgBByE0muyuNb0Bbar2lY=";
            };
          }
          {
            name = "forgit";
            file = "forgit.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "wfxr";
              repo = "forgit";
              rev = "25.02.0";
              sha256 = "sha256-vVsJe/MycQrwHLJOlBFLCuKuVDwQfQSMp56Y7beEUyg=";
            };
          }
        ];
        sessionVariables = {
          FORGIT_FZF_DEFAULT_OPTS = "--tmux=center,80%,70%";
        };
      };
    };
  }
