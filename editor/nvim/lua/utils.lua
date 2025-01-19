local opt = vim.opt

local M = {}
M.opt = {}

do
	if vim.fn.has("win32") == 1 then
		function os.name()
			return "win"
		end
	elseif vim.fn.has("macunix") == 1 then
		function os.name()
			return "darwin"
		end
	else
		function os.name()
			return "linux"
		end
	end
end

function M.appearance()
	local result
	if os.name() == "darwin" then
		local handle = assert(io.popen("defaults read -globalDomain AppleInterfaceStyle 2>&1", "r"))
		result = assert(handle:read("*a")):find("^Dark")
		handle:close()
	elseif os.getenv("WHM_APPEARANCE") then
		result = os.getenv("WHM_APPEARANCE"):find("^Dark")
	else
		result = true
	end
	return result ~= nil and "dark" or "light"
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

-- Merge table2 into table1
function M.merge(t1, t2)
	if type(t2) == "table" and type(t2) == "table" then
		for key, value in pairs(t2) do
			if type(value) == "table" then
				t1[key] = t1[key] or {}
				M.merge(t1[key], value)
			else
				t1[key] = value
			end
		end
	end
end

return M
