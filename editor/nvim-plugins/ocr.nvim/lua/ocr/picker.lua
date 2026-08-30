local config = require('ocr.config')
local parser = require('ocr.parser')
local diagnostics = require('ocr.diagnostics')
local utils = require('ocr.utils')

local M = {}

---Trim leading and trailing whitespace
---@param s string
---@return string
local function trim(s)
	return (s:gsub('^%s*(.-)%s*$', '%1'))
end

---Parse `ocr session list` command output into structured items
---@param output string
---@return table[]
function M.parse_session_list(output)
	if not output or output == '' then
		return {}
	end

	local sessions = {}

	for line in output:gmatch('[^\r\n]+') do
		local trimmed = trim(line)
		-- Skip header line
		if not trimmed:match('^SESSION%s+ID') then
			local id = trimmed:match(utils.UUID_REGEX)
			if id then
				local rest = trimmed:sub(#id + 1)
				local parts = {}
				for item in rest:gmatch('%S+') do
					table.insert(parts, item)
				end

				local started = ''
				local comments = '0'
				local status = 'unknown'

				if #parts >= 2 and parts[#parts - 1]:match('%d%d%d%d%-%d%d%-%d%d') then
					started = parts[#parts - 1] .. ' ' .. parts[#parts]
					if #parts >= 3 then
						status = parts[#parts - 2]
					end
					if #parts >= 4 then
						comments = parts[#parts - 3]
					end
				elseif #parts >= 1 then
					started = parts[#parts]
				end

				table.insert(sessions, {
					['id'] = id,
					['started'] = started,
					['comments'] = comments,
					['status'] = status,
					['display'] = string.format('%s  │ %-19s │ %2s comments │ [%s]', id, started, comments, status),
				})
			end
		end
	end

	return sessions
end

---Load comments for a specific session ID and apply diagnostics
---@param session_id string
function M.load_session(session_id)
	if not session_id or not session_id:match(utils.UUID_EXACT_REGEX) then
		vim.notify('Invalid session id: ' .. tostring(session_id), vim.log.levels.ERROR)
		return
	end

	local opts = config.options
	local comments_json = vim.fn.system(opts['command'] .. ' session comments --json ' .. vim.fn.shellescape(session_id))

	if vim.v.shell_error ~= 0 then
		vim.notify('Failed to fetch session comments (exit code ' .. vim.v.shell_error .. ')', vim.log.levels.ERROR)
		diagnostics.apply({})
		return
	end

	local diagnostics_by_file = parser.parse(comments_json)
	if not diagnostics_by_file or not next(diagnostics_by_file) then
		vim.notify('No comments found for session ' .. session_id, vim.log.levels.WARN)
		diagnostics.apply({})
		return
	end

	diagnostics.apply(diagnostics_by_file)
	vim.notify('Loaded OCR session: ' .. session_id, vim.log.levels.INFO)
end

---Open interactive session picker using fzf-lua or vim.ui.select fallback
function M.open()
	local opts = config.options
	local raw_output = vim.fn.system(opts['command'] .. ' session list')

	if vim.v.shell_error ~= 0 then
		vim.notify('Failed to list OCR sessions (exit code ' .. vim.v.shell_error .. ')', vim.log.levels.ERROR)
		return
	end

	local sessions = M.parse_session_list(raw_output)

	if #sessions == 0 then
		vim.notify('No saved OCR review sessions found', vim.log.levels.INFO)
		return
	end

	local fzf_ok, fzf = pcall(require, 'fzf-lua')
	if fzf_ok then
		local entries = {}
		for _, s in ipairs(sessions) do
			table.insert(entries, s['display'])
		end

		local exec_ok, exec_err = pcall(fzf.fzf_exec, entries, {
			['prompt'] = 'OCR Review Sessions> ',
			['preview'] = opts['command'] .. ' session show {1}',
			['actions'] = {
				['default'] = function(selected)
					if not selected or #selected == 0 then
						return
					end
					local sid = selected[1]:match(utils.UUID_REGEX)
					if sid then
						M.load_session(sid)
					end
				end,
			},
		})

		if not exec_ok then
			vim.notify('fzf-lua failed, falling back to vim.ui.select: ' .. tostring(exec_err), vim.log.levels.WARN)
			vim.ui.select(sessions, {
				['prompt'] = 'Select OCR Review Session:',
				['format_item'] = function(item)
					return item['display']
				end,
			}, function(choice)
				if choice and choice['id'] then
					M.load_session(choice['id'])
				end
			end)
		end
	else
		-- Fallback to vim.ui.select if fzf-lua is not available
		vim.ui.select(sessions, {
			['prompt'] = 'Select OCR Review Session:',
			['format_item'] = function(item)
				return item['display']
			end,
		}, function(choice)
			if choice and choice['id'] then
				M.load_session(choice['id'])
			end
		end)
	end
end

return M
