---
description: '将任务计划同步到 GitHub，创建 Milestones、Issues 和 PR 模板'
allowed_tools: Read(docs/**), Write(.github/**), Bash(gh issue create, gh milestone create, gh pr create, git)
argument_hint: <同步目标> [phase-name | milestone-name | close-issue #X]
# examples:
#   /zcf:github-sync "Phase 1: MVP"
#   /zcf:github-sync "爬虫模块"
#   /zcf:github-sync "close-issue #1"
---

# Workflow - GitHub 任务同步

**定位**：将任务计划转换为 GitHub Issues/Milestones，实现可视化追踪

**前置条件**：
- 已有任务计划文档（`docs/superpowers/plans/*.md` 或 `docs/architecture/plans/*.md`）
- 已安装 GitHub CLI (`gh`)
- 已认证：`gh auth status`

---

## 核心功能

### 1️⃣ 创建 Milestone（阶段级）

**触发**：
```bash
/zcf:github-sync "Phase 1: MVP"
```

**执行步骤**：

1. **读取任务计划文档**
   ```bash
   # 查找相关 plan 文档
   find docs -name "*phase-1*" -o -name "*mvp*" | head -5
   ```

2. **提取阶段信息**
   - 阶段名称
   - 包含模块列表
   - 预计完成时间
   - 阶段目标

3. **创建 Milestone**
   ```bash
   gh milestone create "Phase 1: MVP" \
     --description "MVP 阶段：核心功能可运行" \
     --due "2026-04-15"
   ```

4. **输出结果**
   ```
   ✅ 创建 Milestone #1: Phase 1: MVP
      URL: https://github.com/owner/repo/milestone/1
      截止：2026-04-15
   ```

---

### 2️⃣ 创建 Issues（任务级）

**触发**：
```bash
/zcf:github-sync "爬虫模块"
```

**执行步骤**：

1. **读取模块任务计划**
   ```bash
   # 查找模块 plan 文档
   find docs -name "*crawler*" | grep -E "\.md$"
   ```

2. **为每个 Task 创建 Issue**
   
   **Issue 结构**：
   ```markdown
   ---
   assignee: [开发者]
   labels: ["phase-1", "crawler", "feature"]
   milestone: Phase 1: MVP
   ---
   
   ## Task 001: 创建基础爬虫类
   
   **来源计划**：`docs/superpowers/plans/2026-03-26-crawler-module.md`
   
   **目标**：
   - 创建 `Crawler` 基类
   - 实现基础抓取方法
   - 编写单元测试
   
   **文件**：
   - Create: `src/crawler/base.py`
   - Test: `tests/crawler/test_base.py`
   
   **验收标准**：
   - [ ] `Crawler` 类可实例化
   - [ ] `fetch()` 方法返回 HTML
   - [ ] 单元测试覆盖率 > 80%
   
   **预计工时**：2-3 小时
   
   **依赖任务**：无（首个任务）
   
   ---
   
   ## 实现步骤
   
   <details>
   <summary>查看详细步骤（来自 writing-plans）</summary>
   
   ### Step 1: Write the failing test
   ```python
   def test_crawler_fetch():
       crawler = Crawler()
       html = crawler.fetch("http://example.com")
       assert "<html>" in html
   ```
   
   ### Step 2: Run test to verify it fails
   ```bash
   pytest tests/crawler/test_base.py::test_crawler_fetch -v
   ```
   Expected: FAIL with "NameError: name 'Crawler' is not defined"
   
   ### Step 3: Write minimal implementation
   ...（完整步骤来自 plan 文档）
   
   </details>
   
   ---
   
   **完成后请**：
   1. 运行测试：`pytest tests/crawler/ -v`
   2. 运行 lint：`ruff check src/crawler/`
   3. 提交代码：`git commit -m "feat: add Crawler base class"`
   4. 关闭此 Issue 并关联 PR
   ```

3. **批量创建 Issues**
   ```bash
   # 方式 1：使用 gh issue create
   gh issue create \
     --title "Task 001: 创建基础爬虫类" \
     --body-file /tmp/issue-body.md \
     --label "phase-1,crawler,feature" \
     --milestone "Phase 1: MVP"
   
   # 方式 2：批量创建（从 JSON）
   gh issue create --json /tmp/issues.json
   ```

4. **输出结果**
   ```
   ✅ 创建 Issue #1: Task 001: 创建基础爬虫类
   ✅ 创建 Issue #2: Task 002: 实现 HTML 解析器
   ✅ 创建 Issue #3: Task 003: 添加 URL 管理器
   ...
   
   📋 查看 Issues: https://github.com/owner/repo/issues?q=milestone:"Phase+1:+MVP"
   ```

---

### 3️⃣ 创建 PR 模板（模块级）

**触发**：
```bash
/zcf:github-sync "PR 模板：爬虫模块"
```

**执行步骤**：

1. **创建 PR 模板文件**
   ```markdown
   ## Phase 1: 爬虫模块
   
   **关联 Issues**： #1, #2, #3, #4, #5
   
   **架构文档**：
   - 总体架构：`docs/architecture/2026-03-26-ecommerce-analysis-system.md`
   - 模块设计：`docs/architecture/phases/phase-1/crawler/detailed-design.md`
   - API 规范：`docs/architecture/phases/phase-1/crawler/api-spec.md`
   
   **变更清单**：
   - `src/crawler/base.py` — 爬虫基类
   - `src/crawler/html_parser.py` — HTML 解析器
   - `tests/crawler/test_base.py` — 基础测试
   
   **测试报告**：
   ```bash
   pytest tests/crawler/ -v --cov=src/crawler
   # 覆盖率：85%
   # 通过：12/12
   ```
   
   **架构一致性检查**：
   - [ ] 模块依赖符合架构文档（无循环依赖）
   - [ ] API 接口符合 api-spec.md
   - [ ] 数据库 Schema 符合 database-schema.md
   
   **评审清单**：
   - [ ] 代码通过 lint 检查
   - [ ] 所有测试通过
   - [ ] 添加了必要的注释
   - [ ] 更新了相关文档
   ```

2. **保存到 `.github/PULL_REQUEST_TEMPLATE/`**
   ```bash
   mkdir -p .github/PULL_REQUEST_TEMPLATE
   cp /tmp/pr-template.md .github/PULL_REQUEST_TEMPLATE/crawler-module.md
   ```

3. **输出结果**
   ```
   ✅ 创建 PR 模板：.github/PULL_REQUEST_TEMPLATE/crawler-module.md
   
   📝 创建 PR 时使用：
   gh pr create --template crawler-module.md
   ```

---

### 4️⃣ 关闭 Issue 并关联 PR

**触发**：
```bash
/zcf:github-sync "close-issue #1"
```

**执行步骤**：

1. **验证任务完成**
   ```bash
   # 检查提交是否存在
   git log --oneline -10 | grep "Crawler base class"
   
   # 检查测试是否通过
   pytest tests/crawler/test_base.py -v
   ```

2. **关闭 Issue**
   ```bash
   gh issue close #1 \
     --comment "已完成，PR #15 已合并" \
     --reason completed
   ```

3. **更新 Milestone 进度**
   ```bash
   # 自动更新进度（GitHub 自动计算）
   gh milestone view "Phase 1: MVP"
   ```

4. **输出结果**
   ```
   ✅ 关闭 Issue #1: Task 001: 创建基础爬虫类
   ✅ 关联 PR: #15
   📊 Milestone 进度：1/12 (8%)
   ```

---

## 同步模式

### 模式 A：阶段同步（创建 Milestone + 所有 Issues）

```bash
/zcf:github-sync "Phase 1: MVP"
```

**执行流程**：
1. 读取 `docs/architecture/plans/implementation-plan.md`
2. 提取阶段 1 的所有模块
3. 创建 Milestone
4. 为每个模块创建 Issue
5. 创建模块 PR 模板
6. 输出同步报告

---

### 模式 B：模块同步（创建模块 Issues）

```bash
/zcf:github-sync "爬虫模块"
```

**执行流程**：
1. 读取 `docs/architecture/phases/phase-1/crawler/detailed-design.md`
2. 读取 `docs/superpowers/plans/2026-03-26-crawler-module.md`
3. 为每个 Task 创建 Issue
4. 输出同步报告

---

### 模式 C：PR 模板创建

```bash
/zcf:github-sync "PR 模板：爬虫模块"
```

**执行流程**：
1. 读取模块详细设计文档
2. 读取架构文档（获取文档链接）
3. 生成 PR 模板
4. 保存到 `.github/PULL_REQUEST_TEMPLATE/`

---

### 模式 D：Issue 关闭

```bash
/zcf:github-sync "close-issue #1"
```

**执行流程**：
1. 验证任务完成（提交、测试）
2. 关闭 Issue
3. 更新 Milestone 进度
4. 输出完成报告

---

## 命令参考

### 创建 Milestone
```bash
gh milestone create "名称" \
  --description "描述" \
  --due "YYYY-MM-DD"
```

### 创建 Issue
```bash
gh issue create \
  --title "标题" \
  --body-file /tmp/body.md \
  --label "label1,label2" \
  --milestone "Milestone 名称"
```

### 批量创建 Issues（JSON）
```bash
# issues.json 格式
[
  {
    "title": "Task 001: 创建基础爬虫类",
    "body": "...",
    "labels": ["phase-1", "crawler"],
    "milestone": "Phase 1: MVP"
  }
]

# 执行
gh issue create --json /tmp/issues.json
```

### 关闭 Issue
```bash
gh issue close #ID \
  --comment "关闭原因" \
  --reason completed
```

### 查看 Milestone 进度
```bash
gh milestone view "名称"
```

---

## 输出报告格式

```markdown
# GitHub 同步报告

## 创建结果

### Milestone
✅ #1: Phase 1: MVP
   URL: https://github.com/owner/repo/milestone/1
   截止：2026-04-15

### Issues
✅ #1: Task 001: 创建基础爬虫类
✅ #2: Task 002: 实现 HTML 解析器
✅ #3: Task 003: 添加 URL 管理器

### PR 模板
✅ .github/PULL_REQUEST_TEMPLATE/crawler-module.md

## 进度追踪

**Milestone 进度**：0/12 (0%)
**查看 Issues**：https://github.com/owner/repo/issues?q=milestone:"Phase+1:+MVP"

## 下一步

1. 执行 Task 001
2. 完成后运行：`/zcf:task-review "Task 001 完成"`
3. 关闭 Issue：`/zcf:github-sync "close-issue #1"`
```

---

## 错误处理

### 常见错误

**错误 1**：GitHub CLI 未安装
```
❌ gh: command not found
解决方案：brew install gh 或 apt-get install gh
```

**错误 2**：未认证
```
❌ gh: To get started with GitHub CLI, please run `gh auth login`
解决方案：gh auth login
```

**错误 3**：Milestone 已存在
```
⚠️ Milestone "Phase 1: MVP" already exists (ID: #1)
解决方案：使用现有 Milestone，跳过创建
```

**错误 4**：Issue 已存在
```
⚠️ Issue "Task 001: 创建基础爬虫类" already exists (ID: #1)
解决方案：跳过创建，更新现有 Issue
```

---

## 时间戳获取规则

**任何需要时间戳的场景，必须通过 bash 命令获取**：

```bash
# 默认格式
date +'%Y-%m-%d'

# 文件名格式
date +'%Y-%m-%d_%H%M%S'

# ISO 格式
date +'%Y-%m-%dT%H:%M:%S%z'
```

---

## 与现有工作流的关系

| 命令 | 定位 | 输出 |
|------|------|------|
| `/zcf:arch-doc` | 架构文档生成 | 架构文档 + 阶段计划 + 详细设计 |
| `writing-plans` | 任务计划生成 | 原子任务列表 |
| `/zcf:github-sync` | **GitHub 同步** | **Milestones + Issues + PR 模板** |
| `/zcf:task-review` | 任务评审 | 完成报告 + 架构偏差检查 |
| `/zcf:workflow` | 代码开发 | 可运行代码 + 测试 |

---

**开始执行前，先读取用户输入的同步目标，然后识别同步模式。**
