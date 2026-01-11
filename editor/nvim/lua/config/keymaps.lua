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
					model = "gpt-4.1",
					sticky = { "#gitdiff:staged" },
					system_prompt = system_prompt,
					headless = true,
					callback = function(response)
						local _, msg = string.match(response.content, [[^```(%w*)%W(.+)%W```]])
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

-- Gemini CLI Integration
do
	local function run_gemini(prompt, range, replace)
		-- Get the selected text
		local lines
		if range then
			local start_row, _, end_row, _ = unpack(range)
			-- Adjust for 0-based indexing if needed, but vim.api works with 0-based
			-- getpos returns 1-based, get_lines expects 0-based start, exclusive end?
			-- vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
			lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
		else
			lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		end
		local code = table.concat(lines, "\n")

		local full_prompt = prompt .. "\n\nCode Context:\n" .. code

		-- UI Setup: Floating window with spinner
		local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
		local spinner_idx = 1
		local buf = vim.api.nvim_create_buf(false, true)
		local width = 24
		local height = 1
		local win = vim.api.nvim_open_win(buf, false, {
			relative = "editor",
			width = width,
			height = height,
			col = math.floor((vim.o.columns - width) / 2),
			row = math.floor((vim.o.lines - height) / 2),
			style = "minimal",
			border = "rounded",
			title = " Gemini ",
			title_pos = "center",
		})

		local timer = (vim.uv or vim.loop).new_timer()
		timer:start(
			0,
			80,
			vim.schedule_wrap(function()
				if vim.api.nvim_buf_is_valid(buf) then
					vim.api.nvim_buf_set_lines(
						buf,
						0,
						-1,
						false,
						{ " " .. spinner_frames[spinner_idx] .. " Processing..." }
					)
					spinner_idx = (spinner_idx % #spinner_frames) + 1
				end
			end)
		)

		local function cleanup_ui()
			if timer then
				timer:stop()
				timer:close()
				timer = nil
			end
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
			if vim.api.nvim_buf_is_valid(buf) then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end

		-- Execute the gemini command
		-- Note: Ensure 'gemini' is in your PATH and configured.
		-- Adjust the command arguments based on the specific CLI tool version.
		-- Example: `gemini prompt "..."`
		vim.system({ "gemini", "--resume", "--model", "flash", "prompt", full_prompt }, { text = true }, function(out)
			vim.schedule(cleanup_ui)

			if out.code ~= 0 then
				vim.schedule(function()
					vim.notify("Gemini Error: " .. (out.stderr or "Unknown error"), vim.log.levels.ERROR)
				end)
				return
			end

			local result = out.stdout or ""
			-- Remove potential markdown code block wrappers if replacing
			if replace then
				result = result:gsub("^```%w*\n", ""):gsub("\n```$", "")
			end

			vim.schedule(function()
				if replace and range then
					local new_lines = vim.split(result, "\n")
					vim.api.nvim_buf_set_lines(0, range[1] - 1, range[3], false, new_lines)
					vim.notify("Code refactored!", vim.log.levels.INFO)
				else
					-- Show in floating window
					local buf = vim.api.nvim_create_buf(false, true)
					vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, "\n"))
					vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

					local width = math.floor(vim.o.columns * 0.8)
					local height = math.floor(vim.o.lines * 0.8)
					vim.api.nvim_open_win(buf, true, {
						relative = "editor",
						width = width,
						height = height,
						col = math.floor((vim.o.columns - width) / 2),
						row = math.floor((vim.o.lines - height) / 2),
						style = "minimal",
						border = "rounded",
						title = " Gemini Response ",
						title_pos = "center",
					})
					-- Map q to close
					vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf })
				end
			end)
		end)
	end

	local function get_visual_range()
		-- Must exit visual mode to update the '< and '> marks
		if vim.fn.mode():match("^[vV\22]") then
			vim.cmd("normal! \27")
		end

		local start_row = vim.api.nvim_buf_get_mark(0, "<")[1]
		local end_row = vim.api.nvim_buf_get_mark(0, ">")[1]

		return { start_row, 0, end_row, 0 }
	end

	-- Keymaps
	map("v", "<leader>gr", function()
		local prompt = [[
You are a Clean Code expert. Refactor the following code to improve its readability, maintainability, and performance.

Guidelines:
1. Strict Logic Preservation: The refactored code must behave exactly the same as the original.
2. Idiomatic Style: Use standard conventions and idioms for the language.
3. No Markdown: Return ONLY the raw code. Do not wrap it in markdown code blocks (```).
4. No Commentary: Do not include any explanations or text before/after the code.
]]
		run_gemini(prompt, get_visual_range(), true)
	end, { desc = "Gemini Refactor" })
end
