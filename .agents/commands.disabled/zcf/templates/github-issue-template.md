# GitHub Issue 模板

**用途**：用于 `/zcf:github-sync` 创建 Issue 时的标准格式

**变量说明**：
- `{{TASK_ID}}` — 任务编号（如 Task 001）
- `{{TASK_TITLE}}` — 任务标题
- `{{MODULE_NAME}}` — 模块名称
- `{{PHASE_NAME}}` — 阶段名称
- `{{PLAN_FILE}}` — 任务计划文件路径
- `{{FILES_CREATE}}` — 需要创建的文件列表
- `{{FILES_MODIFY}}` — 需要修改的文件列表
- `{{ACCEPTANCE_CRITERIA}}` — 验收标准列表
- `{{ESTIMATED_TIME}}` — 预计工时
- `{{DEPENDENCIES}}` — 依赖任务列表
- `{{STEPS}}` — 详细实现步骤（来自 writing-plans）

---

```markdown
---
assignee: {{ASSIGNEE}}
labels: ["{{PHASE_LABEL}}", "{{MODULE_LABEL}}", "feature"]
milestone: {{PHASE_NAME}}
---

## {{TASK_ID}}: {{TASK_TITLE}}

**来源计划**：`{{PLAN_FILE}}`

**所属模块**：{{MODULE_NAME}}

**所属阶段**：{{PHASE_NAME}}

---

## 目标

{{任务目标描述，2-3 句话}}

---

## 文件变更

**创建文件**：
{{#each FILES_CREATE}}
- `{{this}}`
{{/each}}

**修改文件**：
{{#each FILES_MODIFY}}
- `{{this}}`
{{/each}}

---

## 验收标准

{{#each ACCEPTANCE_CRITERIA}}
- [ ] {{this}}
{{/each}}

---

## 预计工时

**估算**：{{ESTIMATED_TIME}}

**依赖任务**：
{{#if DEPENDENCIES}}
{{#each DEPENDENCIES}}
- {{this}}
{{/each}}
{{else}}
无（首个任务）
{{/if}}

---

## 实现步骤

<details>
<summary>查看详细步骤（来自 writing-plans）</summary>

{{STEPS}}

</details>

---

## 完成后请

1. **运行测试**
   ```bash
   {{TEST_COMMAND}}
   ```

2. **运行 Lint**
   ```bash
   {{LINT_COMMAND}}
   ```

3. **提交代码**
   ```bash
   git add {{FILES}}
   git commit -m "{{COMMIT_MESSAGE}}"
   ```

4. **关闭此 Issue 并关联 PR**
   - 创建 PR 时关联此 Issue：`Fixes #{{ISSUE_NUMBER}}`
   - 或使用命令：`gh issue close #{{ISSUE_NUMBER}} --reason completed`

---

## 架构一致性检查

**提交前请确认**：
- [ ] 模块位置符合架构文档
- [ ] 类/函数命名符合设计原则
- [ ] 接口签名符合 api-spec.md
- [ ] 无违规依赖（检查 import 语句）
- [ ] 数据库 Schema 符合 database-schema.md（如适用）

---

**备注**：
{{额外说明或注意事项}}
```

---

## 使用示例

### 示例 1：Task 001 - 创建 Crawler 基类

```markdown
---
assignee: developer-name
labels: ["phase-1", "crawler", "feature"]
milestone: Phase 1: MVP
---

## Task 001: 创建基础爬虫类

**来源计划**：`docs/superpowers/plans/2026-03-26-crawler-module.md`

**所属模块**：爬虫模块

**所属阶段**：Phase 1: MVP

---

## 目标

创建 `Crawler` 基类，实现基础网页抓取功能。
这是爬虫模块的核心组件，为后续 HTML 解析器和 URL 管理器提供基础。

---

## 文件变更

**创建文件**：
- `src/crawler/base.py`
- `tests/crawler/test_base.py`

**修改文件**：
- `src/crawler/__init__.py` （导出 Crawler 类）

---

## 验收标准

- [ ] `Crawler` 类可实例化
- [ ] `fetch(url: str) -> str` 方法返回 HTML
- [ ] `parse(html: str) -> dict` 方法提取标题和链接
- [ ] 单元测试覆盖率 > 80%
- [ ] 通过 lint 检查（ruff）

---

## 预计工时

**估算**：2-3 小时

**依赖任务**：
无（首个任务）

---

## 实现步骤

<details>
<summary>查看详细步骤（来自 writing-plans）</summary>

### Step 1: Write the failing test

```python
def test_crawler_init():
    crawler = Crawler()
    assert crawler is not None

def test_crawler_fetch():
    crawler = Crawler()
    html = crawler.fetch("http://example.com")
    assert "<html>" in html

def test_crawler_parse():
    crawler = Crawler()
    result = crawler.parse("<html><head><title>Test</title></head></html>")
    assert result["title"] == "Test"
```

### Step 2: Run test to verify it fails

```bash
pytest tests/crawler/test_base.py::test_crawler_init -v
```
Expected: FAIL with "NameError: name 'Crawler' is not defined"

### Step 3: Write minimal implementation

```python
# src/crawler/base.py
class Crawler:
    def __init__(self):
        pass
    
    def fetch(self, url: str) -> str:
        import requests
        response = requests.get(url)
        return response.text
    
    def parse(self, html: str) -> dict:
        from bs4 import BeautifulSoup
        soup = BeautifulSoup(html, 'html.parser')
        title = soup.find('title')
        links = soup.find_all('a')
        return {
            "title": title.text if title else "",
            "links": [link.get('href') for link in links]
        }
```

### Step 4: Run test to verify it passes

```bash
pytest tests/crawler/test_base.py -v
```
Expected: PASS (3/3)

### Step 5: Commit

```bash
git add src/crawler/base.py tests/crawler/test_base.py src/crawler/__init__.py
git commit -m "feat: add Crawler base class with fetch and parse methods"
```

</details>

---

## 完成后请

1. **运行测试**
   ```bash
   pytest tests/crawler/test_base.py -v --cov=src/crawler
   ```

2. **运行 Lint**
   ```bash
   ruff check src/crawler/
   ```

3. **提交代码**
   ```bash
   git add src/crawler/base.py tests/crawler/test_base.py src/crawler/__init__.py
   git commit -m "feat: add Crawler base class with fetch and parse methods"
   ```

4. **关闭此 Issue 并关联 PR**
   - 创建 PR 时关联此 Issue：`Fixes #1`
   - 或使用命令：`gh issue close #1 --reason completed`

---

## 架构一致性检查

**提交前请确认**：
- [ ] 模块位置符合架构文档（`src/crawler/`）
- [ ] 类命名符合设计原则（`Crawler` 使用 CamelCase）
- [ ] 接口签名符合 api-spec.md
- [ ] 无违规依赖（爬虫模块不应依赖 presentation 层）
- [ ] 数据库 Schema 符合 database-schema.md（不适用）

---

**备注**：
- 使用 `requests` 库进行 HTTP 请求
- 使用 `beautifulsoup4` 进行 HTML 解析
- 异常处理：网络错误抛出 `CrawlerError` 异常
```

---

## 批量创建 Issues 的 JSON 格式

```json
[
  {
    "title": "Task 001: 创建基础爬虫类",
    "body": "...(见上方示例)...",
    "labels": ["phase-1", "crawler", "feature"],
    "milestone": "Phase 1: MVP"
  },
  {
    "title": "Task 002: 实现 HTML 解析器",
    "body": "...",
    "labels": ["phase-1", "crawler", "feature"],
    "milestone": "Phase 1: MVP"
  }
]
```

---

## 创建命令

### 单个创建
```bash
gh issue create \
  --title "Task 001: 创建基础爬虫类" \
  --body-file /tmp/issue-body.md \
  --label "phase-1,crawler,feature" \
  --milestone "Phase 1: MVP"
```

### 批量创建
```bash
gh issue create --json /tmp/issues.json
```

---

## 模板变量填充指南

**由 `/zcf:github-sync` 自动填充**：

| 变量 | 来源 |
|------|------|
| `{{TASK_ID}}` | 从 plan 文档提取 |
| `{{TASK_TITLE}}` | 从 plan 文档提取 |
| `{{MODULE_NAME}}` | 从用户输入或 plan 文档提取 |
| `{{PHASE_NAME}}` | 从用户输入或 plan 文档提取 |
| `{{PLAN_FILE}}` | 从 plan 文档路径提取 |
| `{{FILES_CREATE}}` | 从 plan 文档的 Files 部分提取 |
| `{{FILES_MODIFY}}` | 从 plan 文档的 Files 部分提取 |
| `{{ACCEPTANCE_CRITERIA}}` | 从 plan 文档提取或生成 |
| `{{ESTIMATED_TIME}}` | 从 plan 文档提取 |
| `{{DEPENDENCIES}}` | 从 plan 文档的任务依赖提取 |
| `{{STEPS}}` | 从 plan 文档的详细步骤提取 |
| `{{TEST_COMMAND}}` | 根据项目类型生成 |
| `{{LINT_COMMAND}}` | 根据项目类型生成 |
| `{{COMMIT_MESSAGE}}` | 根据任务内容生成 |

---

## 最佳实践

1. **Issue 标题** — 使用 "Task XXX: 动词 + 名词" 格式
2. **验收标准** — 使用可验证的陈述（避免"高质量代码"等模糊描述）
3. **实现步骤** — 保持详细，包括完整代码和命令
4. **架构检查** — 列出具体检查项，避免泛泛而谈
5. **标签使用** — 统一标签格式（phase-X, module-name, feature/bug/chore）
