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
				["neotest-vitest"] = {},
			},
		},
	},
}
