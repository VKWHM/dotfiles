local group = vim.api.nvim_create_augroup("whm_rust_indent", { clear = true })

local function set_rust_indent(event)
	local buf = event.buf
	if vim.bo[buf].filetype ~= "rust" then
		return
	end

	vim.bo[buf].tabstop = 4
	vim.bo[buf].shiftwidth = 4
	vim.bo[buf].softtabstop = 4
	vim.bo[buf].expandtab = true
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	group = group,
	pattern = "*.rs",
	callback = set_rust_indent,
})
