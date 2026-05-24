return {
	{
		"Equilibris/nx.nvim",

		dependencies = {
			"nvim-telescope/telescope.nvim",
		},

		opts = {
			-- See below for config options
			nx_cmd_root = "bunx nx",
		},

		-- Plugin will load when you use these keys
		keys = {
			{ "<leader>nx", "<cmd>Telescope nx actions<CR>", desc = "nx actions" },
			{ "<leader>ng", "<cmd>Telescope nx generators<CR>", desc = "nx generators" },
			{ "<leader>nr", "<cmd>Telescope nx run_many<CR>", desc = "nx run-many" },
		},
	},
}
