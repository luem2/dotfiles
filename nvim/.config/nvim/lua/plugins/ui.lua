return {
	-- https://github.com/folke/noice.nvim
	-- fix bug on hover
	{
		"folke/noice.nvim",
		opts = function(_, opts)
			table.insert(opts.routes, {
				filter = {
					event = "notify",
					find = "No information available",
				},
				opts = { skip = true },
			})

			opts.presets.lsp_doc_border = true
		end,
	},

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		opts = {
			close_if_last_window = true,
			window = {
				position = "right",
			},
			filesystem = {
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = false,
				},
			},
			event_handlers = {
				{
					event = "file_opened",
					handler = function()
						--auto close
						-- vimc.cmd("Neotree close")
						-- or
						require("neo-tree.command").execute({ action = "close" })
					end,
				},
			},
		},
	},
}
