return {
	"mfussenegger/nvim-dap",
	config = function()
		local dap = require("dap")

		-- Path to js-debug-adapter server installed via Mason
		local js_debug_path = vim.fn.stdpath("data")
			.. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

		dap.adapters["pwa-node"] = {
			type = "server",
			host = "127.0.0.1",
			port = "${port}",
			executable = {
				command = "node",
				args = { js_debug_path, "${port}" },
			},
		}

		local ts_attach_config = {
			{
				type = "pwa-node",
				request = "attach",
				name = "Attach to Encore (port 9229)",
				address = "127.0.0.1",
				port = 9229,
				cwd = "${workspaceFolder}",
				sourceMaps = true,
				resolveSourceMapLocations = {
					"${workspaceFolder}/**",
					"!**/node_modules/**",
				},
				skipFiles = {
					"<node_internals>/**",
					"**/node_modules/**",
				},
			},
			{
				type = "pwa-node",
				request = "attach",
				name = "Attach to Process (Pick Port)",
				address = "127.0.0.1",
				port = function()
					return tonumber(vim.fn.input("Port: ", "9229"))
				end,
				cwd = "${workspaceFolder}",
				sourceMaps = true,
				resolveSourceMapLocations = {
					"${workspaceFolder}/**",
					"!**/node_modules/**",
				},
				skipFiles = {
					"<node_internals>/**",
					"**/node_modules/**",
				},
			},
		}

		dap.configurations.typescript = ts_attach_config
		dap.configurations.javascript = ts_attach_config
	end,
}
