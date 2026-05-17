---
name: council-workflow
description: 多智能体委员会工作流 - 增强版 PRD/ADR 创建与审查。采用文档驱动状态机，确保任何中断后可从断点恢复。核心改进：DevMate 主动与用户讨论决策点，而非仅发送列表。
---

# Council Workflow Skill (v5)

## 核心理念

1. **文档驱动**：使用 `{project}/docs/.council-todo.md` 作为唯一事实来源
2. **验证前置**：每个子 agent 必须验证输出文件，才算完成
3. **主动讨论**：Step 6 必须 DevMate 主动分析 + 推荐，与用户讨论后再确认
4. **中断恢复**：任何时候启动技能，先读 todo，根据当前步骤状态决定下一步

---

## Todo 文档格式

位置：`{project}/docs/.council-todo.md`

```markdown
# Council Workflow Todo

**项目**: {project}
**主题**: {topic}
**创建时间**: {timestamp}
**最后更新**: {timestamp}

## 步骤清单

### Step 1: 初始化工作流
- **状态**: pending | in_progress | done | failed
- **执行者**: Director
- **输出**: .council-todo.md 已创建

### Step 2: 执行调研（Research）
- **状态**: pending | in_progress | done | failed
- **执行者**: subagent:researcher
- **输出**: docs/research/research-YYYYMMDD-{topic}.md

### Step 3: 执行 PM 讨论
- **状态**: pending | in_progress | done | failed
- **执行者**: subagent:pm
- **输出**: docs/council/pm/pm-YYYYMMDD-{topic}.md

### Step 4: 执行 Architect 讨论
- **状态**: pending | in_progress | done | failed
- **执行者**: subagent:architect
- **输出**: docs/council/architect/architect-YYYYMMDD-{topic}.md

### Step 5: 执行 Reviewer 评审
- **状态**: pending | in_progress | done | failed
- **执行者**: subagent:reviewer
- **输出**: docs/council/reviewer/reviewer-YYYYMMDD-{topic}.md

### Step 6: DevMate 主动讨论决策点
- **状态**: pending | in_progress | done | failed
- **执行者**: Director
- **输出**: 决策点讨论记录（更新在 todo 中）

### Step 7: 用户确认决策
- **状态**: pending | in_progress | done | failed
- **执行者**: Director + 用户
- **输出**: 用户决策记录

### Step 8: 生成 PRD + ADR
- **状态**: pending | in_progress | done | failed
- **执行者**: subagent:librarian
- **输出**: docs/prd/prd-YYYYMMDD-{topic}.md, docs/adr/adr-YYYYMMDD-{seq}-{topic}.md

## 当前步骤

{N} - {description}

## 待确认决策点

（Step 6 完成后填写，包含 DevMate 推荐和用户回复）

## 错误记录

（如有失败步骤）

## 恢复说明

（如中断后恢复，指导下一步动作）
```

---

## 完整步骤定义

### Step 1: 初始化工作流

**执行者**: Director

1. 读取 `.council-todo.md`
2. 如已存在 → 检查当前步骤，恢复执行（见中断恢复流程）
3. 如不存在 → 创建新 todo 文档
4. 设置 Step 1 → `in_progress`，执行初始化
5. Step 1 → `done`，进入 Step 2

**输出**: `.council-todo.md` 已创建

---

### Step 2: 执行调研（Research）

**执行者**: subagent:researcher

**前置条件**: Step 1 完成

1. 更新 todo：Step 2 → `in_progress`
2. 读取调研主题
3. spawn researcher subagent（mode=run）
4. **立即 sessions_yield** — 等待 subagent 完成，subagent 结果返回到当前 session
5. 子 agent 完成返回后，检查输出文件：`{project}/docs/research/research-YYYYMMDD-{topic}.md`
   - 文件不存在 → 重新 spawn（1次）
   - 仍不存在 → Step 2 → `failed`，向用户报告错误
6. 验证文件大小 > 0
   - 通过 → Step 2 → `done`，进入 Step 3

> **关键**：spawn 后必须 yield，否则 subagent 在独立 session 运行，结果通过 subagent_announce 推送，无法捕获文件验证结果。

**Researcher 任务模板**：
```
你是 Researcher Agent，负责调研"[主题]"相关资料。

## 调研主题
[具体描述要调研的内容]

## 已有的调研文件（可复用或更新）
[如果存在已有调研文件，读取并判断是否需要更新]

## 调研要求
1. 如果已有调研文件且内容充分 → 读取后判断是否需要补充更新，无需重写
2. 如果无调研文件或内容不足 → 搜集相关技术资料、行业案例、竞品分析
3. 对比不同方案的优劣势
4. 标注信息来源可信度（A/B/C 级）
5. 给出核心发现摘要（不超过3条）

## 输出路径
`{project}/docs/research/research-YYYYMMDD-[主题].md`

## 强制执行步骤
1. 确认目录存在：`mkdir -p {project}/docs/research/`
2. 如果已有调研文件 → 读取内容，判断是否需要更新（检查日期和覆盖度）
   - 需要更新 → 补充或重写
   - 无需更新 → 记录"沿用已有调研"，验证文件大小 > 0 即可
3. 创建或更新 Markdown 文件并写入内容
4. 验证文件存在且大小 > 0：`ls -la {path}`
5. 文件不存在或大小为 0 → 输出：❌ 调研失败，原因：验证失败

完成后输出：✅ 调研完成，输出：{path}
```

---

### Step 3: 执行 PM 讨论

**执行者**: subagent:pm

**前置条件**: Step 2 完成

1. 更新 todo：Step 3 → `in_progress`
2. 读取调研报告，提取核心结论
3. spawn pm subagent（mode=run）
4. **立即 sessions_yield** — 等待 subagent 完成
5. 子 agent 完成返回后，检查输出文件：`{project}/docs/council/pm/pm-YYYYMMDD-{topic}.md`
6. 验证通过 → Step 3 → `done`
7. 失败 → 重新 spawn（1次），仍失败 → Step 3 → `failed`

**PM 任务模板**：
```
你是 PM Agent，基于调研报告，参与"[主题]"的决策讨论。

## 调研报告（必须先读取）
调研报告路径：`{project}/docs/research/research-YYYYMMDD-[主题].md`

**强制执行步骤 1**：读取调研报告内容
```bash
cat {project}/docs/research/research-YYYYMMDD-[主题].md
```
- 文件不存在 → 输出：❌ 调研报告不存在，无法进行 PM 讨论
- 文件存在但为空 → 输出：❌ 调研报告为空，无法进行 PM 讨论
- 读取成功后，引用调研报告中的"核心发现"章节或关键结论（如"发现1: ..."）作为你分析的基础

## 你的任务
1. 从产品需求角度，提出 3-5 个需要决策的问题点
2. 对每个问题点，给出 2-3 个选项
3. 说明每个选项的利弊
4. 给出你的推荐选择和理由

**重要**：在输出文档中，必须引用调研报告的具体内容（如"根据调研报告发现X，PM推荐..."）

## 输出路径
`{project}/docs/council/pm/pm-YYYYMMDD-[主题].md`

## 强制执行步骤
1. `mkdir -p {project}/docs/council/pm/`
2. **必须先读取调研报告**（见上方步骤1）
3. 创建 Markdown 文件，**在文档开头引用调研报告的核心发现**
4. 验证：`ls -la {path}`
5. 文件不存在或大小为 0 → 输出：❌ PM 失败，原因：验证失败

完成后输出：✅ PM 讨论完成，输出：{path}
```

---

### Step 4: 执行 Architect 讨论

**执行者**: subagent:architect

**前置条件**: Step 2 完成（可与 Step 3 并行执行）

> **并行说明**：Step 3 和 Step 4 可同时 spawn，两者都 yield 返回且都 done 后才进入 Step 5。

1. 更新 todo：Step 4 → `in_progress`
2. 读取调研报告，提取核心结论
3. spawn architect subagent（mode=run）
4. **立即 sessions_yield** — 等待 subagent 完成
5. 子 agent 完成返回后，检查输出文件：`{project}/docs/council/architect/architect-YYYYMMDD-{topic}.md`
6. 验证通过 → Step 4 → `done`
7. 失败 → 重新 spawn（1次），仍失败 → Step 4 → `failed`

**Architect 任务模板**：
```
你是 Architect Agent，基于调研报告，参与"[主题]"的决策讨论。

## 调研报告（必须先读取）
调研报告路径：`{project}/docs/research/research-YYYYMMDD-[主题].md`

**强制执行步骤 1**：读取调研报告内容
```bash
cat {project}/docs/research/research-YYYYMMDD-[主题].md
```
- 文件不存在 → 输出：❌ 调研报告不存在，无法进行 Architect 讨论
- 文件存在但为空 → 输出：❌ 调研报告为空，无法进行 Architect 讨论
- 读取成功后，引用调研报告中的"核心发现"章节或关键结论（如"发现1: ..."）作为你分析的基础

## 你的任务
1. 从技术架构角度，提出 3-5 个需要决策的问题点
2. 对每个问题点，给出 2-3 个技术方案选项
3. 说明每个方案的优缺点
4. 给出推荐选择和理由（含技术风险评估：Critical/Warning/Info）

**重要**：在输出文档中，必须引用调研报告的具体内容（如"根据调研报告发现X，Architect推荐..."）

## 输出路径
`{project}/docs/council/architect/architect-YYYYMMDD-[主题].md`

## 强制执行步骤
1. `mkdir -p {project}/docs/council/architect/`
2. **必须先读取调研报告**（见上方步骤1）
3. 创建 Markdown 文件，**在文档开头引用调研报告的核心发现**
4. 验证：`ls -la {path}`
5. 文件不存在或大小为 0 → 输出：❌ Architect 失败，原因：验证失败

完成后输出：✅ Architect 讨论完成，输出：{path}
```

---

### Step 5: 执行 Reviewer 评审

**执行者**: subagent:reviewer

**前置条件**: Step 3 + Step 4 都完成

1. 更新 todo：Step 5 → `in_progress`
2. 读取 PM 和 Architect 的输出文件
3. spawn reviewer subagent（mode=run）
4. **立即 sessions_yield** — 等待 subagent 完成
5. 子 agent 完成返回后，检查输出文件：`{project}/docs/council/reviewer/reviewer-YYYYMMDD-{topic}.md`
6. 验证通过 → Step 5 → `done`，进入 Step 6

**Reviewer 任务模板**：
```
你是 Reviewer Agent，负责评审 PM 和 Architect 的讨论结果。

## 待评审文件（必须先读取）
1. PM 讨论：`{project}/docs/council/pm/pm-YYYYMMDD-[主题].md`
2. Architect 讨论：`{project}/docs/council/architect/architect-YYYYMMDD-[主题].md`

**强制执行步骤 1**：读取并验证两个文件
```bash
# 读取 PM 文档
cat {project}/docs/council/pm/pm-YYYYMMDD-[主题].md
# 读取 Architect 文档
cat {project}/docs/council/architect/architect-YYYYMMDD-[主题].md
```
- 任一文件不存在 → 输出：❌ 评审失败，原因：缺少必要文档
- 任一文件为空 → 输出：❌ 评审失败，原因：文档为空
- 读取成功后，在评审文档中引用两个文档的章节/小标题/关键结论，证明已读取（如"PM 文档 Q1 节提到...，Architect 文档 Q1 节提到..."）

## 评审要求
1. 验证讨论的完整性和一致性（检查两个文档是否覆盖相同的决策点）
2. 识别分歧点和风险（Critical/Warning/Info 分级）
3. 对有分歧的问题，给出调解建议
4. 输出统一的决策点清单（给 DevMate 确认用）

**重要**：在输出文档中，必须体现对两个原始文档的具体引用（如"PM 文档§Q1 指出...，与 Architect 文档§Q2 的...存在分歧"）

## 输出路径
`{project}/docs/council/reviewer/reviewer-YYYYMMDD-[主题].md`

## 强制执行步骤
1. `mkdir -p {project}/docs/council/reviewer/`
2. **必须先读取两个输入文件**（见上方步骤1）
3. 创建 Markdown 文件，**在文档开头列出已读取的文档路径和关键章节**
4. 验证：`ls -la {path}`
5. 文件不存在或大小为 0 → 输出：❌ Review 失败，原因：验证失败

完成后输出：✅ Review 完成，输出：{path}
```

---

### Step 6: DevMate 主动讨论决策点 ⭐ 核心改进

**执行者**: Director（DevMate）

**前置条件**: Step 5 完成

**这是 Skill 的核心改进点**：DevMate 必须主动分析并与用户讨论，不能仅发送列表。

**执行步骤**：

1. 更新 todo：Step 6 → `in_progress`

2. 读取 Reviewer 的输出文件，提取：
   - 已一致的决策点（可直接采纳）
   - 有分歧的决策点（需要讨论）
   - Reviewer 的风险评估

3. **DevMate 主动分析**：
   - 对每个需要讨论的决策点，给出：
     - 我的**分析**：基于调研报告和已有讨论的理解
     - 我的**推荐**：倾向于哪个选项
     - 我的**理由**：为什么推荐这个
   - 对有分歧的决策点，提出调解建议

4. **主动发起讨论**：
   - 不要只发"请确认"，要主动说"我认为..."
   - 例如："对于 C2（断点粒度），我推荐 Warp 级，原因是 X、Y。你怎么看？"
   - 等待用户回复，进行多轮讨论（最多 3 轮）

5. 讨论完成后，将结论记录在 todo 的"待确认决策点"中

6. Step 6 → `done`，进入 Step 7

**Step 6 的输出格式**：

```markdown
## 决策点讨论记录

### 已一致通过（无需讨论）

| # | 决策点 | 结论 |
|---|--------|------|
| 1 | ... | ... |

### 需要讨论的决策点

#### C2: 断点粒度
- **我的分析**：...
- **我的推荐**：B) Warp 级
- **我的理由**：...
- **用户回复**：...

#### W1: ...
...
```

**关键要求**：
- 必须在发送决策点清单之前，先给出 DevMate 的分析和推荐
- 这是"讨论"，不是"考试"
- 如果用户有不同意见，要认真考虑并回应

---

### Step 7: 用户确认决策

**执行者**: Director + 用户

**前置条件**: Step 6 完成（讨论结束）

1. 更新 todo：Step 7 → `in_progress`
2. 向用户确认：讨论是否完成？是否需要修改？
3. 用户确认后，将最终决策记录在 todo 中
4. Step 7 → `done`，进入 Step 8

---

### Step 8: 生成 PRD + ADR

**执行者**: subagent:librarian

**前置条件**: Step 7 完成

1. 更新 todo：Step 8 → `in_progress`
2. 将用户确认的决策点传给 librarian
3. spawn librarian subagent（mode=run）
4. **立即 sessions_yield** — 等待 subagent 完成
5. 子 agent 完成返回后，检查 PRD 和 ADR 文件都存在
6. 验证通过 → Step 8 → `done` → 工作流完成

**Librarian 任务模板**：
```
你是 Librarian Agent，基于已确认的决策点，撰写 PRD 和 ADR。

## 已确认的决策点
[用户确认的决策点清单]

## PRD 输出要求
路径：`{project}/docs/prd/prd-YYYYMMDD-[功能名].md`

必须包含：
- 用户故事（Who/What/Why）
- MoSCoW 需求分层
- 验收标准（可测试）
- 非功能需求
- 优先级

## ADR 输出要求
路径：`{project}/docs/adr/adr-YYYYMMDD-[序号]-[决策名].md`

必须包含：
- 背景：决策上下文
- 至少 2 个备选方案及对比
- 明确的选择理由
- 风险识别和应对
- 技术债务标注

## 强制执行步骤
1. `mkdir -p {project}/docs/prd/`
2. `mkdir -p {project}/docs/adr/`
3. 创建 PRD 文件
4. 创建 ADR 文件
5. 验证两个文件都存在且大小 > 0

完成后输出：✅ PRD + ADR 已生成，路径：{prd-path}, {adr-path}
```

---

## 中断恢复流程

**任意时刻启动技能时**：

```
1. 读取 {project}/docs/.council-todo.md
2. if 不存在 → 创建新工作流（Step 1）
   else if 存在 → 根据当前步骤状态决定动作：

   | 当前步骤状态 | 恢复动作 |
   |-------------|---------|
   | Step X in_progress | 检查 Step X 的输出文件是否存在且有效 |
   |                   | - 有效 → 标记 Step X done，继续 Step X+1 |
   |                   | - 无效 → 重新执行 Step X |
   | Step X done       | 直接继续 Step X+1 |
   | Step X failed     | 向用户报告错误，询问是否重试或终止 |
   | Step 6 in_progress | 继续 Step 6 的讨论（检查 todo 中的进度） |
   | Step 7 in_progress（等待用户） | 向用户发送当前状态，请求决策 |
```

---

## 错误处理

| 错误类型 | 处理 |
|---------|------|
| 子 agent 文件验证失败 | 重新 spawn（1次），仍失败 → Step failed，向用户报告 |
| Step 7 等待超时 | 向用户发送提醒 |
| todo 文档损坏 | 向用户报告，询问是否从头开始 |
| 子 agent spawn 失败 | 向用户报告，检查错误原因 |

---

## 核心原则

1. **Step 6 必须主动讨论**：DevMate 先分析 + 推荐，再与用户讨论
2. **验证驱动**：不验证文件就不认为阶段完成
3. **支持断点恢复**：任何中断都可以从 todo 文档恢复
4. **讨论优于确认**：先充分讨论，再确认决策

---

*Version: 5.2 - 修复子 agent 数据流缺陷：PM/Architect 必须先读取 research 文件并在输出中引用；Reviewer 必须先读取 PM+Architect 文件并引用具体章节；文件不存在/为空时强制失败*