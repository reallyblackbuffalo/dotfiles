return {
	{
		"neovim/nvim-lspconfig",
		enabled = true,
		config = function()
			vim.lsp.enable("lua_ls")
		end,
	}
}
