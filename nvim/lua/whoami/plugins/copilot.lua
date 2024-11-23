return {
	"github/copilot.vim",
	config = function()
		local keymap = vim.keymap
		keymap.set("n", "<leader>uc", function()
			if vim.g.copilot_enabled == 1 then
				vim.cmd([[Copilot disable]])
			else
				vim.cmd([[Copilot enable]])
			end
			vim.cmd([[Copilot status]])
		end, { desc = "Toggle Copilot" })
	end,
}
