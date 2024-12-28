return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		local toggleterm = require("toggleterm")
		toggleterm.setup({
			size = function(term)
				if term.direction == "horizontal" then
					return 10
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.42
				end
			end,
			open_mapping = [[<c-\>]],
			shading_factor = -10,
		})

		local keymap = vim.keymap

		keymap.set("n", [[<leader>\v]], "<cmd>ToggleTerm direction=vertical<CR>", { desc = "Open vertical term" })
		keymap.set("n", [[<leader>\h]], "<cmd>ToggleTerm direction=horizontal<CR>", { desc = "Open horizontal term" })
		keymap.set("n", [[<leader>\f]], "<cmd>ToggleTerm direction=float<CR>", { desc = "Open float term" })
		keymap.set("n", [[<leader>\t]], "<cmd>ToggleTerm direction=tab<CR>", { desc = "Open tab term" })

		-- Terminal mode keymaps
		function _G.set_terminal_keymaps()
			local keymap = vim.keymap
			local opts = { buffer = 0 }

			keymap.set("t", "xx", [[<c-\><c-n>]], opts)
			keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
			keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
			keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
			keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
		end
		vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
	end,
}
