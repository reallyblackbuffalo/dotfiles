return {
	{
		"obsidian-nvim/obsidian.nvim",
		enabled = true,
		version = "*", -- use latest release
		--@module 'obsidian'
		--@type obsidian.config
		opts = {
			legacy_commands = false,
			workspaces = {
				{
					name = "ObsidianVault",
					path = "~/Documents/ObsidianVault",
					overrides = {
						daily_notes = {
							folder = "daily",
						},
					},
				},
			},
			ui = { enable = false },
		},
	}
}
