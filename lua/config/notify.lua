-- colorscheme for highlights
local dark = {
	INFO = { fg = "#66800B" }, -- green-600
	WARN = { fg = "#AD8301" }, -- yellow-600
	ERROR = { fg = "#AF3029" }, -- red-600
	DEBUG = { fg = "#24837B" }, -- cyan-600
	TRACE = { fg = "#5E409D" }, -- purple-600
	BODY = { fg = "#B7B5AC" }, -- base-300
}

local light = {
	INFO = { fg = "#879A39" }, -- green-400
	WARN = { fg = "#D0A215" }, -- yellow-400
	ERROR = { fg = "#D14D41" }, -- red-400
	DEBUG = { fg = "#3AA99F" }, -- cyan-400
	TRACE = { fg = "#8B7EC8" }, -- purple-400
	BODY = { fg = "#403E3C" }, -- base-800
}

local function set_notify_highlights()
	local theme = vim.g.colors_name or ""

	-- Default to Flexoki Dark colors
	local palette = dark

	if theme:lower():find("flexoki-light") then
		palette = light
	end

	for level, color in pairs(palette) do
		vim.api.nvim_set_hl(0, "Notify" .. level .. "Border", { fg = color.fg })
		vim.api.nvim_set_hl(0, "Notify" .. level .. "Title", { fg = color.fg, bold = true })
		vim.api.nvim_set_hl(0, "Notify" .. level .. "Icon", { fg = color.fg })
		if level ~= "BODY" then
			vim.api.nvim_set_hl(0, "Notify" .. level .. "Body", { fg = palette.BODY.fg })
		end
	end
end

-- Apply on colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		vim.schedule(set_notify_highlights)
	end,
})

-- Apply immediately on startup too
vim.schedule(set_notify_highlights)
