-- --------------------------------------
-- Plugin
--
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

require("oil").setup({
  columns = {
    "permissions",
    "size",
    { "mtime", format = "%Y-%m-%d %H:%M:%S" },
  },
  view_options = {
    show_hidden = true,
  },
})

-- --------------------------------------
-- Option
--
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.list = true
vim.opt.listchars = { trail = "~", leadmultispace = "-+" }
vim.opt.nrformats = { "unsigned" }
vim.opt.number = true
vim.opt.swapfile = false
vim.opt.termguicolors = true

vim.g.clipboard = "tmux"

vim.fn.timer_stop(vim.g.auto_reload or -1)
vim.g.auto_reload = vim.fn.timer_start(1000, function()
  vim.cmd("silent! checktime")
end, { ["repeat"] = -1 })

-- --------------------------------------
-- Keymap
--
vim.keymap.set("i", ",now", [[<C-R><C-O>=strftime("%Y-%m-%d %H:%M:%S %z")<CR>]])
vim.keymap.set("i", ",today", [[<C-R><C-O>=strftime("%Y-%m-%d")<CR>]])
vim.keymap.set("n", "-", "<Cmd>edit %:p:h<CR>")
vim.keymap.set("n", "<Space>pt", "<Cmd>let @+ = expand('%:p:~')<CR>")
vim.keymap.set("n", "<Space>sn", "<Cmd>setlocal number! number?<CR>")
vim.keymap.set("n", "<Space>st", "<Cmd>setlocal expandtab! expandtab?<CR>")
vim.keymap.set("n", "<Space>sw", "<Cmd>setlocal wrap! wrap?<CR>")

-- --------------------------------------
-- Autocmd
--
local augroup = vim.api.nvim_create_augroup("MyAutocmd", { clear = true })

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  command = [[silent! normal! g`"]],
})

-- --------------------------------------
-- ColorScheme
--
vim.cmd.colorscheme("retrobox")

for _, name in ipairs({
  "EndOfBuffer",
  "Folded",
  "LineNr",
  "NonText",
  "Normal",
  "WinSeparator",
}) do
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  hl.bg = nil
  vim.api.nvim_set_hl(0, name, hl)
end
