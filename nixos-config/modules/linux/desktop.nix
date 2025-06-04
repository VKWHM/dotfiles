{pkgs, config, lib, ...}:
{
  config = {
    home.whmConfig = {
      link.wezterm = true;
    };
    fonts.fontconfig.enable = true;
    home.packages = [
    ] ++ (import ../shared/fonts.nix pkgs);
  };
}
