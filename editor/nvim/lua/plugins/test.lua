return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"marilari88/neotest-vitest",
			"nvim-neotest/neotest-plenary",
		},
		opts = {
			adapters = {
				"neotest-plenary",
				["neotest-vitest"] = {
					vitestCommand = function()
						local root = vim.fs.root(0, ".git")
						if root and vim.uv.fs_stat(vim.fs.joinpath(root, "encore.app")) then
							return "encore test"
						end
						return "bun run test"
					end,
				},
			},
		},
	},
}
