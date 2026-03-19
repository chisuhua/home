# LSP 配置指南

> **版本**: 1.0  
> **最后更新**: 2026-03-18  
> **clangd 版本**: 18.1.3

---

## ✅ 当前状态

| 组件 | 状态 | 位置 |
|------|------|------|
| **clangd** | ✅ 已安装 | `/usr/bin/clangd` |
| **compile_commands.json** | ✅ 已生成 | `/workspace/PTX-EMU/build/compile_commands.json` |
| **符号链接** | ✅ 已创建 | `/workspace/PTX-EMU/compile_commands.json` → build/ |
| **LSP 配置** | ✅ 已创建 | `~/.config/opencode/lsp.json` |

---

## 🔧 已完成的配置

### 1. clangd 安装
```bash
sudo apt install -y clangd-18
# 版本：Ubuntu clangd version 18.1.3
```

### 2. compile_commands.json
```bash
. env.sh
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -sf build/compile_commands.json .
```

### 3. LSP 配置文件
**位置**: `~/.config/opencode/lsp.json`

**配置内容**:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "lsp": {
    "clangd": {
      "enabled": true,
      "command": "clangd",
      "args": [
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--header-insertion=iwyu",
        "--pch-storage=memory"
      ],
      "filetypes": [
        "c", "cpp", "cc", "cxx", "c++",
        "h", "hpp", "hh", "hxx", "h++",
        "cu", "cuh"
      ],
      "rootPatterns": [
        "compile_commands.json",
        "compile_flags.txt",
        ".git",
        "CMakeLists.txt"
      ],
      "offsetEncoding": "utf-8",
      "settings": {
        "clangd": {
          "compilationDatabase": "compile_commands.json",
          "fallbackFlags": [
            "-std=c++20",
            "-xc++",
            "-ICUDA_PATH/include"
          ]
        }
      }
    }
  }
}
```

---

## 📋 可用的 LSP 工具

| 工具 | 用途 | 示例 |
|------|------|------|
| `lsp_diagnostics` | 获取错误/警告 | 检查文件编译问题 |
| `lsp_goto_definition` | 跳转到定义 | 查找函数/类定义 |
| `lsp_find_references` | 查找引用 | 找出所有使用位置 |
| `lsp_symbols` | 获取符号 | 列出文件中的函数/类 |
| `lsp_prepare_rename` | 重命名检查 | 验证重命名是否安全 |
| `lsp_rename` | 跨文件重命名 | 统一修改符号名 |

---

## 🔍 使用示例

### 检查诊断
```
lsp_diagnostics filePath="/workspace/PTX-EMU/src/cudart/cudart_sim.cpp"
```

### 获取文件符号
```
lsp_symbols filePath="/workspace/PTX-EMU/src/cudart/cudart_sim.cpp" scope="document" limit=20
```

### 查找引用
```
lsp_find_references filePath="/path/to/file.cpp" line=42 character=10 includeDeclaration=true
```

### 跳转到定义
```
lsp_goto_definition filePath="/path/to/file.cpp" line=42 character=10
```

---

## ⚠️ 注意事项

### 首次使用预热
clangd 需要构建索引，首次使用可能较慢：
- 构建 preamble：约 1-2 分钟
- 索引标准库：约 1-2 分钟

**建议**: 打开文件后等待 clangd 完成初始化再使用 LSP 功能

### CUDA 文件支持
LSP 支持 CUDA 文件 (`.cu`, `.cuh`)，但需要：
- `compile_commands.json` 包含 CUDA 编译命令
- nvcc 路径正确配置

### 性能优化
clangd 启动参数已优化：
- `--background-index`: 后台索引，提高后续访问速度
- `--pch-storage=memory`: 内存存储预编译头，减少磁盘 IO
- `--completion-style=detailed`: 详细补全信息

---

## 🛠️ 故障排查

### 问题：LSP server not found
**解决**:
```bash
which clangd
# 如果未找到：sudo apt install clangd-18
```

### 问题：compile_commands.json not found
**解决**:
```bash
cd /workspace/PTX-EMU
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -sf build/compile_commands.json .
```

### 问题：LSP 响应慢
**解决**:
1. 等待 clangd 完成索引（查看后台日志）
2. 关闭不必要的文件
3. 重启 clangd：`killall clangd`（会自动重启）

### 问题：CUDA 文件诊断错误
**解决**:
```bash
# 检查 CUDA_PATH 环境变量
echo $CUDA_PATH

# 确保 env.sh 已执行
. env.sh
```

---

## 📚 相关文档

- [clangd 官方文档](https://clangd.llvm.org/)
- [compile_commands.json 说明](https://clang.llvm.org/docs/CompilationDatabase.html)
- [文档驱动开发流程](README.md)

---

## 修订历史

| 日期 | 变更说明 |
|------|---------|
| 2026-03-18 | 初始配置完成 |

---

## 🤖 LSP 自动触发能力测试 (2026-03-18)

### 测试结果

| 工具 | 状态 | 说明 |
|------|------|------|
| `lsp_diagnostics` | ✅ 可用 | 返回快速，无错误 |
| `lsp_symbols` | ⚠️ 超时 | clangd 正在构建索引 |
| `lsp_goto_definition` | ⚠️ 超时 | 索引未完成 |
| `lsp_find_references` | ❓ 待测试 | 需要索引完成后 |

### 关键发现

**⚠️ LSP 不会自动触发**

当前配置下，LSP 工具**需要手动调用**，不会在以下场景自动触发：
- ❌ 读取 C++ 文件时
- ❌ 生成代码分析时
- ❌ 修改代码时

**需要手动触发**:
```typescript
// 必须显式调用
lsp_diagnostics(filePath="...")
lsp_symbols(filePath="...", scope="document")
lsp_goto_definition(filePath="...", line=42, character=10)
```

### 最佳实践

**在分析 C++ 代码时，建议工作流程**:

1. **先读取文件**: `read(filePath="...")`
2. **检查诊断**: `lsp_diagnostics(filePath="...")`
3. **获取符号**: `lsp_symbols(filePath="...", scope="document")`
4. **需要时跳转**: `lsp_goto_definition(...)`

### 预热建议

首次使用或长时间未使用后:
```bash
# 打开一个文件触发 clangd 索引
read filePath="/workspace/PTX-EMU/src/cudart/cudart_sim.cpp"

# 等待 30-60 秒让 clangd 完成索引
# 然后使用其他 LSP 工具
```

### 配置优化建议

如需自动触发，需要在 Agent 配置中添加规则:

```markdown
## LSP 自动触发规则

在分析 C++ 文件时:
1. 读取文件后自动调用 `lsp_diagnostics`
2. 需要理解结构时自动调用 `lsp_symbols`
3. 遇到未定义符号时自动调用 `lsp_goto_definition`
```


---

## 🔄 索引管理

### 项目初始化 (`/init`)

**运行一次** (克隆项目后或首次使用):
```bash
./init.sh
# 或全局脚本
~/.config/opencode/scripts/init-clangd.sh /path/to/project
```

**执行操作**:
1. ✅ 检查 clangd 安装
2. ✅ 设置环境变量 (`. env.sh`)
3. ✅ 生成 `compile_commands.json`
4. ✅ 创建符号链接
5. ✅ 触发 clangd 索引

### 代码变化后

**自动更新**:
- clangd 监听文件系统事件
- 修改 `.cpp`/`.h`/`.cu` 文件后自动重新解析
- 通常延迟 < 1 秒

**手动刷新**:
```bash
# 刷新单个文件
touch src/changed_file.cpp

# 刷新所有头文件
find include -name "*.h" | xargs touch

# 重启 clangd (强制重新索引)
killall clangd
# clangd 会自动重启
```

### 清理索引

**删除缓存**:
```bash
# 删除 .clangd 索引目录 (如果有)
rm -rf .clangd/

# 重新生成 compile_commands.json
rm compile_commands.json
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -sf build/compile_commands.json .
```

### 多项目索引

**每个项目独立**:
- 每个项目有自己的 `compile_commands.json`
- clangd 为每个项目维护独立索引
- 切换项目时自动加载对应索引

**全局脚本**:
```bash
# 初始化任意 C++ 项目
~/.config/opencode/scripts/init-clangd.sh /path/to/cpp-project
```

---

## 🌍 全局 /init 命令

**位置**: `~/.config/opencode/commands/init`

**适用范围**: 所有 C++/CUDA 项目

### 使用方式

**任何 C++ 项目**:
```bash
cd <project-root>
/init
```

**执行**:
1. 检查 clangd 安装
2. 设置环境变量 (如果存在 `env.sh`)
3. 生成 `compile_commands.json` (CMake 项目)
4. 创建符号链接
5. 触发 clangd 索引

### 项目级自定义

如果项目有特殊需求:

**方式 1**: 创建项目级 `init.sh`
```bash
./init.sh  # 优先执行
```

**方式 2**: 使用全局脚本
```bash
~/.config/opencode/scripts/init-clangd.sh .
```

### 新项目模板

**模板位置**: `~/.config/opencode/templates/PROJECT_SETUP.md`

**复制模板**:
```bash
cp ~/.config/opencode/templates/PROJECT_SETUP.md <project>/SETUP.md
```

---
