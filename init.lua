require("config.lazy")

vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")

-- as of now - fails, appears to be a problem with permissions for writing files
-- should look into it, since <Control - s> in insert mode would be grand
function FormatAndSave()
	local mode = vim.api.nvim_get_mode().mode
	vim.cmd("lua vim.lsp.buf.format()")
	if mode == "n" then
		vim.cmd(":w<CR>")
	elseif mode == "i" then
		vim.cmd("<Esc>:w<CR>")
	else
	end
end

-- vim keymaps
-- Save file with <Control + S> in insert mode
-- vim.api.nvim_set_keymap("i", "<C-s>", "v:lua.FormatAndSave()", { noremap = true, expr = true })
-- vim.api.nvim_set_keymap("n", "<C-s>", "v:lua.FormatAndSave()", { noremap = true, expr = true })
-- Format and save file with <Control + Shift + s> in insert mode
-- vim.keymap.set('i', '<C-s>', format_and_save, { noremap = true, expr = true })0
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
vim.keymap.set("n", "S", vim.lsp.buf.format, {})
