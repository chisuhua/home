---
description: '显示工作流使用指南和快速参考'
allowed_tools: Read(~/.claude/commands/zcf/docs/**)
argument-hint: [guide | quick | all]
# examples:
#   /zcf:guide           # 显示完整工作流指南
#   /zcf:guide quick     # 显示快速参考
#   /zcf:guide all       # 显示所有内容
---

# 工作流指南查看器

**用途**：查看 AI 辅助开发工作流的使用指南

---

## 使用方法

```bash
# 查看完整工作流指南
/zcf:guide

# 查看快速参考
/zcf:guide quick

# 查看全部内容
/zcf:guide all
```

---

## 快速参考

### 完整工作流（一句话版）

```bash
/zcf:arch-doc "系统" → /zcf:arch-doc "错误处理" → /zcf:arch-doc "测试策略" → /zcf:arch-doc "阶段计划" → /zcf:arch-doc "模块设计" → writing-plans → github-sync → 执行任务 → task-review
```

---

### 架构设计阶段

```bash
# 1. 创建总体架构
/zcf:arch-doc "电商分析系统"

# 2. 创建错误处理策略（优先）
/zcf:arch-doc "错误处理策略"

# 3. 创建项目测试策略
/zcf:arch-doc "电商分析系统测试策略"

# 4. 创建实施计划
/zcf:arch-doc "阶段实施计划：电商分析系统"
```

---

### 模块设计阶段（每个模块）

```bash
# 5-8. 创建模块文档
/zcf:arch-doc "阶段 1：爬虫模块详细设计"
/zcf:arch-doc "阶段 1：爬虫模块测试策略"
/zcf:arch-doc "阶段 1：爬虫模块 API 规范"
/zcf:arch-doc "阶段 1：爬虫模块数据库设计"
```

---

### 任务执行阶段

```bash
# 9. 生成任务计划
skill_use writing-plans

# 10. 同步到 GitHub
/zcf:github-sync "Phase 1: MVP"

# 11. 执行任务
task(category="quick", load_skills=["subagent-driven-development"],
     prompt="Task 001: 创建 Crawler 基类")

# 12. 任务评审
/zcf:task-review "Task 001 完成"

# 13. 关闭 Issue
/zcf:github-sync "close-issue #1"
```

---

### 阶段评审阶段

```bash
# 14. 模块评审
/zcf:task-review "爬虫模块完成"

# 15. 阶段评审
/zcf:task-review "Phase 1: MVP 完成"
```

---

## 文档位置

**工作流指南**：`~/.claude/commands/zcf/docs/WORKFLOW_GUIDE.md`

**快速参考**：`~/.claude/commands/zcf/docs/QUICK_REFERENCE.md`

---

## 参考文档

**项目根目录** (`/home/ubuntu/`)：

| 文档 | 用途 |
|------|------|
| `CONSISTENCY_CHECK_REPORT.md` | 文档一致性检查报告 |
| `WORKFLOW_ORDER_UPDATE.md` | 工作流顺序更新总结 |
| `HYBRID_ERROR_HANDLING_COMPLETE.md` | Hybrid 错误处理方案总结 |
| `TEST_STRATEGY_SUMMARY.md` | 测试策略总结 |
| `ERROR_HANDLING_STRATEGY_UPDATE.md` | 错误处理更新记录 |
| `IMPLEMENTATION_SUMMARY.md` | 实施总结 |

---

## 完整工作流图

```
┌─────────────────────────────────────────┐
│   阶段 1：架构设计                       │
├─────────────────────────────────────────┤
│ 1. 总体架构                             │
│ 2. 错误处理策略 ← 优先                  │
│ 3. 测试策略                             │
│ 4. 阶段计划                             │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│   阶段 2：模块设计（每模块）              │
├─────────────────────────────────────────┤
│ 5-8. 详细设计/测试/API/数据库           │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│   阶段 3：任务执行                       │
├─────────────────────────────────────────┤
│ 9. writing-plans → 10. github-sync     │
│ → 11. task → 12. review → 13. close   │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│   阶段 4：阶段评审                       │
├─────────────────────────────────────────┤
│ 14. 模块评审 → 15. 阶段评审             │
└─────────────────────────────────────────┘
```

---

## 常用命令速查

| 命令 | 用途 |
|------|------|
| `/zcf:arch-doc` | 架构文档生成 |
| `/zcf:github-sync` | GitHub 同步 |
| `/zcf:task-review` | 任务评审 |
| `/zcf:guide` | 查看工作流指南 |
| `skill_use writing-plans` | 生成任务计划 |

---

**提示**：详细文档请查看 `~/.claude/commands/zcf/docs/WORKFLOW_GUIDE.md`
