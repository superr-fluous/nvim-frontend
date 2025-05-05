return {
	{
		"rcarriga/nvim-notify",
		config = function()
			require("notify").setup({
				render = "compact",
				stages = "slide", -- or "slide"
				timeout = 15000, -- 15 seconds
				background_colour = "transparent",
			})
			vim.notify = require("notify") -- replace built-in notify
		end,
	},
}
