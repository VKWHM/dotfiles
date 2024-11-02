return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	opts = {
		diagnostics = {
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			virtual_text = {
				spacing = 4,
				source = "if_many",
				prefix = "●",
			},
		},
		-- Enable lsp cursor word highlighting
		document_highlight = {
			enabled = true,
		},
	},
	config = function()
		-- import lspconfig plugin
		local lspconfig = require("lspconfig")

		-- import mason_lspconfig plugin
		local mason_lspconfig = require("mason-lspconfig")

		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		-- setup sourcekit lsp
		lspconfig.sourcekit.setup({
			root_dir = lspconfig.util.root_pattern(".git", "Package.swift", "root.swift"), -- 'root.swift' for testing purposes

			capabilities = {
				workspace = {
					didChangeWatchedFiles = {
						dynamicRegistration = true,
					},
				},
			},
		})

		local keymap = vim.keymap -- for conciseness

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "<leader>lR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Goto declaration"
				keymap.set("n", "<leader>lcD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "<leader>lcd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "<leader>lci", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "<leader>lct", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>lca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>lcr", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>lD", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Goto previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Goto next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Show signature help for what is under cursor"
				keymap.set("i", "lk", vim.lsp.buf.signature_help, opts) -- show signature for what is under cursor
				keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts) -- show signature for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>lr", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

				opts.desc = "Open LSP Manager"
				keymap.set("n", "<leader>ll", ":Mason<CR>", opts) -- mapping to restart lsp if necessary
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()
		capabilities.textDocument.completion.completionItem = {
			documentationFormat = { "markdown", "plaintext" },
			snippetSupport = true,
			preselectSupport = true,
			insertReplaceSupport = true,
			labelDetailsSupport = true,
			deprecatedSupport = true,
			commitCharactersSupport = true,
			tagSupport = { valueSet = { 1 } },
			resolveSupport = {
				properties = {
					"documentation",
					"detail",
					"additionalTextEdits",
				},
			},
		}
		-- Change the Diagnostic symbols in the sign column (gutter)
		-- (not in youtube nvim video)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		mason_lspconfig.setup_handlers({
			-- default handler for installed servers
			function(server_name)
				lspconfig[server_name == "tsserver" and "ts_ls" or server_name].setup({
					capabilities = capabilities,
				})
			end,
			["emmet_ls"] = function()
				-- configure emmet language server
				lspconfig["emmet_ls"].setup({
					capabilities = capabilities,
					filetypes = {
						"html",
						"typescriptreact",
						"javascriptreact",
						"css",
						"sass",
						"scss",
						"less",
						"svelte",
						"php",
					},
				})
			end,
			["lua_ls"] = function()
				-- configure lua server (with special settings)
				lspconfig["lua_ls"].setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							-- make the language server recognize "vim" global
							diagnostics = {
								globals = { "vim" },
							},
							workspace = {
								library = {
									[vim.fn.expand("$VIMRUNTIME/lua")] = true,
									[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
									[vim.fn.stdpath("data") .. "/lazy/ui/nvchad_types"] = true,
									[vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
								},
								maxPreload = 100000,
								preloadFileSize = 10000,
							},
							codeLens = {
								enable = true,
							},
							completion = {
								callSnippet = "Replace",
							},
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
						},
					},
				})
			end,
			["clangd"] = function()
				lspconfig["clangd"].setup({
					cmd = {
						-- see clangd --help-hidden
						"clangd",
						"--background-index",
						-- by default, clang-tidy use -checks=clang-diagnostic-*,clang-analyzer-*
						-- to add more checks, create .clang-tidy file in the root directory
						-- and add Checks key, see https://clang.llvm.org/extra/clang-tidy/
						"--clang-tidy",
						"--completion-style=bundled",
						"--cross-file-rename",
						"--header-insertion=iwyu",
					},
					capabilities = capabilities,
					init_options = {
						clangdFileStatus = true, -- Provides information about activity on clangd’s per-file worker thread
						usePlaceholders = true,
						completeUnimported = true,
						semanticHighlighting = true,
					},
				})
			end,
			["pyright"] = function()
				lspconfig["pyright"].setup({
					capabilities = capabilities,
					filetypes = { "python" },
				})
			end,
		})
	end,
}
