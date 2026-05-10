vim.cmd("filetype off")
vim.cmd("filetype plugin indent off")
vim.cmd("syntax off")

-- --------------------------------------
-- Helper
--
local function send_tmux_clipboard(content)
  if vim.fn.executable("tmux") == 1 and vim.env.TMUX and vim.env.TMUX ~= "" then
    vim.system({ "tmux", "load-buffer", "-w", "-" }, { stdin = content }):wait()
  end
end

local function send_register(reg)
  local content = vim.fn.getreg(reg)
  pcall(vim.fn.setreg, "+", content)
  send_tmux_clipboard(content)
end

vim.api.nvim_create_user_command("R", function(opts)
  send_register(opts.args)
end, { nargs = "?" })

-- Location list replacement recipes:
--   :lgrep! old **/*.lua
--   ! keeps the cursor in place instead of jumping to the first match.
--   :ldo s/old/new/ge | update
--   :lfdo %s/old/new/ge | update
-- Use :ldo for matched lines and :lfdo for matched files.
local function lprevious()
  if not pcall(vim.cmd.lprevious) then
    pcall(vim.cmd.llast)
  end
end

local function lnext()
  if not pcall(vim.cmd.lnext) then
    pcall(vim.cmd.lfirst)
  end
end

local function highlight_define()
  vim.api.nvim_set_hl(0, "HlMS", { bg = "#FFB6C1", fg = "#000000" })
  vim.api.nvim_set_hl(0, "markdownError", { link = "Normal" })
  vim.api.nvim_set_hl(0, "markdownItalic", { link = "Normal" })

  for _, group in ipairs({
    "EndOfBuffer",
    "Folded",
    "Identifier",
    "LineNr",
    "NonText",
    "Normal",
    "Special",
    "StatusLine",
    "StatusLineNC",
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

  add("Error", [[\%u3000]])
  add("Error", [[\s\+$]])
  add("HlMS", "HlMS")
  add("HlMS", [[TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:\|HACK:]])
  add("HlMS", [[# %%]])
  add("HlMS", [[\[ \]])
  local now = vim.fn.localtime()
  add("HlMS", vim.fn.strftime("%Y%m%d", now))
  add("HlMS", vim.fn.strftime("%Y-%m-%d", now))
  add("HlMS", vim.fn.strftime("%Y/%m/%d", now))

  vim.w.my_highlight_match_ids = ids
end

local function toggle_quote(line1, line2)
  if line2 < line1 then
    line1, line2 = line2, line1
  end

  local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)
  local all_quoted = true
  for _, line in ipairs(lines) do
    if not line:match("^>") then
      all_quoted = false
      break
    end
  end

  local new_lines = {}
  for _, line in ipairs(lines) do
    if all_quoted then
      new_lines[#new_lines + 1] = line:gsub("^>%s?", "", 1)
    else
      new_lines[#new_lines + 1] = "> " .. line
    end
  end

  vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, new_lines)
end

-- --------------------------------------
-- Keymap
--
vim.keymap.set("n", "-", "<Cmd>edit %:p:h<CR>")
vim.keymap.set("n", "gqq", function()
  toggle_quote(vim.fn.line("."), vim.fn.line("."))
end)
vim.keymap.set("v", "gqq", function()
  toggle_quote(vim.fn.line("v"), vim.fn.line("."))
end)
vim.keymap.set("i", ",now", function()
  return vim.fn.strftime("%Y-%m-%d %X +0900")
end, { expr = true })
vim.keymap.set("i", ",today", function()
  return vim.fn.strftime("%Y-%m-%d")
end, { expr = true })
vim.keymap.set("n", "<C-p>", lprevious)
vim.keymap.set("n", "<C-n>", lnext)
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

vim.g.auto_reload = vim.fn.timer_start(1000, function()
  vim.cmd("silent! checktime")
end, { ["repeat"] = -1 })

-- --------------------------------------
-- Option
--
vim.opt.hidden = true
vim.opt.nrformats = { "unsigned" }

if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --no-heading"
  vim.opt.grepformat = "%f:%l:%c:%m"
end

vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
pcall(function()
  vim.opt.shortmess:remove("S")
end)
vim.opt.smartcase = true
vim.opt.wrapscan = true

vim.opt.ambiwidth = "double"
vim.opt.cursorline = true
vim.opt.list = true
vim.opt.listchars = { space = "␣", tab = ">-", trail = "~", nbsp = "%" }
vim.opt.number = true

vim.g.netrw_home = vim.fn.expand("$XDG_CACHE_HOME")
vim.opt.autoread = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undofile = false
vim.opt.clipboard = ""

if vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1 then
  vim.opt.clipboard:prepend("unnamed")
else
  vim.opt.clipboard:prepend("unnamedplus")
end

if vim.fn.has("termguicolors") == 1 then
  vim.opt.termguicolors = true
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
      view_options = {
        show_hidden = true,
      },
    },
  },
})

-- --------------------------------------
-- End of settings
--
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")
vim.cmd.colorscheme(vim.g.colors_name or "habamax")
