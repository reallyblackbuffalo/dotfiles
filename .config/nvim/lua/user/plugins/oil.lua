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
		end
	}
}
