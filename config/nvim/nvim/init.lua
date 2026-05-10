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
  local all_quoted = true
  for lnum = line1, line2 do
    if not fn.getline(lnum):match("^>") then
      all_quoted = false
      break
    end
  end

  for lnum = line1, line2 do
    local line = fn.getline(lnum)
    if all_quoted then
      fn.setline(lnum, (line:gsub("^>%s?", "", 1)))
    else
      fn.setline(lnum, "> " .. line)
    end
  end
end

local function send_tmux_clipboard(content)
  if fn.executable("tmux") == 1 and vim.env.TMUX and vim.env.TMUX ~= "" then
    fn.system({ "tmux", "load-buffer", "-w", "-" }, content)
  end
end

local function send_register(reg)
  local content = fn.getreg(reg)
  pcall(fn.setreg, "+", content)
  send_tmux_clipboard(content)
end

local function highlight_define()
  vim.cmd("highlight HlMS guibg=#FFB6C1 guifg=#000000")
  vim.cmd("highlight link markdownError Normal")
  vim.cmd("highlight link markdownItalic Normal")

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
    vim.cmd("highlight " .. group .. " guibg=NONE")
  end
end

local function highlight_match()
  fn.clearmatches()
  fn.matchadd("HlMS", "HlMS")
  fn.matchadd("HlMS", [[TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:\|HACK:\|# %%\|\[ \]])

  local now = fn.localtime()
  fn.matchadd("HlMS", fn.strftime("%Y%m%d", now))
  fn.matchadd("HlMS", fn.strftime("%Y-%m-%d", now))
  fn.matchadd("HlMS", fn.strftime("%Y/%m/%d", now))
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

api.nvim_create_user_command("ToggleQuote", function(opts)
  toggle_quote(opts.line1, opts.line2)
end, { range = true })

api.nvim_create_user_command("Lprevious", lprevious, {})
api.nvim_create_user_command("Lnext", lnext, {})

-- --------------------------------------
-- Keymap
--
local map = vim.keymap.set

map("n", "gf", "gF")
map("n", "gqq", "<Cmd>ToggleQuote<CR>")
map("v", "gqq", ":'<,'>ToggleQuote<CR>")
map("i", ",now", function()
  return fn.strftime("%Y-%m-%d %X +0900")
end, { expr = true })
map("i", ",today", function()
  return fn.strftime("%Y-%m-%d")
end, { expr = true })
map("n", "<C-p>", "<Cmd>Lprevious<CR>")
map("n", "<C-n>", "<Cmd>Lnext<CR>")
map("n", "<Space>r", function()
  send_register(fn.getcharstr())
end)
map("n", "<Space>sl", "<Cmd>setlocal list! list?<CR>")
map("n", "<Space>sn", "<Cmd>setlocal number! number?<CR>")
map("n", "<Space>st", "<Cmd>setlocal expandtab! expandtab?<CR>")
map("n", "<Space>sw", "<Cmd>setlocal wrap! wrap?<CR>")

vim.cmd([[
nmap <Plug>(my-line-motion-repeat) <Nop>
nmap gj gj<Plug>(my-line-motion-repeat)
nmap gk gk<Plug>(my-line-motion-repeat)
nnoremap <script> <Plug>(my-line-motion-repeat)j gj<Plug>(my-line-motion-repeat)
nnoremap <script> <Plug>(my-line-motion-repeat)k gk<Plug>(my-line-motion-repeat)

nnoremap <script> <C-w>-    <C-w>-<Plug>(my-window-resize-repeat)
nnoremap <script> <C-w>+    <C-w>+<Plug>(my-window-resize-repeat)
nnoremap <script> <C-w><lt> <C-w><lt><Plug>(my-window-resize-repeat)
nnoremap <script> <C-w>>    <C-w>><Plug>(my-window-resize-repeat)
nmap <Plug>(my-window-resize-repeat) <Nop>
nnoremap <script> <Plug>(my-window-resize-repeat)-    <C-w>-<Plug>(my-window-resize-repeat)
nnoremap <script> <Plug>(my-window-resize-repeat)+    <C-w>+<Plug>(my-window-resize-repeat)
nnoremap <script> <Plug>(my-window-resize-repeat)<lt> <C-w><lt><Plug>(my-window-resize-repeat)
nnoremap <script> <Plug>(my-window-resize-repeat)>    <C-w>><Plug>(my-window-resize-repeat)
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
  fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim", lazypath })
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
