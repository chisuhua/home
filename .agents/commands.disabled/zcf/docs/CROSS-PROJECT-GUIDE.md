# 跨项目架构文档模板使用指南

**创建日期**：2026-03-26  
**适用范围**：所有使用 `/zcf:arch-doc` 工作流的项目

---

## 快速开始

### 1. 在新项目中启动工作流

```bash
# 第一步：创建总体架构文档
/zcf:arch-doc "<项目名称>"

# 第二步：创建错误处理策略（项目级框架）
/zcf:arch-doc "错误处理策略"

# 第三步：创建项目测试策略
/zcf:arch-doc "<项目名称>测试策略"

# 第四步：创建实施计划
/zcf:arch-doc "阶段实施计划：<项目名称>"
```

### 2. 创建模块文档

```bash
# 模块详细设计
/zcf:arch-doc "阶段 1：爬虫模块详细设计"

# 模块测试策略（引用项目级错误处理策略）
/zcf:arch-doc "阶段 1：爬虫模块测试策略"

# 模块 API 规范
/zcf:arch-doc "阶段 1：爬虫模块 API 规范"
```

---

## 文档模板说明

### 模板位置

所有模板文件位于：`~/.claude/commands/zcf/templates/`

```
templates/
├── error-handling-strategy-template.md   # 错误处理策略（简化版，5KB）
├── test-strategy-template.md             # 项目测试策略（8KB）
├── module-test-strategy-template.md      # 模块测试策略（7KB）
├── detailed-design-template.md           # 模块详细设计（9KB）
├── api-spec-template.md                  # API 规范（8KB）
├── database-schema-template.md           # 数据库设计（11KB）
├── implementation-plan-template.md       # 实施计划（8KB）
├── architecture-document-template.md     # 总体架构文档（6KB）
├── adr-template.md                       # ADR 模板（3KB）
└── checklist-integrity.md                # 完整性检查清单（5KB）
```

### 参考文档

- **详细版错误处理策略**：`/home/ubuntu/docs/architecture/error-handling-strategy.md` (31KB)
  - 完整框架参考，包含所有细节和实现示例
  - 适合需要深度理解错误处理机制时使用
  
- **简化版错误处理策略模板**：`templates/error-handling-strategy-template.md` (5KB)
  - 快速启动框架，保留核心内容
  - 适合新项目快速建立错误处理规范

---

## 错误处理策略：简化版 vs 详细版

### 简化版（模板）

**特点**：
- 5KB，核心框架
- 包含 P0-P4 分类、错误码规范、4 种处理模式
- 去掉详细实现代码和过多示例
- 适合快速 customization

**适用场景**：
- 新项目启动（快速建立框架）
- 小团队项目（不需要过于复杂的流程）
- MVP 阶段（先有再优化）

**核心内容**：
1. 错误分类（P0-P4）
2. 错误码规范
3. 4 种处理模式（重试/熔断/降级/超时）
4. 日志记录标准
5. 监控告警阈值
6. 恢复流程
7. 检查清单

### 详细版（参考）

**特点**：
- 31KB，800+ 行
- 包含完整实现代码（Python 示例）
- 详细的配置示例和最佳实践
- 决策树和流程图

**适用场景**：
- 复杂系统（需要详细的错误处理逻辑）
- 大团队（需要统一规范）
- 生产环境（需要完整的监控告警）

**额外内容**：
1. 完整的重试/熔断/降级实现代码
2. 详细的配置参数说明
3. 更多的错误场景示例
4. 完整的 Post-Mortem 流程
5. 错误处理决策树
6. 最佳实践（Do's and Don'ts）

### 如何选择

| 项目特点 | 推荐版本 | 理由 |
|---------|---------|------|
| 新项目启动 | 简化版 | 快速建立框架，后续可扩展 |
| MVP/原型 | 简化版 | 满足基本需求，不增加负担 |
| 生产系统 | 详细版 | 需要完整的错误处理机制 |
| 大团队（>10 人） | 详细版 | 需要统一规范和详细指导 |
| 复杂分布式系统 | 详细版 | 需要熔断/降级等高级模式 |
| 简单 CRUD 应用 | 简化版 | 基础错误处理即可 |

---

## 文档引用链

### 项目级文档

```
error-handling-strategy.md（项目级框架）
    ↓
test-strategy.md（引用错误处理策略）
    ↓
implementation-plan.md（引用测试策略）
```

### 模块级文档

```
<module>/detailed-design.md
    ↓  引用
<module>/test-strategy.md（引用项目级 error-handling-strategy.md）
```

### 引用示例

在模块测试策略文档中：

```markdown
## 错误处理测试

本模块的错误处理遵循项目级错误处理策略：
- 文档：`docs/architecture/error-handling-strategy.md`
- 错误分类：P0-P4（见文档第 1 章）
- 错误码规范：`CRAWLER_XXX`（见文档 1.2 节）
- 处理模式：重试/熔断/降级/超时（见文档第 2 章）

### 模块特定错误

| 错误码 | 错误级别 | 触发条件 | 处理策略 |
|--------|---------|---------|---------|
| CRAWLER_001 | P1 | 连续 3 次请求失败 | 重试 3 次后熔断 |
| CRAWLER_002 | P2 | 解析失败 | 记录日志，跳过该条目 |
```

---

## 工作流顺序

**推荐的文档创建顺序**：

```
1. 总体架构文档（YYYY-MM-DD-<system-name>.md）
   ↓
2. 错误处理策略（error-handling-strategy.md）← 项目级框架
   ↓
3. 项目测试策略（test-strategy.md）← 引用错误处理策略
   ↓
4. 实施计划（implementation-plan.md）
   ↓
5. 模块详细设计（phase-X/<module>/detailed-design.md）
   ↓
6. 模块测试策略（phase-X/<module>/test-strategy.md）← 引用项目级错误处理
```

**为什么这个顺序**：
1. 先有总体架构，明确系统边界
2. 建立错误处理框架（所有模块遵循）
3. 基于错误处理制定测试策略
4. 制定实施计划（分阶段）
5. 逐个模块详细设计
6. 模块测试策略（基于项目级策略细化）

---

## 在不同项目中使用

### 场景 1：全新项目

```bash
# 项目初始化
/zcf:arch-doc "电商分析系统"

# 创建项目级框架
/zcf:arch-doc "错误处理策略"
/zcf:arch-doc "电商分析系统测试策略"

# 创建实施计划
/zcf:arch-doc "阶段实施计划：电商分析系统"

# 创建模块文档
/zcf:arch-doc "阶段 1：爬虫模块详细设计"
/zcf:arch-doc "阶段 1：爬虫模块测试策略"
/zcf:arch-doc "阶段 1：存储模块详细设计"
/zcf:arch-doc "阶段 1：存储模块测试策略"
```

### 场景 2：已有项目补充文档

```bash
# 补充错误处理策略
/zcf:arch-doc "错误处理策略"

# 补充测试策略
/zcf:arch-doc "电商分析系统测试策略"

# 补充缺失的模块文档
/zcf:arch-doc "阶段 1：爬虫模块详细设计"
```

### 场景 3：更新现有文档

```bash
# 更新架构文档
/zcf:arch-doc "更新：电商分析系统架构，添加消息队列"

# 更新错误处理策略
/zcf:arch-doc "更新：错误处理策略，添加 Kafka 连接错误"

# 更新模块设计
/zcf:arch-doc "更新：爬虫模块详细设计，添加重试次数配置"
```

---

## 模板 Customization

### 错误处理策略模板

复制模板到项目文档目录：

```bash
cp ~/.claude/commands/zcf/templates/error-handling-strategy-template.md \
   docs/architecture/error-handling-strategy.md
```

**需要替换的占位符**：
```
{{DATE}} → 2026-03-26
{{LAST_UPDATE}} → 2026-03-26
{{VERSION}} → v1.0
{{MODULE_1}} → 爬虫模块
{{PREFIX_1}} → CRAWLER
{{MODULE_2}} → 存储模块
{{PREFIX_2}} → STORAGE
```

**可以调整的内容**：
1. 错误分类阈值（根据项目规模）
2. 响应时间要求（根据业务需求）
3. 通知渠道（根据团队习惯）
4. 重试次数和超时时间（根据系统特点）

### 测试策略模板

```bash
cp ~/.claude/commands/zcf/templates/test-strategy-template.md \
   docs/architecture/test-strategy.md
```

**需要替换的占位符**：
```
{{DATE}} → 2026-03-26
{{PROJECT_NAME}} → 电商分析系统
{{TEST_LEAD}} → 测试负责人姓名
```

---

## 工作流指南

完整的 workflow guide 可以通过以下命令查看：

```bash
# 查看完整工作流指南
/zcf:guide

# 查看快速参考
/zcf:guide --quick
```

**指南位置**：
- 完整指南：`~/.claude/commands/zcf/docs/WORKFLOW_GUIDE.md`
- 快速参考：`~/.claude/commands/zcf/docs/QUICK_REFERENCE.md`

---

## 常见问题

### Q1: 是否每个项目都需要创建错误处理策略？

**A**: 是的，建议每个项目都创建。原因：
1. 统一错误分类标准（P0-P4）
2. 统一错误码规范
3. 明确处理模式（重试/熔断/降级/超时）
4. 明确监控告警阈值

使用简化版模板只需 5KB，不会增加负担。

### Q2: 模块需要创建自己的错误处理策略吗？

**A**: 不需要。模块只需：
1. 在模块测试策略中引用项目级错误处理策略
2. 定义模块特定的错误码（遵循项目规范）
3. 实现模块级别的错误处理逻辑

### Q3: 简化版不够用怎么办？

**A**: 参考详细版（31KB）：
```bash
# 查看详细版
cat /home/ubuntu/docs/architecture/error-handling-strategy.md

# 根据需要添加内容到项目文档
```

### Q4: 可以在简化版基础上扩展吗？

**A**: 可以。推荐做法：
1. 先使用简化版模板创建基础框架
2. 根据项目实际需求添加章节
3. 参考详细版添加实现代码示例
4. 保持 P0-P4 分类和错误码规范不变

---

## 总结

### 核心价值

1. **简化版模板**：5KB，快速启动，适合大多数项目
2. **详细版参考**：31KB，完整框架，适合复杂系统
3. **统一工作流**：`/zcf:arch-doc` 命令，一致的文档创建流程
4. **清晰的引用链**：项目级 → 模块级，避免重复

### 最佳实践

1. ✅ 新项目先创建错误处理策略（简化版）
2. ✅ 模块文档引用项目级策略，不重复创建
3. ✅ 按推荐顺序创建文档（架构 → 错误处理 → 测试 → 实施 → 模块）
4. ✅ 根据项目规模选择合适的版本（简化版/详细版）

### 下一步

1. 在新项目中使用 `/zcf:arch-doc` 创建工作流
2. 根据项目特点 customization 模板
3. 创建第一个模块的详细设计和测试策略
4. 使用 `/zcf:github-sync` 同步到 GitHub Issues

---

**相关文档**：
- 完整工作流指南：`~/.claude/commands/zcf/docs/WORKFLOW_GUIDE.md`
- 快速参考：`~/.claude/commands/zcf/docs/QUICK_REFERENCE.md`
- 错误处理策略详细版：`/home/ubuntu/docs/architecture/error-handling-strategy.md`
