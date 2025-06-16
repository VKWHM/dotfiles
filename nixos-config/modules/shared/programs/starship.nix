{pkgs, lib, config, ...}:
let
  appearance = config.utils.theme.appearance;
  rootDir = ../../../../.;
in {
  config = {
    programs.starship = {
      enable = true;
      settings = lib.mkIf (appearance != "auto") ( builtins.fromTOML (
        builtins.unsafeDiscardStringContext (
          builtins.readFile "${rootDir}/shell/starship_${if appearance == "light" then "latte" else "mocha"}.toml"
        )
      ) );
    };
    utils.theme.autoconfig = {
      light = ''
        export STARSHIP_CONFIG="${rootDir}/shell/starship_latte.toml"
      '';
      dark = ''
        export STARSHIP_CONFIG="${rootDir}/shell/starship_mocha.toml"
      '';
    };
  };
}
