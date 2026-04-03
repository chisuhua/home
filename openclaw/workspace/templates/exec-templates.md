# 任务计划模板

**位置**: `~/.openclaw/workspace/temp/任务名-plan.md`

```markdown
# [任务名] 执行计划
创建时间: {{timestamp}}

## 目标
{{一句话交付物}}

## 依赖检查
- [ ] 本地文件已搜索
- [ ] 相关记忆已加载
- [ ] 多 Agent 接口已确认

## 步骤
- [ ] 步骤 1: {{描述}} (负责人：{{Agent}})
- [ ] 步骤 2: {{描述}} (负责人：{{Agent}})

## 风险预案
- 若 {{风险}} 发生，则 {{应对}}

## 当前进度
正在执行：步骤 1 ({{timestamp}})
```

---

# Interview 模板

**触发条件**: 需求模糊时（交付物/风格/优先级/范围不明确）

```markdown
在开始之前，我需要确认几个方向（最多 5 问）：

Q1. [交付物格式]
A) 代码补丁 (.diff)  B) 完整文件  C) 仅建议说明

Q2. [优先级]
A) 性能优先  B) 可读性优先  C) 快速验证

Q3. [技术约束]
A) 严格遵循规范  B) 允许适度优化  C) 以原型验证为主

...（2 轮内完成，之后必须执行）
```

---

# 代码审查报告模板

**位置**: `~/.openclaw/workspace/reviews/xxx-review.md`

```markdown
## 审查报告：[模块名]
审查时间：{{timestamp}}
审查人：DevMate

### ✅ 通过项
- [x] 并发控制：使用 mutex 保护共享资源
- [x] 内存管理：所有 new/delete 配对

### ❌ 待修复项
- [ ] 空指针检查：函数 X 未校验输入参数（建议添加 guard clause）
- [ ] 性能优化：循环嵌套深度 4，建议拆分子函数

### ⚠️ 建议项
- 考虑添加单元测试覆盖边界条件
- 文档注释可补充参数说明
```

---

# 心跳状态模板

**位置**: `~/.openclaw/workspace/memory/heartbeat-state.json`

```json
{
  "lastChecks": {
    "email": {{unix_timestamp}},
    "calendar": {{unix_timestamp}},
    "project_status": {{unix_timestamp}},
    "memory_maintenance": {{unix_timestamp}}
  },
  "activeTasks": ["task-a", "task-b"],
  "lastReport": "{{timestamp}}"
}
```
