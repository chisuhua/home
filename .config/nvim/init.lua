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
    enabled = false;
  }
})

-- 设置光标颜色（iTerm2 OSC 512）
-- 格式: \x1b]PlRRGGBB\x1b\\  (RRGGBB 为十六进制颜色，无需 #)
-- local function set_cursor_color(color_hex)
  -- 移除 # 符号（如果存在）
--   color_hex = color_hex:gsub("#", "")
--   return string.format("\x1b]Pl%s\x1b\\", color_hex)
-- end

-- 配置光标颜色切换
-- vim.opt.t_SI = set_cursor_color("#00FF00")  -- Insert 模式：亮绿色
-- vim.opt.t_SR = set_cursor_color("#FFA500")  -- Replace 模式：亮橙色
-- vim.opt.t_EI = set_cursor_color("#505050")  -- Normal 模式：暗灰色

-- 可选：退出 Neovim 时恢复默认光标颜色
-- vim.api.nvim_create_autocmd("VimLeave", {
--  callback = function()
--    print(set_cursor_color("#FFFFFF"))  -- 恢复白色（需终端支持）
--  end,
--})

-- 加载快捷键
require("keymaps")
