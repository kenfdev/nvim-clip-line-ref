-- Minimal init for running tests with plenary.nvim
local plenary_path = vim.fn.expand("~/.local/share/nvim/site/pack/packer/start/plenary.nvim")
if vim.fn.empty(vim.fn.glob(plenary_path)) > 0 then
  -- Try lazy.nvim path
  plenary_path = vim.fn.expand("~/.local/share/nvim/lazy/plenary.nvim")
end

vim.opt.rtp:append(".")
vim.opt.rtp:append(plenary_path)

vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")
