{pkgs, config, lib, ...}:
{
  config = {
    home.whmConfig = {
      link.wezterm = true;
    };
    fonts.fontconfig.enable = true;
    home.packages = [
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.wezterm
      pkgs.zed-editor
    ];
  };
}
