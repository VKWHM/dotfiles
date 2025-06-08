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
	local system_prompt = [[
You are an expert Git commit message generator.  

When given repository staged diff, produce exactly one Conventional Commits–style commit message and nothing else.
]]

	local prompt = [[
Please generate a Git commit message based on the following staged changes.
Steps:

1. Read the staged changes (the diff) only to extract relevant information.  
2. Classify the change under one of these types:  
   - **feat**     — a new feature  
   - **fix**      — a bug fix  
   - **docs**     — documentation only changes  
   - **style**    — formatting, code style (no logic changes)  
   - **refactor** — code change that neither fixes a bug nor adds a feature  
   - **perf**     — code change that improves performance  
   - **test**     — adding or correcting tests  
   - **build**    — changes affecting the build system or dependencies  
   - **ci**       — CI configuration or scripts  
   - **chore**    — other changes that don’t modify src or test files  
   - **revert**   — reverts a previous commit  

3. (Optional) If applicable, identify a single-word scope for the affected module (e.g. `(auth)`). Otherwise omit the scope.  

4. Generate a one-line **title** in imperative mood, ≤50 characters:  

```
<type>(<scope>): <short description>
```

- Omit `(scope)` if none.  
- Do not exceed 50 characters including type and scope.  

5. Add a blank line, then a **detailed description** wrapped at ~72 characters per line:  
- Explain **what** changed and **why** in concise prose.  
- Reference any issue or ticket if mensioned in changes.  
- Do not include implementation details, code snippets, or unrelated commentary.  

6. Output **only** the commit message (title, blank line, description) enclosed with markdown code block (```).  
- Do not include any metadata, analysis, or commentary.  
- Do not include any additional text, explanations, or formatting.
]]

	map("n", "<leader>ac", function()
		vim.system({ "git", "diff", "--staged", "--name-only" }, { text = true }, function(out)
			if out.code ~= 0 then
				vim.notify("Getting staged files failed: " .. out.stderr, vim.log.levels.ERROR)
				return
			elseif out.stdout == "" then
				vim.notify("No staged files to commit", vim.log.levels.WARN)
				return
			end
			vim.notify("Generating commit message with Copilot...", vim.log.levels.INFO)
			vim.schedule(function()
				require("CopilotChat").ask(prompt, {
					model = "gpt-4",
					context = { "git:staged" },
					system_prompt = system_prompt,
					headless = true,
					callback = function(response)
						local _, msg = string.match(response, [[^```(%w*)%W(.+)%W```]])
						if not msg then
							print("Copilot response:", response)
							vim.notify("Failed to parse Copilot response", vim.log.levels.ERROR)
							return response
						end
						vim.system({ "git", "commit", "-m", msg }, {}, function(commit_out)
							if commit_out.code ~= 0 then
								vim.notify("Git commit failed: " .. commit_out.stderr, vim.log.levels.ERROR)
							else
								print(msg)
								vim.notify("Changes committed successfully!", vim.log.levels.INFO)
							end
						end)
						return response
					end,
				})
			end)
		end)
	end, { desc = "Commit changes with Copilot generated message" })
end
