-- VSCode-specific customizations to keymaps

-- Toggle Show Whitespace
-- The list option from Neovim isn't currently synced with VSCode's corresponding
-- setting in the vscode-neovim extension, so I need to remap it here to toggle
-- the right setting for me.
vim.keymap.set("n", "<Leader>ts", "<Cmd>lua require('vscode').action('editor.action.toggleRenderWhitespace')<CR>")

-- Easier window navigation
-- Need to remap these with recursive mapping enabled so that the special mappings
-- the vscode-neovim extension sets up for the window commands take effect.
vim.keymap.set("n", "<C-H>", "<C-W>h", { remap = true })
vim.keymap.set("n", "<C-J>", "<C-W>j", { remap = true })
vim.keymap.set("n", "<C-K>", "<C-W>k", { remap = true })
vim.keymap.set("n", "<C-L>", "<C-W>l", { remap = true })

-- Toggle the sidebar
vim.keymap.set("n", "<Leader>b", "<Cmd>lua require('vscode').action('workbench.action.toggleSidebarVisibility')<CR>")

-- Toggle file explorer focus
-- Use VSCode's builtin file explorer rather than trying to use netrw, which opens
-- in a separate tab due to it being a new buffer.
vim.keymap.set("n", "<Leader>e", "<Cmd>lua require('vscode').action('workbench.view.explorer')<CR>")

-- Toggle search in sidebar
vim.keymap.set("n", "<Leader>F", "<Cmd>lua require('vscode').action('workbench.view.search')<CR>")

-- Toggle Git/Source Control in sidebar
vim.keymap.set("n", "<Leader>g", "<Cmd>lua require('vscode').action('workbench.view.scm')<CR>")

-- Find Files (like telescope, but using VSCode's quick open file picker)
vim.keymap.set("n", "<Leader>ff", "<Cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>")

-- Open the Command Palette
vim.keymap.set("n", "<Leader>p", "<Cmd>lua require('vscode').action('workbench.action.showCommands')<CR>")

-- Toggle the panel (for the terminal, etc)
vim.keymap.set("n", "<Leader>j", "<Cmd>lua require('vscode').action('workbench.action.togglePanel')<CR>")

-- Open keyboard shortcuts
vim.keymap.set("n", "<Leader>ks", "<Cmd>lua require('vscode').action('workbench.action.openGlobalKeybindings')<CR>")