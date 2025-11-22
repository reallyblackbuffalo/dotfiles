return {
	{
		"folke/tokyonight.nvim",
		enabled = true,
		config = function()
			vim.api.nvim_create_autocmd("UIEnter", {
				callback = function()
					vim.schedule(function()
						if vim.o.termguicolors then
							vim.cmd.colorscheme "tokyonight-night"
						end
					end)
				end
		})
		end
	}
}
