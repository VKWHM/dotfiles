-- Shortcuts
P = function(tbl)
	print(vim.inspect(tbl))
end

-- Keymaps
local map = vim.keymap.set

map("n", "<leader>vv", "<cmd>PlenaryBustedFile %<CR>", { desc = "Run all tests in file" })

-- Autocmds

local PluginDevelopemnt = vim.api.nvim_create_augroup("PluginDevelopemnt", {
	clear = true,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = PluginDevelopemnt,
	pattern = "*.nvim/*",
	callback = function(ev)
		local plugin_name = (ev.match or ""):match("^/.*/(.-)%.nvim")
		package.loaded[plugin_name] = nil
		vim.notify(("%s.nvim package reloaded!"):format(plugin_name), vim.log.levels.INFO)
	end,
})
