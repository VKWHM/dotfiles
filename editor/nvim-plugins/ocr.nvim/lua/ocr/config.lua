local M = {}

M.defaults = {
	['height_ratio'] = 0.2,
	['command'] = 'ocr',
	['auto_open_panel'] = true,
	['auto_close_terminal'] = true,
	['diagnostic_namespace'] = 'ocr_review',
}

M.options = vim.deepcopy(M.defaults)

---Setup ocr.nvim configuration options with input validation
---@param opts? table
---@return table
function M.setup(opts)
	if opts ~= nil then
		if type(opts) ~= 'table' then
			vim.notify('ocr.nvim setup options must be a table', vim.log.levels.ERROR)
			return M.options
		end
		M.options = vim.tbl_deep_extend('force', M.defaults, opts)
	else
		M.options = vim.deepcopy(M.defaults)
	end
	return M.options
end

return M
