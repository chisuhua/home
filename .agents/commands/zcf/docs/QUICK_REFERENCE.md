# 快速参考卡片

## 🎯 完整工作流（一句话版）

```bash
/zcf:arch-doc "系统" → /zcf:arch-doc "错误处理" → /zcf:arch-doc "测试策略" → /zcf:arch-doc "阶段计划" → /zcf:arch-doc "模块设计" → /zcf:arch-doc "模块测试策略" → writing-plans → github-sync → 执行任务 → task-review
```

---

## 📋 命令速查

### 架构文档

```bash
# 总体架构
/zcf:arch-doc "电商分析系统"

# 项目测试策略
/zcf:arch-doc "电商分析系统测试策略"

# 错误处理策略（新增）
/zcf:arch-doc "错误处理策略"

# 阶段实施计划
/zcf:arch-doc "阶段实施计划：电商分析系统"

# 模块详细设计
/zcf:arch-doc "阶段 1：爬虫模块详细设计"

# 模块测试策略
/zcf:arch-doc "阶段 1：爬虫模块测试策略"

# API 规范
/zcf:arch-doc "阶段 1：爬虫模块 API 规范"

# 数据库设计
/zcf:arch-doc "阶段 1：爬虫模块数据库设计"

# 更新文档
/zcf:arch-doc "更新：爬虫模块 API 规范，添加 retry_count 参数"
```

### GitHub 同步

```bash
# 创建 Milestone + Issues
/zcf:github-sync "Phase 1: MVP"

# 创建模块 Issues
/zcf:github-sync "爬虫模块"

# 创建 PR 模板
/zcf:github-sync "PR 模板：爬虫模块"

# 关闭 Issue
/zcf:github-sync "close-issue #1"
```

### 任务评审

```bash
# Task 评审
/zcf:task-review "Task 001 完成"

# 模块评审
/zcf:task-review "爬虫模块完成"

# 阶段评审
/zcf:task-review "Phase 1: MVP 完成"
```

### 任务计划

```bash
# 生成任务计划
skill_use writing-plans
```

---

## 📂 输出路径

### 总体架构
```
docs/architecture/YYYY-MM-DD-<system-name>.md
```

### 项目测试策略（新增）
```
docs/architecture/test-strategy.md
```

### 实施计划
```
docs/architecture/plans/implementation-plan.md
```

### 模块设计
```
docs/architecture/phases/phase-1-mvp/<module-name>/
├── detailed-design.md
├── api-spec.md
├── database-schema.md
└── test-strategy.md          # 模块测试策略（新增）
```

### ADR
```
docs/architecture/decisions/ADR-XXX-<title>.md
```

### 评审
```
docs/architecture/reviews/YYYY-MM-DD-<review-name>-review.md
```

---

## 🔄 工作流图示

```
架构设计          任务计划         GitHub 同步        任务执行        评审
    │                │                │                │              │
    ▼                ▼                ▼                ▼              ▼
/zcf:arch-doc   writing-plans   /zcf:github-sync   subagent      /zcf:task-review
```

---

## ✅ 检查清单

### 架构设计阶段
- [ ] 总体架构文档创建
- [ ] **项目测试策略创建**（新增）
- [ ] 阶段实施计划创建
- [ ] 模块详细设计创建
- [ ] API 规范创建
- [ ] 数据库设计创建
- [ ] **模块测试策略创建**（新增）

### 任务计划阶段
- [ ] writing-plans 生成任务
- [ ] 任务评审通过

### GitHub 同步阶段
- [ ] Milestone 创建
- [ ] Issues 创建
- [ ] PR 模板创建

### 任务执行阶段
- [ ] Task 001 完成
- [ ] Task 评审通过
- [ ] Issue 关闭

### 阶段完成
- [ ] 所有模块完成
- [ ] 阶段评审通过
- [ ] 进入下一阶段

---

## 🔗 相关文件

- **命令**：`~/.claude/commands/zcf/`
- **模板**：`~/.claude/commands/zcf/templates/`
- **文档**：`docs/architecture/`
- **总结**：`IMPLEMENTATION_SUMMARY.md`
