return {
	"nvimtools/none-ls.nvim",
	dependencies = { "nvimtools/none-ls-extras.nvim" },
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua.with({ filetypes = { "lua" } }),
				null_ls.builtins.formatting.prettier.with({
					-- https://github.com/MunifTanjim/prettier.nvim
					bin = "prettierd",
					filetypes = {
						"javascript",
						"typescript",
						"javascriptreact",
						"typescriptreact",
						"css",
						"html",
						"markdown",
						"json",
						"less",
						"css",
						"scss",
					},
					cli_options = {
						config_precedence = "prefer-file",
						tab_width = 2,
						trailing_comma = "es5",
						use_tabs = true,
						print_width = 120,
					},
				}),
				require("none-ls.diagnostics.eslint_d"),
				require("none-ls.formatting.eslint_d"),
			},
		})
	end,
}
