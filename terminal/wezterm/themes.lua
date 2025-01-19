local wezterm = require("wezterm")
local utils = require("utils")
local M = {}

function M.apply_to_config(config)
	local cMocha = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
	local cLatte = wezterm.color.get_builtin_schemes()["Catppuccin Latte"]

	cMocha.scrollbar_thumb = "#FFFFFF"
	cLatte.scrollbar_thumb = "#000000"
	config.color_schemes = {
		["Catppuccin Mocha"] = cMocha,
		["Catppuccin Latte"] = cLatte,
	}
	config.color_scheme = utils.scheme_for_appearance(wezterm.gui.get_appearance())
end

return M
