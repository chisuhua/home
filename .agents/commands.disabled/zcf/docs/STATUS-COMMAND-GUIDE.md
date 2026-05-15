# /zcf:status 命令使用指南

**创建日期**：2026-03-26  
**命令位置**：`~/.claude/commands/zcf/status.md`

---

## 🎯 命令用途

在新 session 中快速了解项目工作流完成状态，获得下一步建议。

**适用场景**：
- ✅ 新 session 开始，不了解项目状态
- ✅ 长时间中断后恢复工作
- ✅ 每日站会前生成进度报告
- ✅ 阶段转换前确认完成度
- ✅ 团队成员交接项目

---

## 📋 命令语法

```bash
# 完整状态报告（默认）
/zcf:status

# 简要状态 + 下一步
/zcf:status brief

# 仅下一步建议（最简洁）
/zcf:status next

# 完整报告 + 详细分析
/zcf:status full
```

---

## 📊 输出示例

### 示例 1：完整状态报告（`/zcf:status`）

```markdown
# 项目工作流状态报告

**生成时间**：2026-03-26 10:30:00
**项目根目录**：/home/ubuntu

---

## 📊 总体完成度

| 维度 | 完成度 | 状态 |
|------|--------|------|
| 架构文档 | 2/6 | 🟡 部分完成 |
| 模块设计 | 0/3 | 🔴 进行中 |
| GitHub 追踪 | 0/3 | 🔴 未同步 |
| 代码实现 | 0% | 🔴 未开始 |
| 文档 - 代码一致性 | - | 🟢 一致 |

**总体进度**：15%

---

## 📄 架构文档状态

### 已完成 ✅
- [x] 错误处理策略 (1122 行，~25KB)
- [x] 目录结构索引 (6 个 README)

### 进行中 🟡
- [ ] 总体架构文档 (缺失)
- [ ] 项目测试策略 (缺失)
- [ ] 实施计划 (缺失)

### 待创建 ❌
- [ ] ADR 文档 (0 个)
- [ ] 评审记录 (0 个)

---

## 🧩 模块设计状态

### Phase 1: MVP
| 模块 | 详细设计 | API 规范 | 数据库 | 测试策略 | 完成度 |
|------|----------|----------|--------|----------|--------|
| crawler | ❌ | ❌ | ❌ | ❌ | 0% |
| storage | ❌ | ❌ | ❌ | ❌ | 0% |
| analysis | ❌ | ❌ | ❌ | ❌ | 0% |

### Phase 2: Features
状态：未初始化

### Phase 3: Production
状态：未初始化

---

## 🔗 GitHub 追踪状态

**Milestones**：
- Phase 1: MVP (未创建)
- Phase 2: Features (未创建)

**Issues**：
- 开启中：0
- 已完成：0
- 总计：0

**PRs**：
- 审核中：0
- 已合并：0

---

## 💻 代码实现状态

**源代码**：
- 文件数：0
- 最近一周提交：0
- 状态：未开始

**测试代码**：
- 文件数：0
- 覆盖率：0%

---

## ⚠️ 风险与建议

### 高风险
1. 总体架构文档缺失，模块边界未定义
2. 项目测试策略缺失，无法指导模块测试

### 中风险
1. Phase 1 模块文档全部缺失
2. 无 ADR 记录，技术决策可能遗忘

### 低风险
1. 无评审记录，建议完成首个模块后进行评审

---

## 🎯 下一步建议

### 推荐路径（快速启动）
```bash
# 1. 创建爬虫模块详细设计（10 分钟）
/zcf:arch-doc "阶段 1：爬虫模块详细设计"

# 2. 创建爬虫模块测试策略（5 分钟）
/zcf:arch-doc "阶段 1：爬虫模块测试策略"

# 3. 生成任务计划（5 分钟）
skill_use writing-plans

# 4. 同步到 GitHub（2 分钟）
/zcf:github-sync "Phase 1: MVP"

# 5. 执行第一个任务
task(category="deep", load_skills=["subagent-driven-development"],
     prompt="Task 001: 创建 Crawler 基类")
```

### 备选路径（完整文档）
```bash
# 1. 创建总体架构文档
/zcf:arch-doc "电商分析系统"

# 2. 创建项目测试策略
/zcf:arch-doc "电商分析系统测试策略"

# 3. 创建实施计划
/zcf:arch-doc "阶段实施计划：电商分析系统"

# 然后再开始模块设计...
```

---

## 📋 检查清单

### 立即行动（今天）
- [ ] 选择推荐路径或备选路径
- [ ] 创建第一个文档或模块

### 本周内完成
- [ ] Phase 1 所有模块设计完成
- [ ] GitHub Milestones 和 Issues 创建
- [ ] 第一个模块代码实现完成

### 下周计划
- [ ] Phase 1 代码全部完成
- [ ] 通过 `/zcf:task-review` 进行阶段评审
- [ ] 开始 Phase 2 设计
```

---

### 示例 2：简要报告（`/zcf:status brief`）

```markdown
## 📊 项目状态简报

**生成时间**：2026-03-26 10:30:00
**总体进度**：15%

---

### 架构文档：2/6 完成 🟡
✅ 错误处理策略 (1122 行)
✅ 目录索引 (6 个 README)
❌ 总体架构（缺失）
❌ 测试策略（缺失）
❌ 实施计划（缺失）

### 模块设计：0/3 完成 🔴
Phase 1: MVP - 3 个模块均未开始

### GitHub 追踪：未同步 🔴
Milestones: 0
Issues: 0
PRs: 0

---

## 🎯 下一步建议

1. `/zcf:arch-doc "阶段 1：爬虫模块详细设计"`（10 分钟）
2. `/zcf:arch-doc "阶段 1：爬虫模块测试策略"`（5 分钟）
3. `skill_use writing-plans`（5 分钟）
4. `/zcf:github-sync "Phase 1: MVP"`（2 分钟）

**预计总时间**：22 分钟
```

---

### 示例 3：仅下一步（`/zcf:status next`）

```markdown
## 🎯 下一步建议

### 立即执行（5 分钟内可开始）
/zcf:arch-doc "阶段 1：爬虫模块详细设计"

### 后续步骤
1. /zcf:arch-doc "阶段 1：爬虫模块测试策略"
2. skill_use writing-plans
3. /zcf:github-sync "Phase 1: MVP"

### 备选：先完成总体架构
/zcf:arch-doc "电商分析系统"
```

---

## 🔍 检查项目详解

### 架构文档检查（6 项）

| 检查项 | 检查方法 | 通过标准 |
|--------|---------|---------|
| 总体架构文档 | `find docs/architecture -name "YYYY-MM-DD-*.md"` | 存在文件 |
| 错误处理策略 | `ls docs/architecture/error-handling-strategy.md` | 文件 > 500 行 |
| 项目测试策略 | `ls docs/architecture/test-strategy.md` | 存在文件 |
| 实施计划 | `ls docs/architecture/plans/implementation-plan.md` | 存在文件 |
| ADR 文档 | `find docs/architecture/decisions -name "ADR-*.md" \| wc -l` | 数量 > 0 |
| 评审记录 | `find docs/architecture/reviews -name "*-review.md" \| wc -l` | 数量 > 0 |

---

### 模块设计检查

| 检查项 | 检查方法 | 通过标准 |
|--------|---------|---------|
| Phase 目录 | `find docs/architecture/phases -type d -name "phase-*"` | 目录存在 |
| 模块文档 | `ls phase-X/<module>/*.md` | 4 个文档齐全 |
| 测试引用 | `grep "error-handling-strategy.md" modules/*/test-strategy.md` | 引用数 = 模块数 |

**模块文档清单**：
- `detailed-design.md` — 模块详细设计
- `api-spec.md` — API 接口规范
- `database-schema.md` — 数据库设计
- `test-strategy.md` — 模块测试策略

---

### GitHub 追踪检查

| 检查项 | 检查方法 | 通过标准 |
|--------|---------|---------|
| Milestones | `gh milestone list --state all` | 数量 = Phase 数 |
| Open Issues | `gh issue list --state open \| wc -l` | 数量 > 0 |
| Closed Issues | `gh issue list --state closed \| wc -l` | 数量 ≥ 完成模块数 |
| PRs | `gh pr list --state open \| wc -l` | 数量 ≥ 0 |

---

### 代码实现检查

| 检查项 | 检查方法 | 通过标准 |
|--------|---------|---------|
| 源代码文件 | `find src -name "*.py" -o -name "*.cpp" ... \| wc -l` | 数量 > 10 |
| 测试文件 | `find tests -name "*.py" -o -name "*.cpp" ... \| wc -l` | 数量 ≥ 源码 * 0.5 |
| Git 提交 | `git log --oneline --since="1 week ago" \| wc -l` | 数量 > 5 |

---

### 文档 - 代码一致性检查

| 检查项 | 检查方法 | 通过标准 |
|--------|---------|---------|
| 模块匹配 | 对比文档模块名和代码目录名 | 文档模块 ⊆ 代码模块 |
| API 匹配 | 对比 API 文档端点和代码路由 | 端点数 ≈ 路由数 |

---

## 🎯 状态判断逻辑

### 总体进度计算

```python
# 架构文档（权重 30%）
doc_score = completed_docs / 6 * 30

# 模块设计（权重 25%）
module_score = completed_modules / total_modules * 25

# GitHub 追踪（权重 15%）
github_score = synced_items / 3 * 15

# 代码实现（权重 30%）
code_score = (
    min(source_files / 50, 1) * 0.4 +  # 源代码文件（目标 50）
    min(test_ratio / 0.5, 1) * 0.3 +   # 测试比例（目标 50%）
    min(commits / 20, 1) * 0.3         # 提交数（目标 20）
) * 30

total_score = doc_score + module_score + github_score + code_score
```

---

### 风险等级判断

**高风险**（满足任一）：
```python
if not exists("总体架构文档"):
    risk = "高"
if not exists("项目测试策略"):
    risk = "高"
if module_mismatch_rate > 0.5:
    risk = "高"
```

**中风险**（满足任一）：
```python
if adr_count == 0:
    risk = "中"
if review_count == 0:
    risk = "中"
if phase1_completion < 0.5:
    risk = "中"
```

**低风险**（满足任一）：
```python
if commits_last_week == 0:
    risk = "低"
if test_coverage < 0.2:
    risk = "低"
```

---

## 🚀 建议生成逻辑

### 状态 A：项目启动初期（完成度 < 20%）

**特征**：
- 架构文档完成 < 2/6
- 模块设计完成 = 0
- 代码实现 = 0%

**推荐策略**：快速启动
```
理由：避免过度设计，快速产出可运行代码

建议：
1. 直接开始模块设计（边做边完善架构）
2. 或者先完成总体架构文档（稳扎稳打）

时间估算：22 分钟可开始编码
```

---

### 状态 B：模块设计中期（20% < 完成度 < 60%）

**特征**：
- 架构文档完成 2-4/6
- 模块设计完成 30-50%
- 代码实现开始

**推荐策略**：继续模块设计
```
理由：保持 momentum，完成模块设计后统一执行

建议：
1. 完成剩余模块详细设计
2. 同步到 GitHub Issues
3. 开始任务执行

时间估算：根据剩余模块数计算
```

---

### 状态 C：任务执行期（60% < 完成度 < 80%）

**特征**：
- 架构文档完成 4-5/6
- 模块设计完成 > 80%
- 代码实现进行中

**推荐策略**：加速执行
```
理由：文档基本完成，专注代码实现

建议：
1. 执行剩余任务
2. 进行任务评审
3. 准备阶段评审

时间估算：根据剩余任务数计算
```

---

### 状态 D：阶段收尾期（完成度 > 80%）

**特征**：
- 架构文档完成 6/6
- 模块设计完成 100%
- 代码实现完成 > 90%

**推荐策略**：阶段收尾
```
理由：接近完成，需要收尾和评审

建议：
1. 完成剩余任务评审
2. 进行阶段评审
3. 规划下一阶段

时间估算：1-2 小时
```

---

## 💡 使用技巧

### 技巧 1：每日站会

```bash
# 每天开始工作前
/zcf:status brief

# 输出包括：
# - 总体进度
# - 昨日完成情况（通过 git log 判断）
# - 今日建议任务
```

---

### 技巧 2：新成员接手

```bash
# 新成员第一次进入项目
/zcf:status full

# 完整了解：
# - 项目状态
# - 文档结构
# - 代码进度
# - 下一步工作
```

---

### 技巧 3：阶段转换

```bash
# Phase 1 完成前
/zcf:status full

# 检查：
# - Phase 1 所有模块是否完成
# - 文档 - 代码是否一致
# - 是否可以进入 Phase 2
```

---

### 技巧 4：长期中断后恢复

```bash
# 中断一周后恢复
/zcf:status

# 快速了解：
# - 上次完成到哪里
# - 是否有新提交
# - 下一步做什么
```

---

## 🔗 相关命令

| 命令 | 用途 | 配合使用 |
|------|------|---------|
| `/zcf:status` | 状态分析 | 所有命令 |
| `/zcf:arch-doc` | 架构文档生成 | 状态报告显示文档缺失时 |
| `/zcf:github-sync` | GitHub 同步 | 状态报告显示未同步时 |
| `/zcf:task-review` | 任务评审 | 状态报告显示任务完成后 |
| `/zcf:guide` | 工作流指南 | 需要了解完整流程时 |

---

## 📋 最佳实践

### ✅ 推荐做法

1. **每日检查** — 每天开始工作前运行 `/zcf:status brief`
2. **阶段检查** — 阶段转换前运行 `/zcf:status full`
3. **交接检查** — 团队成员交接时运行 `/zcf:status`
4. **执行建议** — 根据状态报告的建议执行下一步

---

### ❌ 避免做法

1. **不要跳过状态检查** — 直接开始编码可能导致方向错误
2. **不要忽略高风险提示** — 高风险必须优先解决
3. **不要过度依赖** — 状态报告是参考，最终决策需结合项目实际
4. **不要只看不做** — 看到建议后应立即执行

---

## 📖 参考文档

| 文档 | 位置 |
|------|------|
| 命令文件 | `~/.claude/commands/zcf/status.md` |
| 工作流指南 | `~/.claude/commands/zcf/docs/WORKFLOW_GUIDE.md` |
| 快速参考 | `~/.claude/commands/zcf/docs/QUICK_REFERENCE.md` |
| 架构文档索引 | `docs/architecture/README.md` |

---

**命令创建完成**：2026-03-26  
**版本**：v1.0  
**维护者**：架构团队
