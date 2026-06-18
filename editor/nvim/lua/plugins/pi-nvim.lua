-- Bridge between pi coding agent and Neovim
-- https://github.com/carderne/pi-nvim
return {
	{
		"carderne/pi-nvim",
		config = function()
			require("pi-nvim").setup({
				set_default_keymaps = false,
			})

			local map = vim.keymap.set

			map({ "n", "v" }, "<leader>ap", ":Pi<CR>", { desc = "Send to pi" })
			map("n", "<leader>app", ":PiSend<CR>", { desc = "Send prompt to pi" })
			map("n", "<leader>apb", ":PiSendBuffer<CR>", { desc = "Send buffer to pi" })
			map("n", "<leader>apf", ":PiSendFile<CR>", { desc = "Send file to pi" })
			map("v", "<leader>aps", ":PiSendSelection<CR>", { desc = "Send selection to pi" })
			map("n", "<leader>api", ":PiPing<CR>", { desc = "Ping pi" })
			map("n", "<leader>apl", ":PiSessions<CR>", { desc = "List pi sessions" })
		end,
	},
}
