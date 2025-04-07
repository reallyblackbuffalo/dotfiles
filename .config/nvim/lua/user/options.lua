-- Tab Settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Backup Settings
vim.opt.backup = true
vim.opt.backupdir = vim.fn.stdpath('data') .. "/backup//"

-- Other Settings
vim.opt.showmatch = true
vim.opt.number = true
vim.opt.listchars = { tab = ">-", space = "·" }
