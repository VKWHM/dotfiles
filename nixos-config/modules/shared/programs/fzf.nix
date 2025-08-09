{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.programs.fzf;
  defaultCmd = "fd --hidden --strip-cwd-prefix --exclude .git";

  catppuccin = import ../utils/catppuccin.nix;
  inherit (catppuccin) latte mocha;
  colorPalette =
    if config.utils.theme.appearance == "dark"
    then mocha
    else latte;
  themeIs = light: dark: "\\$([[ \\$WHM_APPEARANCE == 'Light'* ]] && echo ${light} || echo ${dark})";
  fileOrDir = "if [ -d {} ]; then eza --tree --color=always {} | head -300; else ${pkgs.bat}/bin/bat --theme=\\\"${themeIs "Catppuccin Latte" "Catppuccin Mocha"}\\\" -n --color=always --line-range :500 {}; fi";
in {
  config = mkIf cfg.enable {
    programs.fzf = {
      enableZshIntegration = true;
      defaultOptions = [
        "--height=80%"
        "--layout=reverse"
        "--border"
        "--bind=ctrl-r:toggle-preview,ctrl-t:toggle-preview-wrap,ctrl-e:preview-up,ctrl-y:preview-down,ctrl-f:preview-page-down,ctrl-b:preview-page-up,ctrl-a:toggle-all"
        "--tmux=center,80%,90%"
      ];
      defaultCommand = defaultCmd;
      changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
      changeDirWidgetOptions = ["--preview='eza --tree --color=always {} | head -500'"];
      fileWidgetCommand = defaultCmd;
      fileWidgetOptions = ["--preview='${fileOrDir}'"];
      colors = mkIf (config.utils.theme.appearance != "auto") {
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
    utils.theme.autoconfig = {
      light = ''
        export FZF_DEFAULT_OPTS="''\${FZF_DEFAULT_OPTS%--color*} --color=bg+:${latte.surface0},bg:${latte.base},spinner:${latte.rosewater},hl:${latte.red},fg:${latte.text},header:${latte.red},info:${latte.mauve},pointer:${latte.rosewater},marker:${latte.lavender},fg+:${latte.text},prompt:${latte.mauve},hl+:${latte.red},selected-bg:${latte.surface1},border:${latte.surface0},label:${latte.text}"
      '';
      dark = ''
        export FZF_DEFAULT_OPTS="''\${FZF_DEFAULT_OPTS%--color*} --color=bg+:${mocha.surface0},bg:${mocha.base},spinner:${mocha.rosewater},hl:${mocha.red},fg:${mocha.text},header:${mocha.red},info:${mocha.mauve},pointer:${mocha.rosewater},marker:${mocha.lavender},fg+:${mocha.text},prompt:${mocha.mauve},hl+:${mocha.red},selected-bg:${mocha.surface1},border:${mocha.surface0},label:${mocha.text}"
      '';
    };
  };
}
