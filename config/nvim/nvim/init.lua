-- =============================================================================
-- Plugins
-- =============================================================================

-- Use Oil to browse and manage files as editable buffers.
vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

require("oil").setup({
  -- Show file permissions, size, and modification time.
  columns = {
    "permissions",
    "size",
    { "mtime", format = "%Y-%m-%d %H:%M:%S" },
  },
  view_options = {
    -- Show hidden files and directories.
    show_hidden = true,
  },
})

-- =============================================================================
-- Options
-- =============================================================================

-- Use the system clipboard for yank, delete, and paste operations.
vim.opt.clipboard = "unnamedplus"

-- Search without distinguishing uppercase and lowercase letters.
vim.opt.ignorecase = true

-- Display whitespace characters defined by 'listchars'.
vim.opt.list = true

-- Mark trailing spaces with ~ and leading spaces with alternating - and +.
vim.opt.listchars = { trail = "~", leadmultispace = "-+" }

-- Treat numbers as unsigned when incrementing or decrementing.
vim.opt.nrformats = { "unsigned" }

-- Display absolute line numbers.
vim.opt.number = true

-- Disable swap files to avoid temporary recovery files.
vim.opt.swapfile = false

-- Use tmux as the clipboard provider.
vim.g.clipboard = "tmux"

-- =============================================================================
-- Keymaps
-- =============================================================================

-- Insert the current timestamp with the timezone offset.
vim.keymap.set("i", ",now", [[<C-R><C-O>=strftime("%Y-%m-%d %H:%M:%S %z")<CR>]])

-- Insert the current date in ISO 8601 format.
vim.keymap.set("i", ",today", [[<C-R><C-O>=strftime("%Y-%m-%d")<CR>]])

-- Open the directory containing the current file.
vim.keymap.set("n", "-", "<Cmd>edit %:p:h<CR>")

-- Copy the current file path, replacing the home directory with ~.
vim.keymap.set("n", "<Space>cp", "<Cmd>let @+ = expand('%:p:~')<CR>")

-- Toggle between tabs and spaces for indentation in the current buffer.
vim.keymap.set("n", "<Space>tt", "<Cmd>setlocal expandtab! expandtab?<CR>")

-- Toggle line wrapping in the current window.
vim.keymap.set("n", "<Space>tw", "<Cmd>setlocal wrap! wrap?<CR>")

-- =============================================================================
-- Autocommands
-- =============================================================================

-- Clear existing autocommands in this group when reloading the configuration.
local augroup = vim.api.nvim_create_augroup("MyAutocmd", { clear = true })

-- Restore the last cursor position when reopening a file.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  command = 'silent! normal! g`"',
})

-- Remove selected background colors whenever a color scheme is loaded.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = augroup,
  callback = function()
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
  end,
})

-- =============================================================================
-- Colorscheme
-- =============================================================================

-- Apply the built-in Retrobox color scheme.
vim.cmd.colorscheme("retrobox")
