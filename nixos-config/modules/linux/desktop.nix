{pkgs, config, lib, ...}:
{
  config = {
    home.whmConfig = {
      link.wezterm = true;
    };
    fonts.fontconfig.enable = true;
    home.packages = [
      pkgs.wezterm
      pkgs.zed-editor
    ] ++ (import ./fonts.nix pkgs);
  };
}
