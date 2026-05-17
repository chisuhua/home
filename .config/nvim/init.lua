-- ~/.config/nvim/init.lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 基础设置
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.updatetime = 300
vim.opt.timeoutlen = 400
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.keymap.set({"n", "x"}, "<C-c>", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set({"n", "x"}, "<D-c>", '"+y', { desc = "Copy to system clipboard (macOS)" })
vim.o.autoread = true

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin"
      }
    }
  },
  rocks = {
    enabled = false,
  }
})

-- 加载快捷键
require("keymaps")
