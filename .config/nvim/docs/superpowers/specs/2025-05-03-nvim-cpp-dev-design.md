# Neovim C++ 开发环境增强设计

**日期**: 2025-05-03
**目标**: 改进 Neovim 配置以更好地支持中型 CMake C++ 项目开发

---

## 1. 概述

当前 Neovim 配置已包含：
- clangd LSP（代码补全、跳转、诊断）
- nvim-dap（调试）
- treesitter（语法高亮）
- telescope（模糊查找）
- gitsigns/diffview（Git 集成）

**缺失部分**:
- CMake 完整支持（compile_commands.json 生成、cmake-language-server）
- LSP 深度集成（头文件切换、Type Hierarchy）
- 编译错误快速修复闭环

---

## 2. 改进方案

### 2.1 方案 A：LSP + CMake 深度集成

**目标**: 让 clangd 真正理解 CMake 项目结构

#### 改动 1: 添加 cmake-language-server
- 安装 `cmake-language-server`（通过 Mason）
- 确保 Mason 自动安装 `cmake-language-server`

#### 改动 2: 确保 compile_commands.json 自动生成
在 CMakeLists.txt 中确保设置了：
```cmake
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
```
或在项目根目录添加 CMakePresets.json 包含该选项。

#### 改动 3: 优化 clangd 配置
- 启用 `clangd.index.background = "build"`（后台构建索引）
- 配置 `clangd.index.externals` 加速外部依赖索引
- 添加 `clangd.compilationDatabaseDirectories` 指向 build 目录

#### 改动 4: 添加头文件/源文件切换快捷键
- `<leader>ch` = 切换 .cpp ↔ .h（在 clangd 中对应 `ClangdSwitchSourceHeader`）

### 2.2 方案 B：编译/调试工作流优化

**目标**: 在 Neovim 内完成 "编码→编译→调试" 闭环

#### 改动 5: 添加 CMake Quick Fix 集成
- 配置 Telescope 列出 CMake/编译错误
- `<leader>fc` = 搜索编译错误，跳转到对应文件和行号

#### 改动 6: 增强 dap 配置
- 添加 CMake 目标的调试配置
- 支持按 CMake target 启动调试
- 添加 `launch.json` 模板支持

### 2.3 方案 C：代码导航增强

**目标**: 快速理解大型代码库

#### 改动 7: 添加 LSP 快捷键
- `<leader>cD` = 转到定义（`vim.lsp.buf.definition`）
- `<leader>cR` = 查找引用（`vim.lsp.buf.references`）
- `<leader>cT` = 类型层次（`vim.lsp.buf.type_definition`）
- `<leader>ci` = 实现/接口（`vim.lsp.buf.implementation`）

#### 改动 8: 增强 Telescope LSP 集成
- `<leader>sw` = workspace symbols（已存在，保留）
- 添加 `<leader>s:` = 搜索 document symbols 按类型过滤

---

## 3. 配置文件改动

### 3.1 lua/plugins.lua
- 添加 `cmake-language-server` 到 Mason ensure_installed
- 添加 `cmake-tools.nvim`（可选，用于复杂 CMake 项目）
- 保留所有现有插件

### 3.2 lua/keymaps.lua
- 添加上述 LSP 快捷键
- 添加 CMake 相关快捷键

### 3.3 init.lua
- 如需要，添加 clangd 特殊配置

---

## 4. 实现顺序

1. **方案 C（代码导航）** - 最快见效，最小风险
2. **方案 A（LSP+CMake）** - 核心改进，需要配置调试
3. **方案 B（编译调试）** - 可选，按需启用

---

## 5. 风险评估

- **cmake-language-server**: 需要确保 `pip install cmake-language-server` 或 Mason 能自动安装
- **cmake-tools.nvim**: 较重插件，可选安装
- **现有配置**: 所有改动不破坏现有功能，仅添加新功能

---

## 6. 验收标准

- [ ] clangd 能正确识别项目结构（跳转准确）
- [ ] `<leader>ch` 能切换 .cpp/.h 文件
- [ ] `<leader>cD`, `<leader>cR`, `<leader>cT`, `<leader>ci` 正常工作
- [ ] dap 能针对 CMake target 启动调试
- [ ] 编译错误能通过 quickfix 快速跳转