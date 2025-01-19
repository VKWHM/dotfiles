local wezterm = require("wezterm")
local themes = require("themes")
local keymaps = require("keymaps")
local plugins = require("plugins")

local config = wezterm.config_builder() or {}

-- Apply configurations
themes.apply_to_config(config)
keymaps.apply_to_config(config)
plugins.apply_to_config(config)

require("events") -- configure events

do
	config.use_dead_keys = false
	config.scrollback_lines = 10000
	config.set_environment_variables = {
		WHM_APPEARANCE = wezterm.gui.get_appearance(),
	}
end

-- Font configuration
do
	config.font = wezterm.font("JetBrainsMono Nerd Font", {
		weight = "DemiBold",
		italic = true,
		-- stretch = 'Expanded',
	})
	config.font_size = 12
	config.line_height = 1.2

	config.enable_scroll_bar = true
end

--Window configuration
do
	-- Maximize window on startup
	-- wezterm.on("gui-startup", function(cmd)
	-- 	local tab, pane, window = mux.spawn_window(cmd or {})
	-- 	window:gui_window():maximize()
	-- end)
	-- Window padding
	config.window_padding = {
		left = 1,
		right = 2,
		top = 1,
		bottom = 1,
	}

	-- Window elements and background
	config.enable_tab_bar = true
	config.window_decorations = "RESIZE"
	if wezterm.gui.get_appearance():find("^Dark") then
		config.window_background_opacity = 0.95
	else
		config.window_background_opacity = 0.85
	end

	config.macos_window_background_blur = 10

	config.adjust_window_size_when_changing_font_size = false
	-- config.hide_tab_bar_if_only_one_tab = true

	config.window_frame = {
		font = wezterm.font({ family = "Noto Sans", weight = "Regular" }),
	}

	config.inactive_pane_hsb = {
		saturation = 0.8,
		brightness = 0.7,
	}

	config.hyperlink_rules = {
		-- Linkify things that look like URLs and the host has a TLD name.
		-- Compiled-in default. Used if you don't specify any hyperlink_rules.
		{
			regex = "\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b",
			format = "$0",
		},

		-- linkify email addresses
		-- Compiled-in default. Used if you don't specify any hyperlink_rules.
		{
			regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
			format = "mailto:$0",
		},

		-- file:// URI
		-- Compiled-in default. Used if you don't specify any hyperlink_rules.
		{
			regex = [[\bfile://\S*\b]],
			format = "$0",
		},

		-- Linkify things that look like URLs with numeric addresses as hosts.
		-- E.g. http://127.0.0.1:8000 for a local development server,
		-- or http://192.168.1.1 for the web interface of many routers.
		{
			regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
			format = "$0",
		},

		-- Make username/project paths clickable. This implies paths like the following are for GitHub.
		-- As long as a full URL hyperlink regex exists above this it should not match a full URL to
		-- GitHub or GitLab / BitBucket (i.e. https://gitlab.com/user/project.git is still a whole clickable URL)
		{
			regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
			format = "https://www.github.com/$1/$3",
		},
	}
end

return config
