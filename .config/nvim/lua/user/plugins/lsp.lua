return {
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"lua_ls@3.16.4",
				"ts_ls",
			},
		},
		dependencies = {
			{ "mason-org/mason.nvim", config = true },
			"neovim/nvim-lspconfig",
		}
	},
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		}
	},
}
