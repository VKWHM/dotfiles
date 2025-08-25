{
  config,
  lib,
  pkgs,
  ...
}: let
  catppuccin-btop = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "btop";
    rev = "f437574"; # commit hash
    sha256 = "1rwpsb252mb6kjgai47ns0ssd7xh7zbpbvanz6p62g8m4z0rjhcq"; # replace with nix-prefetch result
  };
in {
  config = lib.mkIf config.programs.btop.enable {
    home.file.".config/btop/themes" = {
      source = "${catppuccin-btop}/themes";
      recursive = true;
    };
    utils.theme.autoconfig = {
      dark = ''
        if [[ -n "$HOME" && -f "$HOME/.config/btop/btop.conf" ]]; then
          sed -Ei ''' "/^color_theme/s|\".+\"|\"$HOME/.config/btop/themes/catppuccin_mocha.theme\"|" ~/.config/btop/btop.conf
        fi
      '';
      light = ''
        if [[ -n "$HOME" && -f "$HOME/.config/btop/btop.conf" ]]; then
          sed -Ei ''' "/^color_theme/s|\".+\"|\"$HOME/.config/btop/themes/catppuccin_latte.theme\"|" ~/.config/btop/btop.conf
        fi
      '';
    };
  };
}
