local diagnostics_mod = require('ocr.diagnostics')
local utils = require('ocr.utils')

local M = {}

---Format a list of diagnostic items into a structured Markdown string
---@param items table[]
---@return string
function M.format_structured_comments(items)
	if not items or #items == 0 then
		return ''
	end

	local cwd = vim.fn.getcwd()
	local lines = { '# OCR Review Comments', '' }

	for _, item in ipairs(items) do
		local rel_path = item.rel_path
		if not rel_path and item.bufnr then
			local bpath = vim.api.nvim_buf_get_name(item.bufnr)
			if vim.startswith(bpath, cwd) then
				rel_path = bpath:sub(#cwd + 2)
			else
				rel_path = bpath
			end
		end
		rel_path = rel_path or item.abs_path or 'unknown'
		local line_num = (item.lnum and item.lnum + 1) or item.line_num or 1
		local category = item.code or 'review'

		table.insert(lines, string.format('### [%s] `%s:%d`', category, rel_path, line_num))
		table.insert(lines, item.message or '')
		table.insert(lines, '')
	end

	return table.concat(lines, '\n')
end

---Copy comments to system clipboard based on mode ('all' | 'buffer' | 'function' | 'line')
---@param mode string
function M.copy(mode)
	mode = mode or 'all'
	if not vim.tbl_contains({ 'all', 'buffer', 'function', 'line' }, mode) then
		vim.notify('Invalid OCR copy mode: ' .. tostring(mode), vim.log.levels.ERROR)
		return
	end

	local active = diagnostics_mod.active_diagnostics or {}
	local target_items = {}

	local current_buf = vim.api.nvim_get_current_buf()
	local current_buf_path = vim.api.nvim_buf_get_name(current_buf)
	local cwd = vim.fn.getcwd()

	local current_rel_path = current_buf_path
	if vim.startswith(current_buf_path, cwd) then
		current_rel_path = current_buf_path:sub(#cwd + 2)
	end

	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

	if mode == 'all' then
		for _, diags in pairs(active) do
			for _, d in ipairs(diags) do
				table.insert(target_items, d)
			end
		end

	elseif mode == 'buffer' then
		for path, diags in pairs(active) do
			if path == current_rel_path or vim.fn.fnamemodify(path, ':p') == current_buf_path then
				for _, d in ipairs(diags) do
					table.insert(target_items, d)
				end
			end
		end

	elseif mode == 'function' then
		local sline, eline = utils.get_current_function_range()
		if not sline or not eline then
			vim.notify('No enclosing function found at cursor position', vim.log.levels.WARN)
			return
		end

		for path, diags in pairs(active) do
			if path == current_rel_path or vim.fn.fnamemodify(path, ':p') == current_buf_path then
				for _, d in ipairs(diags) do
					local dline = (d.lnum and d.lnum + 1) or 1
					if dline >= sline and dline <= eline then
						table.insert(target_items, d)
					end
				end
			end
		end

	elseif mode == 'line' then
		for path, diags in pairs(active) do
			if path == current_rel_path or vim.fn.fnamemodify(path, ':p') == current_buf_path then
				for _, d in ipairs(diags) do
					local dline = (d.lnum and d.lnum + 1) or 1
					if dline == cursor_line then
						table.insert(target_items, d)
					end
				end
			end
		end
	end

	if #target_items == 0 then
		vim.notify('No OCR review comments matched for copy mode: ' .. mode, vim.log.levels.WARN)
		return
	end

	local formatted = M.format_structured_comments(target_items)
	vim.fn.setreg('+', formatted)
	vim.fn.setreg('"', formatted)

	vim.notify('Copied ' .. #target_items .. ' OCR review comment(s) to clipboard (' .. mode .. ')', vim.log.levels.INFO)
end

---Open interactive menu for copy options if no argument specified
function M.open_copy_menu()
	local options = {
		{ ['id'] = 'all', ['label'] = '1. Copy all review comments' },
		{ ['id'] = 'buffer', ['label'] = '2. Copy all review comments inside current buffer' },
		{ ['id'] = 'function', ['label'] = '3. Copy all review comments of current function' },
		{ ['id'] = 'line', ['label'] = '4. Copy review comment of current line' },
	}

	local fzf_ok, fzf = pcall(require, 'fzf-lua')
	if fzf_ok then
		local entries = {}
		for _, opt in ipairs(options) do
			table.insert(entries, opt['label'])
		end

		local exec_ok, exec_err = pcall(fzf.fzf_exec, entries, {
			['prompt'] = 'Copy OCR Comments> ',
			['actions'] = {
				['default'] = function(selected)
					if not selected or #selected == 0 then
						return
					end
					for _, opt in ipairs(options) do
						if selected[1] == opt['label'] then
							M.copy(opt['id'])
							break
						end
					end
				end,
			},
		})

		if not exec_ok then
			vim.notify('fzf-lua failed, falling back to vim.ui.select: ' .. tostring(exec_err), vim.log.levels.WARN)
			vim.ui.select(options, {
				['prompt'] = 'Copy OCR Review Comments:',
				['format_item'] = function(item)
					return item['label']
				end,
			}, function(choice)
				if choice and choice['id'] then
					M.copy(choice['id'])
				end
			end)
		end
	else
		vim.ui.select(options, {
			['prompt'] = 'Copy OCR Review Comments:',
			['format_item'] = function(item)
				return item['label']
			end,
		}, function(choice)
			if choice and choice['id'] then
				M.copy(choice['id'])
			end
		end)
	end
end

return M
