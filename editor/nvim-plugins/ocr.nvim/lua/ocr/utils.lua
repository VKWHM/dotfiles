local M = {}

---Shared UUID regex pattern for matching 36-char session IDs
M.UUID_REGEX = '^([a-f0-9]+%-[a-f0-9]+%-[a-f0-9]+%-[a-f0-9]+%-[a-f0-9]+)'
M.UUID_EXACT_REGEX = '^[a-f0-9]+%-[a-f0-9]+%-[a-f0-9]+%-[a-f0-9]+%-[a-f0-9]+$'

local FUNCTION_TYPES = {
	['function_definition'] = true,
	['function_declaration'] = true,
	['function_item'] = true,
	['method_definition'] = true,
	['method_declaration'] = true,
	['arrow_function'] = true,
}

---Get Treesitter enclosing function line range (1-indexed start_line, end_line) for current window/cursor
---@return integer|nil, integer|nil
function M.get_current_function_range()
	local ok, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
	if ok and ts_utils then
		local node = ts_utils.get_node_at_cursor()
		while node do
			local ntype = node:type()
			if FUNCTION_TYPES[ntype] then
				local srow, _, erow, _ = node:range()
				return srow + 1, erow + 1
			end
			node = node:parent()
		end
	end

	local ts_ok, node = pcall(vim.treesitter.get_node)
	if ts_ok and node then
		while node do
			local ntype = node:type()
			if FUNCTION_TYPES[ntype] then
				local srow, _, erow, _ = node:range()
				return srow + 1, erow + 1
			end
			node = node:parent()
		end
	end

	return nil, nil
end

return M
