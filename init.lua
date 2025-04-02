vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.bo.softtabstop = 2
vim.g.mapleader = "<Space>"

-- turns off timeout for <leader> and removes default behaviour for <Space> in visual mode (i.e. advance one char)
vim.opt.ttimeout = false
vim.opt.timeout = false
vim.api.nvim_set_keymap("n", "<Space>", "<Nop>", { noremap = true, silent = true })

require("config.lazy")
require("todo-comments").setup()

local ufo = require("ufo")

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
vim.keymap.set("n", "fu", ufo.openAllFolds)
vim.keymap.set("n", "ff", ufo.closeAllFolds)

-- todo-cmments (https://github.com/folke/todo-comments.nvim)
-- NOTE: td - search; td<Left> - prev comment; td<Right> - next comment
-- NOTE: :TodoTelescope - search for comments (cwd - specify dir, keywords - keywords)
-- NOTE  :TodoQuickFix - list of all comments
-- NOTE: :TodoLocList - uses location list to show comments
-- NOTE: :Trouble todo - list all projects TODOs in trouble
vim.keymap.set("n", "td<Right>", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "td<Left>", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

-- gitsigns (https://github.com/lewis6991/gitsigns.nvim)
local gitsigns = require("gitsigns")
gitsigns.setup({
  on_attach = function(buf_nr)
    vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk_inline, { noremap = true })

    -- HUNK
    -- NOTE: When in diff mode ~Ctrl+S~ (for "go down") to view next hunk and ~Ctrl+W~ (for "go up") to view prev hunk
    vim.keymap.set("n", "<C-s>", function()
      if vim.wo.diff then
        vim.cmd.normal({ "<C-s>", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end)

    vim.keymap.set("n", "<C-w>", function()
      if vim.wo.diff then
        vim.cmd.normal({ "<C-w>", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end)

    -- HUNK: actions
    -- not really using hunk
    -- NOTE: ~Space+h+p~ (for hunk preview) to show preview
    -- NOTE: ~Space+h+p+i~ (for hunk preview inline) to show inline preview
    vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk)
    vim.keymap.set("n", "<leader>hpi", gitsigns.preview_hunk_inline)

    -- View Text Object in gitsigns readme
    -- vim.keymap.set({ "o", "x" }, "ih", gitsigns.select_hunk)

    -- vim.keymap.set("n", "", gitsigns.reset_hunk)
    -- vim.keymap.set("n", "", gitsigns.stage_hunk)

    --  vim.keymap.set("v", "", function()
    --    gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    --  end)

    --  vim.keymap.set("v", "", function()
    --    gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    --  end)

    -- BUFFER: actions
    -- not really using buffer
    -- vim.keymap.set("n", "", gitsigns.stage_buffer)
    -- vim.keymap.set("n", "", gitsigns.reset_buffer)

    -- BLAME: actions
    -- NOTE: ~Space+g+b~ (for "git blame") to open git blame sidebar
    -- NOTE: ~Space+g+b~ (for "git blame inline") to git blame for the line (not needed though for current config since it's auto appearing)
    vim.keymap.set("n", "<leader>gb", function()
      gitsigns.blame_line({ full = true })
    end)
    vim.keymap.set("n", "<leader>gbi", gitsigns.toggle_current_line_blame)

    -- DIFF: actions
    -- NOTE: ~Space+g+d~ (for "git diff") to open diff for current file
    -- NOTE ~Space+g+d+a~ (for "git diff all") to open diff for all files?
    -- NOTE ~Space+g+d+w~ (for "git diff word") to open word diff for file
    vim.keymap.set("n", "<leader>gd", gitsigns.diffthis)
    vim.keymap.set("n", "<leader>gda", function()
      -- FIX: currently not working - (fatal: path '../..' exists on disk, but not in 'HEAD~') because of wrong slashes ('/' instead of '\' on Windows)
      gitsigns.diffthis("~")
    end)
    vim.keymap.set("n", "<leader>gdw", gitsigns.toggle_word_diff)

    -- Quickfix/Location list
    -- NOTE: ~Space+g+q~ (for "git quickfix") to show quickfix for current file?
    -- NOTE: ~Space+g+q+a~ (for "git quicfix all") to show quickfix for all files?
    vim.keymap.set("n", "<leader>gq", gitsigns.setqflist)
    vim.keymap.set("n", "<leader>gqa", function()
      gitsigns.setqflist("all")
    end)

    -- DELETED: actions
    -- NOTE: ~Space+g+d+e~ (for "git DEleted") to show deleted
    -- TODO: Better keymap?
    vim.keymap.set("n", "<leader>gde", gitsigns.toggle_deleted)
  end,
})
