local xdg_config_home = vim.fn.expand("$XDG_CONFIG_HOME")
local vim_config_path = xdg_config_home .. "/vim"

vim.opt.runtimepath:prepend(vim_config_path)
vim.opt.runtimepath:append(vim_config_path .. "/after")
vim.opt.packpath:prepend(vim_config_path)

local vimrc_path = vim_config_path .. "/vimrc"
if vim.fn.filereadable(vimrc_path) == 1 then
  vim.cmd("source " .. vim.fn.fnameescape(vimrc_path))
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim", lazypath })
end
vim.opt.runtimepath:prepend(lazypath)
require("lazy").setup({
  {
    "stevearc/oil.nvim",
    opts = {},
    keys = { { "-", "<Cmd>Oil<CR>", desc = "Open parent directory" } },
  },
})
