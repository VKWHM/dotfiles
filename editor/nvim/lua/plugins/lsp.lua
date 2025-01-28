return {
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"stylua",
				"shfmt",
				"deno",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			opts = opts or {}
			local vtsls = opts.servers.vtsls
			-- Configure denols
			opts.servers.denols = {
				enabled = true,
				filetypes = vtsls.filetypes,
				settings = {
					complete_function_calls = true,
					typescript = vtsls.settings.typescript,
					denols = vtsls.settings.vtsls,
				},
			}
			local vtsls_setup = opts.setup.vtsls
			opts.setup.vtsls = function(_, opts)
				local util = require("lspconfig.util")
				if util.root_pattern("deno.json", "deno.jsonc")(opts.root_dir or vim.uv.cwd()) then
					return true
				end
				return vtsls_setup(_, opts)
			end
			opts.setup.denols = function(_, deno_opts)
				local util = require("lspconfig.util")
				-- If we do NOT find a deno.json, disable denols
				if not util.root_pattern("deno.json", "deno.jsonc")(deno_opts.root_dir or vim.loop.cwd()) then
					return true
				end

				-- Otherwise, merge the existing vtsls config into denols, so we don't
				-- have to duplicate everything. Then override with actual deno settings.
				local all_servers = require("lazyvim.util").opts("nvim-lspconfig").servers
				if all_servers and all_servers.vtsls then
					deno_opts = vim.tbl_deep_extend("force", deno_opts, all_servers.vtsls)
				end

				-- Force certain deno settings or filetypes
				deno_opts.settings = {
					deno = {
						enable = true,
						lint = true,
					},
				}
				-- If you need a more specialized root_dir for denols:
				deno_opts.root_dir = deno_opts.root_dir or util.root_pattern("deno.json", "deno.jsonc", ".git")
			end
		end,
	},
}
