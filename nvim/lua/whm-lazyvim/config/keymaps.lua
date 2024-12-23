-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set
local unmap = vim.keymap.del

-- Never use arrow keys :p
map({ "n", "i", "v", "x" }, "<up>", "<nop>")
map({ "n", "i", "v", "x" }, "<down>", "<nop>")
map({ "n", "i", "v", "x" }, "<left>", "<nop>")
map({ "n", "i", "v", "x" }, "<right>", "<nop>")

-- Delete word
map("n", "dw", "bde")

-- Increment/Decrement
map("n", "+", "<C-a>")
map("n", "-", "<C-x>")

-- Leave insert mode
map("i", "jk", "<ESC>", { silent = true })

-- Save and quit all
map("n", "<leader>qw", "<cmd>wqall!<CR>", { desc = "Save Files And Quit" })

-- Terminal Options
unmap("n", "<leader>fT")
unmap("n", "<leader>ft")

-- Tab management
do
  unmap("n", "<leader><tab>l", { desc = "Last Tab" })
  unmap("n", "<leader><tab>o", { desc = "Close Other Tabs" })
  unmap("n", "<leader><tab>f", { desc = "First Tab" })
  unmap("n", "<leader><tab><tab>", { desc = "New Tab" })
  unmap("n", "<leader><tab>]", { desc = "Next Tab" })
  unmap("n", "<leader><tab>d", { desc = "Close Tab" })
  unmap("n", "<leader><tab>[", { desc = "Previous Tab" })

  map("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New Tab" })
  map("n", "<leader>tt", "<cmd>tabnew %<CR>", { desc = "Current Buffer In New Tab" })
  map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Current Tab" })
  map("n", "<leader>to", "<cmd>tabonly<CR>", { desc = "Other Tabs" })
  map("n", "<leader>tl", "<cmd>tablast<cr>", { desc = "Last Tab" })
  map("n", "<leader>tf", "<cmd>tabfirst<cr>", { desc = "First Tab" })
  map("n", "<tab>", "<cmd>tabn<cr>", { desc = "Next Tab" })
  map("n", "<s-tab>", "<cmd>tabp<cr>", { desc = "Previous Tab" })
end
