{lib, pkgs, config, ...}:
let
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
    };
  };
in
{
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
  config = (mkIf (config.home.whmConfig.link.tmux) {
    programs.tmux = {
      enable = true;
      historyLimit = 50000;
      keyMode = "vi";
      mouse = true;
      prefix = "C-s";
      terminal = "xterm-256color";
      baseIndex = 1;
      focusEvents = true;
      aggressiveResize = true;
      shell = "${pkgs.zsh}/bin/zsh";
      # TODO: Enable tmuxinator
      # tmuxinator = true;
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
            maintainers = with lib.maintainers; [ kyleondy ];
          };
        }))
        tmuxPlugins.pain-control
        tmuxPlugins.sensible
        # TODO: config tmux yank plugin
        # tmuxPlugins.yank
        {
          plugin = tmuxPlugins.open;
          extraConfig = ''
            set -g @open 'x'
            set -g @open-editor 'f'
            set -g @open-S 'https://www.google.com/search?q='
          '';
        }
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
      extraConfig = (builtins.concatStringsSep "\n" (builtins.map (binding: ''
        # ${binding.name} search (prefix + ${binding.key})
        bind-key ${binding.key} run-shell "\
          pane_id=$(tmux display-message -p '#{pane_id}'); \
          if tmux capture-pane -p -t \"$pane_id\" | grep -qE '${binding.regex}'; then \
            tmux copy-mode -t \"$pane_id\" && \
            tmux send-keys -t \"$pane_id\" -X search-backward '${binding.regex}'; \
          else \
            tmux display-message -t \"$pane_id\" 'No ${lib.strings.toLower binding.name} found!'; \
          fi"
      '') config.programs.tmux.searchKeys));
    };
  });
}
