{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  programs.yazi = {
    enable = true;

    plugins = {
      inherit (pkgs.yaziPlugins) diff git full-border glow;
      eza-preview = inputs.yazi-plugin-eza-preview;
      hexyl = inputs.yazi-plugin-hexyl;
      bypass = inputs.yazi-plugin-bypass;
      omp = inputs.yazi-plugin-omp;
    };

    keymap = {
      manager.prepend_keymap = [
        {
          on = "<C-d>";
          run = "plugin diff";
          desc = "Diff the selected with the hovered file";
        }
        {
          on = ["L"];
          run = "plugin bypass";
          desc = "Recursively enter child directory, skipping single-subdirectory dirs";
        }
        {
          on = ["H"];
          run = "plugin bypass reverse";
          desc = "Recursively enter parent directory, skipping single-subdirectory dirs";
        }
        {
          on = ["l"];
          run = "plugin bypass smart-enter";
          desc = "Open file or recursively enter child directory";
        }
        {
          on = ["e" "t"];
          run = "plugin eza-preview";
          desc = "Toggle tree/list dir preview";
        }
        {
          on = ["e" "-"];
          run = "plugin eza-preview inc-level";
          desc = "Increment tree level";
        }
        {
          on = ["e" "_"];
          run = "plugin eza-preview dec-level";
          desc = "Decrement tree level";
        }
        {
          on = ["e" "$"];
          run = "plugin eza-preview toggle-follow-symlinks";
          desc = "Toggle tree follow symlinks";
        }
        {
          on = ["e" "*"];
          run = "plugin eza-preview toggle-hidden";
          desc = "Toggle hidden files";
        }
        {
          on = ["e" "g" "i"];
          run = "plugin eza-preview toggle-git-ignore";
          desc = "Toggle .gitignore files";
        }
        {
          on = ["e" "g" "s"];
          run = "plugin eza-preview toggle-git-status";
          desc = "Toggle showing git status";
        }
      ];
    };

    initLua = ''
      require("full-border"):setup {
        type = ui.Border.ROUNDED,
      }

      require("git"):setup()

      require("eza-preview"):setup({
        default_tree = true,
        level = 3,
        icons = true,
        follow_symlinks = true,
        all = true,
        git_ignore = true,
        git_status = false,
      })

      require("omp"):setup()
    '';

    settings = {
      plugin = {
        prepend_fetchers = [
          {
            id = "git";
            url = "*";
            run = "git";
          }
          {
            id = "git";
            url = "*/";
            run = "git";
          }
        ];
        prepend_previewers = [
          {
            url = "*/";
            run = "eza-preview";
          }
          {
            name = "*.md";
            run = "glow";
          }
        ];
        append_previewers = [
          {
            name = "*";
            run = "hexyl";
          }
        ];
      };
    };
  };

  home.packages = with pkgs; [
    hexyl
    glow
    oh-my-posh
  ];
}