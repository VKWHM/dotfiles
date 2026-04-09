local encore_root_cache = nil
local encore_root_resolved = false

local function get_encore_root()
	if encore_root_resolved then
		return encore_root_cache
	end
	encore_root_resolved = true
	local root = vim.fs.root(0, ".git")
	if root and vim.uv.fs_stat(vim.fs.joinpath(root, "encore.app")) then
		encore_root_cache = root
	end
	return encore_root_cache
end

return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"marilari88/neotest-vitest",
			"nvim-neotest/neotest-plenary",
		},
		opts = {
			adapters = {
				"neotest-plenary",
				["neotest-vitest"] = {
				vitestCommand = function()
					if get_encore_root() then
						return "encore test"
					end
					return "npx vitest"
				end,
					cwd = function()
						return get_encore_root()
					end,
				},
			},
		},
	},
}
