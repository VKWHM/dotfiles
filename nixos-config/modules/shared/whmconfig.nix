{lib, config, pkgs, ...}:
let
  inherit (lib) mkOption mkEnableOption types mkIf;
  cfg = config.home.whmConfig;
  homeDir = config.home.homeDirectory;
  whmDotDir = "${homeDir}/${cfg.dotDir}";
in {
  options = {
    home.whmConfig = {
      enable = mkEnableOption "WHM Configurations";
      dotDir = mkOption {
        type = types.str;
        default = ".whm_shell";
        description = ''
          Directory for WHM Configurations relative to home directory.
          This is where the WHM shell will be installed.
        '';
      };
      link = {
        nvim = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Link the nvim configuration to the WHM shell.
            This will create a symlink from ${homeDir}/.config/nvim to ${cfg.dotDir}/editor/nvim.
          '';
        };
        vim = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Link the vim configuration to the WHM shell.
            This will create a symlink from ${homeDir}/.vim to ${cfg.dotDir}/editor/vim.
          '';
        };
        tmux = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Link the tmux configuration to the WHM shell.
            This will create a symlink from ${homeDir}/.tmux.conf to ${cfg.dotDir}/terminal/tmux.conf.
          '';
        };
        wezterm = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Link the wezterm configuration to the WHM shell.
            This will create a symlink from ${homeDir}/.config/wezterm to ${cfg.dotDir}/terminal/wezterm.
          '';
        };
      };
      repo = mkOption {
        type = types.str;
        default = "vkwhm/dotfiles";
        description = ''
          The GitHub repository to clone the WHM shell from.
          This is where the WHM shell will be installed from.
          The default is vkwhm/dotfiles.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    home.activation = {
      whm1Install = ''
        _WHMCONFIG_INSTALLED=$(test -d "${whmDotDir}" && echo "true" || echo "false")
        if [[ $_WHMCONFIG_INSTALLED == "false" ]]; then
          ${pkgs.git}/bin/git clone https://github.com/${cfg.repo}.git ${whmDotDir}
          _WHMCONFIG_INSTALLED=true;
        fi
      '';

      whm2Link = let 
        getLink = opts: let enabled = cfg.link."${opts.name}"; in [
          ( { inherit enabled; } // opts )
        ];
        linkList = ([] ++
          (getLink {
            name = "nvim";
            files = [
              {
                src = "${whmDotDir}/editor/nvim";
                dst = "${homeDir}/.config/nvim";
              }
            ];
          }) ++
          (getLink {
            name = "vim";
            files = [
              {
                src = "${whmDotDir}/editor/vimrc";
                dst = "${homeDir}/.vimrc";
              }
            ];
          }) ++
          (getLink {
            name = "tmux";
            files = [
              {
                src = "${whmDotDir}/terminal/tmux.conf";
                dst = "${homeDir}/.tmux.conf";
              }
            ];
          }) ++
          (getLink {
            name = "wezterm";
            files = [
              {
                src = "${whmDotDir}/terminal/wezterm";
                dst = "${homeDir}/.config/wezterm";
              }
              {
                src = "${whmDotDir}/terminal/wezterm/wezterm.lua";
                dst = "${homeDir}/.wezterm.lua";
              }
            ];
          })
        );
    
        in
        (builtins.concatStringsSep "\n" ([
        ''
          if [[ $_WHMCONFIG_INSTALLED == "true" ]]; then
            true;
        '' 
        (builtins.concatStringsSep "\n" (builtins.map (prog: (builtins.concatStringsSep "\n"
          (builtins.map (link:
            let 
              name = builtins.baseNameOf link.dst;
            in if prog.enabled then ''
            if [[ -e "${link.dst}" ]]; then
              if [[ ! -L "${link.dst}" ]]; then
                echo "[!!] ${name} configuration already exists. Create Backup..." >&2;
                extension=".backup-$(date +%Y-%m-%d_%H-%M-%S)";
                mv "${link.dst}" "${link.dst}.$\{extension}";
                echo "[!!] Backup created: ${link.dst}.$\{extension}" >&2;
              elif [[ "$(readlink '${link.dst}')" != "${link.src}" ]]; then
                echo "[!!] Remove link $(stat -c '%N' '${link.dst}')" >&2;
                unlink "${link.dst}";
              fi;
            fi;
            if [[ ! -e "${link.dst}" ]]; then
              echo "[*] Link ${link.src} -> ${link.dst}" >&2;
              ln -s "${link.src}" "${link.dst}";
              echo "[+] ${name} configuration linked." >&2;
            fi
          '' else ''
            if [[ -L "${link.dst}" && $(readlink "${link.dst}") == "${link.src}" ]]; then
              echo "[*] Remove link $(stat -c '%N' '${link.dst}')" >&2;
              unlink "${link.dst}";
            fi;
          '') prog.files))
        ) linkList))
        ''
          else
            echo "[-] Failed to install WHM Configurations. Please install it manually." >&2;
          fi;
        ''
        ]));
    };
  };
}
