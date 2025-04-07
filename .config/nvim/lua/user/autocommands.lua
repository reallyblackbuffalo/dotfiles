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
