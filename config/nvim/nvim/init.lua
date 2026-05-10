-- ~/ghq/github.com/i9wa4/dotfiles/config/vim/vimrc
local vimrc_path = vim.fn.expand("$XDG_CONFIG_HOME") .. "/vim/vimrc"
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
