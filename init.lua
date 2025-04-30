vim.opt.endofline = true
vim.opt.endoffile = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.list = true

vim.wo.linebreak = false
vim.wo.number = true

vim.wo.wrap = false
vim.wo.list = false

vim.bo.softtabstop = 2
vim.g.mapleader = "<Space>"

-- turns off timeout for <leader> and removes default behaviour for <Space> in visual mode (i.e. advance one char)
vim.opt.ttimeout = true
vim.opt.timeout = true

vim.api.nvim_set_keymap("n", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Space>", " ", { noremap = true, silent = true })

require("config.lazy")
require("todo-comments").setup()

local function EnterLineVisual()
	vim.api.nvim_feedkeys("V", "n", true)
end

local function EscapeToNormal()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end

local function LineSelection()
	local mode = vim.api.nvim_get_mode().mode

	if mode == "V" then
		local j = vim.api.nvim_replace_termcodes("j", true, false, true)
		vim.api.nvim_feedkeys(j, "n", false) -- select next line
		return
	end

	if mode ~= "n" then
		EscapeToNormal()
	end

	local row = vim.api.nvim_win_get_cursor(0)[1]
	local line = vim.api.nvim_get_current_line()
	local col = #line                           -- Column is 0-based, so this is fine
	vim.api.nvim_win_set_cursor(0, { row, col }) -- move cursor to the end of line
	EnterLineVisual()
end

-- TODO: MoveSelection (same but move multiple lines in line-visual mode)
local function MoveAbove()
	local row = vim.api.nvim_win_get_cursor(0)[1] -- current line number (1-based)
	if row == 1 then
		return                                     -- already at the top, can't swap
	end

	local bufnr = 0                                                     -- current buffer
	local lines = vim.api.nvim_buf_get_lines(bufnr, row - 2, row, false) -- get 2 lines: above and current

	if #lines < 2 then
		return
	end

	-- swap the lines
	vim.api.nvim_buf_set_lines(bufnr, row - 2, row, false, { lines[2], lines[1] })

	-- move cursor to the line we swapped with (i.e., one line up)
	vim.api.nvim_win_set_cursor(0, { row - 1, 0 })
end

local function MoveBelow()
	local row = vim.api.nvim_win_get_cursor(0)[1] -- current line number (1-based)
	local bufnr = 0                              -- current buffer

	local line_count = vim.api.nvim_buf_line_count(bufnr)
	if row >= line_count then
		return -- can't swap with a non-existent line
	end

	-- Get the current and next line
	local lines = vim.api.nvim_buf_get_lines(bufnr, row - 1, row + 1, false)
	if #lines < 2 then
		return
	end

	-- Swap them
	vim.api.nvim_buf_set_lines(bufnr, row - 1, row + 1, false, { lines[2], lines[1] })

	-- Move cursor down to the swapped line
	vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
end

local function MoveLinesAbove()
	-- Get start and end of selection
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")

	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	if start_line == 1 then
		return -- can't move above the top of the buffer
	end

	local bufnr = 0
	local above_line = vim.api.nvim_buf_get_lines(bufnr, start_line - 2, start_line - 1, false)[1]
	local selected_lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

	-- Build the new swapped block: selected_lines + above_line
	local new_block = vim.deepcopy(selected_lines)
	table.insert(new_block, above_line)

	-- Replace the range: from above_line to end of selection
	vim.api.nvim_buf_set_lines(bufnr, start_line - 2, end_line, false, new_block) -- Reselect using marks

	-- Set '< and '> marks to new selection
	vim.api.nvim_buf_set_mark(bufnr, "<", start_line - 1, 0, {})
	vim.api.nvim_buf_set_mark(bufnr, ">", end_line - 1, 0, {})

	-- Enter visual-line mode on new selection using feedkeys
	local keys = vim.api.nvim_replace_termcodes("gvV", true, false, true)
	vim.api.nvim_feedkeys(keys, "x", false)
end

-- BUG: SELECTION IS NOT PRESERVED
local function MoveLinesBelow()
	-- Get the start and end of the visual selection
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")

	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	local bufnr = 0
	local line_count = vim.api.nvim_buf_line_count(bufnr)

	if end_line >= line_count then
		return -- can't move below the bottom of the file
	end

	-- Get the selected lines and the line below
	local selected_lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
	local below_line = vim.api.nvim_buf_get_lines(bufnr, end_line, end_line + 1, false)[1]

	-- Replace lines
	vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line + 1, false, { below_line, unpack(selected_lines) })

	-- Reselect using marks
	-- Set '< and '> marks to new selection
	vim.api.nvim_buf_set_mark(bufnr, "<", start_line, 0, {})
	vim.api.nvim_buf_set_mark(bufnr, ">", end_line + 1, 0, {})

	-- Enter visual-line mode on new selection using feedkeys
	local keys = vim.api.nvim_replace_termcodes("gvV", true, false, true)
	vim.api.nvim_feedkeys(keys, "x", false)
end

local ufo = require("ufo")
local telescope_builtin = require("telescope.builtin")

-- Keyboard Shortcut

-- ~Ctrl + Enter~
-- NOTE: requires a terminal that recognizes such input and correctly translates it to NeoVim or can be customized to do so (wezterm, alacritty, kitty)
-- insert new line before and jump to it
vim.keymap.set("i", "<C-Enter>", "<Esc>o", { noremap = true, silent = true })

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
vim.keymap.set("i", "<C-S-z>", "<Esc>:redo<CR>:startinsert<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-S-z>", ":redo<CR>", { noremap = true })

-- ~Ctrl + s~
-- format + save
vim.keymap.set("n", "<C-s>", ":write<CR>", { noremap = true })
vim.keymap.set("i", "<C-s>", "<Esc>:write<CR>", { noremap = true })

-- ~Ctrl  + S~
-- format + save + exit
vim.keymap.set("n", "<C-S-s>", ":wq<CR>", { noremap = true })
vim.keymap.set("i", "<C-S-s>", "<Esc>:wq<CR>", { noremap = true })

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

-- ~Ctrl + U~
-- bringup definition
vim.keymap.set("n", "<C-u>", vim.lsp.buf.definition, { noremap = true })

-- ~Ctrl + .~
-- code action
vim.keymap.set("n", "<C-.>", vim.lsp.buf.code_action, { noremap = true })

-- ~Ctrl + d~
-- select word; grep and loop

-- ~Ctrl + l~
-- select entire line (possibly copy as well?)
-- in insert, normal mode - enter visual + select line
-- in visual - add next line to selection
vim.keymap.set({ "n", "v", "i", "x", "s" }, "<C-l>", LineSelection, { noremap = true })

-- ~Alt + DownArrow~
-- switch current line with line after it
vim.keymap.set({ "i", "n" }, "<C-Down>", MoveBelow, { noremap = true })
vim.keymap.set("x", "<C-Down>", MoveLinesBelow, { noremap = true })

-- ~Alt + UpArrow~
-- switch current line with line before it
vim.keymap.set({ "i", "n" }, "<C-Up>", MoveAbove, { noremap = true })
vim.keymap.set("x", "<C-Up>", MoveLinesAbove, { noremap = true })

-- ~Ctrl + /~
-- comment/uncomment current line
-- vim.keymap.set({'i', 'n'}, "<C-/>", "", { noremap = true })

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

-- indent-blankline setup with flexoki theme colors
local indent_hl = {
	"flexoki-light-orange",
	"flexoki-light-yellow",
	"flexoki-light-green",
	"flexoki-light-cyan",
	"flexoki-light-blue",
	"flexoki-light-purple",
	"flexoki-light-magenta",
}

local ibl_hooks = require("ibl.hooks")
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
ibl_hooks.register(ibl_hooks.type.HIGHLIGHT_SETUP, function()
	vim.api.nvim_set_hl(0, "flexoki-light-orange", { fg = "#EC8B49" })
	vim.api.nvim_set_hl(0, "flexoki-light-yellow", { fg = "#DFB431" })
	vim.api.nvim_set_hl(0, "flexoki-light-green", { fg = "#A0AF54" })
	vim.api.nvim_set_hl(0, "flexoki-light-cyan", { fg = "#5ABDAC" })
	vim.api.nvim_set_hl(0, "flexoki-light-blue", { fg = "#66A0C8" })
	vim.api.nvim_set_hl(0, "flexoki-light-purple", { fg = "#A699D0" })
	vim.api.nvim_set_hl(0, "flexoki-light-magenta", { fg = "#E47DA8" })
end)

require("ibl").setup({ indent = { highlight = indent_hl } })
