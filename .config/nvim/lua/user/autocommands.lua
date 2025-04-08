-- When editing a file, always jump to the last known cursor position.
-- Don't do it when the position is invalid or when inside an event handler.
-- Also don't do it when the mark is in the first line, that is the default
-- position when opening a file.
vim.api.nvim_create_autocmd("BufReadPost", {
	desc = "Jump to last known cursor position",
	group = vim.api.nvim_create_augroup("last-cursor-pos", { clear = true }),
	callback = function()
		local current_line = vim.fn.line([['"]])
		local last_line = vim.fn.line("$")
		local buffer_name = vim.api.nvim_buf_get_name(0)
		if not buffer_name:match("COMMIT_EDITMSG") and current_line > 1 and current_line <= last_line then
			vim.cmd([[normal! g`"]])
		end
	end,
})

-- Helper function for setting buffer-local keymaps
local local_keymap = function(mode, lhs, rhs)
	vim.keymap.set(mode, lhs, rhs, { buffer = true })
end

-- Autocommands to set mappings to comment out the current line in different languages.
-- Might end up moving these to files in after/ftplugin.
local comment_keymap = function(comment_chars)
	local lhs = "<LocalLeader>c"
	local normal_rhs = "I" .. comment_chars .. "<esc>"
	local_keymap("n", lhs, normal_rhs)
	local_keymap("v", lhs, ":normal " .. normal_rhs)
end
local comment_mappings_group = vim.api.nvim_create_augroup("filetype_comment_mappings", { clear = true })
local register_comment_keymap = function(filetypes, comment_chars)
	vim.api.nvim_create_autocmd("Filetype", {
		pattern = filetypes,
		desc = "Set local keymaps for commenting lines in " .. table.concat(filetypes, ", ") .. " files.",
		group = comment_mappings_group,
		callback = function ()
			comment_keymap(comment_chars)
		end,
	})
end
register_comment_keymap({ "javascript", "c", "cpp", "java" }, "//")
register_comment_keymap({ "python" }, "#")
register_comment_keymap({ "vim" }, '"')
register_comment_keymap({ "lua" }, "--")

-- Autocommand to set mapping for folding the current tag in an html file.
vim.api.nvim_create_autocmd("Filetype", {
	pattern = { "html" },
	desc = "Set local keymap for folding the current tag in html files.",
	group = vim.api.nvim_create_augroup("filetype_html", { clear = true }),
	callback = function()
		local_keymap("n", "<LocalLeader>f", "Vatzf")
	end,
})
