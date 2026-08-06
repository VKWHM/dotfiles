local config = require('ocr.config')
local utils = require('ocr.utils')

local M = {}

local current_ns_name = nil
local ns = nil

M.active_diagnostics = {}

---Get or create the active diagnostic namespace
---@return integer
function M.get_namespace()
	local ns_name = config.options['diagnostic_namespace']
	if not ns or current_ns_name ~= ns_name then
		if ns then
			vim.diagnostic.reset(ns)
		end
		current_ns_name = ns_name
		ns = vim.api.nvim_create_namespace(current_ns_name)
	end
	return ns
end

---Configure diagnostic display formatting for the active namespace
function M.configure_namespace()
	local target_ns = M.get_namespace()
	vim.diagnostic.config({
		['virtual_text'] = {
			['prefix'] = '💡 ',
			['format'] = function(diagnostic)
				local category = diagnostic.code and ('[' .. diagnostic.code .. '] ') or ''
				local first_line = diagnostic.message:match('([^\r\n]+)') or diagnostic.message
				if #first_line > 80 then
					first_line = first_line:sub(1, 77) .. '…'
				end
				return string.format('%s%s', category, first_line)
			end,
		},
		['float'] = {
			['border'] = 'rounded',
			['source'] = 'always',
			['format'] = function(diagnostic)
				return diagnostic.message
			end,
		},
		['signs'] = true,
		['underline'] = true,
	}, target_ns)
end

---Clear OCR Review diagnostics selectively by mode ('all' | 'buffer' | 'function' | 'line')
---@param mode? string
function M.clear(mode)
	if not mode or mode == '' then
		M.open_clear_menu()
		return
	end

	if not vim.tbl_contains({ 'all', 'buffer', 'function', 'line' }, mode) then
		vim.notify('Invalid OCR clear mode: ' .. tostring(mode), vim.log.levels.ERROR)
		return
	end

	local target_ns = M.get_namespace()

	if mode == 'all' then
		vim.diagnostic.reset(target_ns)
		M.active_diagnostics = {}
		vim.notify('OCR Review diagnostics cleared (all)', vim.log.levels.INFO)
		return
	end

	local current_buf = vim.api.nvim_get_current_buf()
	local current_buf_path = vim.api.nvim_buf_get_name(current_buf)
	local cwd = vim.fn.getcwd()

	local current_rel_path = current_buf_path
	if vim.startswith(current_buf_path, cwd) then
		current_rel_path = current_buf_path:sub(#cwd + 2)
	end

	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local count_cleared = 0

	if mode == 'buffer' then
		for path, _ in pairs(M.active_diagnostics) do
			if path == current_rel_path or vim.fn.fnamemodify(path, ':p') == current_buf_path then
				count_cleared = count_cleared + #(M.active_diagnostics[path] or {})
				M.active_diagnostics[path] = nil
			end
		end
		vim.diagnostic.reset(target_ns, current_buf)
		vim.notify('Cleared ' .. count_cleared .. ' OCR comment(s) in current buffer', vim.log.levels.INFO)

	elseif mode == 'function' then
		local sline, eline = utils.get_current_function_range()
		if not sline or not eline then
			vim.notify('No enclosing function found at cursor position', vim.log.levels.WARN)
			return
		end

		for path, diags in pairs(M.active_diagnostics) do
			if path == current_rel_path or vim.fn.fnamemodify(path, ':p') == current_buf_path then
				local remaining = {}
				for _, d in ipairs(diags) do
					local dline = (d.lnum and d.lnum + 1) or 1
					if dline >= sline and dline <= eline then
						count_cleared = count_cleared + 1
					else
						table.insert(remaining, d)
					end
				end
				M.active_diagnostics[path] = remaining
				vim.diagnostic.set(target_ns, current_buf, remaining)
			end
		end
		vim.notify('Cleared ' .. count_cleared .. ' OCR comment(s) in current function', vim.log.levels.INFO)

	elseif mode == 'line' then
		for path, diags in pairs(M.active_diagnostics) do
			if path == current_rel_path or vim.fn.fnamemodify(path, ':p') == current_buf_path then
				local remaining = {}
				for _, d in ipairs(diags) do
					local dline = (d.lnum and d.lnum + 1) or 1
					if dline == cursor_line then
						count_cleared = count_cleared + 1
					else
						table.insert(remaining, d)
					end
				end
				M.active_diagnostics[path] = remaining
				vim.diagnostic.set(target_ns, current_buf, remaining)
			end
		end
		vim.notify('Cleared ' .. count_cleared .. ' OCR comment(s) on current line', vim.log.levels.INFO)
	end
end

---Open interactive menu for clear options
function M.open_clear_menu()
	local options = {
		{ ['id'] = 'all', ['label'] = '1. Clean all comments' },
		{ ['id'] = 'buffer', ['label'] = '2. Clean comments of current buffer' },
		{ ['id'] = 'function', ['label'] = '3. Clean comments of current function' },
		{ ['id'] = 'line', ['label'] = '4. Clean comment of current line' },
	}

	local fzf_ok, fzf = pcall(require, 'fzf-lua')
	if fzf_ok then
		local entries = {}
		for _, opt in ipairs(options) do
			table.insert(entries, opt['label'])
		end

		local exec_ok, exec_err = pcall(fzf.fzf_exec, entries, {
			['prompt'] = 'Clean OCR Comments> ',
			['actions'] = {
				['default'] = function(selected)
					if not selected or #selected == 0 then
						return
					end
					for _, opt in ipairs(options) do
						if selected[1] == opt['label'] then
							M.clear(opt['id'])
							break
						end
					end
				end,
			},
		})

		if not exec_ok then
			vim.notify('fzf-lua failed, falling back to vim.ui.select: ' .. tostring(exec_err), vim.log.levels.WARN)
			vim.ui.select(options, {
				['prompt'] = 'Clean OCR Review Comments:',
				['format_item'] = function(item)
					return item['label']
				end,
			}, function(choice)
				if choice and choice['id'] then
					M.clear(choice['id'])
				end
			end)
		end
	else
		vim.ui.select(options, {
			['prompt'] = 'Clean OCR Review Comments:',
			['format_item'] = function(item)
				return item['label']
			end,
		}, function(choice)
			if choice and choice['id'] then
				M.clear(choice['id'])
			end
		end)
	end
end

---Open diagnostic panel (Trouble qflist or Quickfix window) displaying ONLY ocr_review comments
function M.open_panel()
	local target_ns = M.get_namespace()

	-- Populate quickfix list strictly with ocr_review namespace items across all files
	vim.diagnostic.setqflist({ ['namespace'] = target_ns, ['open'] = false })

	-- Open Trouble on qflist / quickfix mode or fallback to copen
	local trouble_ok, trouble = pcall(require, 'trouble')
	if trouble_ok then
		local opened = false
		local ok1 = pcall(trouble.open, 'qflist')
		if ok1 then
			opened = true
		else
			local ok2 = pcall(trouble.open, 'quickfix')
			if ok2 then
				opened = true
			end
		end
		if opened then
			return
		end
	end

	vim.cmd('copen')
end

---Apply parsed diagnostics to file buffers
---@param diagnostics_by_file table<string, table[]>
function M.apply(diagnostics_by_file)
	M.configure_namespace()
	local target_ns = M.get_namespace()
	vim.diagnostic.reset(target_ns)
	M.active_diagnostics = diagnostics_by_file or {}

	local cwd = vim.fn.getcwd()
	local total_count = 0

	for rel_path, diags in pairs(diagnostics_by_file) do
		local abs_path = rel_path
		if not vim.startswith(rel_path, '/') then
			abs_path = cwd .. '/' .. rel_path
		end

		local bufnr = vim.fn.bufadd(abs_path)
		if bufnr and bufnr ~= 0 then
			vim.fn.bufload(bufnr)
			vim.diagnostic.set(target_ns, bufnr, diags)
			total_count = total_count + #diags
		end
	end

	if total_count > 0 then
		vim.notify('OCR Review complete: ' .. total_count .. ' issue(s) reported', vim.log.levels.INFO)
	else
		vim.notify('OCR Review complete: No issues reported!', vim.log.levels.INFO)
	end

	if config.options['auto_open_panel'] then
		M.open_panel()
	end
end

return M
