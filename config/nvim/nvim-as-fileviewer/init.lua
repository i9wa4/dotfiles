local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim", lazypath })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  {
    "stevearc/oil.nvim",
    opts = {},
    keys = { { "-", "<Cmd>Oil<CR>", desc = "Open parent directory" } },
  },
})
