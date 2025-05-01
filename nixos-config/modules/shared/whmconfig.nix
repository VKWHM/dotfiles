{lib, config, ...}:
let
  inherit (lib) mkOption mkEnableOption types mkIf;
  cfg = config.home.whmConfig;
  homeDir = config.home.homeDirectory;
in {
  options = {
    home.whmConfig = {
      enable = mkEnableOption "WHM Configurations";
      dotDir = mkOption {
        type = types.path;
        default = "${homeDir}/.whm_shell";
        description = ''
          Directory for WHM Configurations.
          This is where the WHM shell will be installed.
        '';
      };
      link = {
        nvim = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Link the nvim configuration to the WHM shell.
            This will create a symlink from ${homeDir}/.config/nvim to ${cfg.dotDir}/editor/nvim.
          '';
        };
      };
    };
  };
  config = mkIf cfg.enable {
    home.activation = {
      whm-1-install = ''
        _WHMCONFIG_INSTALLED=$(test -d "${cfg.dotDir}" && echo "true" || echo "false")
        if [[ $_WHMCONFIG_INSTALLED == "false" ]]; then
          if command -v git 2>&1 > /dev/null; then
            git clone https://github.com/vkwhm/dotfiles.git ${cfg.dotDir}
            _WHMCONFIG_INSTALLED=true;
          elif command wget 2>&1 > /dev/null; then
            zip_file="$(mktemp)";
            wget https://github.com/vkwhm/dotfiles/archive/refs/heads/main.zip -O "$zip_file";
            unzip "$zip_file" -d "${cfg.dotDir}";
            rm "$zip_file";
            _WHMCONFIG_INSTALLED=true;
          fi
        fi
        export _WHMCONFIG_INSTALLED
      '';

      whm-2-link = (mkIf cfg.link.nvim ''
        if [[ $_WHMCONFIG_INSTALLED == "true" ]]; then
          echo "Linking WHM Neovim Configurations...";
          ln -s "${cfg.dotDir}/editor/nvim" "${homeDir}/.config/nvim";
        else
          echo "Failed to install WHM shell. Please install it manually.";
        fi;
      '');

      whm-3-cleanup = ''
        unset _WHMCONFIG_INSTALLED
      '';
    };
  };
}
