local wezterm = require("wezterm")
local M = {}

local project_directory = "/Volumes/MyData/Projects/"
function M.get_project_dirs()
	local dirs = {}
	for _, dir in ipairs(wezterm.glob(project_directory .. "*")) do
		table.insert(dirs, dir)
	end
	return dirs
end

function M.choose_project()
	local choices = {}
	for _, value in ipairs(M.get_project_dirs()) do
		table.insert(choices, { label = value })
	end
	return wezterm.action.InputSelector({
		title = "Projects",
		choices = choices,
		fuzzy = true,
		action = wezterm.action_callback(function(child_window, child_pane, id, label)
			if not label then
				return
			end
			child_window:perform_action(
				wezterm.action.SwitchToWorkspace({
					name = label:match("[^/]+$"),
					spawn = { cwd = label },
				}),
				child_pane
			)
			wezterm.log_info("you chose " .. label)
		end),
	})
end
function M.trim(str)
	if str then
		return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
	end
	return ""
end
function M.filter(tbl, callback)
	local filter_table = {}
	for i, value in ipairs(tbl) do
		if callback(value, i) then
			table.insert(filter_table, value)
		end
	end
	return filter_table
end

function M.kill_workspace(workspace)
	local success, stdout = wezterm.run_child_process({ "/usr/local/bin/wezterm", "cli", "list", "--format=json" })
	if success then
		local json = wezterm.json_parse(stdout)
		if not json then
			return
		end
		local workspace_panes = M.filter(json, function(p)
			return p.workspace == workspace
		end)

		for _, p in ipairs(workspace_panes) do
			wezterm.run_child_process({
				"/usr/local/bin/wezterm",
				"cli",
				"kill-pane",
				"--pane-id=" .. p.pane_id,
			})
		end
	end
end

function M.scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Catppuccin Mocha"
	else
		return "Catppuccin Latte"
	end
end
return M
