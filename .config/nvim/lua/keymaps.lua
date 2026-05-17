-- ~/.config/nvim/lua/keymaps.lua
local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })

-- Insert mode: jk = ESC
map("i", "jk", "<ESC>", { silent = true })

-- Terminal mode: C-q = exit
map("t", "<C-q>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
