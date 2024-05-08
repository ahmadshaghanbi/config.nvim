vim.cmd [[
	filetype plugin on
	syntax on
]]

if vim.env.COLORTERM == "truecolor" then
	vim.opt.termguicolors = true
end

table.join = function(t1, t2)
	for k,v in pairs(t2) do t1[k] = v end
end

-- Basic setup
table.join(vim.opt, {
	compatible = false,
	encoding = "utf-8",
	number = true,
	showmode = false,
	mouse = "",
	scrolloff = 5,
	laststatus = 3,
	tw = 118,
	ts = 4,
	sw = 4,
	et = false,
	ignorecase = true,
	smartcase = true,
	gdefault = true,
	list = true,
	undofile = true
})

-- Allow h and l to switch lines
-- From https://superuser.com/a/559436
table.join(vim.opt.whichwrap, {"<", ">", "h", "l", "[" , "]"})
table.join(vim.opt.colorcolumn, { 80, 120 })
table.join(vim.opt.listchars, { tab="▸", eol="¬", space="." })

-- Language specific
vim.g.c_comment_strings = 1

-- Move through soft wrapped lines
-- From https://stackoverflow.com/a/21000307
-- vim.keymap.set("n", "j", "", { noremap = true, expr = true, callback = function()
--	 if vim.v.count ~= 0 then return 'j'
--	 else return 'gj' end
-- end})
-- vim.keymap.set("n", "k", "", { noremap = true, expr = true, callback = function()
--	 if vim.v.count ~= 0 then return 'k'
--	 else return 'gk' end
-- end})

-- Move through soft wrapped lines
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- -- Not an issue anymore as I use CapsLock instead of Esc now
-- I hate it when I hit F1 instead of Esc and help appears
vim.keymap.set("n", "<F1>", "<Nop>")
vim.keymap.set("i", "<F1>", "<Nop>")

-- Keep visual mode open after indent
-- vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true, expr = true })
vim.keymap.set("v", ">", function()
	return ">gv"
end, { noremap = true, silent = true, expr = true })
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true, expr = true })

-- Instantly delete a line with Ctrl + d in insert and normal mode
vim.keymap.set("i", "<C-d>", "<C-R>\"_ddi", { noremap = true })
vim.keymap.set("n", "<C-d>", "\"_dd", { noremap = true })

-- Undo/Redo in insert mode (not working)
vim.keymap.set("i", "<C-u>u", "<esc>ui", { noremap = true })
vim.keymap.set("i", "<C-u>r", "<esc><C-r>i", { noremap = true })

-- vim.keymap.set("i", "C-u", "", { noremap = true, callback = function() vim.api.nvim_get_current_buf().undo() end })
-- vim.keymap.set("i", "C-r", "", { noremap = true, callback = function() vim.api.nvim_get_current_buf().redo() end })

-- let mapleader=","
vim.keymap.set("n", "/", "/\\v", { noremap = true })
vim.keymap.set("v", "/", "/\\v", { noremap = true })
vim.keymap.set("n", "<leader>h", "<CMD>noh<CR>", { noremap=true })
vim.keymap.set("n", "<tab>", "%", { noremap = true })
vim.keymap.set("v", "<tab>", "%", { noremap = true })

-- Make <F1> The same as <ESC> in all modes including terminal mode
vim.keymap.set("i", "<F1>", "<ESC>", { noremap = true })
vim.keymap.set("n", "<F1>", "<ESC>", { noremap = true })
vim.keymap.set("v", "<F1>", "<ESC>", { noremap = true })
vim.keymap.set("t", "<F1>", "<ESC>", { noremap = true })

-- Alias ; and : for command mode
vim.keymap.set("n", ";", ":", { noremap = true })

-- Allow CTRL + Backspace for word removal
vim.keymap.set("i", "<C-BS>", "vbda", { noremap = true, silent = true, expr = true })

-- Indentation and strike-through selection in markdown
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown" },
	callback = function()
		table.join(vim.opt_local, { tabstop = 2, shiftwidth = 2, textwidth = 80, expandtab = true })
		vim.keymap.set("v", "z/", "c~~<esc>pa~~<esc>", { noremap = true, buffer = true })
	end
})

-- Setup indentation in ninja
vim.api.nvim_create_autocmd("FileType", {
	pattern = "ninja",
	callback = function() table.join(vim.opt_local, { tabstop = 2, shiftwidth = 2, textwidth = 0, expandtab = true }) end
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	callback = function() table.join(vim.opt_local, { tabstop = 2, shiftwidth = 2, expandtab = false }) end
})

-- gvim setup (why?)
if vim.fn.has('gui_running') == 1 then
	vim.opt.t_Co = 256
end

-- Neovide configuration
if vim.fn.exists("g:neovide") then
	require("xeno.neovide")
end

require("xeno.plugins")
-- vim: ts=2 sw=2 noet
