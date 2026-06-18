return {
	{
		"cordx56/rustowl",
		version = "*",
		build = "cargo install rustowl",
		lazy = false,
		opts = {
			auto_enable = false,
			idle_time = 500,
			colors = {
				-- catppuccin-friendly palette (works for both latte and mocha)
				lifetime = "#40a02b", -- green
				imm_borrow = "#1e66f5", -- blue
				mut_borrow = "#8839ef", -- mauve/purple
				move = "#fe640b", -- peach/orange
				call = "#df8e1d", -- yellow
				outlive = "#d20f39", -- red
			},
			client = {
				on_attach = function(_, buf)
					vim.keymap.set("n", "<leader>crO", function()
						require("rustowl").toggle(buf)
					end, { buffer = buf, desc = "RustOwl Toggle" })
				end,
			},
		},
	},
	{
		"mrcjkb/rustaceanvim",
		opts = {
			server = {
				settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
							loadOutDirsFromCheck = true,
							buildScripts = { enable = true },
						},
						checkOnSave = {
							allFeatures = true,
							command = "clippy",
							extraArgs = { "--no-deps" },
						},
						procMacro = {
							enable = true,
							ignored = {
								["async-trait"] = { "async_trait" },
								["napi-derive"] = { "napi" },
								["async-recursion"] = { "async_recursion" },
							},
						},
						inlayHints = {
							bindingModeHints = { enable = false },
							chainingHints = { enable = true },
							closingBraceHints = { enable = true, minLines = 25 },
							closureReturnTypeHints = { enable = "never" },
							lifetimeElisionHints = { enable = "never" },
							maxLength = { enable = true, maxLength = 25 },
							parameterHints = { enable = true },
							renderColons = { enable = true },
							typeHints = {
								enable = true,
								hideClosureInitialization = false,
								hideNamedConstructor = false,
							},
						},
					},
				},
			},
		},
	},
	{
		"saecki/crates.nvim",
		opts = {
			completion = {
				crates = { enabled = true, max_results = 8, min_chars = 3 },
			},
			lsp = {
				enabled = true,
				actions = true,
				completion = true,
				hover = true,
			},
		},
		keys = {
			{
				"<leader>ct",
				function()
					require("crates").toggle()
				end,
				ft = "toml",
				desc = "Crates Toggle",
			},
			{
				"<leader>cR",
				function()
					require("crates").reload()
				end,
				ft = "toml",
				desc = "Crates Reload",
			},
			{
				"<leader>cv",
				function()
					require("crates").show_versions_popup()
				end,
				ft = "toml",
				desc = "Crates Versions",
			},
			{
				"<leader>cf",
				function()
					require("crates").show_features_popup()
				end,
				ft = "toml",
				desc = "Crates Features",
			},
			{
				"<leader>cd",
				function()
					require("crates").show_dependencies_popup()
				end,
				ft = "toml",
				desc = "Crates Dependencies",
			},
			{
				"<leader>cu",
				function()
					require("crates").upgrade_crate()
				end,
				ft = "toml",
				desc = "Crates Upgrade",
			},
			{
				"<leader>cU",
				function()
					require("crates").upgrade_all_crates()
				end,
				ft = "toml",
				desc = "Crates Upgrade All",
			},
		},
	},
}
