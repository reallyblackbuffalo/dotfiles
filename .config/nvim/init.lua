require "user.options"
require "user.keymaps"
require "user.autocommands"
if vim.g.vscode then
    -- Don't load plugins/plugin manager when in VSCode. Most of the things we need
    -- plugins for VSCode has support for natively, and a lot of the plugins that
    -- try to do visual things end up getting in the way when they don't work.
    -- Also include the VSCode-specific keymaps.
    require "user.vscode-keymaps"
else
    -- Load the plugin manager (which will load all the plugins)
    require "user.plugin-manager"
end
