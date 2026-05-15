---
description: '任务完成评审，检查架构一致性、文档偏差，决定下一步行动'
allowed_tools: Read(docs/**, src/**), Write(docs/**), Bash(pytest, git diff, git log, date, bash scripts/check-compliance.sh)
argument_hint: <任务标识> [Task XXX | module-name | phase-name]
# examples:
#   /zcf:task-review "Task 001 完成"
#   /zcf:task-review "爬虫模块完成"
#   /zcf:task-review "Phase 1: MVP 完成"
---

# Workflow - 任务评审

**定位**：任务完成后进行评审，检查架构一致性、发现文档偏差、决定下一步行动

**触发时机**：每个 Task/Module/Phase 完成后（通过 ACP 驱动 OpenCode 执行后）

**目标读者**：**DevMate**（技术合伙人）

**执行者角色**：**编码助手**（Encoding Assistant）

---

## 编码助手角色定义

**你是**: 编码助手（Encoding Assistant）  
**你的职责**: 根据架构文档实现代码，完成任务后进行自评  
**你的反馈对象**: **DevMate**（技术合伙人）  
**报告格式**: 标准化评审报告（给 DevMate 看）

**禁止行为**:
- ❌ 直接修改 `docs/architecture/`（只读，仅 DevMate 可写）
- ❌ 自动执行 `git commit/push`（需 DevMate 确认）
- ❌ 合并分支（需 DevMate 执行 `merge-branches.sh`）

---

## Git 分支策略（关联 acf-workflow §2.5）

**分支命名**: `feature/<task-id>-<short-desc>`  
**示例**: `feature/task-001-crawler-base`

**评审前确认**:
```bash
# 1. 确认当前分支
git rev-parse --abbrev-ref HEAD  # 应该是 feature/task-xxx-xxx

# 2. 检查工作区干净
git status --porcelain  # 应该为空

# 3. 运行合规检查
bash scripts/check-compliance.sh  # 必须通过
```

**评审通过后**:
```bash
# 等待 DevMate 执行合并
# DevMate 将运行：bash scripts/merge-branches.sh --feature feature/task-xxx-xxx
```

---

## 核心功能

### 1️⃣ 任务级评审（Task-Level Review）

**触发**：
```bash
/zcf:task-review "Task 001 完成"
```

**评审内容**：

#### A. 任务执行结果验证

1. **读取任务计划**
   ```bash
   # 查找 plan 文档
   find docs -name "*crawler*" | grep plan
   ```

2. **验证产出物**
   ```bash
   # 检查文件是否创建
   ls -la src/crawler/base.py
   ls -la tests/crawler/test_base.py
   
   # 检查 git 提交
   git log --oneline -5 -- src/crawler/
   
   # 运行测试
   pytest tests/crawler/test_base.py -v
   ```

3. **收集执行指标**
   - 实际耗时 vs 预计耗时
   - 代码行数
   - 测试覆盖率
   - 提交数量

---

#### B. 架构一致性检查

**检查项**：

1. **模块位置** — 是否符合架构文档的目录结构？
   ```bash
   # 检查架构文档中的模块定义
   grep -A 5 "爬虫模块" docs/architecture/phases/phase-1/crawler/detailed-design.md
   ```

2. **类/函数命名** — 是否符合设计原则？
   ```bash
   # 检查类名
   grep "^class " src/crawler/base.py
   
   # 对比架构文档
   grep "Crawler" docs/architecture/phases/phase-1/crawler/detailed-design.md
   ```

3. **接口签名** — 是否符合 api-spec.md？
   ```bash
   # 提取实际接口
   grep "def " src/crawler/base.py
   
   # 对比 API 规范
   cat docs/architecture/phases/phase-1/crawler/api-spec.md
   ```

4. **依赖关系** — 是否有循环依赖或违规依赖？
   ```bash
   # 检查 import 语句
   grep "^import\|^from" src/crawler/base.py
   
   # 检查是否违反依赖规则（如：爬虫模块不应依赖 presentation 层）
   grep "from.*presentation" src/crawler/
   ```

5. **数据库 Schema** — 是否符合 database-schema.md？
   ```bash
   # 检查模型定义
   grep "class.*Model" src/crawler/
   
   # 对比数据库设计
   cat docs/architecture/phases/phase-1/crawler/database-schema.md
   ```

---

#### C. 文档偏差识别

**偏差类型**：

1. **新增功能** — 实现了架构文档未提及的功能
   ```markdown
   示例：
   - 架构文档：Crawler 只有 fetch() 方法
   - 实际实现：Crawler 新增了 fetch_with_retry() 方法
   - 偏差级别：⚠️ 轻微（功能增强）
   - 建议：更新 api-spec.md
   ```

2. **接口变更** — 接口签名与设计不符
   ```markdown
   示例：
   - 架构文档：`fetch(url: str) -> str`
   - 实际实现：`fetch(url: str, timeout: int = 30, retry_count: int = 3) -> str`
   - 偏差级别：⚠️ 轻微（向后兼容）
   - 建议：更新 api-spec.md，说明新增参数
   ```

3. **技术选型变更** — 使用了架构文档未提及的库
   ```markdown
   示例：
   - 架构文档：未指定 HTTP 库
   - 实际实现：使用了 `aiohttp`
   - 偏差级别：⚠️ 中等（需要记录）
   - 建议：更新架构文档 4.1 技术选型表
   ```

4. **架构违规** — 违反了架构原则或依赖规则
   ```markdown
   示例：
   - 架构原则：领域层不应依赖基础设施层
   - 实际实现：domain/service.py import infrastructure/database.py
   - 偏差级别：❌ 严重（需要重构）
   - 建议：立即重构，或通过 ADR 记录例外
   ```

---

#### D. 文档更新建议

**更新策略**：

1. **立即更新**（推荐用于轻微偏差）
   ```markdown
   适用场景：
   - 接口参数新增（向后兼容）
   - 技术选型补充
   - 功能增强
   
   操作：
   /zcf:arch-doc "更新：爬虫模块 API 规范，添加 retry_count 参数"
   ```

2. **累积更新**（适用于多个轻微偏差）
   ```markdown
   适用场景：
   - 同一模块有多个轻微偏差
   - 偏差之间有关联
   
   操作：
   - 记录偏差到 `docs/architecture/phases/phase-1/crawler/CHANGELOG.md`
   - 模块完成后统一更新
   ```

3. **暂停审查**（适用于严重偏差）
   ```markdown
   适用场景：
   - 架构违规
   - 重大设计变更
   - 影响其他模块的接口变更
   
   操作：
   - 暂停后续任务
   - 创建 ADR 记录决策
   - 更新架构文档
   - 用户审查确认
   ```

---

#### E. 下一步决策

**决策矩阵**：

| 偏差级别 | 任务状态 | 建议行动 |
|----------|----------|----------|
| ✅ 无偏差 | 完成 | 继续执行 Task 002 |
| ⚠️ 轻微偏差 | 完成 | 选项 A：直接继续 Task 002<br>选项 B：先更新文档再续 |
| ⚠️ 中等偏差 | 完成 | 选项 B：先更新文档再续（推荐） |
| ❌ 严重偏差 | 完成 | 选项 C：暂停，用户审查（必须） |

---

### 2️⃣ 模块级评审（Module-Level Review）

**触发**：
```bash
/zcf:task-review "爬虫模块完成"
```

**评审内容**：

1. **所有 Task 完成检查**
   ```bash
   # 读取 plan 文档，检查所有 Task 标记
   grep -E "^\- \[X\]|^- \[ \]" docs/superpowers/plans/2026-03-26-crawler-module.md
   ```

2. **模块整体测试**
   ```bash
   pytest tests/crawler/ -v --cov=src/crawler --cov-report=term-missing
   ```

3. **模块依赖检查**
   ```bash
   # 检查是否有其他模块依赖此模块
   grep -r "from.*crawler" src/ --exclude-dir=crawler
   ```

4. **架构文档更新**
   ```markdown
   更新内容：
   - 变更记录（添加完成日期）
   - 实现状态标记（从未完成→已完成）
   - 实际技术指标（性能、覆盖率）
   ```

5. **下一步建议**
   ```markdown
   建议：
   - ✅ 爬虫模块完成，建议进入下一个模块：价格分析 Agent
   - ⏸️  爬虫模块完成，但发现 3 个轻微偏差，建议先更新文档
   - ⏹️  爬虫模块完成，但发现严重架构问题，需要审查
   ```

---

### 3️⃣ 阶段级评审（Phase-Level Review）

**触发**：
```bash
/zcf:task-review "Phase 1: MVP 完成"
```

**评审内容**：

1. **所有模块完成检查**
   ```bash
   # 检查所有模块目录
   ls -la docs/architecture/phases/phase-1/
   ```

2. **集成测试**
   ```bash
   # 运行全模块集成测试
   pytest tests/integration/ -v
   ```

3. **架构一致性总览**
   - 各模块依赖关系
   - 整体接口一致性
   - 技术债务清单

4. **阶段完成报告**
   ```markdown
   # Phase 1: MVP 完成报告
   
   ## 完成情况
   
   **模块**：5/5 完成
   - ✅ 爬虫模块（12 Tasks）
   - ✅ 存储模块（8 Tasks）
   - ✅ 分析模块（10 Tasks）
   - ✅ API 模块（6 Tasks）
   - ✅ 配置模块（4 Tasks）
   
   **总任务数**：40/40 完成
   **总耗时**：3 周（预计 2-3 周）
   **测试覆盖率**：82%
   
   ## 架构偏差汇总
   
   **轻微偏差**：5 个（已更新文档）
   **中等偏差**：2 个（已记录 ADR）
   **严重偏差**：0 个
   
   ## 技术债务
   
   1. [债务 1]
   2. [债务 2]
   
   ## 建议行动
   
   - ✅ Phase 1 完成，建议进入 Phase 2：功能扩展
   - ⏸️  Phase 1 完成，但建议先清理技术债务再进入 Phase 2
   ```

---

## 输出报告格式（标准化，给 DevMate）

### 任务级评审报告（必须包含以下章节）

```markdown
# {{TASK_ID}} 完成评审报告（给 DevMate）

**日期**：{{DATE}}
**评审人**：编码助手（{{AGENT_NAME}}）
**反馈对象**：DevMate

---

## 一、任务执行结果

**任务**：{{TASK_TITLE}}
**执行时间**：{{START_TIME}}-{{END_TIME}}（{{DURATION}}）
**预计时间**：{{ESTIMATED_TIME}}
**状态**：✅ 完成 / ⚠️ 部分完成 / ❌ 阻塞

**产出物清单**：
{{#each FILES_CREATED}}
- `{{this.path}}` ({{this.lines}} 行，新增)
{{/each}}
{{#each FILES_MODIFIED}}
- `{{this.path}}` (修改 {{this.changed_lines}} 行)
{{/each}}

**Git 分支**：`{{BRANCH_NAME}}`
**Git 提交**：
{{#each COMMITS}}
- `{{this.hash}}` {{this.message}}
{{/each}}

**测试结果**：
```bash
{{TEST_COMMAND}}
```
```
{{TEST_OUTPUT}}
# 覆盖率：{{COVERAGE}}%
```

**合规检查**：
```bash
bash scripts/check-compliance.sh
# ✅ 架构合规检查通过
```

---

## 二、架构一致性检查

### ✅ 一致项
{{#each CONSISTENT_ITEMS}}
- {{this}}
{{/each}}

### ⚠️ 发现偏差（如无偏差，写"无"）

{{#each DEVIATIONS}}
#### 偏差 {{@index}}：{{this.title}}

- **描述**：{{this.description}}
- **原因**：{{this.reason}}
- **影响**：{{this.impact}}
- **建议**：{{this.suggestion}}
- **偏差级别**：{{this.severity}}（轻微/中等/严重）

{{/each}}

---

## 三、给 DevMate 的行动建议

**需要 DevMate 确认的事项**：
{{#each ITEMS_NEED_CONFIRMATION}}
- [ ] {{this}}
{{/each}}

**需要 DevMate 执行的命令**：
{{#each COMMANDS_FOR_DEVMATE}}
```bash
{{this}}
```
{{/each}}

**文档更新建议**：
{{#each DOCS_TO_UPDATE}}
1. `{{this.file}}` — {{this.change}}
{{/each}}

**更新策略**：
- [ ] 立即更新（推荐，偏差轻微）
- [ ] 累积到阶段结束时统一更新
- [ ] 暂停，DevMate 审查（严重偏差）

---

## 四、下一步决策

**下一任务**：{{NEXT_TASK_ID}}: {{NEXT_TASK_TITLE}}

**前置条件检查**：
{{#each PRECONDITIONS}}
- [{{this.status}}] {{this.description}}
{{/each}}

**建议行动**（给 DevMate）：
1. **选项 A**：{{OPTION_A}}
2. **选项 B**：{{OPTION_B}}
3. **选项 C**：{{OPTION_C}}

**等待 DevMate 决定**。

---

## 附录：详细输出

### 详细测试输出
{{DETAILED_TEST_OUTPUT}}

### Git Diff 摘要
```diff
{{GIT_DIFF_SUMMARY}}
```

### 分支状态
```bash
git status
git log --oneline -3
```
```

---

## 评审报告填写指南（编码助手必读）

**必须填写的章节**：
1. ✅ 一、任务执行结果（产出物清单、Git 提交、测试结果、合规检查）
2. ✅ 二、架构一致性检查（一致项、偏差）
3. ✅ 三、给 DevMate 的行动建议（需要确认的事项、需要执行的命令）
4. ✅ 四、下一步决策（下一任务、建议行动）

**可选填写的章节**：
- 附录：详细输出（仅当 DevMate 要求时）

**偏差级别定义**：
| 级别 | 定义 | 处理策略 |
|------|------|----------|
| **轻微** | 向后兼容变更，不影响其他模块 | 立即更新文档或累积更新 |
| **中等** | 需要记录的技术选型变更 | 更新架构文档，可能需要 ADR |
| **严重** | 架构违规或破坏性变更 | 暂停，DevMate 审查，必须 ADR |

**合规检查必须通过**：
```bash
bash scripts/check-compliance.sh
# 检查项：
# 1. 架构文档只读性
# 2. 外部依赖检查
# 3. 测试覆盖率≥80%
# 4. 架构问题记录
```

---

## 命令参考

### 运行测试
```bash
pytest tests/<module>/ -v --cov=src/<module>
```

### 检查 git 提交
```bash
git log --oneline -10 -- src/<module>/
```

### 检查依赖
```bash
grep "^import\|^from" src/<module>/*.py
```

### 更新 GitHub Issue
```bash
gh issue comment #ID --body "评论内容"
```

### 关闭 Issue
```bash
gh issue close #ID --reason completed
```

---

## 评审清单模板

### Task 级清单
```markdown
**评审清单**：
- [ ] 任务产出物已创建（文件、测试）
- [ ] 所有测试通过
- [ ] 测试覆盖率 > 80%
- [ ] Git 提交已完成
- [ ] 架构一致性检查完成
- [ ] 文档偏差已识别
- [ ] 下一步行动已建议
```

### 模块级清单
```markdown
**评审清单**：
- [ ] 所有 Task 完成（X/X）
- [ ] 模块整体测试通过
- [ ] 模块依赖检查完成
- [ ] 架构文档已更新（变更记录）
- [ ] 技术债务已记录
- [ ] 下一步模块已建议
```

### 阶段级清单
```markdown
**评审清单**：
- [ ] 所有模块完成（X/X）
- [ ] 集成测试通过
- [ ] 架构一致性总览完成
- [ ] 阶段完成报告已生成
- [ ] 技术债务清单已汇总
- [ ] 下一阶段建议已提出
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
| `/zcf:github-sync` | GitHub 同步 | Milestones + Issues + PR 模板 |
| `/zcf:task-review` | **任务评审** | **完成报告 + 架构偏差检查 + 下一步决策** |
| `/zcf:workflow` | 代码开发 | 可运行代码 + 测试 |

---

## 错误处理

### 常见错误

**错误 1**：找不到任务计划文档
```
❌ 错误：未找到任务计划文档
解决方案：先运行 skill_use writing-plans 生成计划
```

**错误 2**：测试失败
```
❌ 错误：测试未通过（3/5 PASSED）
解决方案：不生成评审报告，先修复测试
```

**错误 3**：文件未创建
```
❌ 错误：预期文件 src/crawler/base.py 不存在
解决方案：任务未完成，无法评审
```

---

**开始执行前，先读取用户输入的任务标识，然后识别评审级别（Task/Module/Phase）。**
