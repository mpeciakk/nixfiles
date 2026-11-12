local o = vim.o

o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.list = true

o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"
o.scrolloff = 8
o.laststatus = 3
o.winborder = "rounded"

o.swapfile = false
o.undofile = true
o.clipboard = "unnamedplus"
-- CursorHold drives checktime and gitsigns
o.updatetime = 250

o.splitright = true
o.splitbelow = true

o.ignorecase = true
o.smartcase = true

o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldtext = ""
o.foldlevelstart = 99
