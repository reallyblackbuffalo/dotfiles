-- VSCode-specific customizations to keymaps

local vscode = require('vscode')

-- Determine the correct path for the keybindings.json file based on the operating system
local function get_keybindings_file_path()
    local home = vim.fn.expand("$HOME")
    if vim.fn.has("win32") == 1 then
        return home .. "\\AppData\\Roaming\\Code\\User\\keybindings.json"
    elseif vim.fn.has("macunix") == 1 then
        return home .. "/Library/Application Support/Code/User/keybindings.json"
    else
        return home .. "/.config/Code/User/keybindings.json"
    end
end

-- Path to the keybindings.json file
local keybindings_file = get_keybindings_file_path()

-- Table to store keybindings to be written to the JSON file
local custom_keybindings = {}

-- Helper function to build the key string for passthrough keybindings
local function build_key_string(lhs)
    local leader_key = vim.g.vscode_leader_key or error("build_key_string: VSCode leader key string not set")

    -- Ensure <Leader>, if present, is at the start of lhs
    if lhs:find("<Leader>") and not lhs:find("^<Leader>") then
        error("build_key_string: <Leader> must only appear at the start of lhs if present")
    end

    -- Throw an error if lhs contains spaces
    if lhs:find("%s") then
        error("build_key_string: lhs must not contain spaces")
    end

    -- Handle special cases like <C-h> or <A-j>
    local special_key = lhs:match("^<[CA]%-.+>$")
    if special_key then
        local modifiers, key = special_key:match("^<([CA])%-(.+)>$")
        if modifiers:find("C") then
            return "ctrl+" .. key:lower()
        elseif modifiers:find("A") then
            return "alt+" .. key:lower()
        end
    end

    local key_parts = {}

    -- Replace <Leader> with the leader key representation if it exists at the start
    local processed_lhs = lhs:gsub("^<Leader>", "")
    if lhs:find("^<Leader>") then
        table.insert(key_parts, leader_key) -- Add the leader key representation first
    end

    -- Process the remaining characters in the lhs
    for char in processed_lhs:gmatch(".") do
        if char:match("%u") then
            table.insert(key_parts, "shift+" .. char:lower()) -- Add "shift+" for uppercase letters
        else
            table.insert(key_parts, char) -- Add the character as-is
        end
    end

    return table.concat(key_parts, " ") -- Join parts with spaces
end

-- Helper function to define a general keybinding
local function define_keybinding(key, command, when_clause, args)
    local common_conditions = "custom-neovim-keybinding"
    local full_when_clause = common_conditions
    if when_clause and when_clause ~= "" then
        full_when_clause = full_when_clause .. " && " .. when_clause
    end
    
    -- Construct the keybinding and add it to the table
    table.insert(custom_keybindings, {
        key = key,
        command = command,
        when = full_when_clause,
        args = args,
    })
end

-- Helper function to define a passthrough keybinding
local function define_passthrough_keybinding(lhs, when_clause)
    local common_conditions = "neovim.init"
    local full_when_clause = common_conditions
    if when_clause and when_clause ~= "" then
        full_when_clause = full_when_clause .. " && " .. when_clause
    end

    -- Define the passthrough keybinding
    define_keybinding(build_key_string(lhs), "vscode-neovim.send", full_when_clause, lhs:gsub("<Leader>", vim.fn.keytrans(vim.g.mapleader)))
end

-- Function to write keybindings to the JSON file
local function write_keybindings_to_file()
    vscode.eval([[
        const fs = require('fs');
        const filePath = args.filePath;
        const newKeybindings = args.newKeybindings;

        // Read the existing keybindings.json file
        let keybindings = [];
        
        if (fs.existsSync(filePath)) {
            try {
                const content = fs.readFileSync(filePath, 'utf8');
                
                // Remove comments before parsing as JSON
                const jsonContent = content.replace(/\s*\/\/.*|\s*\/\*[\s\S]*?\*\//g, '');
                
                keybindings = JSON.parse(jsonContent);
                
                // Handle parsing errors
                if (!Array.isArray(keybindings)) {
                    console.error('keybindings.json does not contain an array');
                    throw new Error('keybindings.json does not contain an array');
                }
            } catch (e) {
                console.error('Failed to parse keybindings.json:', e);
                vscode.window.showErrorMessage('Failed to parse keybindings.json. No changes were made.');
                return;
            }
        }

        // Remove all keybindings with the "custom-neovim-keybinding" clause in the "when" condition
        keybindings = keybindings.filter(kb => !kb.when || !kb.when.includes('custom-neovim-keybinding'));

        // Add the new keybindings
        keybindings.push(...newKeybindings);

        // Write the updated keybindings back to the file
        fs.writeFileSync(filePath, JSON.stringify(keybindings, null, 4));

        // Set the custom-neovim-keybinding context in VSCode
        vscode.commands.executeCommand('setContext', 'custom-neovim-keybinding', true);
    ]], { args = { filePath = keybindings_file, newKeybindings = custom_keybindings } })
end

-- Function to define key mapping and add a corresponding passthrough keybinding for VSCode.
local function define_keymap_with_passthrough(mode, lhs, rhs, when_clause, opts)
    -- Set the keymap in Neovim
    vim.keymap.set(mode, lhs, rhs, opts or {})

    -- Define the corresponding passthrough keybinding
    define_passthrough_keybinding(lhs, when_clause)
end

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

-- Passthroughs for Alt-k/j to move lines up/down
-- The keymaps are already set up and don't need to be different when using VSCode, but we do need to add the passthroughs
-- to make them work in VSCode.
define_passthrough_keybinding("<A-k>", "neovim.init && editorTextFocus")
define_passthrough_keybinding("<A-j>", "neovim.init && editorTextFocus")

-- Easier window navigation
-- Need to remap these with recursive mapping enabled so that the special mappings
-- the vscode-neovim extension sets up for the window commands take effect.
define_keymap_with_passthrough("n", "<C-h>", "<C-W>h", "neovim.mode == 'normal' && !editorTextFocus", { remap = true })
define_keymap_with_passthrough("n", "<C-j>", "<C-W>j", "neovim.mode == 'normal' && !editorTextFocus", { remap = true })
define_keymap_with_passthrough("n", "<C-k>", "<C-W>k", "neovim.mode == 'normal' && !editorTextFocus", { remap = true })
define_keymap_with_passthrough("n", "<C-l>", "<C-W>l", "neovim.mode == 'normal' && !editorTextFocus", { remap = true })

-- Toggle the sidebar
define_keymap_with_passthrough("n", "<Leader>b", vscode_action_rhs("workbench.action.toggleSidebarVisibility"), "neovim.mode == 'normal' && !editorFocus && !inputFocus")

-- Toggle file explorer focus
-- Use VSCode's builtin file explorer rather than trying to use netrw, which opens
-- in a separate tab due to it being a new buffer.
define_keymap_with_passthrough("n", "<Leader>E", vscode_action_rhs("workbench.view.explorer"), "neovim.mode == 'normal' && !editorFocus && !inputFocus")

-- Toggle search in sidebar
define_keymap_with_passthrough("n", "<Leader>F", vscode_action_rhs("workbench.view.search"), "neovim.mode == 'normal' && !editorFocus && !inputFocus")

-- Toggle Git/Source Control in sidebar
define_keymap_with_passthrough("n", "<Leader>g", vscode_action_rhs("workbench.view.scm"), "neovim.mode == 'normal' && !editorFocus && !inputFocus")

-- Find Files (like telescope, but using VSCode's quick open file picker)
define_keymap_with_passthrough("n", "<Leader>ff", vscode_action_rhs("workbench.action.quickOpen"), "neovim.mode == 'normal' && !editorFocus && !inputFocus")

-- Open the Command Palette
define_keymap_with_passthrough("n", "<Leader>p", vscode_action_rhs("workbench.action.showCommands"), "neovim.mode == 'normal' && !editorFocus && !inputFocus")

-- Toggle the panel (for the terminal, etc)
define_keymap_with_passthrough("n", "<Leader>j", vscode_action_rhs("workbench.action.togglePanel"), "neovim.mode == 'normal' && !editorFocus && !inputFocus")

-- Open keyboard shortcuts
define_keymap_with_passthrough("n", "<Leader>ks", vscode_action_rhs("workbench.action.openGlobalKeybindings"), "neovim.mode == 'normal' && !inKeyBindings && !editorFocus && !inputFocus")

-- Helper function for opening the given folder in a new window.
-- Returns a function that can be passed to a keymap that when called opens the given folder in a new VSCode window.
local open_folder_rhs = function(folder)
    return function()
        local uri = vscode.eval('return vscode.Uri.file(args.path)', { args = { path = folder} })
        vscode.action('vscode.openFolder', { args = { uri, { forceNewWindow = true }}})
    end
end

-- Open Neovim config
define_keymap_with_passthrough("n", "<Leader>en", open_folder_rhs(vim.fn.stdpath('config')), "neovim.mode == 'normal' && !editorFocus && !inputFocus")

-- Open dotfiles config
define_keymap_with_passthrough("n", "<Leader>ed", open_folder_rhs(vim.fn.expand('$HOME') .. '/.dotfiles'), "neovim.mode == 'normal' && !editorFocus && !inputFocus")

-- Close the current VSCode window.
define_keymap_with_passthrough("n", "<Leader>W", vscode_action_rhs("workbench.action.closeWindow"), "neovim.mode == 'normal' && !editorFocus && !inputFocus")

-- Keybindings editor navigation
define_keybinding("escape", "keybindings.editor.focusKeybindings", "neovim.init && inKeybindings && inKeybindingsSearch")
define_keybinding("i", "keybindings.editor.searchKeybindings", "neovim.init && inKeybindings && !inputFocus")
define_keybinding("escape", "workbench.action.closeActiveEditor", "neovim.init && inKeybindings && !inputFocus")

-- Panel navigation
define_keybinding("tab", "workbench.action.nextPanelView", "panelFocus")
define_keybinding("shift+tab", "workbench.action.previousPanelView", "panelFocus")

-- Write all keybindings to the JSON file at the end
write_keybindings_to_file()
