# OpenCode 多代理上下文文件索引

## 概述

本文档记录从 `/home/ubuntu/.local/share/opencode/log/` 日志文件中提取的真实 API payload 上下文。

---

## 已提取的上下文文件

| 文件 | Agent | Model | 来源 Log | 上下文长度 |
|------|-------|-------|---------|-----------|
| `context-01-title-generator.txt` | title (small model) | qwen3.5-flash | 041722.log:188 | 531 chars |
| `context-02-prometheus.txt` | Prometheus (Plan Builder) | kimi-for-coding | 041722.log:519 | 10,196 chars |
| `context-03-explore.txt` | explore (subagent) | deepseek-v4-flash | 034058.log:288 | 531 chars |

---

## 上下文内容详解

### 1. context-01-title-generator.txt

**用途**: 小模型标题生成器（用于 session 标题自动生成）

**触发场景**: 当用户开启新 session 时，OpenCode 自动调用 title generator 为 session 生成标题

**System Prompt**:
```
You are a title generator. You output ONLY a thread title. Nothing else.

<task>
Generate a brief title that would help the user find this conversation later.
...
</task>
```

**特点**: 极简 prompt，仅 531 字符，设计为轻量级任务使用小模型

**验证建议**: 可直接发送给 LLM 测试其是否能正确生成标题

---

### 2. context-02-prometheus.txt

**用途**: Prometheus 计划构建器（子代理模式）

**触发场景**: 当用户请求复杂任务规划时，Sisyphus 调用 Prometheus 进行架构分析和计划生成

**System Prompt 组成** (10,196 字符):
1. **OpenCode 基础提示** (~3,000 chars)
   - "You are OpenCode, an interactive general AI agent..."
   - 通用编码指南、研究指南、工作目录说明

2. **AGENTS.md 内容** (~7,000 chars)
   - 来自 `/home/ubuntu/.config/opencode/AGENTS.md`
   - 包含编码风格、安全约束、决策准则、TDD 流程等

3. **Prometheus prompt_append** (~500 chars)
   - `<identity>`: Prometheus — strategic planner
   - `<decision_completeness>`: 零决策留给实施者
   - `<methodology>`: SCOPE → DEPENDENCY GRAPH → BREAKDOWN → RISK MAP → QA
   - `<output_format>`: Markdown 格式的计划模板

**关键发现**: Subagent 收到完整的 OpenCode 基础提示 + AGENTS.md 内容，但 prompt_append 是各自 agent 特有的

---

### 3. context-03-explore.txt

**用途**: Explore 代码搜索代理

**状态**: 与 Title Generator 相同（531 chars）- 来自 ERROR 行的系统提示

**说明**: Explore 成功调用时使用 deepseek-v4-flash 模型，ERROR 行记录的是 title generator 的备用 prompt

---

## 缺失的上下文

以下上下文在日志中未找到完整 API payload（可能因为成功调用未记录）:

| Agent | 预期 Model | 说明 |
|-------|-----------|------|
| Sisyphus | MiniMax-M2.7 | 主编排器，mode=primary |
| Oracle | kimi-for-coding | 架构/调试顾问 |
| Librarian | MiniMax-M2.7 | 文档/参考搜索 |
| Atlas | MiniMax-M2.7 | 批量执行器 |
| Hephaestus | DeepSeek-v4-pro | 深度 C++ 工作者 |

---

## 如何验证这些上下文

### 方法 1: 直接发送给 LLM

```bash
# 测试 Title Generator
curl -X POST https://api.example.com/chat \
  -H "Content-Type: application/json" \
  -d @context-01-title-generator.txt

# 测试 Prometheus
curl -X POST https://api.kimi.com/coding/v1/chat/completions \
  -H "Authorization: Bearer $KIMI_API_KEY" \
  -d @context-02-prometheus.txt
```

### 方法 2: 手动复制粘贴到 Chat UI

1. 打开目标模型的 Chat UI
2. 选择 "System Prompt" 或 "Assistant" 角色
3. 粘贴文件内容
4. 添加测试 User Message
5. 观察 LLM 输出

### 方法 3: 对比分析

比较 `context-01-title-generator.txt` 和 `context-02-prometheus.txt`：
- 两者都使用 OpenCode 基础提示框架
- 但 prompt_append 内容完全不同
- Title Generator 无 AGENTS.md 内容
- Prometheus 有完整 AGENTS.md 内容

---

## 关键发现总结

### 1. System Prompt 注入方式

```
OpenCode 基础提示 (固定) + AGENTS.md 内容 (引用后注入) + prompt_append (agent 特有)
```

### 2. Subagent 与 Primary Agent 的区别

| 组成部分 | Sisyphus (Primary) | Subagent (Prometheus) |
|---------|--------------------|-----------------------|
| OpenCode 基础提示 | ✅ | ✅ |
| AGENTS.md 内容 | ✅ | ✅ |
| prompt_append | Sisyphus 专用 | Prometheus 专用 |
| Tool Schema | ✅ | ❌ (未在日志中确认) |

### 3. 小模型上下文特点

- 仅 531 chars
- 无 AGENTS.md 内容
- 专门为轻量任务设计
- 使用 qwen3.5-flash 等小模型

### 4. 日志限制

- **成功调用不记录完整 payload** - 只有 ERROR 行包含 requestBodyValues
- 需要通过 ERROR 行反推正常调用的上下文组成

---

## 文件位置

```
/home/ubuntu/.config/opencode/
├── context-01-title-generator.txt  # Title Generator 上下文
├── context-02-prometheus.txt        # Prometheus 上下文
├── context-03-explore.txt           # Explore 上下文
├── opencode-context-baseline.md    # 之前构造的基线文档
└── opencode-real-context-verified.md # 基于日志验证的文档
```

---

## 验证步骤建议

1. **读取上下文文件**: 查看 `context-*.txt` 内容
2. **选择测试模型**: 如 kimi-for-coding, qwen3.5-flash
3. **构造 API 请求**: 按照日志中的 requestBodyValues 格式
4. **对比输出**: 检查不同上下文对 LLM 输出的影响

---

## 附录: Log 行号对照

| 场景 | Log 文件 | 行号 | Agent | Model |
|------|---------|------|-------|-------|
| Title Generator 调用 | 041722.log | 188 | title | qwen3.5-flash |
| Prometheus 调用 | 041722.log | 519 | Prometheus | kimi-for-coding |
| Explore ERROR | 034058.log | 288 | explore | deepseek-v4-flash |
| Sisyphus session 标题生成 | 041722.log | 4431 | title (via Sisyphus) | qwen3.5-flash |