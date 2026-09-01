return {
	{
		"mfussenegger/nvim-dap",
		optional = true,
		opts = function()
			local dap = require("dap")

			if not dap.adapters["pwa-node"] then
				dap.adapters["pwa-node"] = {
					type = "server",
					host = "127.0.0.1",
					port = "${port}",
					executable = {
						command = "node",
						args = {
							vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
							"${port}",
						},
					},
				}
			end

			local encore_configs = {
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

			for _, lang in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
				dap.configurations[lang] = dap.configurations[lang] or {}
				for i = #encore_configs, 1, -1 do
					table.insert(dap.configurations[lang], 1, encore_configs[i])
				end
			end
		end,
	},
}
