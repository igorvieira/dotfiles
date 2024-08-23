require("nvim-treesitter.configs").setup({
	auto_install = true,
	ensure_installed = {
		"c",
		"lua",
		"python",
		"rust",
		"javascript",
		"typescript",
		"tsx",
		"markdown",
		"markdown_inline",
		"html",
		"css",
		"json",
		"bash",
	},
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true,
	},
	-- windwp/nvim-ts-autotag
	autotag = {
		enable = true,
	},
})
