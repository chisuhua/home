# C++ 项目设置模板

> **用途**: 新项目快速配置指南  
> **位置**: `~/.config/opencode/templates/PROJECT_SETUP.md`

---

## 快速开始

### 1. 克隆项目后运行

```bash
cd <project-root>
/init
```

### 2. 验证配置

```bash
# 检查 clangd
which clangd

# 检查 compile_commands.json
ls -la compile_commands.json
```

---

## 可选：创建项目级 init.sh

如果项目有特殊需求：

```bash
#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 自定义步骤
export CUSTOM_VAR=value

# 调用全局脚本
~/.config/opencode/scripts/init-clangd.sh .
```

---

## 可选：创建项目级 AGENTS.md

```markdown
# <Project> Agent Instructions

> **全局流程**: [文档驱动开发](~/.config/opencode/docs/dev-process/README.md)  
> **LSP 配置**: [全局规则](~/.config/opencode/agents/AGENTS.md)

---

## 项目特定规则

### 构建
cmake -S . -B build && cmake --build build

### 测试
cd build && ctest
```

---

## 验证清单

- [ ] clangd 已安装
- [ ] compile_commands.json 已生成
- [ ] LSP 可以工作

---

## 相关文档

- [全局 AGENTS.md](~/.config/opencode/agents/AGENTS.md)
- [LSP 配置](~/.config/opencode/docs/dev-process/lsp-setup.md)
