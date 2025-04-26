return {
	'nvim-tree/nvim-tree.lua',
	enabled = true,
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	config = function()
		require('nvim-tree').setup()
		vim.keymap.set('n', '<Leader>E', '<Cmd>NvimTreeToggle<CR>')
	end
}
