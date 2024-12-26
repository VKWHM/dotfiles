-- bootstrap lazy.nvim, LazyVim and your plugins
local utils = require("utils")

vim.api.nvim_create_autocmd("User", {
	pattern = "LazyDone",
	once = true,
	callback = function()
		vim.opt.background = utils.appearance()
	end,
})
require("config.lazy")
