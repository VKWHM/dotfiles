{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.programs.bat;
in {
  config = mkIf cfg.enable {
    programs.bat = {
      config.theme = "Catppuccin Mocha";
      themes = let
        cpLatte = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/bat/699f60f/themes/Catppuccin%20Latte.tmTheme";
          sha256 = "sha256-8fm+zCL5HJykuknBh36MxFCCwji2kTNGjwAtZ3Usd94=";
          name = "catppuccin-latte";
        };
        cpMocha = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/bat/699f60f/themes/Catppuccin%20Mocha.tmTheme";
          sha256 = "sha256-Rj7bB/PCaC/r0y+Nh62yI+Jg1O0WDm88E+DrsaDZj6o=";
          name = "catppuccin-mocha";
        };
        catppuccin-bat-derivation = pkgs.stdenv.mkDerivation {
          name = "catppuccin-bat";
          sourceRoot = ".";
          srcs = [cpLatte cpMocha];
          unpackPhase = "true";
          dontBuild = true;
          installPhase = ''
            mkdir -p $out
            cp ${cpLatte} $out/cpLatte.tmTheme
            cp ${cpMocha} $out/cpMocha.tmTheme
          '';
        };
      in {
        "Catppuccin Latte" = {
          src = catppuccin-bat-derivation;
          file = "cpLatte.tmTheme";
        };
        "Catppuccin Mocha" = {
          src = catppuccin-bat-derivation;
          file = "cpMocha.tmTheme";
        };
      };
    };
  };
}
