-- VSCode-specific customizations to keymaps

-- Helper function to make it easier to call VSCode actions from keymaps.
-- Returns a function that can be passed to the keymap that when called executes the given action in VSCode.
callVscodeActionHelper = function(action)
    return function() require('vscode').action(action) end
end

-- Toggle Show Whitespace
-- The list option from Neovim isn't currently synced with VSCode's corresponding
-- setting in the vscode-neovim extension, so I need to remap it here to toggle
-- the right setting for me.
vim.keymap.set("n", "<Leader>ts", callVscodeActionHelper('editor.action.toggleRenderWhitespace'))

-- Easier window navigation
-- Need to remap these with recursive mapping enabled so that the special mappings
-- the vscode-neovim extension sets up for the window commands take effect.
vim.keymap.set("n", "<C-H>", "<C-W>h", { remap = true })
vim.keymap.set("n", "<C-J>", "<C-W>j", { remap = true })
vim.keymap.set("n", "<C-K>", "<C-W>k", { remap = true })
vim.keymap.set("n", "<C-L>", "<C-W>l", { remap = true })

-- Toggle the sidebar
vim.keymap.set("n", "<Leader>b", callVscodeActionHelper('workbench.action.toggleSidebarVisibility'))

-- Toggle file explorer focus
-- Use VSCode's builtin file explorer rather than trying to use netrw, which opens
-- in a separate tab due to it being a new buffer.
vim.keymap.set("n", "<Leader>E", callVscodeActionHelper('workbench.view.explorer'))

-- Toggle search in sidebar
vim.keymap.set("n", "<Leader>F", callVscodeActionHelper('workbench.view.search'))

-- Toggle Git/Source Control in sidebar
vim.keymap.set("n", "<Leader>g", callVscodeActionHelper('workbench.view.scm'))

-- Find Files (like telescope, but using VSCode's quick open file picker)
vim.keymap.set("n", "<Leader>ff", callVscodeActionHelper('workbench.action.quickOpen'))

-- Open the Command Palette
vim.keymap.set("n", "<Leader>p", callVscodeActionHelper('workbench.action.showCommands'))

-- Toggle the panel (for the terminal, etc)
vim.keymap.set("n", "<Leader>j", callVscodeActionHelper('workbench.action.togglePanel'))

-- Open keyboard shortcuts
vim.keymap.set("n", "<Leader>ks", callVscodeActionHelper('workbench.action.openGlobalKeybindings'))

-- Helper function for opening the given folder in a new window unless it is already open in the current window.
open_folder = function(folderToOpen)
    local vscode = require('vscode')
    local already_open = vscode.eval([[
        const fs = require("fs");
        const pathToOpen = fs.realpathSync(args.folderToOpen);
        const currentPath = fs.realpathSync(vscode.workspace.workspaceFolders[0].uri.fsPath);
        return pathToOpen === currentPath;
    ]], { args = { folderToOpen = folderToOpen }})

    if not already_open then
        local uri = vscode.eval('return vscode.Uri.file(args.path)', { args = { path = folderToOpen } })
        vscode.action('vscode.openFolder', { args = { uri, { forceNewWindow = true }}})
    else
        print(foldertoopen .. "is already open")
    end
end

-- Open Neovim config
vim.keymap.set("n", "<Leader>en", function() open_folder(vim.fn.stdpath('config')) end)

-- Open dotfiles config
vim.keymap.set("n", "<Leader>ed", function() open_folder(vim.fn.expand('$HOME') .. '/.dotfiles') end)