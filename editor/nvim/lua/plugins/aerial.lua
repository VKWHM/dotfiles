return {
	"stevearc/aerial.nvim",
	config = function()
		local aerial = require("aerial")
		local map = vim.keymap.set
		aerial.setup({
			on_attach = function(bufnr)
				map({ "n", "v" }, "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
				map({ "n", "v" }, "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
			end,
		})
	end,
}
