local config = require("ocr.config")
local parser = require("ocr.parser")
local diagnostics = require("ocr.diagnostics")
local utils = require("ocr.utils")

local M = {}

---Invoke `ocr review` in a 1/5 horizontal terminal split and close window upon exit
---@param args_str? string
function M.run(args_str)
	local opts = config.options
	local ratio = math.min(math.max(tonumber(opts["height_ratio"]) or 0.2, 0.05), 0.9)
	local height = math.max(3, math.floor(vim.o.lines * ratio))

	vim.cmd("botright " .. height .. "new")

	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_get_current_buf()

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"

	local cmd_args = args_str or ""
	if cmd_args ~= "" then
		cmd_args = " " .. cmd_args
	end

	local full_cmd = opts["command"] .. " review" .. cmd_args
	local stdout_chunks = {}

	local job_id = vim.fn.termopen(full_cmd, {
		["on_stdout"] = function(_, data, _)
			if data then
				for _, line in ipairs(data) do
					if line ~= "" then
						table.insert(stdout_chunks, line)
					end
				end
			end
		end,
		["on_exit"] = function(_, exit_code, _)
			vim.schedule(function()
				if opts["auto_close_terminal"] and vim.api.nvim_win_is_valid(win) then
					pcall(vim.api.nvim_win_close, win, true)
				end

				if exit_code ~= 0 then
					vim.notify("OCR review failed with exit code " .. exit_code, vim.log.levels.ERROR)
					return
				end

				local raw_json = ""
				local session_list = vim.fn.system(opts["command"] .. " session list")
				local session_id = nil
				if type(session_list) == "string" then
					for line in session_list:gmatch("[^\r\n]+") do
						local trimmed = (line:gsub("^%s*(.-)%s*$", "%1"))
						local sid = trimmed:match(utils.UUID_REGEX)
						if sid then
							session_id = sid
							break
						end
					end
				end

				if session_id then
					local comments_json =
						vim.fn.system(opts["command"] .. " session comments --json " .. vim.fn.shellescape(session_id))
					local trimmed_comments = comments_json and vim.trim(comments_json) or ""
					if trimmed_comments ~= "" and trimmed_comments ~= "[]" and trimmed_comments:match("^%s*[%[%{]") then
						raw_json = comments_json
					end
				end

				if raw_json == "" or raw_json == "[]" then
					raw_json = table.concat(stdout_chunks, "\n")
					local json_start = raw_json:find("[%[%{]")
					if json_start then
						raw_json = raw_json:sub(json_start)
					end
				end

				local diagnostics_by_file = parser.parse(raw_json)
				diagnostics.apply(diagnostics_by_file)
			end)
		end,
	})

	if job_id <= 0 then
		if opts["auto_close_terminal"] and vim.api.nvim_win_is_valid(win) then
			pcall(vim.api.nvim_win_close, win, true)
		end
		vim.notify("Failed to start OCR review process", vim.log.levels.ERROR)
		return
	end

	vim.cmd("startinsert")
end

return M
