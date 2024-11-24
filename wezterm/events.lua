local wezterm = require("wezterm")
local utils = require("utils")

-- Maximize window on startup
wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

wezterm.on("toggle-pane-hsb", function(window, _)
	local overrides = window:get_config_overrides() or {}
	overrides.window_background_opacity = nil
	local hsb = overrides.inactive_pane_hsb or {}
	hsb.brightness = hsb.brightness == 0.7 and 1 or 0.7
	hsb.saturation = hsb.saturation == 0.8 and 1 or 0.8
	overrides.inactive_pane_hsb = hsb
	window:set_config_overrides(overrides)
end)

wezterm.on("update-right-status", function(window)
	local appearance = wezterm.gui.get_appearance()
	local overrides = window:get_config_overrides() or {}
	local color_scheme = utils.scheme_for_appearance(appearance)
	if overrides.color_scheme ~= appearance then
		overrides.color_scheme = color_scheme
		window:set_config_overrides(overrides)
	end
end)

local function get_segments(window)
	local bat = ""
	for _, b in ipairs(wezterm.battery_info()) do
		bat = string.format("%.0f%%", b.state_of_charge * 100)
	end
	return {
		window:active_workspace(),
		wezterm.strftime("%a %b %-d %H:%M"),
		wezterm.hostname(),
		bat,
	}
end

wezterm.on("update-status", function(window)
	local appearance = wezterm.gui.get_appearance()
	local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
	local segments = get_segments(window)

	local color_scheme = window:effective_config().resolved_palette
	local bg = wezterm.color.parse(color_scheme.background)
	local fg = color_scheme.foreground

	local gradient_to, gradient_from = bg, nil
	if appearance:find("Dark") then
		gradient_from = gradient_to:lighten(0.3)
	else
		gradient_from = gradient_to:darken(0.3)
	end

	local gradient = wezterm.color.gradient(
		{
			orientation = "Horizontal",
			colors = { gradient_from, gradient_to },
		},
		#segments -- only gives us as many colours as we have segments.
	)

	local elements = {}
	for i, seg in ipairs(segments) do
		local is_first = i == 1
		if is_first then
			table.insert(elements, { Background = { Color = bg } })
		end
		table.insert(elements, { Foreground = { Color = gradient[i] } })
		table.insert(elements, { Text = SOLID_LEFT_ARROW })

		table.insert(elements, { Foreground = { Color = fg } })
		table.insert(elements, { Background = { Color = gradient[i] } })
		table.insert(elements, { Text = " " .. seg .. " " })
	end

	window:set_right_status(wezterm.format(elements))
end)
