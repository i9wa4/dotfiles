vim.cmd("filetype off")
vim.cmd("filetype plugin indent off")
vim.cmd("syntax off")

-- --------------------------------------
-- Helper
--
local api = vim.api
local fn = vim.fn
local opt = vim.opt

local function toggle_quote(line1, line2)
  if line2 < line1 then
    line1, line2 = line2, line1
  end

  local lines = api.nvim_buf_get_lines(0, line1 - 1, line2, false)
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

  api.nvim_buf_set_lines(0, line1 - 1, line2, false, new_lines)
end

local function send_tmux_clipboard(content)
  if fn.executable("tmux") == 1 and vim.env.TMUX and vim.env.TMUX ~= "" then
    vim.system({ "tmux", "load-buffer", "-w", "-" }, { stdin = content }):wait()
  end
end

local function send_register(reg)
  local content = fn.getreg(reg)
  pcall(fn.setreg, "+", content)
  send_tmux_clipboard(content)
end

local function highlight_define()
  api.nvim_set_hl(0, "HlMS", { bg = "#FFB6C1", fg = "#000000" })
  api.nvim_set_hl(0, "markdownError", { link = "Normal" })
  api.nvim_set_hl(0, "markdownItalic", { link = "Normal" })

  local function clear_bg(group)
    local hl = api.nvim_get_hl(0, { name = group, link = false })
    hl.bg = nil
    api.nvim_set_hl(0, group, hl)
  end

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
    clear_bg(group)
  end
end

local function delete_highlight_matches()
  for _, id in ipairs(vim.w.my_highlight_match_ids or {}) do
    pcall(fn.matchdelete, id)
  end
  vim.w.my_highlight_match_ids = {}
end

local function highlight_match()
  delete_highlight_matches()

  local ids = {}
  local function add(pattern)
    ids[#ids + 1] = fn.matchadd("HlMS", pattern)
  end

  add("HlMS")
  add([[TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:\|HACK:\|# %%\|\[ \]])
  local now = fn.localtime()
  add(fn.strftime("%Y%m%d", now))
  add(fn.strftime("%Y-%m-%d", now))
  add(fn.strftime("%Y/%m/%d", now))

  vim.w.my_highlight_match_ids = ids
end

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

-- Location list replacement recipes:
--   :lgrep! old **/*.lua
--   ! keeps the cursor in place instead of jumping to the first match.
--   :ldo s/old/new/ge | update
--   :lfdo %s/old/new/ge | update
-- Use :ldo for matched lines and :lfdo for matched files.
local function open_quickfix_item_keep_focus()
  local qf_win = api.nvim_get_current_win()
  local wininfo = fn.getwininfo(qf_win)[1] or {}
  local command = wininfo.loclist == 1 and "ll" or "cc"

  pcall(vim.cmd, command .. " " .. fn.line("."))
  if api.nvim_win_is_valid(qf_win) then
    api.nvim_set_current_win(qf_win)
  end
end

api.nvim_create_user_command("R", function(opts)
  send_register(opts.args)
end, { nargs = "?" })

-- --------------------------------------
-- Keymap
--
local map = vim.keymap.set

map("n", "gf", "gF")
map("n", "gqq", function()
  toggle_quote(fn.line("."), fn.line("."))
end)
map("v", "gqq", function()
  toggle_quote(fn.line("v"), fn.line("."))
end)
map("i", ",now", function()
  return fn.strftime("%Y-%m-%d %X +0900")
end, { expr = true })
map("i", ",today", function()
  return fn.strftime("%Y-%m-%d")
end, { expr = true })
map("n", "<C-p>", lprevious)
map("n", "<C-n>", lnext)
map("n", "<Space>sl", "<Cmd>setlocal list! list?<CR>")
map("n", "<Space>sn", "<Cmd>setlocal number! number?<CR>")
map("n", "<Space>st", "<Cmd>setlocal expandtab! expandtab?<CR>")
map("n", "<Space>sw", "<Cmd>setlocal wrap! wrap?<CR>")

vim.cmd([[
nmap <C-w>-    <C-w>-<SNR>999_my_window_resize_repeat
nmap <C-w>+    <C-w>+<SNR>999_my_window_resize_repeat
nmap <C-w><lt> <C-w><lt><SNR>999_my_window_resize_repeat
nmap <C-w>>    <C-w>><SNR>999_my_window_resize_repeat
nmap <SNR>999_my_window_resize_repeat <Nop>
nnoremap <script> <SNR>999_my_window_resize_repeat-    <C-w>-<SNR>999_my_window_resize_repeat
nnoremap <script> <SNR>999_my_window_resize_repeat+    <C-w>+<SNR>999_my_window_resize_repeat
nnoremap <script> <SNR>999_my_window_resize_repeat<lt> <C-w><lt><SNR>999_my_window_resize_repeat
nnoremap <script> <SNR>999_my_window_resize_repeat>    <C-w>><SNR>999_my_window_resize_repeat
]])

-- --------------------------------------
-- Autocmd
--
local augroup = api.nvim_create_augroup("MyAutocmd", { clear = true })

api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    pcall(vim.cmd, [[normal! g`"]])
  end,
})

api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  callback = function()
    if vim.bo.buftype == "" then
      fn.setreg("a", fn.fnamemodify(fn.expand("%"), ":p:~"))
    end
  end,
})

api.nvim_create_autocmd("FileType", {
  group = augroup,
  callback = function()
    if vim.bo.filetype == "qf" then
      map("n", "<CR>", open_quickfix_item_keep_focus, { buffer = true })
      return
    end

    if vim.wo.diff then
      vim.opt_local.spell = false
    else
      vim.opt_local.spelllang:append("cjk")
      vim.opt_local.spell = true
    end
  end,
})

api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    if vim.v.event.operator == "y" and vim.v.event.regname == "" then
      send_tmux_clipboard(fn.getreg(""))
    end
  end,
})

api.nvim_create_autocmd("ColorScheme", {
  group = augroup,
  callback = highlight_define,
})

api.nvim_create_autocmd({ "WinEnter", "FileType" }, {
  group = augroup,
  callback = highlight_match,
})

vim.g.auto_reload = fn.timer_start(1000, function()
  vim.cmd("silent! checktime")
end, { ["repeat"] = -1 })

-- --------------------------------------
-- Option
--
opt.hidden = true
opt.nrformats = { "unsigned" }

if fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --no-heading"
  opt.grepformat = "%f:%l:%c:%m"
end

opt.hlsearch = true
opt.ignorecase = true
opt.incsearch = true
pcall(function()
  opt.shortmess:remove("S")
end)
opt.smartcase = true
opt.wrapscan = true

opt.ambiwidth = "double"
opt.cursorline = true
opt.list = true
opt.listchars = { space = "␣", tab = ">-", trail = "~", nbsp = "%" }
opt.number = true

vim.g.netrw_home = fn.expand("$XDG_CACHE_HOME")
opt.autoread = true
opt.backup = false
opt.swapfile = false
opt.undofile = false
opt.clipboard = ""

if fn.has("mac") == 1 or fn.has("macunix") == 1 then
  opt.clipboard:prepend("unnamed")
else
  opt.clipboard:prepend("unnamedplus")
end

if fn.has("termguicolors") == 1 then
  opt.termguicolors = true
end

-- --------------------------------------
-- Plugin
--
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim", lazypath }):wait()
end
opt.runtimepath:prepend(lazypath)

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
    keys = { { "-", "<Cmd>Oil<CR>", desc = "Open parent directory" } },
  },
})

-- --------------------------------------
-- End of settings
--
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")
vim.cmd.colorscheme(vim.g.colors_name or "habamax")
