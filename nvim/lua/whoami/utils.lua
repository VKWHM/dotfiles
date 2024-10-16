local opt = vim.opt

local M = {}
M.opt = {}

do
	local BinaryFormat = package.cpath:match("%p[\\|/]?%p(%a+)")
	if BinaryFormat == "dll" then
		function os.name()
			return "win"
		end
	elseif BinaryFormat == "so" then
		function os.name()
			return "linux"
		end
	elseif BinaryFormat == "dylib" then
		function os.name()
			return "darwin"
		end
	end
	BinaryFormat = nil
end

function M.appearance()
	if os.name() == "darwin" then
		local handle = assert(io.popen("defaults read -g AppleInterfaceStyle 2>&1", "r"))
		local result = assert(handle:read("*a"))
		handle:close()
		return result:find("^Dark") and "dark" or "light"
	end
	return "dark"
end

function M.opt.has(option)
	return opt[option] ~= nil
end

function M.opt.enabled(option, value)
	value = value or true
	return M.opt.has(option) and opt[option]._value == value
end

function M.opt.enable(option, stat)
	if M.opt.has(option) then
		opt[option] = stat
	end
end

function M.opt.toggle(option, values)
	if values then
		local first, second = values[1], values[2]
		M.opt.enable(option, M.opt.enabled(option, first) and second or first)
	else
		M.opt.enable(option, not M.opt.enabled(option))
	end
end

return M