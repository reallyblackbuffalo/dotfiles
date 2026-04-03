return {
	{
		'stevearc/oil.nvim',
		enabled = true,
		config = function()
			require('oil').setup({
				view_options = {
					show_hidden = true,
				}
			})
			vim.keymap.set("n", "<Leader>-", "<Cmd>Oil<CR>")
		end
	}
}
