return {
	"saghen/blink.cmp",
	opts = {
		keymap = {
			preset = "super-tab",
			["<C-l>"] = { "snippet_forward", "fallback" },
			["<C-j>"] = { "snippet_backward", "fallback" },
			["<C-b>"] = { "scroll_documentation_up" },
			["<C-f>"] = { "scroll_documentation_down" },
			["<C-e>"] = { "cancel" },
			["<C-n>"] = {
				function(cmp)
					if cmp.is_menu_visible() then
						return cmp.select_next()
					else
						return cmp.show()
					end
				end,
			},

			["<Tab>"] = { "accept", "fallback" },
		},
		sources = {
			default = function(ctx)
				local sources = {
					"lsp",
					"path",
					"snippets",
					"buffer",
				}

				local success, node = pcall(vim.treesitter.get_node)
				if
					success
					and node
					and vim.tbl_contains({ "comment", "comment_content", "line_comment", "block_comment" }, node:type())
				then
					return { "buffer" }
				end

				if vim.bo.filetype == "lua" then
					table.insert(sources, 1, "lazydev")
				end
				return sources
			end, --

			providers = {
				cmdline = {
					enabled = function()
						return not vim.fn.getcmdtype() == ":" or vim.fn.getcmdline():match("^[a-pr-vx-zA-Z]")
					end,
				},
			},
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
		completion = {
			documentation = {
				window = {
					border = "rounded",
				},
			},
			menu = {
				border = "rounded",
				scrolloff = 2,
				draw = {
					columns = {
						{ "kind_icon", "label", "label_description", gap = 1 },
						{ "kind" },
					},
					components = {},
				},
			},
		},
	},
}
