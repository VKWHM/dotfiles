return {
	{
		"github/copilot.vim",
		enabled = false,
		config = function()
			local map = vim.keymap.set
			map("n", "<leader>at", function()
				if vim.g.copilot_enabled ~= 0 then
					vim.cmd([[Copilot disable]])
				else
					vim.cmd([[Copilot enable]])
				end
				vim.cmd([[Copilot status]])
			end, { desc = "Toggle Copilot" })
			-- Disable tab mapping
			vim.g.copilot_no_tab_map = true
			-- Map <M-y> to accept completion
			map("i", "<M-y>", '"\\<C-g>u" .. copilot#Accept("\\<CR>")', {
				expr = true,
				silent = true,
				noremap = true,
				replace_keycodes = false,
			})
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		opts = {
			enabled = true,
			suggestion = {
				keymap = {
					accept = "<M-y>",
					accept_line = "<M-l>",
				},
			},
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = function(_, opts)
			table.insert(
				opts.sections.lualine_x,
				3,
				LazyVim.lualine.status(LazyVim.config.icons.kinds.Copilot, function()
					local clients = package.loaded["copilot"]
							and LazyVim.lsp.get_clients({ name = "copilot", bufnr = 0 })
						or {}
					if #clients > 0 then
						local status = require("copilot.api").status.data.status
						return (status == "InProgress" and "pending") or (status == "Warning" and "error") or "ok"
					end
				end)
			)
		end,
	},
}
