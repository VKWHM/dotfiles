{pkgs, lib, ...}:
let
  themeIs = light: dark: "\\$([[ \\\"\\$WHM_APPEARANCE\\\" == \\\"Light\\\"* ]] && echo ${light} || echo ${dark})";
  ctMocha = "bg:#24273A,bg+:#1E2030,fg:#D9E0EE,fg+:#A5ADCB,hl:#89B4FA,hl+:#89B4FA,info:#F9E2AF,marker:#D9E0EE,pointer:#D9E0EE,prompt:#F9E2AF,spinner:#F9E2AF";
  ctLatte = "bg:#EFF1F5,bg+:#E6E9EF,fg:#4C4F69,fg+:#5C5F77,hl:#1E66F5,hl+:#1E66F5,info:#DC8A78,marker:#4C4F69,pointer:#4C4F69,prompt:#DC8A78,spinner:#DC8A78";
  fileOrDir = "if [ -d {} ]; then eza --tree --color=always {} | head -300; else ${pkgs.bat}/bin/bat --theme=\\\"${themeIs "Catppuccin Latte" "Catppuccin Mocha"}\\\" -n --color=always --line-range :500 {}; fi";
  defaultCmd = "fd --hidden --strip-cwd-prefix --exclude .git";
in {
  enable = true;
  enableZshIntegration = true;
  defaultOptions = [
    "--height=80%"
    "--layout=reverse"
    "--border"
    "--tmux=center,80%,90%"
    "--color ${ctMocha}"
  ];
  defaultCommand = defaultCmd;
  changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
  changeDirWidgetOptions = [ "--preview='eza --tree --color=always {} | head -500'" ];
  fileWidgetCommand = defaultCmd;
  fileWidgetOptions = ["--preview='${fileOrDir}'"];
  tmux = {
    enableShellIntegration = true;
    shellIntegrationOptions = [
      "-p 80%,70%"
    ];
  };
}
