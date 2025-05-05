return {
	{
		"catgoose/nvim-colorizer.lua",
		event = "BufReadPre",
		config = function()
			require("colorizer").setup({
				filetypes = { "css", "html", "astro", "javascript", "typescript" },
				user_default_options = {
					tailwind = true,
				},
			})
		end,
	},
}
