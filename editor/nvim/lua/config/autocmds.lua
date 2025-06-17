-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Define your Lua function
local function on_sigusr1()
	vim.opt.background = vim.opt.background._value == "dark" and "light" or "dark"
end

-- Set up signal handler
local sig = vim.loop.new_signal()
sig:start("sigusr1", function()
	vim.schedule(on_sigusr1) -- Schedule to run safely in main thread
end)
