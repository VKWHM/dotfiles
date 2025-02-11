local wezterm = require("wezterm")
local utils = require("utils")
local M = {}

local act = wezterm.action

local function bind(key, mods, action)
	return {
		key = key,
		mods = mods,
		action = action,
	}
end

local function bind_leader(key, action)
	return bind(key, "LEADER", action)
end

local function make_mouse_binding(dir, streak, button, mods, action)
	return {
		event = { [dir] = { streak = streak, button = button } },
		mods = mods,
		action = action,
	}
end

local function bind_sleader(key, action)
	return bind(key, "SHIFT|LEADER", action)
end

local function move_pane(key, direction)
	return bind(key, "LEADER", act.ActivatePaneDirection(direction))
end

local function resize_pane(key, direction)
	return {
		key = key,
		action = act.AdjustPaneSize({ direction, 1 }),
	}
end

function M.apply_to_config(config)
	config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
	config.keys = {
		-- Open Configuration File
		{
			key = ",",
			mods = "SUPER",
			action = act.SpawnCommandInNewTab({
				cwd = wezterm.home_dir,
				args = { "nvim", wezterm.config_file },
			}),
		},
		-- Make CTRL-A work
		{
			key = "a",
			-- When we're in leader mode _and_ CTRL + A is pressed...
			mods = "LEADER|CTRL",
			-- Actually send CTRL + A key to the terminal
			action = act.SendKey({ key = "a", mods = "CTRL" }),
		},
		bind_leader("c", act.ActivateCopyMode),
		-- Start Panes
		bind_sleader('"', act.SplitVertical({ domain = "CurrentPaneDomain" })),
		bind_sleader("%", act.SplitHorizontal({ domain = "CurrentPaneDomain" })),
		bind_leader(
			"r",
			act.ActivateKeyTable({
				name = "resize_panes",
				one_shot = false,
				timeout_milliseconds = 1500,
			})
		),
		bind_leader("z", act.TogglePaneZoomState),
		bind_leader(
			"q",
			act.PaneSelect({
				alphabet = "abcdefghijklmnopqrstuvwxyz",
			})
		),
		bind_leader(
			"w",
			act.PaneSelect({
				mode = "SwapWithActive",
			})
		),
		bind_sleader("}", act.RotatePanes("Clockwise")),
		bind_sleader("{", act.RotatePanes("CounterClockwise")),
		{
			key = "g",
			mods = "CTRL",
			action = act.EmitEvent("toggle-pane-hsb"),
		},
		bind_leader(
			"x",
			act.CloseCurrentPane({
				confirm = true,
			})
		),
		move_pane("j", "Down"),
		move_pane("k", "Up"),
		move_pane("h", "Left"),
		move_pane("l", "Right"),
		-- End Panes
		-- Start Workspace
		bind_leader("p", utils.choose_project()),
		bind_leader("f", act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" })),
		bind_sleader(
			"&",
			act.PromptInputLine({
				description = "Are you sure you want close this workspace? [Y/n] ",
				action = wezterm.action_callback(function(window, pane, line)
					line = utils.trim(line)
					if line ~= "" and line:lower() == "y" then
						local w = window:active_workspace()
						utils.kill_workspace(w)
					end
				end),
			})
		),
		bind_sleader(
			"$",
			act.PromptInputLine({
				description = "Rename current window",
				action = wezterm.action_callback(function(window, ane, line)
					if utils.trim(line) ~= "" then
						wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
					end
				end),
			})
		),
		-- End Workspace
	}
	if wezterm.target_triple:find("linux") then
		for i = 1, 9 do
			table.insert(config.keys, {
				key = tostring(i),
				mods = "ALT",
				action = wezterm.action({ ActivateTab = i - 1 }),
			})
		end
	end
	config.key_tables = {
		resize_panes = {
			resize_pane("j", "Down"),
			resize_pane("k", "Up"),
			resize_pane("h", "Left"),
			resize_pane("l", "Right"),
		},
	}
	-- Start Mouse Bindings ## https://google.com
	config.mouse_bindings = {
		make_mouse_binding(
			"Up",
			1,
			"Left",
			"NONE",
			wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection")
		),
		make_mouse_binding(
			"Up",
			1,
			"Left",
			"SHIFT",
			wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection")
		),
		make_mouse_binding("Up", 1, "Left", "ALT", wezterm.action.CompleteSelection("ClipboardAndPrimarySelection")),
		make_mouse_binding(
			"Up",
			1,
			"Left",
			"SHIFT|ALT",
			wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection")
		),
		make_mouse_binding("Up", 2, "Left", "NONE", wezterm.action.CompleteSelection("ClipboardAndPrimarySelection")),
		make_mouse_binding("Up", 3, "Left", "NONE", wezterm.action.CompleteSelection("ClipboardAndPrimarySelection")),
	}
	-- End Mouse Bindings
end

return M
