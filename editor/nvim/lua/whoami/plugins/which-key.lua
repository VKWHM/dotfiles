return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	config = function()
		local wk = require("which-key")
		wk.add({
			{ "<leader>f", group = "Find" },
			{ "<leader>b", group = "Buffer" },
			{ "<leader>u", group = "Toggle" },
			{ "<leader>e", group = "Explorer" },
			{ "<leader>h", group = "Git" },
			{ "<leader>l", group = "LSP" },
			{ "<leader>lc", group = "Code Action" },
			{ "<leader>q", group = "Quite" },
			{ "<leader>s", group = "Window" },
			{ "<leader>t", group = "Tab" },
			{ "<leader>w", group = "Session" },
			{ "<leader>x", group = "Diagnostic" },
			{ "<leader>\\", group = "Terminal" },
		})
	end,
	opts = {},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
