-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set
local unmap = vim.keymap.del

-- Never use arrow keys :p
-- map({ "n", "i", "v", "x" }, "<up>", "<nop>")
-- map({ "n", "i", "v", "x" }, "<down>", "<nop>")
-- map({ "n", "i", "v", "x" }, "<left>", "<nop>")
-- map({ "n", "i", "v", "x" }, "<right>", "<nop>")

-- Increment/Decrement
map("n", "+", "<C-a>")
map("n", "-", "<C-x>")

-- Leave insert mode
map("i", "jk", "<ESC>", { silent = true })

-- Save and quit all
map("n", "<leader>qw", "<cmd>wqall!<CR>", { desc = "Save Files And Quit" })

-- Terminal Options
unmap("n", "<leader>fT")
unmap("n", "<leader>ft")

-- Tab management
do
	unmap("n", "<leader><tab>l", { desc = "Last Tab" })
	unmap("n", "<leader><tab>o", { desc = "Close Other Tabs" })
	unmap("n", "<leader><tab>f", { desc = "First Tab" })
	unmap("n", "<leader><tab><tab>", { desc = "New Tab" })
	unmap("n", "<leader><tab>]", { desc = "Next Tab" })
	unmap("n", "<leader><tab>d", { desc = "Close Tab" })
	unmap("n", "<leader><tab>[", { desc = "Previous Tab" })

	map("n", "<tab>n", "<cmd>tabnew<CR>", { desc = "New Tab" })
	map("n", "<tab>t", "<cmd>tabnew %<CR>", { desc = "Current Buffer In New Tab" })
	map("n", "<tab>x", "<cmd>tabclose<CR>", { desc = "Current Tab" })
	map("n", "<tab>o", "<cmd>tabonly<CR>", { desc = "Other Tabs" })
	map("n", "<tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
	map("n", "<tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
	map("n", "<leader><tab>", "<cmd>tabn<cr>", { desc = "Next Tab" })
	map("n", "<leader><s-tab>", "<cmd>tabp<cr>", { desc = "Previous Tab" })
end

-- Git commit with Copilot Chat
do
	local prompt = [[
    Generate a Git commit message using the Conventional Commits format based on my staged changes. Use the following structure:

    <type>(<optional scope>): <title line> (max 50 characters, imperative mood)

    <blank line>

    <Description>
    Explain what the change does and why it was made. Include relevant context but avoid implementation details. Use the staged diff to guide the message.

    Valid <type> values include: feat, fix, chore, docs, style, refactor, perf, test, build, ci, revert.
  ]]
	local function sanitize(str, allowed_chars) end
	map("n", "<leader>ac", function()
		vim.system({ "git", "diff", "--staged", "--name-only" }, { text = true }, function(out)
			if out.code ~= 0 then
				vim.notify("Getting staged files failed: " .. out.stderr, vim.log.levels.ERROR)
				return
			elseif out.stdout == "" then
				vim.notify("No staged files to commit", vim.log.levels.WARN)
				return
			end
			require("CopilotChat").ask(prompt, {
				model = "gpt-4",
				context = { "git:staged" },
				callback = function(response)
					vim.system({ "git", "commit", "-m", response }, {}, function(commit_out)
						if commit_out.code ~= 0 then
							vim.notify("Git commit failed: " .. commit_out.stderr, vim.log.levels.ERROR)
						else
							vim.notify("Changes committed successfully!", vim.log.levels.INFO)
						end
					end)
					return response
				end,
			})
		end)
	end, { desc = "Commit changes with Copilot generated message" })
end
