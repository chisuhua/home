# GitHub PR 模板

**用途**：用于模块完成时创建 Pull Request 的标准格式

**保存位置**：`.github/PULL_REQUEST_TEMPLATE/<module-name>.md`

**使用方式**：
```bash
gh pr create --template <module-name>.md
```

---

## 模板结构

```markdown
## {{PHASE_NAME}}: {{MODULE_NAME}}

**关联 Issues**：{{ISSUE_LIST}}

**架构文档**：
- 总体架构：`{{ARCHITECTURE_FILE}}`
- 模块设计：`{{DETAILED_DESIGN_FILE}}`
- API 规范：`{{API_SPEC_FILE}}`
- 数据库设计：`{{DATABASE_SCHEMA_FILE}}`（如适用）

---

## 变更清单

{{#each FILES_CHANGED}}
- `{{this.path}}` — {{this.description}}
{{/each}}

---

## 测试报告

### 单元测试
```bash
{{UNIT_TEST_COMMAND}}
# 覆盖率：{{COVERAGE}}%
# 通过：{{PASSED}}/{{TOTAL}}
```

### 集成测试（如适用）
```bash
{{INTEGRATION_TEST_COMMAND}}
# 通过：{{PASSED}}/{{TOTAL}}
```

### Lint 检查
```bash
{{LINT_COMMAND}}
# 结果：{{LINT_RESULT}}
```

---

## 架构一致性检查

**请评审者确认**：
- [ ] 模块依赖符合架构文档（无循环依赖）
- [ ] API 接口符合 api-spec.md
- [ ] 数据库 Schema 符合 database-schema.md（如适用）
- [ ] 代码风格符合项目规范
- [ ] 所有公共方法有文档注释

---

## 技术债务（如适用）

{{#if TECH_DEBT}}
**已知问题**：
{{#each TECH_DEBT}}
- [ ] {{this.description}} — {{this.reason}}
{{/each}}

**计划解决时间**：{{DEADLINE}}
{{else}}
无已知技术债务
{{/if}}

---

## 文档更新

**已更新的文档**：
{{#each DOCS_UPDATED}}
- [ ] `{{this}}`
{{/each}}

**需要后续更新的文档**：
{{#each DOCS_PENDING}}
- [ ] `{{this}}`
{{/each}}

---

## 部署说明（如适用）

**环境变量**：
```bash
{{ENV_VARS}}
```

**数据库迁移**：
```bash
{{MIGRATION_COMMANDS}}
```

**回滚方案**：
```bash
{{ROLLBACK_COMMANDS}}
```

---

## 评审清单

**提交前自检**：
- [ ] 代码通过 lint 检查
- [ ] 所有测试通过
- [ ] 添加了必要的注释
- [ ] 更新了相关文档
- [ ] 无阻塞性技术债务
- [ ] 架构一致性检查通过

**评审者**：
- [ ] 代码质量评审（@reviewer-1）
- [ ] 架构一致性评审（@architect）
- [ ] 功能测试验证（@qa）

---

## 截图/录屏（如适用）

{{SCREENSHOTS_OR_RECORDINGS}}

---

## 其他说明

{{ADDITIONAL_NOTES}}
```

---

## 使用示例

### 示例：爬虫模块 PR

```markdown
## Phase 1: MVP: 爬虫模块

**关联 Issues**： #1, #2, #3, #4, #5

**架构文档**：
- 总体架构：`docs/architecture/2026-03-26-ecommerce-analysis-system.md`
- 模块设计：`docs/architecture/phases/phase-1/crawler/detailed-design.md`
- API 规范：`docs/architecture/phases/phase-1/crawler/api-spec.md`

---

## 变更清单

- `src/crawler/base.py` — 爬虫基类（156 行）
- `src/crawler/html_parser.py` — HTML 解析器（89 行）
- `src/crawler/url_manager.py` — URL 管理器（67 行）
- `src/crawler/exceptions.py` — 异常定义（23 行）
- `src/crawler/__init__.py` — 模块导出（12 行）
- `tests/crawler/test_base.py` — 基础测试（89 行）
- `tests/crawler/test_html_parser.py` — 解析器测试（56 行）
- `tests/crawler/test_url_manager.py` — URL 管理器测试（34 行）

---

## 测试报告

### 单元测试
```bash
pytest tests/crawler/ -v --cov=src/crawler --cov-report=term-missing
# 覆盖率：85%
# 通过：24/24
```

**覆盖率详情**：
```
Name                         Stmts   Miss  Cover
------------------------------------------------
src/crawler/base.py            156     12    92%
src/crawler/html_parser.py      89      8    91%
src/crawler/url_manager.py      67     15    78%
src/crawler/exceptions.py       23      0   100%
------------------------------------------------
TOTAL                          335     35    85%
```

### Lint 检查
```bash
ruff check src/crawler/
# 结果：All checks passed!
```

---

## 架构一致性检查

**请评审者确认**：
- [x] 模块位置符合架构文档（`src/crawler/`）
- [x] 类命名符合设计原则（`Crawler`, `HTMLParser`, `URLManager`）
- [x] 接口签名符合 api-spec.md
- [x] 无违规依赖（爬虫模块仅依赖标准库和 requests/bs4）
- [ ] 数据库 Schema 符合 database-schema.md（不适用）

**依赖检查**：
```bash
# 检查是否有违规依赖
grep -r "from.*presentation" src/crawler/
# 结果：无匹配（✅ 通过）

grep -r "from.*domain" src/crawler/
# 结果：无匹配（✅ 通过）
```

---

## 技术债务

**已知问题**：
- [ ] `url_manager.py` 的 `normalize_url()` 函数未处理 IDN（国际化域名）
  - **原因**：需要额外依赖 `idna` 库
  - **计划**：Phase 2 处理
- [ ] 爬虫未实现 robots.txt 尊重
  - **原因**：MVP 阶段优先核心功能
  - **计划**：Phase 2 实现 `RobotsParser`

**计划解决时间**：Phase 2 结束前（2026-04-30）

---

## 文档更新

**已更新的文档**：
- [x] `docs/architecture/phases/phase-1/crawler/api-spec.md` — 添加 `retry_count` 参数
- [x] `docs/architecture/2026-03-26-ecommerce-analysis-system.md` — 添加 `aiohttp` 到技术选型表

**需要后续更新的文档**：
- [ ] `README.md` — 添加爬虫模块使用示例
- [ ] `docs/api/crawler.md` — 生成完整 API 文档（使用 pdoc）

---

## 部署说明

**环境变量**：
```bash
# 爬虫配置
CRAWLER_USER_AGENT="MyBot/1.0"
CRAWLER_REQUEST_TIMEOUT=30
CRAWLER_MAX_RETRIES=3
```

**数据库迁移**：
不适用（爬虫模块无数据库操作）

**回滚方案**：
```bash
# 回滚到此 PR 前的版本
git revert {{COMMIT_HASH}}..HEAD
```

---

## 截图/录屏

**爬虫运行示例**：
```bash
python -m crawler https://example.com
# 输出：
# Fetched: https://example.com (200 OK, 12345 bytes)
# Parsed: title="Example Domain", links=42
```

---

## 其他说明

**性能基准**：
- 单次抓取平均耗时：1.2s（n=100）
- 解析平均耗时：0.05s（n=100）

**后续优化建议**：
- 实现并发抓取（使用 `asyncio`）
- 添加缓存层（使用 `redis`）
- 实现分布式抓取（多节点协作）

---

## 评审者指派

**代码质量评审**：@senior-dev-1
**架构一致性评审**：@architect
**功能测试验证**：@qa-engineer

**期望完成时间**：2026-03-28
```

---

## 多模块 PR 模板

如果是整个阶段的 PR（多个模块合并），使用以下格式：

```markdown
## {{PHASE_NAME}}: 完整实施

**包含模块**：
- {{MODULE_1}}
- {{MODULE_2}}
- {{MODULE_3}}

**关联 Issues**：{{ALL_ISSUES}}

**子 PR**：
- [ ] PR #{{X}}: {{MODULE_1}}
- [ ] PR #{{Y}}: {{MODULE_2}}
- [ ] PR #{{Z}}: {{MODULE_3}}

---

## 阶段完成状态

| 模块 | 任务数 | 完成 | 测试覆盖率 | 状态 |
|------|--------|------|------------|------|
| {{MODULE_1}} | {{N}} | {{N}} | {{X}}% | ✅ |
| {{MODULE_2}} | {{N}} | {{N}} | {{X}}% | ✅ |
| {{MODULE_3}} | {{N}} | {{N}} | {{X}}% | ✅ |

**总计**：{{TOTAL_TASKS}}/{{TOTAL_TASKS}} (100%)

---

## 集成测试
```bash
pytest tests/integration/ -v
# 通过：{{PASSED}}/{{TOTAL}}
```

---

（其他章节同上）
```

---

## 创建 PR 的命令

### 创建单个模块 PR
```bash
gh pr create \
  --title "Phase 1: 爬虫模块" \
  --body-file .github/PULL_REQUEST_TEMPLATE/crawler-module.md \
  --base main \
  --label "phase-1,crawler"
```

### 创建 Draft PR（早期评审）
```bash
gh pr create \
  --title "Phase 1: 爬虫模块" \
  --body-file .github/PULL_REQUEST_TEMPLATE/crawler-module.md \
  --base main \
  --label "phase-1,crawler" \
  --draft
```

### 关联 Issue
```bash
gh pr edit #PR_NUMBER --add-issue #ISSUE_NUMBER
```

---

## 模板变量填充指南

**由 `/zcf:github-sync` 自动填充**：

| 变量 | 来源 |
|------|------|
| `{{PHASE_NAME}}` | 从用户输入或 plan 文档提取 |
| `{{MODULE_NAME}}` | 从用户输入或 plan 文档提取 |
| `{{ISSUE_LIST}}` | 从已关闭的 Issues 列表提取 |
| `{{ARCHITECTURE_FILE}}` | 从架构文档路径提取 |
| `{{DETAILED_DESIGN_FILE}}` | 从详细设计文档路径提取 |
| `{{API_SPEC_FILE}}` | 从 API 规范文档路径提取 |
| `{{FILES_CHANGED}}` | 从 git diff 提取 |
| `{{UNIT_TEST_COMMAND}}` | 根据项目类型生成 |
| `{{COVERAGE}}` | 从 pytest --cov 输出提取 |
| `{{PASSED}}/{{TOTAL}}` | 从 pytest 输出提取 |
| `{{LINT_COMMAND}}` | 根据项目类型生成 |
| `{{TECH_DEBT}}` | 从 task-review 报告提取 |
| `{{DOCS_UPDATED}}` | 从 git diff 提取文档变更 |

---

## 最佳实践

1. **PR 标题** — 使用 "Phase X: 模块名" 格式，清晰表达范围
2. **关联 Issues** — 使用 `Fixes #X, Closes #Y` 自动关闭 Issues
3. **测试报告** — 包含覆盖率详情，不只是通过率
4. **架构检查** — 列出具体检查项和结果（✅/❌）
5. **技术债务** — 诚实记录，注明解决计划
6. **评审者指派** — 提前 @相关人员，设置期望时间
7. **截图/录屏** — 对于 UI 或复杂功能，提供可视化证据
