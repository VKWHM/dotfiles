local M = {}

---@type table
M.opts = {}
---@type number
M.opts.count = 15
---@type table<string>
M.opts.keys = { "h", "j", "k", "l", "<Up>", "<Down>", "<Left>", "<Right>" }
---@type number
M.opts.timeout = 2

M._stack = {}
M._username = os.getenv("USER") or "Cowboy"

function M.configure_key(key)
	local username = M._username
	local count = 0
	---@type number
	local last_time = 0
	local timer = assert(vim.uv.new_timer())
	local notified = false
	return function()
		if vim.v.count == 0 and count > M.opts.count then
			if not notified then
				timer:start(1000, 500, function()
					timer:stop()
					count = 0
					notified = false
				end)
				notified = true
				vim.notify(("Hold it %s! (%s)"):format(username, key), vim.log.levels.WARN, {
					title = "Cowboy",
					icon = "🤠",
					keep = function()
						return count > M.opts.count
					end,
				})
			else
				timer:again()
			end
			return nil
		end
		if os.time() - last_time >= M.opts.timeout then
			count = 0
		end
		count = count + 1
		last_time = os.time()
		return key
	end
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
	for _, key in ipairs(M.opts.keys) do
		M.push(maps, key)
	end

	local map = vim.keymap.set
	for _, key in ipairs(M.opts.keys) do
		map("n", key, M.configure_key(key), { silent = true, noremap = true, expr = true })
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
	for _, key in ipairs(M.opts.keys) do
		local backup = M.pop(key)
		if backup then
			map("n", backup.lhs, backup.rhs or backup.callback, {
				expr = backup.expr == 1 and true or nil,
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

function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", M.opts, opts)
	local active = true
	local autocmd_id
	local map_callback = {
		[false] = M.map_keys,
		[true] = M.unmap_keys,
	}
	vim.keymap.set("n", "<leader>uu", function()
		map_callback[active]()
		active = not active
		vim.notify("Cowboy is " .. (active and "active" or "inactive"))
	end, { desc = "Toggle Cowboy" })

	autocmd_id = vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		pattern = "*.*",
		callback = function()
			M.map_keys()
			vim.api.nvim_del_autocmd(autocmd_id)
		end,
	})
end

return M
