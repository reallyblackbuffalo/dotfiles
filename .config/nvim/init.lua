require "user.options"
require "user.keymaps"
require "user.autocommands"
if not vim.g.vscode then
    require "user.lazy"
end
