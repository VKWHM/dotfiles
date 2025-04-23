{config, lib, pkgs, user, ...}:
let
  ln = path: {
    source = path;
  };
in rec {
  ## Programs
  # ZSH
  programs.zsh = import ./zsh.nix pkgs;
  programs.fzf = import ./fzf.nix  pkgs;
  programs.bat = import ./bat.nix pkgs;
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case" 
      "--max-columns-preview"
    ];
  };
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.unsafeDiscardStringContext (builtins.readFile ../shell/starship.toml));
  };
  programs.neovim = {
    enable = true;
    vimdiffAlias = true;
    withPython3 = true;
    withNodeJs = true;
    withRuby = true;
  };
  home.file.".config/nvim" = ln ../editor/nvim;
  home.file.".config/wezterm" = ln ../terminal/wezterm;
  home.file.".vimrc" = ln ../editor/vimrc;
  home.file.".wezterm.lua" = ln ../terminal/wezterm/wezterm.lua;
  home.file.".tmux.conf" = ln ../terminal/tmux.conf;
  programs.fd.enable = true;
  programs.git.enable = true;
  programs.eza.enable = true;
  programs.zoxide.enable = true;
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    tmux 
    go cargo # for neovim
  ];
  home.activation = let 
  zshDir = "${user.home}/${if programs.zsh.dotDir != null then programs.zsh.dotDir else ""}";
  sourceFile = [".zshenv" ".zshrc" ".zprofile" ".zlogin" ".zlogout" ".zsh_aliases" ".zsh_functions"];
  in {
    zsh = ''
      if [ -f "${user.home}/.zshrc" ]; then
        if grep -q "Home Manager generated lines" ${user.home}/.zshrc; then
          sed -i'.home-manager-backup' "/Home Manager generated lines/,+${builtins.toString (1 + (builtins.length sourceFile))}d" ${user.home}/.zshrc
        fi
        cat <<MYEOF>> ${user.home}/.zshrc
      # Home Manager generated lines
      ${lib.concatStringsSep "\n" (builtins.map (file: "[[ -f \"${zshDir}/${file}\" ]] && source \"${zshDir}/${file}\"") sourceFile)}
      MYEOF
      fi
    '';
  };
}
