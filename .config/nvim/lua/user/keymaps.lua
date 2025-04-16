-- Set leader and local leader to space
vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Toggle Show Whitespace
if vim.g.vscode then
    vim.keymap.set("n", "<Leader>ts", "<Cmd>lua require('vscode').action('editor.action.toggleRenderWhitespace')<CR>")
else
    vim.keymap.set("n", "<Leader>ts", "<Cmd>set list! list?<CR>")
end

-- Toggle Tabs
vim.keymap.set("n", "<Leader>tt", "<Cmd>set expandtab! expandtab?<CR>")

-- Toggle explorer
if vim.g.vscode then
    vim.keymap.set("n", "<Leader>e", "<Cmd>lua require('vscode').action('workbench.view.explorer')<CR>")
else
    vim.keymap.set("n", "<Leader>e", "<Cmd>Lexplore 30<CR>")
end

-- Press Space twice to turn off highlighting and clear any message already displayed.
vim.keymap.set("n", "<Leader><Leader>", "<Cmd>nohlsearch<CR><Cmd>echo<CR>", { silent = true })

-- Toggle Highlighting, and show current value.
vim.keymap.set("n", "<Leader>th", "<Cmd>set hlsearch! hlsearch?<CR>")

-- Toggle Ignorecase
vim.keymap.set("n", "<Leader>ti", "<Cmd>set ignorecase! ignorecase?<CR>")

-- Highlight all occurrences of the current word.
vim.keymap.set("n", "<Leader>H", ":let @/='\\<<C-R>=expand(\"<cword>\")<CR>\\>'<CR>:set hls<CR>")

-- Easier window navigation
vim.keymap.set("n", "<C-H>", "<C-W>h", { remap = vim.g.vscode })
vim.keymap.set("n", "<C-J>", "<C-W>j", { remap = vim.g.vscode })
vim.keymap.set("n", "<C-K>", "<C-W>k", { remap = vim.g.vscode })
vim.keymap.set("n", "<C-L>", "<C-W>l", { remap = vim.g.vscode })

-- Move current line/selection up/down using Alt-k/j
vim.keymap.set({ "n", "i" }, "<A-k>", "<Cmd>m -2<CR>")
vim.keymap.set({ "n", "i" }, "<A-j>", "<Cmd>m +<CR>")
vim.keymap.set("x", "<A-k>", ":m '<-2<CR>gv")
vim.keymap.set("x", "<A-j>", ":m '>+<CR>gv")

-- Mappings for sourcing the current file or running the current or highlighted Lua lines.
-- These are originally from the suggestions in TJ DeVries' video:
-- [Everything You Need To Start Writing Lua](https://youtu.be/CuWfgiwI73Q?si=9VGWKluwNvZtkfvl)
vim.keymap.set("n", "<Leader>sf", "<Cmd>source %<CR>")
vim.keymap.set("n", "<Leader>x", "<Cmd>.lua<CR>")
vim.keymap.set("v", "<Leader>x", ":lua<CR>")

-- Open the previous buffer in a vertical split
vim.keymap.set("n", "<Leader>op", "<Cmd>vsplit #<CR>")
