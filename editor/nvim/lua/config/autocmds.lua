-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Define your Lua function
local snacks = require("snacks")

local function on_sigusr1()
	local backgroundClass = snacks.toggle.get("background")
	if backgroundClass then
		backgroundClass:toggle()
	else
		vim.notify("Background toggle class not found", vim.log.levels.WARN)
	end
end

-- Set up signal handler
local sig = vim.loop.new_signal()
sig:start("sigusr1", function()
	vim.schedule(on_sigusr1) -- Schedule to run safely in main thread
end)

-- TypeScript/JavaScript extra keymaps not provided by LazyVim's typescript extra
local ts_fts = { typescript = true, typescriptreact = true, javascript = true, javascriptreact = true }

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("whm_ts_keymaps", { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then
			return
		end
		local buf = args.buf
		if not ts_fts[vim.bo[buf].filetype] then
			return
		end
		local map = vim.keymap.set

		if client.name == "vtsls" then
			map("n", "<leader>cs", function()
				vim.lsp.buf.code_action({
					context = { only = { "source.sortImports" }, diagnostics = {} },
					apply = true,
				})
			end, { buffer = buf, desc = "Sort Imports" })
		end

		if client.name == "eslint" then
			map("n", "<leader>ce", function()
				vim.lsp.buf.code_action({
					context = { only = { "source.fixAll.eslint" }, diagnostics = {} },
					apply = true,
				})
			end, { buffer = buf, desc = "ESLint Fix All" })
		end
	end,
})
