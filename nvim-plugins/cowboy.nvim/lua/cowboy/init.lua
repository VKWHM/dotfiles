local M = {}
M.keys = { "h", "j", "k", "l", "<Up>", "<Down>", "<Left>", "<Right>" }
M._stack = {}

-- TODO: Implement configure_key
local function configure_key(key)
	return function() end
end

function M.push(maps, lhs)
	for _, value in pairs(maps) do
		if value.lhs == lhs then
			table.insert(M._stack, value)
			return value
		end
	end
end

function M.map_keys()
	local maps = vim.api.nvim_get_keymap("n")
	for _, key in ipairs(M.keys) do
		M.push(maps, key)
	end

	local map = vim.keymap.set
	for _, key in ipairs(M.keys) do
		map("n", key, configure_key(key), { silent = true })
	end
end

function M.pop(lhs)
	local unmap = vim.keymap.del
	for i, backup in ipairs(M._stack) do
		if backup.lhs == lhs then
			unmap("n", lhs)
			return table.remove(M._stack, i)
		end
	end
end

function M.unmap_keys()
	local map = vim.keymap.set
	for _, key in ipairs(M.keys) do
		backup = M.pop(key)
		if backup then
			map("n", backup.lhs, backup.rhs or backup.callback, {
				remap = backup.remap,
				callback = backup.callback,
				desc = backup.desc,
				silent = backup.silent,
				noremap = backup.noremap,
				script = backup.script,
				nowait = backup.nowait,
			})
		end
	end
end

function M.setup()
	local active = true
	local map_callback = {
		[false] = map_keys,
		[true] = unmap_keys,
	}
	vim.keymap.set("n", "<leader>uu", function()
		map_callback[active]()
		active = not active
	end, { desc = "Toggle cowboy" })
end

return M
