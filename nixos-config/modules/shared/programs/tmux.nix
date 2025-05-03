{lib, pkgs, config, ...}:
{
  config = (lib.mkMerge [
    (lib.mkIf (config.whmConfig.link.tmux) {
      home.packages = [
        pkgs.tmux
      ];
    })
    (lib.mkIf (!config.whmConfig.link.tmux) {
        programs.tmux = {
          enable = true;
          hitoryLimit = 50000;
          keyMode = "vi";
          mouse = true;
          prefix = "C-s";
          escapeTime = 1500;
          terminal = "xterm-256color";
          baseIndex = 1;
          focusEvents = true;
          aggrassiveResize = true;
          # TODO: Enable tmuxinator
          # tmuxinator = true;
          plugins = with pkgs; [
            tmuxPlugins.pain-control
            tmuxPlugins.sensible
            tmuxPlugins.copycat
            # TODO: config tmux yank plugin
            # tmuxPlugins.yank
            {
              plugin = tmuxPlugins.open;
              extraConfig = ''
                set -g @open 'x'
                set -g @open-editor 'f'
              '';
            }
            {
              plugin = tmuxPlugins.tmux-fzf;
              extraConfig = ''
                TMUX_FZF_LAUNCH_KEY="C-f"
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
          extraConfig = ''
            set -g display-time 2000
            set -g status-interval 3
            set-option -sa terminal-overrides ",xterm-256color:Tc"
            set-option -g focus-events on
            setw -g pane-base-index 1
            set -g status-keys emacs
            bind-key -T copy-mode-vi v send-keys -X begin-selection
            bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
            set-option -g @thm_bg "#1e1e2e"
            set-option -g @thm_fg "#cdd6f4"
            set-option -g @thm_cyan "#89dceb"
            set-option -g @thm_black "#181825"
            set-option -g @thm_gray "#313244"
            set-option -g @thm_magenta "#cba6f7"
            set-option -g @thm_pink "#f5c2e7"
            set-option -g @thm_red "#f38ba8"
            set-option -g @thm_green "#a6e3a1"
            set-option -g @thm_yellow "#f9e2af"
            set-option -g @thm_blue "#89b4fa"
            set-option -g @thm_orange "#fab387"
            set-option -g status "on"
            set-option -g status-style "bg=default,fg=#{@thm_fg}"
            set-window-option -g window-status-style "bg=#{@thm_yellow},fg=#{@thm_bg}"
            set-window-option -g window-status-activity-style "bg=#{@thm_bg},fg=#{@thm_gray}"
            set-window-option -g window-status-current-style "bg=#{@thm_red},fg=#{@thm_bg}"
            set-option -g pane-active-border-style "fg=#{@thm_fg}"
            set-option -g pane-border-style "fg=#{@thm_bg}"
            set-option -g message-style "bg=#{@thm_gray},fg=#{@thm_fg}"
            set-option -g message-command-style "bg=#{@thm_gray},fg=#{@thm_fg}"
            set-window-option -g window-status-bell-style "bg=#{@thm_red},fg=#{@thm_bg}"
            set-option -g status-justify "left"
            set-option -g status-left-style none
            set-option -g status-left-length "80"
            set-option -g status-right-style none
            set-option -g status-right-length "80"
            set-window-option -g window-status-separator ""
            set-option -g status-left "#{prefix_highlight}#[bg=#{@thm_red},fg=#{@thm_bg}] #S #[bg=#{@thm_bg},fg=#{@thm_red},nobold,noitalics,nounderscore]"
            set-option -g status-right "#[bg=default,fg=#{@thm_gray},nobold,nounderscore,noitalics]#[bg=#{@thm_gray},fg=#{@thm_cyan}] %Y-%m-%d  %H:%M #[bg=#{@thm_gray},fg=#{@thm_blue},nobold,noitalics,nounderscore]#[bg=#{@thm_blue},fg=#{@thm_bg}] #h "
            set-window-option -g window-status-current-format "#[bg=#{@thm_yellow},fg=#{@thm_bg},nobold,noitalics,nounderscore]#[bg=#{@thm_yellow},fg=#{@thm_bg}] #I #[bg=#{@thm_yellow},fg=#{@thm_bg},bold] #W#{?window_zoomed_flag,*Z,} #[bg=#{@thm_bg},fg=#{@thm_yellow},nobold,noitalics,nounderscore]"
            set-window-option -g window-status-format "#[bg=#{@thm_gray},fg=#{@thm_bg},noitalics]#[bg=#{@thm_gray},fg=#{@thm_fg}] #I #[bg=#{@thm_gray},fg=#{@thm_fg}] #W #[bg=#{@thm_bg},fg=#{@thm_gray},noitalics]"
          '';
        };
      })
    ]
  );
}
