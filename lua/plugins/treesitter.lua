return {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        main = "nvim-treesitter.configs",
        opts = {
                ensure_instsalled = { "lua", "javascript", "typescript", "html", "css", "go" },
                highlight = { enable = true },
                indent = { enable = true },
                auto_install = { enable = true },
        }
}
