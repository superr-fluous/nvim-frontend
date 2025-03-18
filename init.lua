require("config.lazy")

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.bo.softtabstop = 2

-- autoformat on save
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp", { clear = true }),
  callback = function(args)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = args.buf,
      callback = function()
        vim.lsp.buf.format({ async = false, id = args.data.client_id })
      end,
    })
  end,
})

-- flexoki theme
vim.cmd("colorscheme flexoki-dark")

-- telescope
local telescope_builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-o>", telescope_builtin.find_files, {})
vim.keymap.set("n", "<C-p>", telescope_builtin.live_grep, {})

-- neo-tree
vim.keymap.set("n", "<C-f>", ":Neotree filesystem reveal left<CR>", {})

-- lspconfig
vim.keymap.set("n", "I", vim.lsp.buf.hover, {})
vim.keymap.set("n", "D", vim.lsp.buf.definition, {})
vim.keymap.set("n", "A", vim.lsp.buf.code_action, {})
vim.keymap.set("n", "<C-s>", ":write<CR>", { noremap = true })
vim.keymap.set("i", "<C-s>", "<Esc>:write<CR>", { noremap = true })

-- nvim-ufo
vim.o.foldcolumn = "1" -- '0' is not bad
vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
-- "za" to toggle fold at cursor
vim.keymap.set("n", "fu", require("ufo").openAllFolds)
vim.keymap.set("n", "ff", require("ufo").closeAllFolds)
