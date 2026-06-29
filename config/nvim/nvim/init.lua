-- --------------------------------------
-- Option
--
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.autoread = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undofile = false

vim.opt.nrformats = { "unsigned" }

vim.opt.ignorecase = true

vim.opt.cursorline = true
vim.opt.number = true

vim.opt.termguicolors = true

vim.g.auto_reload = vim.fn.timer_start(1000, function()
  vim.cmd("silent! checktime")
end, { ["repeat"] = -1 })

vim.opt.clipboard = ""
if vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1 then
  vim.opt.clipboard:prepend("unnamed")
else
  vim.opt.clipboard:prepend("unnamedplus")
end

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
      win_options = {
        statusline = "%<%{substitute(expand('%'), '^oil://\\zs.*', '\\=fnamemodify(submatch(0), \":~\")', '')}%h%m%r%=%-14.(%l,%c%V%) %P",
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

local function open_url_under_cursor()
  if vim.fn.expand("<cfile>"):match("^https?://") then
    vim.fn.maparg("gx", "n", false, true).callback()
  end
end

vim.api.nvim_create_user_command("OpenUrlUnderCursor", open_url_under_cursor, {})

local function highlight_define()
  vim.api.nvim_set_hl(0, "markdownError", { link = "Normal" })
  vim.api.nvim_set_hl(0, "markdownItalic", { link = "Normal" })

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
end

local function highlight_match()
  for _, id in ipairs(vim.w.my_highlight_match_ids or {}) do
    pcall(vim.fn.matchdelete, id)
  end

  local ids = {}
  local function add(group, pattern)
    ids[#ids + 1] = vim.fn.matchadd(group, pattern)
  end

  add("TermCursor", [[# %%\|# COMMAND ----------]])
  add("TermCursor", [[\[ \]])
  add("TermCursor", vim.fn.strftime("%Y%m%d", vim.fn.localtime()))
  add("TermCursor", vim.fn.strftime("%Y-%m-%d", vim.fn.localtime()))
  add("TermCursor", vim.fn.strftime("%Y/%m/%d", vim.fn.localtime()))
  add("Error", [[\%u3000]])
  add("Error", [[\s\+$]])

  vim.w.my_highlight_match_ids = ids
end

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

vim.keymap.set({ "n", "i" }, "<LeftMouse>", "<LeftMouse><Cmd>OpenUrlUnderCursor<CR>", {
  desc = "Open URL under mouse",
  silent = true,
})

vim.keymap.set("n", "<Space>sl", "<Cmd>setlocal list! list?<CR>")
vim.keymap.set("n", "<Space>sn", "<Cmd>setlocal number! number?<CR>")
vim.keymap.set("n", "<Space>st", "<Cmd>setlocal expandtab! expandtab?<CR>")
vim.keymap.set("n", "<Space>sw", "<Cmd>setlocal wrap! wrap?<CR>")

-- --------------------------------------
-- Autocmd
--
local augroup = vim.api.nvim_create_augroup("MyAutocmd", { clear = true })

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

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  callback = function()
    if vim.wo.diff then
      vim.opt_local.spell = false
    else
      vim.opt_local.spelllang:append("cjk")
      vim.opt_local.spell = true
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    if vim.v.event.operator == "y" and vim.v.event.regname == "" then
      send_tmux_clipboard(vim.fn.getreg(""))
    end
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = augroup,
  callback = highlight_define,
})

vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "FileType" }, {
  group = augroup,
  callback = highlight_match,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup,
  pattern = { "*.md", "*.qmd" },
  callback = function()
    if vim.fn.executable("mdfmt") == 1 then
      vim.system({ "mdfmt", "--write", vim.fn.expand("%:p") }):wait()
      vim.cmd("silent noautocmd edit!")
    end
  end,
})

-- --------------------------------------
-- End of settings
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
