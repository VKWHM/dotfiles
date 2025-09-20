return {
	{ "LazyVim/LazyVim", opts = {
		colorscheme = "catppuccin",
	} },
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000, opts = { flavour = "mocha" } },
	{
		"folke/noice.nvim",
		opts = {
			views = {
				cmdline_popup = {
					position = {
						row = 2,
					},
				},
			},
		},
	},
}
