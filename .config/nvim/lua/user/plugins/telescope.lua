return {
	{
		'nvim-telescope/telescope.nvim', tag = '0.1.8',
		enabled = true,
		dependencies = {
			'nvim-lua/plenary.nvim',
		},
		config = function()
			require("telescope").setup({
				defaults = {
					file_ignore_patterns = { ".git" },
				}
			})

			local Path = require('plenary.path')

			-- Find Files (in the current directory)
			vim.keymap.set("n", "<Leader>ff", require('telescope.builtin').find_files)

			-- Edit Neovim (files in Neovim config)
			vim.keymap.set("n", "<Leader>en", function()
				require('telescope.builtin').find_files {
					cwd = vim.fn.stdpath("config")
				}
			end)

			-- Edit Packages (files in Neovim plugin packages installed via Lazy)
			vim.keymap.set("n", "<Leader>ep", function()
				require('telescope.builtin').find_files {
					cwd = Path:new(vim.fn.stdpath("data"), "lazy").filename
				}
			end)

			-- Edit dotfiles (files in my dotfiles repo)
			vim.keymap.set("n", "<Leader>ed", function()
				require('telescope.builtin').find_files {
					cwd = Path:new(vim.fn.expand('$HOME'), '.dotfiles').filename
				}
			end)

			-- Find Buffers
			vim.keymap.set("n", "<Leader>fb", require('telescope.builtin').buffers)

			-- Find Help
			vim.keymap.set("n", "<Leader>fh", require('telescope.builtin').help_tags)
		end
	}
}
