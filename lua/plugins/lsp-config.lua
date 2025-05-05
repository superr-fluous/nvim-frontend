return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"ts_ls",
					"html",
					"astro",
					"tailwindcss",
				},
			})

			require("mason-lspconfig").setup_handlers({
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
						on_attach = function()
							print(server_name .. " LSP attached ✅")
						end,
					})
				end,
			})
		end,
	},
}
