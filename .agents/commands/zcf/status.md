---
description: '分析项目工作流完成状态，生成进度报告并给出下一步建议'
allowed_tools: Read(docs/**, plans/**, .github/**), Glob, Grep, Bash(gh issue list, gh milestone list, git log, git status, find, ls, date)
argument_hint: [full | brief | next]
# examples:
#   /zcf:status              # 完整状态报告
#   /zcf:status brief        # 简要状态 + 下一步
#   /zcf:status next         # 只显示下一步建议
---

# Workflow - 工作流状态分析

**定位**：在任意时间点分析项目工作流完成状态，生成进度报告并给出下一步建议

**使用场景**：
- 新 session 开始时了解项目状态
- 长时间中断后恢复工作
- 阶段转换前确认完成度
- 每日站会前生成进度报告

**目标读者**：软件架构师、项目负责人、团队成员

---

## 核心功能

### 1️⃣ 架构文档完成度分析

**检查项目**：

#### A. 总体架构文档
```bash
# 检查总体架构文档
find docs/architecture -maxdepth 1 -name "*.md" | grep -v README
ls -la docs/architecture/YYYY-MM-DD-*.md 2>/dev/null
```

**评估标准**：
- ✅ 已创建：存在 `YYYY-MM-DD-<system-name>.md`
- ❌ 缺失：无总体架构文档

---

#### B. 错误处理策略
```bash
# 检查错误处理策略
ls -la docs/architecture/error-handling-strategy.md 2>/dev/null
wc -l docs/architecture/error-handling-strategy.md 2>/dev/null
```

**评估标准**：
- ✅ 完整：> 500 行，包含 P0-P4 分类、处理模式、日志规范
- ⚠️ 简化：< 200 行，只有框架
- ❌ 缺失：文件不存在

---

#### C. 项目测试策略
```bash
# 检查项目测试策略
ls -la docs/architecture/test-strategy.md 2>/dev/null
```

**评估标准**：
- ✅ 已创建：存在 `test-strategy.md`，引用错误处理策略
- ❌ 缺失：文件不存在

---

#### D. 实施计划
```bash
# 检查实施计划
ls -la docs/architecture/plans/implementation-plan.md 2>/dev/null
```

**评估标准**：
- ✅ 已创建：存在 `implementation-plan.md`，包含阶段划分
- ❌ 缺失：文件不存在

---

#### E. 架构决策记录 (ADR)
```bash
# 检查 ADR 数量
find docs/architecture/decisions -name "ADR-*.md" 2>/dev/null | wc -l
```

**评估标准**：
- ✅ 有记录：ADR 数量 > 0
- ⚠️ 过少：ADR 数量 = 0（可能决策未记录）

---

#### F. 评审记录
```bash
# 检查评审记录
find docs/architecture/reviews -name "*-review.md" 2>/dev/null | wc -l
```

**评估标准**：
- ✅ 有评审：评审记录 > 0
- ❌ 无评审：评审记录 = 0

---

### 2️⃣ 模块设计完成度分析

**检查项目**：

#### A. Phase 目录结构
```bash
# 列出所有 phase 目录
find docs/architecture/phases -type d -name "phase-*" | sort

# 检查每个 phase 的 README
find docs/architecture/phases -name "README.md" | wc -l
```

---

#### B. 模块文档完整性
```bash
# 检查每个模块的文档
for module_dir in docs/architecture/phases/phase-*/; do
    for module in $module_dir/*/; do
        if [ -d "$module" ] && [[ "$module" != *"README"* ]]; then
            echo "=== $module ==="
            ls "$module"/*.md 2>/dev/null || echo "无文档"
        fi
    done
done
```

**评估标准**：
- ✅ 完整：4 个文档齐全（detailed-design, api-spec, database-schema, test-strategy）
- ⚠️ 部分：1-3 个文档
- ❌ 缺失：无文档

---

#### C. 模块测试策略引用检查
```bash
# 检查模块测试策略是否引用项目级错误处理策略
grep -r "error-handling-strategy.md" docs/architecture/phases/*/ 2>/dev/null | wc -l
```

**评估标准**：
- ✅ 正确引用：引用数 = 模块数
- ❌ 未引用：引用数 = 0（可能导致重复定义）

---

### 3️⃣ GitHub 任务追踪状态

**检查项目**：

#### A. Milestone 状态
```bash
# 检查 GitHub Milestones（如果已认证）
gh milestone list --state all 2>/dev/null || echo "未认证或无 Milestones"
```

**评估标准**：
- ✅ 已同步：Milestone 数量 = Phase 数量
- ⚠️ 部分同步：Milestone 数量 < Phase 数量
- ❌ 未同步：无 Milestones

---

#### B. Issue 状态
```bash
# 检查 Issues 状态
gh issue list --state open 2>/dev/null | wc -l  # 开启中
gh issue list --state closed 2>/dev/null | wc -l  # 已完成
```

**评估标准**：
- ✅ 正常：开启数 + 完成数 = 总任务数
- ⚠️ 滞后：完成数 < 文档完成模块数（可能未更新）
- ❌ 未同步：无 Issues

---

#### C. PR 状态
```bash
# 检查 PRs
gh pr list --state open 2>/dev/null | wc -l  # 审核中
gh pr list --state merged 2>/dev/null | wc -l  # 已合并
```

**评估标准**：
- ✅ 活跃：有 open 或 merged PRs
- ⚠️ 停滞：有 open PRs 但长期未合并（> 7 天）
- ❌ 未使用：无 PRs

---

### 4️⃣ 代码实现进度

**检查项目**：

#### A. 源代码目录结构
```bash
# 检查源代码目录
find src -type f -name "*.py" -o -name "*.cpp" -o -name "*.js" -o -name "*.ts" 2>/dev/null | wc -l
find src -type d | head -20
```

**评估标准**：
- ✅ 已实现：源代码文件 > 10
- ⚠️ 初期：源代码文件 1-10
- ❌ 未开始：无源代码

---

#### B. 测试代码
```bash
# 检查测试代码
find tests -type f -name "*.py" -o -name "*.cpp" -o -name "*.js" -o -name "*.ts" 2>/dev/null | wc -l
```

**评估标准**：
- ✅ 配套：测试文件数 ≈ 源代码文件数 * 0.5
- ⚠️ 不足：测试文件数 < 源代码文件数 * 0.2
- ❌ 无测试：无测试文件

---

#### C. Git 提交历史
```bash
# 检查提交历史
git log --oneline --since="1 week ago" 2>/dev/null | wc -l  # 最近一周
git log --oneline 2>/dev/null | head -5
```

**评估标准**：
- ✅ 活跃：最近一周提交 > 5
- ⚠️ 缓慢：最近一周提交 1-5
- ❌ 停滞：最近一周提交 = 0

---

### 5️⃣ 文档 - 代码一致性检查

**检查项目**：

#### A. 文档中提到的模块是否在代码中存在
```bash
# 提取文档中的模块名
grep -r "模块.*详细设计" docs/architecture/phases/ 2>/dev/null | \
    sed 's/.*阶段.*：\(.*\)模块.*/\1/' | sort -u

# 检查源代码目录
ls -d src/*/ 2>/dev/null | sed 's/src\/\(.*\)\//\1/' | sort -u
```

**评估标准**：
- ✅ 一致：文档模块 ⊆ 代码模块
- ⚠️ 部分一致：部分模块有代码
- ❌ 不一致：文档模块与代码模块无交集

---

#### B. API 文档与实现对比
```bash
# 检查 API 文档提到的端点
grep -r "GET\|POST\|PUT\|DELETE" docs/architecture/phases/*/api-spec.md 2>/dev/null | wc -l

# 检查代码中的路由定义
grep -r "@app.route\|router.get\|router.post" src/ 2>/dev/null | wc -l
```

**评估标准**：
- ✅ 一致：API 端点数 ≈ 路由数
- ⚠️ 滞后：路由数 < API 端点数（代码未完成）
- ❌ 不一致：路由数 >> API 端点数（文档未更新）

---

## 状态报告生成

### 输出格式

```markdown
# 项目工作流状态报告

**生成时间**：YYYY-MM-DD HH:MM:SS
**项目根目录**：{project_root}

---

## 📊 总体完成度

| 维度 | 完成度 | 状态 |
|------|--------|------|
| 架构文档 | X/6 | 🟡 部分完成 |
| 模块设计 | X/Y | 🔴 进行中 |
| GitHub 追踪 | X/3 | 🟢 正常 |
| 代码实现 | X% | 🟡 部分完成 |
| 文档 -代码一致性 | - | 🟢 一致 |

**总体进度**：XX%

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

## 命令参数

### `/zcf:status`（默认）
生成完整状态报告（如上所示）

---

### `/zcf:status brief`
生成简要状态 + 下一步建议

**输出格式**：
```markdown
## 📊 项目状态简报

**总体进度**：15%

**架构文档**：2/6 完成
- ✅ 错误处理策略
- ✅ 目录索引
- ❌ 总体架构（缺失）
- ❌ 测试策略（缺失）
- ❌ 实施计划（缺失）

**模块设计**：0/3 完成（Phase 1）

**下一步**：
1. /zcf:arch-doc "阶段 1：爬虫模块详细设计"
2. /zcf:arch-doc "阶段 1：爬虫模块测试策略"
3. skill_use writing-plans
```

---

### `/zcf:status next`
只显示下一步建议（最简洁）

**输出格式**：
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

## 执行流程

### 步骤 1：收集上下文（并行）

```bash
# 同时执行以下检查（后台任务）
task(subagent_type="explore", prompt="检查 docs/architecture/ 下所有.md 文件...")
task(subagent_type="explore", prompt="检查 src/ 和 tests/ 目录结构...")
task(subagent_type="explore", prompt="读取关键文档评估质量...")

# GitHub 检查（如果已认证）
gh milestone list --state all
gh issue list --state open
gh issue list --state closed
```

---

### 步骤 2：分析完成度

**架构文档完成度计算**：
```python
completed = 0
total = 6

if exists("YYYY-MM-DD-<system-name>.md"): completed += 1
if exists("error-handling-strategy.md") and lines > 500: completed += 1
if exists("test-strategy.md"): completed += 1
if exists("plans/implementation-plan.md"): completed += 1
if count("decisions/ADR-*.md") > 0: completed += 1
if count("reviews/*-review.md") > 0: completed += 1

completion_rate = completed / total * 100
```

---

### 步骤 3：识别风险

**高风险条件**（满足任一）：
- 总体架构文档缺失
- 项目测试策略缺失
- 文档 - 代码严重不一致（模块完全不匹配）

**中风险条件**（满足任一）：
- 无 ADR 记录
- 无评审记录
- Phase 1 模块文档完成度 < 50%

**低风险条件**：
- 最近一周无提交
- 测试覆盖率 < 20%

---

### 步骤 4：生成建议

**根据状态生成不同建议**：

#### 状态 A：项目启动初期（完成度 < 20%）
```
推荐：快速启动路径
1. 直接开始模块设计（边做边完善架构）
2. 或者先完成总体架构文档（稳扎稳打）
```

#### 状态 B：模块设计中期（20% < 完成度 < 60%）
```
推荐：继续模块设计
1. 完成剩余模块详细设计
2. 同步到 GitHub Issues
3. 开始任务执行
```

#### 状态 C：任务执行期（60% < 完成度 < 80%）
```
推荐：加速执行
1. 执行剩余任务
2. 进行任务评审
3. 准备阶段评审
```

#### 状态 D：阶段收尾期（完成度 > 80%）
```
推荐：阶段收尾
1. 完成剩余任务评审
2. 进行阶段评审
3. 规划下一阶段
```

---

## 使用示例

### 示例 1：新 session 开始

```bash
# 用户进入新 session，询问状态
/zcf:status

# AI 生成完整报告，包括：
# - 架构文档完成度
# - 模块设计进度
# - GitHub 追踪状态
# - 代码实现进度
# - 下一步建议
```

---

### 示例 2：每日站会

```bash
# 快速查看状态
/zcf:status brief

# 输出：
# - 总体进度
# - 昨日完成情况
# - 今日建议任务
```

---

### 示例 3：只需要下一步建议

```bash
# 最简洁模式
/zcf:status next

# 输出：
# - 1-3 个下一步命令
# - 预计时间
```

---

### 示例 4：阶段转换前

```bash
# 完整状态 + 详细分析
/zcf:status full

# 输出：
# - 完整报告
# - 文档 - 代码一致性检查
# - 风险评估
# - 阶段完成判断
```

---

## 沟通守则

1. **客观中立** — 基于事实数据，不夸大不贬低
2. **具体可操作** — 建议必须是具体命令，可立即执行
3. **风险透明** — 高风险必须明确告知，提供缓解方案
4. **灵活适配** — 根据项目状态调整建议（快速启动 vs 完整文档）
5. **时间估算** — 每个建议附带预计时间

---

## 相关文件

- **命令位置**：`~/.claude/commands/zcf/status.md`
- **相关命令**：
  - `/zcf:arch-doc` — 架构文档生成
  - `/zcf:github-sync` — GitHub 同步
  - `/zcf:task-review` — 任务评审
- **参考文档**：
  - `~/.claude/commands/zcf/docs/WORKFLOW_GUIDE.md`
  - `~/.claude/commands/zcf/docs/QUICK_REFERENCE.md`

---

## 开始执行

**收到 `/zcf:status` 命令后**：

1. 先询问用户是否需要特定模式：
   ```
   需要生成完整状态报告还是简要报告？
   - 完整报告：/zcf:status 或 /zcf:status full
   - 简要报告：/zcf:status brief
   - 仅下一步：/zcf:status next
   ```

2. 如果用户已指定模式，直接执行相应分析

3. 并行启动 explore agents 收集上下文

4. 等待结果后生成报告

5. 最后询问用户是否执行建议的下一步

---

**命令结束**
