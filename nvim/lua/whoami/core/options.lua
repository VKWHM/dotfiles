local utils = require("whoami.utils")
vim.cmd("let g:netrw_liststyle = 3") -- built-in neovim file explorer

local opt = vim.opt

opt.number = true
opt.relativenumber = true

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.cursorline = true

-- turn on termguicolors
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = utils.appearance() -- automaticlly detect appearance
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

--backspace
opt.backspace = "indent,eol,start"

-- split windows

opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- folds
opt.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
}

-- Option for session restore plugin
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
