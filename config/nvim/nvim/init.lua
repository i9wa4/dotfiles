-- --------------------------------------
-- Option
--
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.clipboard = "unnamedplus"
vim.opt.cursorline = true
vim.opt.ignorecase = true
vim.opt.list = true
vim.opt.listchars = { trail = "~", leadmultispace = "-+" }
vim.opt.nrformats = { "unsigned" }
vim.opt.number = true
vim.opt.spell = true
vim.opt.spelllang:append("cjk")
vim.opt.swapfile = false
vim.opt.termguicolors = true

vim.fn.timer_stop(vim.g.auto_reload or -1)
vim.g.auto_reload = vim.fn.timer_start(1000, function()
  vim.cmd("silent! checktime")
end, { ["repeat"] = -1 })

-- --------------------------------------
-- Plugin
--
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim", lazypath }):wait()
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = {
      columns = {
        "permissions",
        "size",
        { "mtime", format = "%Y-%m-%d %H:%M:%S" },
      },
      keymaps = {
        ["t"] = { "actions.select", opts = { tab = true } },
      },
      view_options = {
        show_hidden = true,
      },
    },
  },
})

-- --------------------------------------
-- Keymap
--
vim.keymap.set("n", "-", "<Cmd>edit %:p:h<CR>")
vim.keymap.set("n", "<Space>pt", "<Cmd>let @+ = expand('%:p:~')<CR>")
vim.keymap.set("n", "<Space>sn", "<Cmd>setlocal number! number?<CR>")
vim.keymap.set("n", "<Space>st", "<Cmd>setlocal expandtab! expandtab?<CR>")
vim.keymap.set("n", "<Space>sw", "<Cmd>setlocal wrap! wrap?<CR>")

vim.keymap.set("i", ",now", function()
  return vim.fn.strftime("%Y-%m-%d %H:%M:%S %z")
end, { expr = true })
vim.keymap.set("i", ",today", function()
  return vim.fn.strftime("%Y-%m-%d")
end, { expr = true })

-- --------------------------------------
-- Autocmd
--
local augroup = vim.api.nvim_create_augroup("MyAutocmd", { clear = true })

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  command = [[silent! normal! g`"]],
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    if vim.v.event.operator ~= "y" or vim.v.event.regname ~= "" then
      return
    end

    if not vim.env.TMUX or vim.env.TMUX == "" or vim.fn.executable("tmux") ~= 1 then
      return
    end

    vim
      .system({ "tmux", "load-buffer", "-w", "-" }, {
        stdin = vim.fn.getreg(""),
      })
      :wait()
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = augroup,
  callback = function()
    vim.api.nvim_set_hl(0, "markdownError", { link = "Normal" })
    vim.api.nvim_set_hl(0, "markdownItalic", { link = "Normal" })

    for _, group in ipairs({
      "EndOfBuffer",
      "Folded",
      "LineNr",
      "NonText",
      "Normal",
      "WinSeparator",
    }) do
      local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
      hl.bg = nil
      vim.api.nvim_set_hl(0, group, hl)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  callback = function()
    pcall(function()
      -- Keep literal ':' insertion from triggering insert-mode reindent,
      -- e.g. the time separators inserted by the ",now" mapping.
      vim.opt_local.indentkeys:remove({ ":", "<:>" })
      vim.opt_local.cinkeys:remove({ ":", "<:>" })
    end)
  end,
})

-- --------------------------------------
-- ColorScheme
--
vim.cmd.colorscheme("retrobox")
