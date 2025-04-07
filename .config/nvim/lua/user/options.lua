-- Tab Settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Backup Settings
vim.opt.backup = true
vim.opt.backupdir = vim.fn.stdpath('data') .. "/backup//"

-- Always split below/to the right
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Other Settings
vim.opt.showmatch = true
vim.opt.number = true
vim.opt.listchars = { tab = ">-", space = "·" }
