# 文档驱动开发流程 - 快速参考

> **用途**: 日常开发快速查阅  
> **完整文档**: [document-driven-development-flow.md](document-driven-development-flow.md)  
> **全局位置**: `~/.config/opencode/docs/dev-process/`

---

## 流程总览

```
需求 → 头脑风暴 → 架构设计 (ADR) → 详细规划 → 执行 (TDD) → 验证完成
  ↑              ↑            ↑           ↑           ↑
  └──────────────┴────────────┴───────────┴───────────┘
                        可迭代回溯
```

---

## 何时使用完整流程

| 场景 | 流程 | 说明 |
|------|------|------|
| 新功能开发 | ✅ 完整 | 所有阶段 |
| Bug 修复 | ⚡ 简化 | 跳过头脑风暴，直接规划 +TDD |
| 架构重构 | ✅ 完整 + 额外审查 | 多轮 ADR |
| 小修改 | ⚡ 最简 | 仅计划 + 验证 |

---

## 核心规则

### 🚫 禁止

```
NO IMPLEMENTATION WITHOUT APPROVED DESIGN
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

### ✅ 必须

- 设计文档批准前 → 不写实现代码
- 计划审查通过前 → 不开始执行
- 每个新功能 → 必须先写测试
- 每个任务完成 → 必须代码审查

---

## 阶段检查清单

### 阶段一：需求讨论
- [ ] 探索项目上下文
- [ ] 逐一澄清问题 (一次一个)
- [ ] 提出 2-3 种方案
- [ ] 逐节批准设计
- [ ] 编写设计文档 → `docs/superpowers/specs/`
- [ ] Spec 审查通过 (≤3 轮)
- [ ] 用户批准

### 阶段二：架构设计 (如需要)
- [ ] 识别决策点
- [ ] 编写 ADR → `docs/adr/`
- [ ] ADR 审查通过
- [ ] 生成架构图 (Mermaid)

### 阶段三：详细规划
- [ ] 文件结构规划
- [ ] 任务分解 (2-5 分钟/步)
- [ ] 编写计划 → `docs/superpowers/plans/`
- [ ] 计划审查通过 (≤3 轮)
- [ ] 选择执行模式 (子代理/内联)

### 阶段四：执行
- [ ] 设置 Git Worktree
- [ ] 每个任务：写测试 → 看失败 → 实现 → 看通过 → 提交
- [ ] 每个任务后代码审查
- [ ] 阻塞时停止求助

### 阶段五：完成
- [ ] 完整测试套件通过
- [ ] 最终代码审查
- [ ] 选择：合并/PR/保留/丢弃
- [ ] 清理 Worktree

---

## 文档路径

```
docs/
├── superpowers/
│   ├── specs/           # 设计文档 (阶段一)
│   └── plans/           # 实现计划 (阶段三)
├── adr/                 # 架构决策 (阶段二)
└── api/                 # API 文档 (Librarian)

state/                   # 状态追踪
├── in_progress.lock
├── progress.log
└── completed_*.json
```

---

## Agent 路由

| 需求 | Agent | 技能 |
|------|-------|------|
| "分析架构" | Prometheus | cpp-architecture |
| "生成计划" | Prometheus | writing-plans |
| "实现 X" | Atlas/Hephaestus | executing-plans |
| "调试" | Hephaestus | cpp-debug, systematic-debugging |
| "加库" | Atlas | cmake-manage |
| "代码审查" | Librarian | requesting-code-review |
| "文档" | Librarian | - |

---

## TDD 循环

```
RED   → 写测试 → 运行确认失败
GREEN → 写实现 → 运行确认通过
REFACTOR → 清理 → 确认保持通过
```

**铁律**: 没看过测试失败 → 删除代码 → 重来

---

## 代码审查时机

- 每个任务完成后
- 主要功能完成后
- 遇到难题时
- 合并/PR 前

**审查等级**:
- Critical → 立即修复
- Important → 继续前修复
- Minor → 记录待处理

---

## 可迭代回溯

| 情况 | 回溯到 | 操作 |
|------|--------|------|
| 新需求 | 阶段一 | 更新设计 |
| 架构问题 | 阶段二 | 更新 ADR |
| 计划问题 | 阶段三 | 更新计划 |
| 执行阻塞 | 阶段三/二/一 | 调整计划/架构/需求 |

---

## 常用命令

### Git Worktree
```bash
git worktree add -b feature/xxx ../worktrees/xxx
git worktree remove ../worktrees/xxx
```

### 测试
```bash
cd build && ctest
ctest -R test_name -V
```

### 静态检查
```bash
clang-tidy -p build/ src/file.cpp
clang-format -i src/file.cpp
```

### 编译
```bash
cmake --build build --target target_name
```

---

## 技能调用

```bash
# 技能名称格式
superpowers/<skill-name>

# 示例
superpowers/brainstorming
superpowers/writing-plans
superpowers/executing-plans
superpowers/test-driven-development
superpowers/requesting-code-review
superpowers/finishing-a-development-branch
```

---

## 阻塞处理

**停止条件**:
- 缺少依赖
- 测试反复失败
- 指令不清晰
- 技术难题

**操作**:
1. 记录阻塞点
2. 向用户请求帮助
3. 等待澄清
4. 继续

**不要**: 猜测、跳过验证、隐藏问题

---

## 完成选项

```
1. Merge locally     → 本地合并，删除分支
2. Create PR         → 推送，创建 PR
3. Keep as-is        → 保留分支
4. Discard           → 删除 (需确认 "discard")
```

---

## 相关文档

- [完整流程](document-driven-development-flow.md)
- [README.md](README.md)
- [ADR 0001](../adr/0001-document-driven-development.md)
- [AGENTS.md](../agents/AGENTS.md)
- [Superpowers Skills](../superpowers/skills/)
