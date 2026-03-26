# 任务评审报告模板

**用途**：用于 `/zcf:task-review` 生成的标准化评审报告

**保存位置**：`docs/architecture/reviews/task-XXX-review.md`

---

## 模板结构

```markdown
# {{TASK_ID}} 完成评审报告

**日期**：{{DATE}}
**评审人**：{{REVIEWER}}

---

## 任务执行结果

**任务**：{{TASK_TITLE}}
**执行时间**：{{START_TIME}}-{{END_TIME}}（{{DURATION}}）
**预计时间**：{{ESTIMATED_TIME}}
**状态**：{{STATUS}}

**产出物**：
{{#each FILES_CREATED}}
- `{{this.path}}` ({{this.lines}} 行)
{{/each}}
{{#each FILES_MODIFIED}}
- `{{this.path}}` (修改 {{this.changed_lines}} 行)
{{/each}}

**Git 提交**：
{{#each COMMITS}}
- `{{this.hash}}` {{this.message}}
{{/each}}

**测试结果**：
```bash
{{TEST_COMMAND}}
{{TEST_OUTPUT}}
# 覆盖率：{{COVERAGE}}%
```

---

## 架构一致性检查

### ✅ 一致项
{{#each CONSISTENT_ITEMS}}
- {{this}}
{{/each}}

### ⚠️ 发现偏差

{{#each DEVIATIONS}}
#### 偏差 {{@index}}：{{this.title}}

- **描述**：{{this.description}}
- **原因**：{{this.reason}}
- **影响**：{{this.impact}}
- **建议**：{{this.suggestion}}
- **偏差级别**：{{this.severity}}（轻微/中等/严重）

{{/each}}

---

## 文档更新建议

**需要更新的文档**：
{{#each DOCS_TO_UPDATE}}
1. `{{this.file}}` — {{this.change}}
{{/each}}

**更新策略建议**：
- [ ] 立即更新（推荐，偏差轻微）
- [ ] 累积到阶段结束时统一更新
- [ ] 暂停，用户审查（严重偏差）

**快速更新命令**：
```bash
{{#each UPDATE_COMMANDS}}
{{this}}
{{/each}}
```

---

## 下一步决策

**下一任务**：{{NEXT_TASK_ID}}: {{NEXT_TASK_TITLE}}

**前置条件检查**：
{{#each PRECONDITIONS}}
- [{{this.status}}] {{this.description}}
{{/each}}

**建议行动**：
1. **选项 A**：{{OPTION_A}}
2. **选项 B**：{{OPTION_B}}
3. **选项 C**：{{OPTION_C}}

**你的决定**：[等待用户输入]

---

## GitHub Issue 更新

**关联 Issue**：#{{ISSUE_NUMBER}}

**更新命令**：
```bash
# 添加评论
gh issue comment #{{ISSUE_NUMBER}} --body "{{COMMENT}}"

# 关闭 Issue（如果 PR 已合并）
gh issue close #{{ISSUE_NUMBER}} --reason completed
```

---

## 附录：详细测试输出

{{DETAILED_TEST_OUTPUT}}

---

## 附录：Git Diff 摘要

```diff
{{GIT_DIFF_SUMMARY}}
```
```

---

## 使用示例

### 示例：Task 001 评审报告

```markdown
# Task 001 完成评审报告

**日期**：2026-03-26
**评审人**：AI Architect

---

## 任务执行结果

**任务**：创建 Crawler 基类
**执行时间**：2026-03-26 14:30-15:45（1 小时 15 分）
**预计时间**：2-3 小时
**状态**：✅ 完成

**产出物**：
- `src/crawler/base.py` (156 行)
- `src/crawler/exceptions.py` (23 行)
- `tests/crawler/test_base.py` (89 行)
- `src/crawler/__init__.py` (12 行)

**Git 提交**：
- `a1b2c3d` feat: add Crawler base class with fetch and parse methods
- `e4f5g6h` feat: add CrawlerError exception class

**测试结果**：
```bash
pytest tests/crawler/test_base.py -v --cov=src/crawler --cov-report=term-missing
```
```
============================= test session starts ==============================
platform linux -- Python 3.10.0, pytest-7.0.0
collected 5 items

tests/crawler/test_base.py::test_crawler_init PASSED
tests/crawler/test_base.py::test_crawler_fetch PASSED
tests/crawler/test_base.py::test_crawler_parse PASSED
tests/crawler/test_base.py::test_crawler_fetch_timeout PASSED
tests/crawler/test_base.py::test_crawler_error_handling PASSED

---------- coverage: platform linux, python 3.10.0 -----------
Name                         Stmts   Miss  Cover
------------------------------------------------
src/crawler/base.py            156     12    92%
src/crawler/exceptions.py       23      0   100%
------------------------------------------------
TOTAL                          179     12    93%

========================== 5 passed in 2.34s ===========================
```
# 覆盖率：93%

---

## 架构一致性检查

### ✅ 一致项
- 模块位置符合架构文档（`src/crawler/`）
- 类命名符合设计原则（`Crawler` 使用 CamelCase）
- 接口签名符合 api-spec.md（`fetch(url: str) -> str`）
- 异常类命名符合规范（`CrawlerError` 继承自 `Exception`）
- 无违规依赖（仅依赖 `requests` 和 `bs4`）

### ⚠️ 发现偏差

#### 偏差 1：新增 `retry_count` 参数

- **描述**：`fetch()` 方法新增了 `retry_count: int = 3` 参数，但 api-spec.md 未记录
- **原因**：实现时发现需要处理网络重试，增强鲁棒性
- **影响**：向后兼容变更，不影响现有调用
- **建议**：更新 api-spec.md 第 3.2 节，添加参数说明
- **偏差级别**：⚠️ 轻微（向后兼容）

#### 偏差 2：依赖 `aiohttp` 未记录

- **描述**：`base.py` 中 import 了 `aiohttp`，但架构文档技术选型表未提及
- **原因**：初始实现使用 `requests`，后改为异步实现
- **影响**：需要更新依赖清单和架构文档
- **建议**：更新架构文档 4.1 技术选型表，添加 `aiohttp`
- **偏差级别**：⚠️ 中等（需要记录）

---

## 文档更新建议

**需要更新的文档**：
1. `docs/architecture/phases/phase-1/crawler/api-spec.md` — 添加 `retry_count` 参数说明
2. `docs/architecture/2026-03-26-ecommerce-analysis-system.md` — 添加 `aiohttp` 到技术选型表
3. `pyproject.toml` — 添加 `aiohttp` 到依赖（如尚未添加）

**更新策略建议**：
- [x] 立即更新（推荐，偏差轻微）
- [ ] 累积到阶段结束时统一更新
- [ ] 暂停，用户审查（不适用）

**快速更新命令**：
```bash
/zcf:arch-doc "更新：爬虫模块 API 规范，添加 retry_count 参数"
/zcf:arch-doc "更新：技术选型表，添加 aiohttp"
```

---

## 下一步决策

**下一任务**：Task 002: 实现 HTML 解析器

**前置条件检查**：
- [x] Task 001 完成且测试通过
- [x] 无阻塞性架构问题
- [ ] api-spec.md 已更新（等待用户决定）

**建议行动**：
1. **选项 A**：直接继续 Task 002（偏差可接受，推荐）
2. **选项 B**：先更新文档，再执行 Task 002（保守做法）
3. **选项 C**：暂停，用户审查当前偏差（不适用）

**你的决定**：[等待用户输入]

---

## GitHub Issue 更新

**关联 Issue**：#1

**更新命令**：
```bash
# 添加评论
gh issue comment #1 --body "任务完成评审通过，发现 2 个轻微偏差，建议更新文档。"

# 关闭 Issue（PR 合并后）
gh issue close #1 --reason completed
```

---

## 附录：详细测试输出

（见上方测试结果）

---

## 附录：Git Diff 摘要

```diff
diff --git a/src/crawler/base.py b/src/crawler/base.py
new file mode 100644
index 0000000..1234567
--- /dev/null
+++ b/src/crawler/base.py
@@ -0,0 +1,156 @@
+"""爬虫模块 - 基础爬虫类"""
+
+import asyncio
+from typing import Dict, List, Optional
+import aiohttp
+
+from .exceptions import CrawlerError
+
+
+class Crawler:
+    """基础爬虫类，提供网页抓取和解析功能"""
+    
+    def __init__(self, timeout: int = 30, retry_count: int = 3):
+        """
+        初始化爬虫
+        
+        Args:
+            timeout: 请求超时时间（秒）
+            retry_count: 重试次数
+        """
+        self.timeout = timeout
+        self.retry_count = retry_count
+    
+    async def fetch(self, url: str) -> str:
+        """抓取网页内容"""
+        # ... 实现代码 ...
```

```

---

## 评审报告自动生成指南

**由 `/zcf:task-review` 自动填充**：

| 变量 | 来源 |
|------|------|
| `{{TASK_ID}}` | 从用户输入提取 |
| `{{TASK_TITLE}}` | 从 plan 文档提取 |
| `{{DATE}}` | 通过 `date` 命令获取 |
| `{{REVIEWER}}` | AI Architect（固定） |
| `{{FILES_CREATED}}` | 从 git status 提取 |
| `{{FILES_MODIFIED}}` | 从 git status 提取 |
| `{{COMMITS}}` | 从 git log 提取 |
| `{{TEST_OUTPUT}}` | 从 pytest 输出提取 |
| `{{COVERAGE}}` | 从 pytest --cov 输出提取 |
| `{{CONSISTENT_ITEMS}}` | 从架构一致性检查生成 |
| `{{DEVIATIONS}}` | 从架构偏差识别生成 |
| `{{DOCS_TO_UPDATE}}` | 从偏差分析生成 |
| `{{NEXT_TASK_ID}}` | 从 plan 文档提取 |
| `{{NEXT_TASK_TITLE}}` | 从 plan 文档提取 |
| `{{PRECONDITIONS}}` | 从任务依赖生成 |

---

## 偏差级别定义

| 级别 | 定义 | 处理策略 |
|------|------|----------|
| **轻微** | 向后兼容变更，不影响其他模块 | 立即更新文档或累积更新 |
| **中等** | 需要记录的技术选型变更 | 更新架构文档，可能需要 ADR |
| **严重** | 架构违规或破坏性变更 | 暂停，用户审查，必须 ADR |

---

## 最佳实践

1. **及时评审** — 任务完成后立即执行评审
2. **客观记录** — 偏差描述基于事实，避免主观判断
3. **明确建议** — 每个偏差都有清晰的处理建议
4. **可追溯** — 所有 Git 提交、测试输出都可追溯
5. **决策记录** — 用户决定要记录，便于后续回顾
