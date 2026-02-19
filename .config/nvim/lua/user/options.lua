-- Tab Settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Use the clipboard for yanks and puts
vim.opt.clipboard = "unnamedplus"

-- Backup Settings
vim.opt.backup = true
vim.opt.backupdir = vim.fn.stdpath('data') .. "/backup//"

-- Always split to the right
vim.opt.splitright = true

-- Other Settings
vim.opt.showmatch = true
vim.opt.number = true
vim.opt.listchars = { tab = ">-", space = "·" }
