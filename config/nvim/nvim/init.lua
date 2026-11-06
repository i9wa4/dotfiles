-- --------------------------------------
-- Option
--
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.cursorline = true
vim.opt.ignorecase = true
vim.opt.list = true
vim.opt.listchars = { tab = ">-", trail = "_" }
vim.opt.nrformats = { "unsigned" }
vim.opt.number = true
vim.opt.spell = true
vim.opt.spelllang:append("cjk")
vim.opt.swapfile = false
vim.opt.termguicolors = true

vim.opt.clipboard = ""
if vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1 then
  vim.opt.clipboard:prepend("unnamed")
else
  vim.opt.clipboard:prepend("unnamedplus")
end

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
      default_file_explorer = true,
      keymaps = {
        ["`"] = { "actions.cd", mode = "n" },
        ["t"] = { "actions.select", opts = { tab = true } },
      },
      view_options = {
        show_hidden = true,
      },
    },
  },
})

-- --------------------------------------
-- Helper
--
local function send_tmux_clipboard(content)
  if vim.fn.executable("tmux") == 1 and vim.env.TMUX and vim.env.TMUX ~= "" then
    vim.system({ "tmux", "load-buffer", "-w", "-" }, { stdin = content }):wait()
  end
end

vim.api.nvim_create_user_command("R", function(opts)
  local content = vim.fn.getreg(opts.args)
  pcall(vim.fn.setreg, "+", content)
  send_tmux_clipboard(content)
end, { nargs = "?" })

-- --------------------------------------
-- Keymap
--
vim.keymap.set("n", "-", "<Cmd>edit %:p:h<CR>")
vim.keymap.set("i", ",now", function()
  return vim.fn.strftime("%Y-%m-%d %X +0900")
end, { expr = true })
vim.keymap.set("i", ",today", function()
  return vim.fn.strftime("%Y-%m-%d")
end, { expr = true })

vim.keymap.set("n", "<Space>sn", "<Cmd>setlocal number! number?<CR>")
vim.keymap.set("n", "<Space>st", "<Cmd>setlocal expandtab! expandtab?<CR>")
vim.keymap.set("n", "<Space>sw", "<Cmd>setlocal wrap! wrap?<CR>")

-- --------------------------------------
-- Autocmd
--
local augroup = vim.api.nvim_create_augroup("MyAutocmd", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    if vim.v.event.operator == "y" and vim.v.event.regname == "" then
      send_tmux_clipboard(vim.fn.getreg(""))
    end
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    pcall(vim.cmd, [[normal! g`"]])
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  callback = function()
    if vim.bo.buftype == "" then
      vim.fn.setreg("a", vim.fn.fnamemodify(vim.fn.expand("%"), ":p:~"))
    end
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = augroup,
  callback = function()
    -- vim.api.nvim_set_hl(0, "markdownError", { link = "Normal" })
    -- vim.api.nvim_set_hl(0, "markdownItalic", { link = "Normal" })

    for _, group in ipairs({
      "EndOfBuffer",
      "Folded",
      "LineNr",
      "NonText",
      "Normal",
      "VertSplit",
    }) do
      local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
      hl.bg = nil
      vim.api.nvim_set_hl(0, group, hl)
    end
  end,
})

-- --------------------------------------
-- Filetype, syntax, and colorscheme
--
vim.cmd("filetype plugin indent on")
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
vim.cmd("syntax enable")
vim.cmd.colorscheme(vim.g.colors_name or "retrobox")
