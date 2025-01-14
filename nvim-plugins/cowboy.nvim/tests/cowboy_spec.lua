local stub = require("luassert.stub")
local spy = require("luassert.spy")
local cowboy = nil

local function find_mapping(maps, lhs)
	for _, value in ipairs(maps) do
		if value.lhs == lhs then
			return value
		end
	end
end

describe("cowboy", function()
	after_each(function()
		package.loaded["cowboy"] = nil
		cowboy = require("cowboy")
	end)

	it("can be required", function()
		cowboy = require("cowboy")
	end)

	it("can be find normal mode mappings", function()
		local lhs = "fake"
		vim.keymap.set("n", lhs, "<nop>")
		local mappings = vim.api.nvim_get_keymap("n")

		local result = cowboy.push(mappings, lhs)

		local stack = cowboy._stack

		assert.are_not.equals(0, #stack)
		assert.are.same(result, stack[1])
	end)

	it("map all movement keys", function()
		stub(vim.keymap, "set")

		cowboy.map_keys()

		assert.stub(vim.keymap.set).was.called(#cowboy.keys)

		vim.keymap.set:revert()
	end)

	it("backup existing mappings before map movement keys", function()
		local cowboy = cowboy
		vim.keymap.set("n", "j", "<nop>")

		cowboy.map_keys()

		local stack = cowboy._stack

		assert.are_not.equals(0, #stack)
		assert.are.equals("j", stack[1].lhs)
	end)

	it("unmap mapped movement keys", function()
		local sd = spy.on(vim.keymap, "del")
		local ss = spy.on(vim.keymap, "set")

		cowboy.map_keys()
		assert.spy(ss).has.called(#cowboy.keys)

		cowboy.unmap_keys()
		assert.spy(sd).has.called(#cowboy.keys)
	end)

	it("restore original keymap after unmap", function()
		local s = spy.on(vim.keymap, "del")
		local lhs = "j"
		local rhs = ":echo Hello"
		vim.keymap.set("n", "j", rhs)

		cowboy.map_keys()
		cowboy.unmap_keys()

		local mapping = find_mapping(vim.api.nvim_get_keymap("n"), lhs)
		assert.is.not_nil(mapping)
		assert.are.same(rhs, mapping.rhs)
	end)

	it("restore original keymap with their opts", function()
		local s = spy.on(vim.keymap, "del")
		local lhs = "j"
		local rhs = ":echo Hello"
		vim.keymap.set("n", "j", rhs, { silent = true, nowait = true, desc = "Test Keymap" })
		local original = find_mapping(vim.api.nvim_get_keymap("n"), lhs)

		cowboy.map_keys()
		cowboy.unmap_keys()

		local modified = find_mapping(vim.api.nvim_get_keymap("n"), lhs)
		assert.is.not_nil(modified)
		assert.are.same(original, modified)
	end)

	it("clears the cowboy._stack after unmap_keys is called", function()
		cowboy.map_keys()
		cowboy.unmap_keys()
		assert.are.equals(0, #cowboy._stack)
	end)
end)
