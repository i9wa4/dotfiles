local path = vim.fn.stdpath("data") .. "/site/pack/plugins/start/oil.nvim"
if not vim.uv.fs_stat(path) then
  vim.fn.system({ "git", "clone", "https://github.com/stevearc/oil.nvim", path })
end
require("oil").setup()
vim.keymap.set("n", "-", "<Cmd>Oil<CR>", { desc = "Open parent directory" })
