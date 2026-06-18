vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.expandtab = true

local map = vim.keymap.set
local buf = vim.api.nvim_get_current_buf()

map("n", "<leader>crr", function() vim.cmd.RustLsp("runnables") end, { buffer = buf, desc = "Rust Runnables" })
map("n", "<leader>crd", function() vim.cmd.RustLsp("debuggables") end, { buffer = buf, desc = "Rust Debuggables" })
map("n", "<leader>crt", function() vim.cmd.RustLsp("testables") end, { buffer = buf, desc = "Rust Testables" })
map("n", "<leader>cre", function() vim.cmd.RustLsp("expandMacro") end, { buffer = buf, desc = "Rust Expand Macro" })
map("n", "<leader>crc", function() vim.cmd.RustLsp("openCargo") end, { buffer = buf, desc = "Rust Open Cargo.toml" })
map("n", "<leader>crp", function() vim.cmd.RustLsp("parentModule") end, { buffer = buf, desc = "Rust Parent Module" })
map("n", "<leader>cro", function() vim.cmd.RustLsp("externalDocs") end, { buffer = buf, desc = "Rust Open Docs" })
map("n", "<leader>crx", function() vim.cmd.RustLsp("explainError") end, { buffer = buf, desc = "Rust Explain Error" })
map("n", "<leader>cra", function() vim.cmd.RustLsp("codeAction") end, { buffer = buf, desc = "Rust Code Actions" })
map("n", "K", function() vim.cmd.RustLsp({ "hover", "actions" }) end, { buffer = buf, desc = "Rust Hover Actions" })
