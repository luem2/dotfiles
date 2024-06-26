return {
	-- snippets
	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = "make install_jsregexp",
		dependencies = { "rafamadriz/friendly-snippets" },
	},

	-- vscode like snippets
	{
		"rafamadriz/friendly-snippets",
	},

	-- codeium
	{
		"Exafunction/codeium.vim",
		event = "BufEnter",
		config = function()
			-- disable default keymaps from command line
			vim.g.codeium_disable_bindings = 1

			vim.keymap.set("i", "<C-l>", function()
				return vim.fn["codeium#Accept"]()
			end, { expr = true, silent = true })

			vim.keymap.set("i", "<C-Z>", function()
				return vim.fn["codeium#Clear"]()
			end, { expr = true, silent = true })

			vim.keymap.set("i", "<C-X>", function()
				return vim.fn["codeium#Complete"]()
			end, { expr = true, silent = true })
		end,
	},
}
