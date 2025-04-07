-- Set leader and local leader to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Toggle Show Whitespace
vim.keymap.set("n", "<Leader>ts", ":set list! list?<CR>")

-- Toggle Tabs
vim.keymap.set("n", "<Leader>tt", ":set expandtab! expandtab?<CR>")

-- Toggle explorer
vim.keymap.set("n", "<Leader>e", ":Lexplore 15<CR>")

-- Press Space twice to turn off highlighting and clear any message already displayed.
vim.keymap.set("n", "<Leader><Leader>", ":nohlsearch<Bar>:echo<CR>", { silent = true })

-- Toggle Highlighting, and show current value.
vim.keymap.set("n", "<Leader>th", ":set hlsearch! hlsearch?<CR>")

-- Toggle Ignorecase
vim.keymap.set("n", "<Leader>ti", ":set ignorecase! ignorecase?<CR")

-- Highlight all occurrences of the current word.
vim.keymap.set("n", "<Leader>H", ":let @/='\\<<C-R>=expand(\"<cword>\")<CR>\\>'<CR>:set hls<CR>")

-- Easier window navigation
vim.keymap.set("n", "<C-H>", "<C-W>h")
vim.keymap.set("n", "<C-J>", "<C-W>j")
vim.keymap.set("n", "<C-K>", "<C-W>k")
vim.keymap.set("n", "<C-L>", "<C-W>l")

-- Move current line/selection up/down using Alt-k/j
vim.keymap.set("n", "<A-k>", ":m -2<CR>")
vim.keymap.set("n", "<A-j>", ":m +<CR>")
vim.keymap.set("i", "<A-k>", "<ESC>:m -2<CR>gi")
vim.keymap.set("i", "<A-j>", "<ESC>:m +<CR>gi")
vim.keymap.set("x", "<A-k>", ":m '<-2<CR>gv")
vim.keymap.set("x", "<A-j>", ":m '>+<CR>gv")

-- Mappings for sourcing the current file or running the current or highlighted Lua lines.
-- These are originally from the suggestions in TJ DeVries' video:
-- [Everything You Need To Start Writing Lua](https://youtu.be/CuWfgiwI73Q?si=9VGWKluwNvZtkfvl)
vim.keymap.set("n", "<Leader>sf", "<cmd>source %<CR>")
vim.keymap.set("n", "<Leader>x", ":.lua<CR>")
vim.keymap.set("v", "<Leader>x", ":lua<CR>")
