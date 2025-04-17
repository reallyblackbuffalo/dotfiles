-- VSCode-specific customizations to keymaps

-- Toggle Show Whitespace
-- The list option from Neovim isn't currently synced with VSCode's corresponding
-- setting in the vscode-neovim extension, so I need to remap it here to toggle
-- the right setting for me.
vim.keymap.set("n", "<Leader>ts", "<Cmd>lua require('vscode').action('editor.action.toggleRenderWhitespace')<CR>")

-- Toggle file explorer
-- Use VSCode's builtin file explorer rather than trying to use netrw, which opens
-- in a separate tab due to it being a new buffer.
vim.keymap.set("n", "<Leader>e", "<Cmd>lua require('vscode').action('workbench.view.explorer')<CR>")

-- Easier window navigation
-- Need to remap these with recursive mapping enabled so that the special mappings
-- the vscode-neovim extension sets up for the window commands take effect.
vim.keymap.set("n", "<C-H>", "<C-W>h", { remap = true })
vim.keymap.set("n", "<C-J>", "<C-W>j", { remap = true })
vim.keymap.set("n", "<C-K>", "<C-W>k", { remap = true })
vim.keymap.set("n", "<C-L>", "<C-W>l", { remap = true })