{config, lib, pkgs, user, ...}:
let
  ln = path: {
    source = path;
  };
  homeCfg = config.home;
in {
  ## Programs
  # ZSH
  programs.zsh = import programs/zsh.nix pkgs;
  programs.fzf = import programs/fzf.nix  pkgs;
  programs.bat = import programs/bat.nix pkgs;
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
  # home.file.".config/nvim" = ln ../editor/nvim;
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
    whmDir = "${homeCfg.homeDirectory}/.whm_shell";
  in {
    uninstall = ''
      echo "Uninstalling WHM shell...";
    '';
    whmShell = ''
      installed=$(test -d "${whmDir}" && echo "true" || echo "false")
      if [[ $installed == "false" ]]; then
        if command -v git 2>&1 > /dev/null; then
          git clone https://github.com/vkwhm/dotfiles.git ${whmDir}
          installed=true;
        elif command wget 2>&1 > /dev/null; then
          zip_file="$(mktemp)";
          wget https://github.com/vkwhm/dotfiles/archive/refs/heads/main.zip -O "$zip_file";
          unzip "$zip_file" -d "${whmDir}";
          installed=true;
        fi
      fi
      if [[ $installed == "true" ]]; then
        echo "Linking WHM Configurations...";
        ln -s "${whmDir}/editor/nvim" "${homeCfg.homeDirectory}/.config/nvim";
      else
        echo "Failed to install WHM shell. Please install it manually.";
      fi;
    '';
  };
}
