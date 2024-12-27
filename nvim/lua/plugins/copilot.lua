return {
	"github/copilot.vim",
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
}
