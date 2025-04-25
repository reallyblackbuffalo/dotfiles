-- VSCode-specific customizations to keymaps

local vscode = require('vscode')

-- Helper function to make it easier to call VSCode actions from keymaps.
-- Returns a function that can be passed to the keymap that when called executes the given action in VSCode.
local vscode_action_rhs = function(action)
    return function() vscode.action(action) end
end

-- Toggle Show Whitespace
-- The list option from Neovim isn't currently synced with VSCode's corresponding
-- setting in the vscode-neovim extension, so I need to remap it here to toggle
-- the right setting for me.
vim.keymap.set("n", "<Leader>ts", vscode_action_rhs('editor.action.toggleRenderWhitespace'))

-- Easier window navigation
-- Need to remap these with recursive mapping enabled so that the special mappings
-- the vscode-neovim extension sets up for the window commands take effect.
vim.keymap.set("n", "<C-H>", "<C-W>h", { remap = true })
vim.keymap.set("n", "<C-J>", "<C-W>j", { remap = true })
vim.keymap.set("n", "<C-K>", "<C-W>k", { remap = true })
vim.keymap.set("n", "<C-L>", "<C-W>l", { remap = true })

-- Toggle the sidebar
vim.keymap.set("n", "<Leader>b", vscode_action_rhs('workbench.action.toggleSidebarVisibility'))

-- Toggle file explorer focus
-- Use VSCode's builtin file explorer rather than trying to use netrw, which opens
-- in a separate tab due to it being a new buffer.
vim.keymap.set("n", "<Leader>E", vscode_action_rhs('workbench.view.explorer'))

-- Toggle search in sidebar
vim.keymap.set("n", "<Leader>F", vscode_action_rhs('workbench.view.search'))

-- Toggle Git/Source Control in sidebar
vim.keymap.set("n", "<Leader>g", vscode_action_rhs('workbench.view.scm'))

-- Find Files (like telescope, but using VSCode's quick open file picker)
vim.keymap.set("n", "<Leader>ff", vscode_action_rhs('workbench.action.quickOpen'))

-- Open the Command Palette
vim.keymap.set("n", "<Leader>p", vscode_action_rhs('workbench.action.showCommands'))

-- Toggle the panel (for the terminal, etc)
vim.keymap.set("n", "<Leader>j", vscode_action_rhs('workbench.action.togglePanel'))

-- Open keyboard shortcuts
vim.keymap.set("n", "<Leader>ks", vscode_action_rhs('workbench.action.openGlobalKeybindings'))

-- Helper function for opening the given folder in a new window.
-- Returns a function that can be passed to a keymap that when called opens the given folder in a new VSCode window.
local open_folder_rhs = function(folder)
    return function()
        local uri = vscode.eval('return vscode.Uri.file(args.path)', { args = { path = folder} })
        vscode.action('vscode.openFolder', { args = { uri, { forceNewWindow = true }}})
    end
end

-- Open Neovim config
vim.keymap.set("n", "<Leader>en", open_folder_rhs(vim.fn.stdpath('config')))

-- Open dotfiles config
vim.keymap.set("n", "<Leader>ed", open_folder_rhs(vim.fn.expand('$HOME') .. '/.dotfiles'))

-- Close the current VSCode window.
vim.keymap.set("n", "<Leader>W", vscode_action_rhs('workbench.action.closeWindow'))