# 完整工作流使用指南

**版本**：v2.0
**最后更新**：2026-03-26
**适用范围**：AI 辅助开发全流程

---

## 📋 目录

1. [工作流总览](#工作流总览)
2. [快速参考](#快速参考)
3. [完整工作流详解](#完整工作流详解)
4. [命令参考](#命令参考)
5. [文档结构](#文档结构)
6. [一致性检查报告](#一致性检查报告)

---

## 工作流总览

### 完整开发流程

```
┌─────────────────────────────────────────────────────────────┐
│                     架构设计阶段                             │
├─────────────────────────────────────────────────────────────┤
│ 1. /zcf:arch-doc "系统"          → 总体架构文档            │
│ 2. /zcf:arch-doc "测试策略"      → 项目测试策略            │
│ 3. /zcf:arch-doc "错误处理"      → 项目错误处理策略        │
│ 4. /zcf:arch-doc "阶段计划"      → 实施计划                │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    模块设计阶段（每模块）                     │
├─────────────────────────────────────────────────────────────┤
│ 5. /zcf:arch-doc "阶段 X：模块详细设计" → 模块详细设计     │
│ 6. /zcf:arch-doc "阶段 X：模块测试策略" → 模块测试策略     │
│ 7. /zcf:arch-doc "阶段 X：模块 API 规范"  → API 规范        │
│ 8. /zcf:arch-doc "阶段 X：模块数据库设计" → 数据库设计     │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                     任务执行阶段                             │
├─────────────────────────────────────────────────────────────┤
│ 9. skill_use writing-plans       → 生成任务计划            │
│ 10. /zcf:github-sync "阶段"     → 同步到 GitHub             │
│ 11. task(...)                   → 执行任务                 │
│ 12. /zcf:task-review "Task"     → 任务评审                 │
│ 13. /zcf:github-sync "close"    → 关闭 Issue               │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                     阶段评审阶段                             │
├─────────────────────────────────────────────────────────────┤
│ 14. /zcf:task-review "模块完成"  → 模块评审                │
│ 15. /zcf:task-review "阶段完成"  → 阶段评审                │
└─────────────────────────────────────────────────────────────┘
```

---

## 快速参考

### 10 分钟速览

```bash
# 步骤 1：创建总体架构（10 分钟）
/zcf:arch-doc "电商分析系统"

# 步骤 2：创建测试策略（5 分钟）
/zcf:arch-doc "电商分析系统测试策略"

# 步骤 3：创建实施计划（5 分钟）
/zcf:arch-doc "阶段实施计划：电商分析系统"

# 步骤 4：创建模块设计（每个模块 10 分钟）
/zcf:arch-doc "阶段 1：爬虫模块详细设计"
/zcf:arch-doc "阶段 1：爬虫模块测试策略"

# 步骤 5：生成任务计划（5 分钟）
skill_use writing-plans

# 步骤 6：同步到 GitHub（2 分钟）
/zcf:github-sync "Phase 1: MVP"

# 步骤 7：执行任务（每个任务 30 分钟）
task(category="quick", load_skills=["subagent-driven-development"],
     prompt="Task 001: 创建 Crawler 基类")

# 步骤 8：任务评审（2 分钟）
/zcf:task-review "Task 001 完成"
```

**总计**：架构设计约 30 分钟 + 模块设计每模块 20 分钟 + 任务执行每任务 30 分钟

---

## 完整工作流详解

### 阶段 1：架构设计

#### 1.1 创建总体架构文档

**命令**：
```bash
/zcf:arch-doc "电商分析系统"
```

**输出**：
- `docs/architecture/YYYY-MM-DD-ecommerce-analysis-system.md`
- `docs/architecture/decisions/ADR-XXX-*.md`
- `docs/architecture/reviews/YYYY-MM-DD-ecommerce-analysis-system-review.md`

**包含内容**：
- 系统概述（愿景、原则、术语）
- 架构决策记录（ADR）
- 系统视图（C4 模型）
- 关键技术选型
- 关键架构内容

---

#### 1.2 创建错误处理策略（优先创建，被测试策略引用）

**命令**：
```bash
/zcf:arch-doc "错误处理策略"
```

**输出**：`docs/architecture/error-handling-strategy.md`

**包含内容**：
- 错误分类（P0-P4）
- 错误处理模式（重试、熔断器、降级）
- 错误日志规范
- 监控指标
- 测试框架
- 覆盖率要求

**注意**：只需创建一次，所有模块引用此文档。**此文档在测试策略之前创建**。

---

#### 1.3 创建项目测试策略（引用错误处理策略）

**命令**：
```bash
/zcf:arch-doc "电商分析系统测试策略"
```

**输出**：`docs/architecture/test-strategy.md`

**包含内容**：
- 测试目标和范围
- 单元测试规范
- Agent 协作测试
- 数据流测试
- E2E 测试
- 错误处理策略（引用 `error-handling-strategy.md`）

---

#### 1.4 创建实施计划

**命令**：
```bash
/zcf:arch-doc "阶段实施计划：电商分析系统"
```

**输出**：`docs/architecture/plans/implementation-plan.md`

**包含内容**：
- 阶段划分（MVP、功能扩展、生产就绪）
- 每个阶段的目标、模块、时间表
- 模块依赖关系
- 里程碑

---

### 阶段 2：模块设计（每个模块重复）

#### 2.1 创建模块详细设计

**命令**：
```bash
/zcf:arch-doc "阶段 1：爬虫模块详细设计"
```

**输出**：
```
docs/architecture/phases/phase-1-mvp/crawler/
├── detailed-design.md
├── api-spec.md
├── database-schema.md
└── test-strategy.md
```

---

#### 2.2 创建模块测试策略

**命令**：
```bash
/zcf:arch-doc "阶段 1：爬虫模块测试策略"
```

**输出**：`docs/architecture/phases/phase-1-mvp/crawler/test-strategy.md`

**包含内容**：
- 模块错误分类（特有错误）
- 单元测试策略
- 错误处理测试（引用项目级策略）
- Agent 协作测试
- 数据流测试
- E2E 测试（模块视角）

---

### 阶段 3：任务执行

#### 3.1 生成任务计划

**命令**：
```bash
skill_use writing-plans
```

**输入**：模块详细设计文档

**输出**：`docs/superpowers/plans/YYYY-MM-DD-module-name.md`

**包含**：原子任务列表（文件路径、测试、命令）

---

#### 3.2 同步到 GitHub

**命令**：
```bash
/zcf:github-sync "Phase 1: MVP"
```

**输出**：
- GitHub Milestone
- GitHub Issues（每个 Task 一个）
- PR 模板

---

#### 3.3 执行任务

**命令**：
```bash
task(category="quick", load_skills=["subagent-driven-development"],
     prompt="Task 001: 创建 Crawler 基类")
```

**输出**：可运行代码 + 测试 + Git 提交

---

#### 3.4 任务评审

**命令**：
```bash
/zcf:task-review "Task 001 完成"
```

**输出**：
- 任务完成报告
- 架构一致性检查
- 文档偏差识别
- 下一步决策建议

---

#### 3.5 关闭 Issue

**命令**：
```bash
/zcf:github-sync "close-issue #1"
```

**输出**：Issue 关闭 + Milestone 进度更新

---

### 阶段 4：阶段评审

#### 4.1 模块完成评审

**命令**：
```bash
/zcf:task-review "爬虫模块完成"
```

**检查**：
- 所有 Task 完成
- 模块整体测试通过
- 文档更新完成

---

#### 4.2 阶段完成评审

**命令**：
```bash
/zcf:task-review "Phase 1: MVP 完成"
```

**输出**：阶段完成报告 + 下一阶段建议

---

## 命令参考

### /zcf:arch-doc

**用途**：架构文档生成

**模式**：
| 模式 | 命令示例 | 输出 |
|------|----------|------|
| 总体架构 | `/zcf:arch-doc "电商分析系统"` | `docs/architecture/YYYY-MM-DD-*.md` |
| 项目测试策略 | `/zcf:arch-doc "电商分析系统测试策略"` | `docs/architecture/test-strategy.md` |
| 错误处理策略 | `/zcf:arch-doc "错误处理策略"` | `docs/architecture/error-handling-strategy.md` |
| 阶段计划 | `/zcf:arch-doc "阶段实施计划：电商分析系统"` | `docs/architecture/plans/implementation-plan.md` |
| 模块详细设计 | `/zcf:arch-doc "阶段 1：爬虫模块详细设计"` | `docs/architecture/phases/phase-1-mvp/crawler/detailed-design.md` |
| 模块测试策略 | `/zcf:arch-doc "阶段 1：爬虫模块测试策略"` | `docs/architecture/phases/phase-1-mvp/crawler/test-strategy.md` |
| API 规范 | `/zcf:arch-doc "阶段 1：爬虫模块 API 规范"` | `docs/architecture/phases/phase-1-mvp/crawler/api-spec.md` |
| 数据库设计 | `/zcf:arch-doc "阶段 1：爬虫模块数据库设计"` | `docs/architecture/phases/phase-1-mvp/crawler/database-schema.md` |
| 更新文档 | `/zcf:arch-doc "更新：爬虫模块 API 规范，添加 retry_count 参数"` | 原文档更新 |

---

### /zcf:github-sync

**用途**：同步任务计划到 GitHub

**模式**：
| 模式 | 命令示例 | 输出 |
|------|----------|------|
| 创建 Milestone | `/zcf:github-sync "Phase 1: MVP"` | GitHub Milestone |
| 创建 Issues | `/zcf:github-sync "爬虫模块"` | GitHub Issues |
| PR 模板 | `/zcf:github-sync "PR 模板：爬虫模块"` | `.github/PULL_REQUEST_TEMPLATE/` |
| 关闭 Issue | `/zcf:github-sync "close-issue #1"` | Issue 关闭 |

---

### /zcf:task-review

**用途**：任务完成评审

**模式**：
| 模式 | 命令示例 | 输出 |
|------|----------|------|
| Task 评审 | `/zcf:task-review "Task 001 完成"` | 任务完成报告 |
| 模块评审 | `/zcf:task-review "爬虫模块完成"` | 模块完成报告 |
| 阶段评审 | `/zcf:task-review "Phase 1: MVP 完成"` | 阶段完成报告 |

---

### skill_use

**用途**：加载技能

**命令**：
```bash
skill_use writing-plans     # 生成任务计划
skill_use brainstorming     # 设计规范
skill_use test-driven-development  # TDD
```

---

## 文档结构

### 目录结构

```
docs/architecture/
├── README.md                             # 架构文档索引
├── YYYY-MM-DD-<system-name>.md          # 总体架构文档
├── test-strategy.md                      # 项目测试策略
├── error-handling-strategy.md            # 错误处理策略
├── plans/
│   ├── README.md
│   └── implementation-plan.md
├── decisions/
│   ├── README.md
│   └── ADR-XXX-<title>.md
├── reviews/
│   ├── README.md
│   └── YYYY-MM-DD-<system-name>-review.md
└── phases/
    ├── README.md
    ├── phase-1-mvp/
    │   ├── README.md
    │   └── crawler/
    │       ├── detailed-design.md
    │       ├── api-spec.md
    │       ├── database-schema.md
    │       └── test-strategy.md
    ├── phase-2-features/
    └── phase-3-production/
```

### 文档引用关系

```
总体架构文档 (YYYY-MM-DD-system.md)
    ↓ 引用
项目测试策略 (test-strategy.md)
    ↓ 引用
错误处理策略 (error-handling-strategy.md) ←──┐
    ↓                                         │
模块测试策略 (phases/phase-X/module/test-strategy.md)
```

---

## 一致性检查报告

### ✅ 一致的文档

| 文档 | 状态 | 说明 |
|------|------|------|
| `arch-doc.md` | ✅ 一致 | 正确引用所有模板和输出路径 |
| `github-sync.md` | ✅ 一致 | 正确引用模板 |
| `task-review.md` | ✅ 一致 | 正确引用项目级文档 |
| `test-strategy-template.md` | ✅ 一致 | 正确引用 `error-handling-strategy.md` |
| `module-test-strategy-template.md` | ✅ 一致 | 正确引用项目级文档 |
| `error-handling-strategy.md` | ✅ 一致 | 独立文档，无外部引用 |
| `docs/architecture/README.md` | ✅ 一致 | 正确描述所有文档类型 |

---

### ⚠️ 需要更新的文档

| 文档 | 问题 | 建议 |
|------|------|------|
| `IMPLEMENTATION_SUMMARY.md` | ⚠️ 未包含错误处理策略 | 添加错误处理策略章节说明 |
| `QUICK_REFERENCE.md` | ⚠️ 未包含错误处理策略命令 | 添加 `/zcf:arch-doc "错误处理策略"` |
| `TEST_STRATEGY_SUMMARY.md` | ⚠️ 错误处理章节已过时 | 更新为引用 `error-handling-strategy.md` |
| `ERROR_HANDLING_STRATEGY_UPDATE.md` | ✅ 一致 | 无需更新 |
| `HYBRID_ERROR_HANDLING_COMPLETE.md` | ✅ 一致 | 无需更新 |

---

### 🔧 建议的修复

#### 1. 更新 QUICK_REFERENCE.md

添加错误处理策略命令：

```markdown
# 架构文档

# 错误处理策略（新增）
/zcf:arch-doc "错误处理策略"
```

---

#### 2. 更新 IMPLEMENTATION_SUMMARY.md

添加错误处理策略章节：

```markdown
### 3. 错误处理策略（新增）
- 创建 `error-handling-strategy.md`
- 定义 P0-P4 错误分类
- 实现重试/熔断器/降级框架
```

---

#### 3. 更新 TEST_STRATEGY_SUMMARY.md

简化错误处理章节，添加引用：

```markdown
## 错误处理策略

详见：[错误处理策略](./error-handling-strategy.md)

项目级错误处理策略包含完整的框架实现、测试工具库和最佳实践。
```

---

## 快速启动模板

### 新项目启动

```bash
# 1. 初始化项目
/zcf:init-project

# 2. 创建总体架构
/zcf:arch-doc "我的系统"

# 3. 创建测试策略
/zcf:arch-doc "我的系统测试策略"

# 4. 创建错误处理策略
/zcf:arch-doc "错误处理策略"

# 5. 创建实施计划
/zcf:arch-doc "阶段实施计划：我的系统"

# 6. 开始第一个模块设计
/zcf:arch-doc "阶段 1：核心模块详细设计"
```

---

## 参考文档

- `QUICK_REFERENCE.md` — 快速参考卡片
- `IMPLEMENTATION_SUMMARY.md` — 实施总结
- `TEST_STRATEGY_SUMMARY.md` — 测试策略总结
- `ERROR_HANDLING_STRATEGY_UPDATE.md` — 错误处理更新
- `HYBRID_ERROR_HANDLING_COMPLETE.md` — Hybrid 方案总结
- `WORKFLOW_GUIDE.md` — 本文档

---

**维护者**：AI Architect

**审查周期**：随工作流变更更新
