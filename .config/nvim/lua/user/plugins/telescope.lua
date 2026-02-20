return {
	{
		'nvim-telescope/telescope.nvim', tag = '0.1.8',
		enabled = true,
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope-fzy-native.nvim'
		},
		config = function()
			require("telescope").setup({
				defaults = {
					file_ignore_patterns = { ".git" },
				}
			})
			require("telescope").load_extension("fzy_native")
			vim.keymap.set("n", "<Leader>ff", require('telescope.builtin').find_files)
			vim.keymap.set("n", "<Leader>en", function()
				require('telescope.builtin').find_files {
					cwd = vim.loop.fs_realpath(vim.fn.stdpath("config"))
				}
			end)
			vim.keymap.set("n", "<Leader>ed", function()
				require('telescope.builtin').find_files {
					cwd = vim.fn.expand('$HOME') .. '/.dotfiles'
				}
			end)
			vim.keymap.set("n", "<Leader>fb", require('telescope.builtin').buffers)
			vim.keymap.set("n", "<Leader>fh", require('telescope.builtin').help_tags)
		end
	}
}
