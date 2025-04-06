vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.bo.softtabstop = 2
vim.g.mapleader = "<Space>"

-- turns off timeout for <leader> and removes default behaviour for <Space> in visual mode (i.e. advance one char)
vim.opt.ttimeout = false
vim.opt.timeout = false

vim.api.nvim_set_keymap("n", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Space>", " ", { noremap = true, silent = true })

require("config.lazy")
require("todo-comments").setup()

local ufo = require("ufo")
local telescope_builtin = require("telescope.builtin")

-- Keyboard Shortcuts

-- ~Alt + o~  BUG: cant detect Ctrl + Enter (switch to allacritty)
-- insert new line before and jump to it

-- NOTE: Nice idea https://www.reddit.com/r/neovim/comments/xj784v/comment/ip8051r/
-- NOTE: Theres also is https://github.com/nvim-telescope/telescope-live-grep-args.nvim but do not like the flow
-- ~CTRL + f~
-- file search
-- telescope
vim.keymap.set("n", "<C-f>", function()
  telescope_builtin.live_grep({ search_dirs = { vim.fn.expand("%:p") } }) -- shout out to https://www.reddit.com/r/neovim/comments/1b9w93g/comment/ktymegi/
end, { noremap = true })

-- ~CTRL + p~
-- project search
vim.keymap.set("n", "<C-P>", telescope_builtin.live_grep, { noremap = true })

-- ~CTRL + e~ / ~Ctrl + o~
-- lookup files
vim.keymap.set("n", "<C-e>", telescope_builtin.find_files, { noremap = true })
vim.keymap.set("n", "<C-o>", telescope_builtin.find_files, { noremap = true })

-- ~Ctrl + b~
-- Toggle neo-tree (filesystem)
vim.keymap.set("n", "<C-b>", ":Neotree filesystem toggle right<CR>", { noremap = true })

-- ~Ctrl + z~
-- undo change
vim.keymap.set("i", "<C-z>", "<Esc>:undo<CR>:startinsert<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-z>", ":undo<CR>", { noremap = true })

-- ~Ctrl + Z~
-- undo undo
-- BUG: Cant bind Ctrl + Shift + <char>  prbly Windows Terminal thing

-- ~Ctrl + s~
-- format + save
vim.keymap.set("n", "<C-s>", ":write<CR>", { noremap = true })
vim.keymap.set("i", "<C-s>", "<Esc>:write<CR>", { noremap = true })

-- ~Ctrl  + S + q~
-- format + save + exit
vim.keymap.set("n", "<C-q>", ":wq<CR>", { noremap = true })
vim.keymap.set("i", "<C-q>", "<Esc>:wq<CR>", { noremap = true })

-- ~Ctrl + ]~
-- indent current line

-- ~Ctrl + [~
-- remove single indent?

-- ~Ctrl + Delete~
-- delete current line
vim.keymap.set("n", "<C-Del>", ":d<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-Del>", "<Esc>:d<CR>:startinsert<CR>", { noremap = true, silent = true })

-- ~Ctrl + I~
-- bringup info
vim.keymap.set("n", "<C-i>", vim.lsp.buf.hover, { noremap = true })

-- ~Ctrl + D~
-- bringup definition
vim.keymap.set("n", "<C-u>", vim.lsp.buf.definition, { noremap = true })

-- ~Ctrl + .~
-- code action
vim.keymap.set("n", "<C-.>", vim.lsp.buf.code_action, { noremap = true })

-- ~Ctrl + d~
-- select word; grep and loop

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
