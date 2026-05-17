# Neovim C++ 开发环境增强实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 改进 Neovim 配置以更好地支持中型 CMake C++ 项目开发

**Architecture:** 通过添加 cmake-language-server、clangd 深度配置、LSP 快捷键和编译/调试工作流集成，实现 "编码→导航→编译→调试" 完整闭环。

**Tech Stack:** Neovim, clangd, nvim-lspconfig, nvim-dap, telescope, cmake-language-server

---

## 文件结构

- Modify: `lua/plugins.lua` - 添加 cmake-language-server，优化 clangd 配置
- Modify: `lua/keymaps.lua` - 添加 LSP 导航快捷键和头文件切换
- Modify: `init.lua` - 如需要添加 clangd 特殊配置

---

## 任务列表

### Task 1: 添加 LSP 导航快捷键（方案 C - 代码导航增强）

**Files:**
- Modify: `lua/keymaps.lua`

- [ ] **Step 1: 添加 LSP 导航快捷键到 keymaps.lua**

在 `lua/keymaps.lua` 末尾添加：

```lua
-- LSP 导航
map("n", "<leader>cD", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "Go to definition" })
map("n", "<leader>cR", "<cmd>lua vim.lsp.buf.references()<cr>", { desc = "Find references" })
map("n", "<leader>cT", "<cmd>lua vim.lsp.buf.type_definition()<cr>", { desc = "Go to type definition" })
map("n", "<leader>ci", "<cmd>lua vim.lsp.buf.implementation()<cr>", { desc = "Go to implementation" })
```

- [ ] **Step 2: 添加头文件切换快捷键**

在同一文件添加：

```lua
-- 头文件/源文件切换（需要 clangd）
map("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", { desc = "Switch source/header" })
```

- [ ] **Step 3: 添加 document symbols 过滤快捷键**

在同一文件添加：

```lua
-- 按类型过滤的 document symbols
map("n", "<leader>s:", "<cmd>lua require('telescope.builtin').lsp_document_symbols({ symbol_type = { 'Class', 'Function', 'Struct' } })<cr>", { desc = "Document symbols (filtered)" })
```

---

### Task 2: 添加 cmake-language-server 支持（方案 A - LSP + CMake 深度集成）

**Files:**
- Modify: `lua/plugins.lua` - 在 mason-lspconfig 的 ensure_installed 添加 "cmake"

- [ ] **Step 1: 修改 mason-lspconfig 确保安装 cmake-language-server**

找到 plugins.lua 中的 mason-lspconfig 配置部分，修改 `ensure_installed`:

```lua
require("mason-lspconfig").setup({
  ensure_installed = { "clangd", "cmake" },  -- 添加 cmake
  handlers = {
    function(server_name)
      require("lspconfig")[server_name].setup({ capabilities = capabilities })
    end,
    -- ... 其他 handler
  },
})
```

- [ ] **Step 2: 添加 cmake-tools.nvim 插件（可选，用于复杂 CMake 项目）**

在 plugins.lua 中添加：

```lua
{
  "Civitasv/cmake-tools.nvim",
  event = "VeryLazy",
  config = function()
    require("cmake-tools").setup({
      cmake_command = "cmake",
      cmake_build_directory = "build",
      cmake_build_type = "Debug",
      cmake_variants = {
        debug = { -DCMAKE_BUILD_TYPE = "Debug" },
        release = { -DCMAKE_BUILD_TYPE = "Release" },
      },
    })
  end,
},
```

---

### Task 3: 优化 clangd 配置（方案 A - LSP + CMake 深度集成）

**Files:**
- Modify: `lua/plugins.lua` - 优化 clangd 的 setup 配置

- [ ] **Step 1: 更新 clangd 配置以支持 CMake 项目**

找到 plugins.lua 中 clangd 的配置部分，修改为：

```lua
clangd = function()
  require("lspconfig").clangd.setup({
    capabilities = capabilities,
    cmd = {
      "clangd",
      "--background-index",
      "--header-insertion=iwyu",
      "--suggest-missing-includes",
      "--compile-commands-dir=build",  -- 指定 compile_commands.json 位置
    },
    init_options = {
      clangd = {
        hints = { parameters = true, deducedTypes = true }
      },
      compilationDatabasePath = "build",  -- CMake 项目指向 build 目录
    },
  })
end,
```

---

### Task 4: 添加编译错误 quickfix 集成（方案 B - 编译/调试工作流优化）

**Files:**
- Modify: `lua/keymaps.lua` - 添加编译错误搜索快捷键

- [ ] **Step 1: 添加 quickfix 相关的 Telescope 快捷键**

在 keymaps.lua 添加：

```lua
-- Quickfix 导航
map("n", "<leader>fc", "<cmd>lua require('telescope.builtin').quickfix()<cr>", { desc = "Find quickfix items" })
map("n", "<leader>fl", "<cmd>lua require('telescope.builtin').loclist()<cr>", { desc = "Find loclist items" })

-- 编译错误搜索
map("n", "<leader>fe", "<cmd>lua require('telescope.builtin').quickfix({ search = vim.fn.input('Search: ') })<cr>", { desc = "Search quickfix" })
```

---

### Task 5: 增强 dap 配置（方案 B - 编译/调试工作流优化）

**Files:**
- Modify: `lua/plugins.lua` - 增强 dap 配置

- [ ] **Step 1: 添加 CMake target 调试支持**

找到 plugins.lua 中 nvim-dap 的配置部分，添加 CMake 配置：

```lua
-- 在 config function 中添加：
local codelldb_path = vim.fn.expand("~/.vscode-server/extensions/vadimcn.vscode-lldb-1.12.1/adapter/codelldb")
local lldb_lib_path = vim.fn.expand("~/.vscode-server/extensions/vadimcn.vscode-lldb-1.12.1/lldb/lib")

if vim.fn.executable(codelldb_path) == 1 then
  dap.adapters.lldb = {
    type = "executable",
    command = codelldb_path,
    options = {
      env = {
        LD_LIBRARY_PATH = lldb_lib_path .. ":" .. (os.getenv("LD_LIBRARY_PATH") or ""),
      },
    },
  }

  -- CMake 项目的调试配置
  dap.configurations.cpp = {
    {
      name = "Debug CMake Target",
      type = "lldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
    {
      name = "Debug CMake (gdb)",
      type = "cppdbg",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      setupCommands = {
        { text = "-enable-pretty-printing", description = "Enable pretty-printing" },
      },
    },
  }
end
```

- [ ] **Step 2: 添加 dap 快捷键（如果还没有）**

在 keymaps.lua 添加：

```lua
-- DAP 调试
map("n", "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>", { desc = "Toggle breakpoint" })
map("n", "<leader>dB", "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Condition: '))<cr>", { desc = "Set conditional breakpoint" })
map("n", "<leader>dc", "<cmd>lua require('dap').continue()<cr>", { desc = "Continue/Start" })
map("n", "<leader>dC", "<cmd>lua require('dap").run_to_cursor()<cr>", { desc = "Run to cursor" })
map("n", "<leader>di", "<cmd>lua require('dap').step_into()<cr>", { desc = "Step into" })
map("n", "<leader>do", "<cmd>lua require('dap').step_over()<cr>", { desc = "Step over" })
map("n", "<leader>dO", "<cmd>lua require('dap').step_out()<cr>", { desc = "Step out" })
map("n", "<leader>dk", "<cmd>lua require('dap').clear_breakpoints()<cr>", { desc = "Clear breakpoints" })
map("n", "<leader>dl", "<cmd>lua require('dap').list_breakpoints()<cr>", { desc = "List breakpoints" })
map("n", "<leader>dr", "<cmd>lua require('dap').repl.open()<cr>", { desc = "Open REPL" })
```

---

### Task 6: 添加 which-key 注册（方案 C 补充）

**Files:**
- Modify: `lua/plugins.lua` - 在 which-key 配置中添加新分组

- [ ] **Step 1: 在 which-key 注册中添加 c (Code) 分组**

找到 which-key 配置部分，确保 c 分组已注册：

```lua
wk.register({
  c = { name = "+Code" },       -- LSP/代码操作
  -- 确保 c 分组包含：
  -- cD = definition, cR = references, cT = type, ci = implementation, ch = header
}, { prefix = "<leader>" })
```

---

## 验证步骤

1. 重启 Neovim
2. 运行 `:Mason` 确认 cmake-language-server 已安装
3. 打开一个 C++ 文件，测试：
   - `<leader>cD` 跳转定义
   - `<leader>cR` 查找引用
   - `<leader>ch` 切换头文件
4. 运行 `:checkhealth` 确认 LSP 正常工作
5. 测试 DAP：`<leader>dc` 启动调试

---

## 风险评估

- **cmake-tools.nvim**: 较重插件，如不需要复杂 CMake 功能可跳过 Task 2 Step 2
- **现有配置**: 所有改动不破坏现有功能，仅添加新功能
- **codelldb 路径**: 假设路径存在，实际使用前需确认