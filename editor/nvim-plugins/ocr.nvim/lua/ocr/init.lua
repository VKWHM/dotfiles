local config = require('ocr.config')
local parser = require('ocr.parser')
local diagnostics = require('ocr.diagnostics')
local runner = require('ocr.runner')
local picker = require('ocr.picker')
local copier = require('ocr.copier')

---@class OCRModule
local M = {}

M.config = config.options
M.parse_comments = parser.parse

---Configure ocr.nvim options
---@param opts? table
function M.setup(opts)
	config.setup(opts)
	M.config = config.options
	diagnostics.get_namespace()
end

---Clear OCR Review diagnostics selectively ('all' | 'buffer' | 'function' | 'line')
---@param mode? string
function M.clear(mode)
	diagnostics.clear(mode)
end

---Invoke `ocr review` in a 1/5 horizontal terminal split
---@param args_str? string
function M.review(args_str)
	runner.run(args_str)
end

---Open interactive OCR session picker (fzf-lua or vim.ui.select)
function M.pick_sessions()
	picker.open()
end

---Copy review comments in structured format ('all' | 'buffer' | 'function' | 'line')
---@param mode? string
function M.copy(mode)
	if not mode or mode == '' then
		copier.open_copy_menu()
	else
		copier.copy(mode)
	end
end

return M
