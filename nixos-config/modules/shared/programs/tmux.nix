{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  searchKey = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "The name of the search";
      };
      key = mkOption {
        type = types.str;
        description = "The keybinding to trigger search action";
      };
      regex = mkOption {
        type = types.str;
        description = "The regex to search";
      };
      onceKey = mkOption {
        type = types.str;
        default = "";
        description = "The keybinding to trigger search action only once (unbind after use)";
      };
      pcre = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to use pcre regex";
      };
      fzf = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to use fzf to select from multiple matches";
      };
      fzfPreview = mkOption {
        type = types.str;
        default = "";
        description = "A command to generate preview in fzf, {1} is the matched text, {2} is the full line";
      };
      preProcessor = mkOption {
        type = types.str;
        default = "";
        description = "A command to preprocess the captured pane content before searching";
      };
      postProcessor = mkOption {
        type = types.str;
        default = "";
        description = "A command to postprocess the matched result before sending to tmux prompt";
      };
    };
  };
in {
  options = {
    programs.tmux.searchKeys = mkOption {
      type = types.listOf searchKey;
      default = [
        {
          name = "Number";
          key = "C-d";
          regex = "[[:digit:]]+";
        }
      ];
      description = ''
        A list of search keys to bind to tmux.
        Each entry should contain a name, keybinding, and regex.
      '';
    };
  };
  config = mkIf (config.home.whmConfig.link.tmux) {
    programs.tmux = {
      enable = true;
      historyLimit = 50000;
      escapeTime = 0;
      keyMode = "vi";
      mouse = true;
      prefix = "C-s";
      terminal = "xterm-256color";
      baseIndex = 1;
      focusEvents = true;
      aggressiveResize = true;
      shell = "${pkgs.zsh}/bin/zsh";
      tmuxinator.enable = true;
      plugins = with pkgs; [
        (mkIf config.programs.fzf.enable (tmuxPlugins.mkTmuxPlugin {
          pluginName = "tmux-fzf";
          rtpFilePath = "main.tmux";
          version = "unstable-2023-10-24";
          src = fetchFromGitHub {
            owner = "sainnhe";
            repo = "tmux-fzf";
            rev = "d62b6865c0e7c956ad1f0396823a6f34cf7452a7";
            hash = "sha256-hVkSQYvBXrkXbKc98V9hwwvFp6z7/mX1K4N3N9j4NN4=";
          };
          postInstall = ''
            find $target -type f -print0 | xargs -0 sed -i -e 's|fzf |${pkgs.fzf}/bin/fzf |g'
            find $target -type f -print0 | xargs -0 sed -i -e 's|sed |${pkgs.gnused}/bin/sed |g'
            find $target -type f -print0 | xargs -0 sed -i -e 's|tput |${pkgs.ncurses}/bin/tput |g'
            find $target -type f -name '.envs' | xargs sed -i -E 's/^TMUX_FZF_BIN.*$/TMUX_FZF_BIN="\$(command -v fzf-tmux)"/'
          '';
          meta = {
            homepage = "https://github.com/sainnhe/tmux-fzf";
            description = "Use fzf to manage your tmux work environment! ";
            longDescription = ''
              Features:
              * Manage sessions (attach, detach*, rename, kill*).
              * Manage windows (switch, link, move, swap, rename, kill*).
              * Manage panes (switch, break, join*, swap, layout, kill*, resize).
              * Multiple selection (support for actions marked by *).
              * Search commands and append to command prompt.
              * Search key bindings and execute.
              * User menu.
              * Popup window support.
            '';
            license = lib.licenses.mit;
            platforms = lib.platforms.unix;
            maintainers = with lib.maintainers; [kyleondy];
          };
        }))
        tmuxPlugins.pain-control
        (lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin == false) tmuxPlugins.sensible)
        # TODO: config tmux yank plugin
        # tmuxPlugins.yank
        # {
        #   plugin = tmuxPlugins.open;
        #   extraConfig = ''
        #     set -g @open 'x'
        #     set -g @open-editor 'f'
        #     set -g @open-S 'https://www.google.com/search?q='
        #   '';
        # }
        {
          plugin = tmuxPlugins.prefix-highlight;
          extraConfig = ''
            set -g @prefix_highlight_fg "#{@thm_bg}"
            set -g @prefix_highlight_bg "#{@thm_red}"
            set -g @prefix_highlight_empty_attr 'bg=#{@thm_red},fg=#{@thm_bg}' # default is 'fg=default,bg=default'
            set -g @prefix_highlight_prefix_prompt ' '
            set -g @prefix_highlight_empty_prompt '   '
          '';
        }
        {
          plugin = tmuxPlugins.vim-tmux-navigator;
          extraConfig = ''
            set -g @vim_navigator_mapping_left "C-Left C-h"  # use C-h and C-Left
            set -g @vim_navigator_mapping_right "C-Right C-l"
            set -g @vim_navigator_mapping_up "C-k"
            set -g @vim_navigator_mapping_down "C-j"
            set -g @vim_navigator_mapping_prev ""  # removes the C-\ binding
          '';
        }
      ];
      extraConfig = builtins.concatStringsSep "\n" (builtins.map (binding: let
        escapeTmux = text: builtins.replaceStrings ["\"" "\\"] ["\\\"" "\\\\"] text;
        escapeRegex = regex:
          escapeTmux ''              $(cat <<END
            ${regex}
            END
            )'';
        preProcessor =
          if binding.preProcessor != ""
          then "${escapeTmux binding.preProcessor} |"
          else "";
        grepFlags =
          if binding.pcre
          then "-P"
          else "-E";
        ripgrepFlags =
          [
            "--color=never"
            "--no-filename"
            "--no-line-number"
            "--only-matching"
          ]
          ++ (
            if binding.pcre
            then ["--pcre2"]
            else []
          );
        coreutils = "${pkgs.coreutils}/bin";
        withFzf = key: let
          fzfFlags = [
            "--delimiter='\\\\t'"
            "--with-nth=1"
            "--ansi"
            "--multi"
            "--layout=default"
            "--tmux center,30%,50%"
            "--preview-window=top:25%,"
            "--preview='${binding.fzfPreview}'"
          ];
        in ''
          # ${binding.name} FZF search (prefix + ${key})
          bind-key ${key} run-shell "\
            if ${pkgs.tmux}/bin/tmux capture-pane -p  | ${pkgs.gnugrep}/bin/grep -q ${grepFlags} ${escapeRegex binding.regex}; then \
              ${pkgs.tmux}/bin/tmux capture-pane -p  -S - | \
              ${preProcessor} ${pkgs.ripgrep}/bin/rg ${lib.strings.escapeShellArgs (ripgrepFlags ++ ["--json"])} ${escapeRegex binding.regex} | \
              ${pkgs.jq}/bin/jq -r 'select(.type==\"match\") | \"\\(.data.submatches[0].match.text)\\t\\(.data.lines.text)\"' | ${pkgs.gawk}/bin/awk '!seen[$1]++' | \
              ${pkgs.fzf}/bin/fzf ${lib.concatStringsSep " " fzfFlags} >/tmp/tspipe3-${binding.name} && ( cat </tmp/tspipe3-${binding.name} | ${coreutils}/cut -f1 |${coreutils}/tr -d '\\n' | \
              ${coreutils}/tee >(${pkgs.tmux}/bin/tmux load-buffer -) >(${pkgs.tmux}/bin/tmux display-message  \"Copied $(cat)\") >/dev/null ) || true;
              unlink /tmp/tspipe3-${binding.name}; \
            else \
              ${pkgs.tmux}/bin/tmux display-message  'No ${lib.strings.toLower binding.name} found!'; \
            fi"
        '';
        withoutFzf = key: ''
          # ${binding.name} search (prefix + ${key})
          bind-key ${key} run-shell "\
            if ${pkgs.tmux}/bin/tmux capture-pane -p  | ${pkgs.gnugrep}/bin/grep -q ${grepFlags} ${escapeRegex binding.regex}; then \
              ${pkgs.tmux}/bin/tmux capture-pane -p  -S - | \
              ${preProcessor} ${pkgs.ripgrep}/bin/rg ${lib.strings.escapeShellArgs (ripgrepFlags ++ ["--max-count=1"])} ${escapeRegex binding.regex} | \
              ${pkgs.coreutils}/bin/tee >(${pkgs.tmux}/bin/tmux load-buffer -) >(${pkgs.tmux}/bin/tmux display-message  \"Copied $(cat)\") >/dev/null; \
            else \
              ${pkgs.tmux}/bin/tmux display-message  'No ${lib.strings.toLower binding.name} found!'; \
            fi"
        '';
      in
        if binding.pcre || binding.fzf
        then
          if binding.fzf
          then
            (
              if binding.onceKey != ""
              then ''
                ${withFzf binding.key}
                ${withoutFzf binding.onceKey}
              ''
              else withFzf binding.key
            )
          else withoutFzf binding.key
        else ''
          # ${binding.name} search (prefix + ${binding.key})
          bind-key ${binding.key} run-shell "\
            if ${pkgs.tmux}/bin/tmux capture-pane -p  | ${pkgs.gnugrep}/bin/grep -q ${grepFlags} ${escapeRegex binding.regex}; then \
              ${pkgs.tmux}/bin/tmux copy-mode && ${pkgs.tmux}/bin/tmux send-keys -X search-backward ${escapeRegex binding.regex}
            else \
              ${pkgs.tmux}/bin/tmux display-message  'No ${lib.strings.toLower binding.name} found!'; \
            fi"
        '')
      config.programs.tmux.searchKeys);
    };
    utils.theme.autoconfig.no-init = {
      light = ''
        if _tmux_env=$(tmux show-environment 2>/dev/null); then
          if ! echo $_tmux_env | grep -q "WHM_APPEARANCE=Light"; then
            tmux set-environment WHM_APPEARANCE Light
            tmux source-file ~/.tmux.conf ~/.config/tmux/tmux.conf
          fi
        fi
      '';
      dark = ''
        if _tmux_env=$(tmux show-environment 2>/dev/null); then
          if ! echo $_tmux_env | grep -q "WHM_APPEARANCE=Dark"; then
            tmux set-environment WHM_APPEARANCE Dark
            tmux source-file ~/.tmux.conf ~/.config/tmux/tmux.conf
          fi
        fi
      '';
    };
  };
}
