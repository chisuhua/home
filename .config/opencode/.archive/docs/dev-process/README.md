# 开发流程文档索引

> **最后更新**: 2026-03-18  
> **状态**: 活跃维护  
> **位置**: 全局配置 (`~/.config/opencode/docs/`)

---

## 快速开始

**第一次使用**:
1. 阅读 [快速参考](quick-reference.md) (5 分钟)
2. 开始你的第一个开发任务

**日常使用**:
- 查阅 [快速参考](quick-reference.md) 的阶段检查清单
- 需要详细说明时参考 [完整流程](document-driven-development-flow.md)

---

## 文档列表

| 文档 | 用途 | 读者 |
|------|------|------|
| [快速参考](quick-reference.md) | 日常开发速查 | 所有开发者 |
| [完整流程](document-driven-development-flow.md) | 详细流程说明 | 所有开发者 |
| [ADR 0001](../adr/0001-document-driven-development.md) | 采用本流程的决策记录 | 架构师/Tech Lead |

---

## 流程概览

```
需求 → 头脑风暴 → 架构设计 (ADR) → 详细规划 → 执行 (TDD) → 验证完成
```

### 核心规则

```
🚫 NO IMPLEMENTATION WITHOUT APPROVED DESIGN
🚫 NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

### 阶段检查清单

**阶段一：需求讨论**
- [ ] 探索项目上下文
- [ ] 逐一澄清问题
- [ ] 提出 2-3 种方案
- [ ] 编写设计文档
- [ ] Spec 审查通过
- [ ] 用户批准

**阶段二：架构设计**
- [ ] 识别决策点
- [ ] 编写 ADR
- [ ] ADR 审查通过
- [ ] 生成架构图

**阶段三：详细规划**
- [ ] 文件结构规划
- [ ] 任务分解
- [ ] 编写计划
- [ ] 计划审查通过
- [ ] 选择执行模式

**阶段四：执行**
- [ ] 设置 Git Worktree
- [ ] TDD 循环
- [ ] 任务后审查
- [ ] 阻塞时求助

**阶段五：完成**
- [ ] 测试套件通过
- [ ] 最终审查
- [ ] 选择完成选项
- [ ] 清理 Worktree

---

## 技能调用

```bash
# Superpowers 技能
superpowers/brainstorming           # 头脑风暴
superpowers/writing-plans           # 编写计划
superpowers/executing-plans         # 执行计划
superpowers/test-driven-development # TDD
superpowers/requesting-code-review  # 代码审查
superpowers/finishing-a-development-branch # 完成分支
```

---

## Agent 路由

| 需求 | Agent | 说明 |
|------|-------|------|
| "分析架构" | Prometheus | 架构分析 |
| "生成计划" | Prometheus | 计划制定 |
| "实现 X" | Atlas/Hephaestus | 执行 |
| "调试" | Hephaestus | 深度调试 |
| "代码审查" | Librarian | 审查 |

---

## 多项目使用指南

### 全局配置位置
```
~/.config/opencode/docs/
├── dev-process/          # 本流程文档
│   ├── README.md         # 本文件
│   ├── quick-reference.md
│   └── document-driven-development-flow.md
└── adr/                  # 架构决策记录
    └── 0001-document-driven-development.md
```

### 项目级引用
在项目 README 中添加:
```markdown
## 开发流程

本项目遵循 [文档驱动开发流程](~/.config/opencode/docs/dev-process/README.md)。

快速参考：[quick-reference.md](~/.config/opencode/docs/dev-process/quick-reference.md)
```

### 项目级覆盖
如项目有特殊需求，可在项目目录创建:
```
<ProjectRoot>/docs/
└── dev-process/
    └── local-overrides.md  # 项目特定覆盖
```

---

## LSP 配置

LSP (Language Server Protocol) 已配置用于 C++ 项目分析：

- **配置文档**: [lsp-setup.md](lsp-setup.md)
- **clangd 版本**: 18.1.3
- **支持文件**: `.cpp`, `.h`, `.cu`, `.cuh` 等

### 快速验证
```bash
# 检查 clangd
which clangd

# 检查 compile_commands.json
ls -la compile_commands.json
```

### 可用工具
- `lsp_diagnostics` - 获取编译错误/警告
- `lsp_symbols` - 获取文件符号
- `lsp_find_references` - 查找引用
- `lsp_goto_definition` - 跳转定义
- `lsp_rename` - 安全重命名
