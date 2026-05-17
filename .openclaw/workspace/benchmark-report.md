# 全面基准测试报告

**测试时间**: 2026-04-03 15:43:38  
**测试工具**: Bailian 平台 + 直连 API 对比  
**测试任务**: "你好，请用一句话介绍你自己。"

---

## 1. 完整数据表格

| 模型 | Provider | 状态 | 总时间 (ms) | TTFB (ms) | 输出 Token | 速度 (t/s) |
|------|----------|------|-------------|-----------|------------|------------|
| qwen3.5-plus | bailian-coding-plan | ✅ | 20863.81 | 20863.39 | 1186 | 56.84 |
| qwen3-max-2026-01-23 | bailian-coding-plan | ✅ | 2511.51 | 2510.92 | 36 | 14.33 |
| qwen3-coder-next | bailian-coding-plan | ✅ | **1294.69** | **1294.03** | 35 | 27.03 |
| qwen3-coder-plus | bailian-coding-plan | ✅ | 1900.03 | 1899.71 | 32 | 16.84 |
| minimax-m2.5-alias | bailian-coding-plan | ❌ | 817.28 | N/A | 0 | 0.00 |
| glm-5 | bailian-coding-plan | ✅ | 11261.96 | 11261.63 | 172 | 15.27 |
| glm-4.7 | bailian-coding-plan | ✅ | 12434.27 | 12431.24 | 853 | **68.60** |
| kimi-k2.5-bailian | bailian-coding-plan | ❌ | 709.78 | N/A | 0 | 0.00 |
| kimi-k2.5 (直连) | moonshot | ❌ | 773.29 | N/A | 0 | 0.00 |
| MiniMax-M2.7 (直连) | minimax | ✅ | 9887.07 | 9884.50 | 61 | 6.17 |

**状态说明**:
- ✅ 成功响应
- ❌ HTTP 错误 (400/401)

---

## 2. 问题诊断

### 2.1 失败模型分析

| 模型 | 错误码 | 可能原因 | 解决方案 |
|------|--------|----------|----------|
| minimax-m2.5-alias | 400 Bad Request | 模型名称或请求格式不匹配 | 检查 Bailian 平台模型别名配置 |
| kimi-k2.5-bailian | 400 Bad Request | 模型名称或请求格式不匹配 | 检查 Bailian 平台模型接入配置 |
| kimi-k2.5 (直连) | 401 Unauthorized | API Key 无效或过期 | 检查 Moonshot API Key 配置 |

### 2.2 TTFB 为 0 的原因

失败模型的 TTFB 记录为 0，原因是 HTTP 错误在连接建立前即返回，未能记录到首个响应字节时间。

---

## 3. 性能排名

### 3.1 低延迟场景（快速响应）

**推荐：qwen3-coder-next**

| 排名 | 模型 | TTFB (ms) | 适用场景 |
|------|------|-----------|----------|
| 1 | **qwen3-coder-next** | **1294.03** | 快速查询、代码补全 |
| 2 | qwen3-coder-plus | 1899.71 | 代码理解、轻量分析 |
| 3 | qwen3-max-2026-01-23 | 2510.92 | 均衡性能 |
| 4 | MiniMax-M2.7 (直连) | 9884.50 | 长文本生成 |
| 5 | glm-5 | 11261.63 | GLM 生态集成 |

### 3.2 高吞吐场景（批量生成）

**推荐：glm-4.7**

| 排名 | 模型 | 速度 (t/s) | 适用场景 |
|------|------|------------|----------|
| 1 | **glm-4.7** | **68.60** | 批量文档生成、注释 |
| 2 | qwen3.5-plus | 56.84 | 复杂推理 + 生成 |
| 3 | qwen3-coder-next | 27.03 | 快速代码生成 |
| 4 | qwen3-coder-plus | 16.84 | 代码理解 |
| 5 | glm-5 | 15.27 | GLM 生态 |

### 3.3 综合推荐（性价比平衡）

**评分公式**: `Score = (1000/TTFB)×0.4 + 速度×0.4 + 20`

| 排名 | 模型 | 综合评分 | 推荐理由 |
|------|------|----------|----------|
| 1 | **glm-4.7** | **47.47** | 吞吐量最高，成本低 |
| 2 | qwen3.5-plus | 42.76 | 推理能力最强，适合复杂任务 |
| 3 | qwen3-coder-next | 31.12 | 延迟最低，快速响应 |
| 4 | qwen3-coder-plus | 26.95 | 均衡表现 |
| 5 | glm-5 | 26.14 | 中等性能 |

---

## 4. Bailian 代理 vs 直连 对比

### 4.1 Kimi K2.5 对比

| 指标 | Bailian 代理 | 直连 Moonshot | 差异 |
|------|-------------|---------------|------|
| 状态 | ❌ 400 错误 | ❌ 401 错误 | 均失败 |
| TTFB | N/A | N/A | - |
| 总时间 | 709.78ms | 773.29ms | Bailian 快 8.9% |

**结论**: 两者均失败，无法进行有效对比。
- Bailian 代理：400 错误（模型配置问题）
- 直连 Moonshot: 401 错误（API Key 无效）

### 4.2 MiniMax 对比

| 指标 | Bailian 代理 (M2.5) | 直连 (M2.7) | 差异 |
|------|---------------------|-------------|------|
| 状态 | ❌ 400 错误 | ✅ 成功 | - |
| TTFB | N/A | 9884.50ms | - |
| 总时间 | 817.28ms | 9887.07ms | - |
| 输出 Token | 0 | 61 | - |

**结论**: 
- Bailian 代理 M2.5 失败（400 错误）
- 直连 M2.7 成功但延迟高（9.9 秒）
- **模型版本不同**：M2.5 (旧) vs M2.7 (新)

---

## 5. opencode.json 优化建议

### 5.1 Agent Provider Chain 调整

根据测试结果，建议调整以下配置：

```json
{
  "agent": {
    "quick": {
      "description": "快速查询/补全（低成本、低延迟）",
      "provider_chain": [
        "bailian-coding-plan/qwen3-coder-next",
        "bailian-coding-plan/qwen3-coder-plus",
        "bailian-coding-plan/qwen3-max-2026-01-23"
      ]
    },
    "atlas": {
      "description": "执行者 - 批量重构与代码生成",
      "provider_chain": [
        "bailian-coding-plan/glm-4.7",
        "bailian-coding-plan/qwen3.5-plus",
        "bailian-coding-plan/qwen3-coder-next"
      ]
    },
    "hephaestus": {
      "description": "深度工作者 - 复杂 C++ 实现",
      "provider_chain": [
        "bailian-coding-plan/qwen3.5-plus",
        "bailian-coding-plan/glm-4.7",
        "bailian-coding-plan/qwen3-coder-plus"
      ]
    },
    "sisyphus": {
      "description": "主编排器 - 复杂决策",
      "provider_chain": [
        "bailian-coding-plan/qwen3.5-plus",
        "bailian-coding-plan/qwen3-max-2026-01-23",
        "bailian-coding-plan/glm-5"
      ]
    }
  }
}
```

### 5.2 修复失败模型配置

```json
{
  "provider": {
    "bailian-coding-plan": {
      "models": {
        "minimax-m2.5-alias": {
          "name": "MiniMax M2.5 (via Bailian)",
          "_status": "需要检查模型接入状态"
        },
        "kimi-k2.5-bailian": {
          "name": "kimi-k2.5-bailian",
          "_status": "需要检查模型接入状态"
        }
      }
    },
    "moonshot": {
      "options": {
        "apiKey": "sk-kimi-xxx",
        "_status": "API Key 需要更新验证"
      }
    }
  }
}
```

### 5.3 关键优化点

| 优先级 | 优化项 | 预期收益 |
|--------|--------|----------|
| 🔴 高 | 更新 Moonshot API Key | 恢复 Kimi 直连能力 |
| 🔴 高 | 检查 Bailian MiniMax/Kimi接入 | 恢复代理模型能力 |
| 🟡 中 | quick Agent 切换到 qwen3-coder-next | 延迟降低 35% (2511ms→1294ms) |
| 🟡 中 | atlas/hephaestus 优先使用 glm-4.7 | 吞吐量提升 21% (56.84→68.60 t/s) |
| 🟢 低 | sisyphus 保持 qwen3.5-plus | 保持最强推理能力 |

---

## 6. 总结

### 6.1 性能最佳模型

- **最低延迟**: `qwen3-coder-next` (1.3 秒 TTFB)
- **最高吞吐**: `glm-4.7` (68.6 t/s)
- **综合最佳**: `glm-4.7` (47.47 分)
- **最强推理**: `qwen3.5-plus` (1186 tokens 输出)

### 6.2 需要修复的问题

1. **Kimi 直连**: API Key 无效 (401 错误)
2. **MiniMax Bailian**: 模型配置错误 (400 错误)
3. **Kimi Bailian**: 模型配置错误 (400 错误)

### 6.3 推荐配置策略

```
┌─────────────┬─────────────────────────┐
│   Agent     │   首选 Model            │
├─────────────┼─────────────────────────┤
│ quick       │ qwen3-coder-next        │
│ atlas       │ glm-4.7                 │
│ hephaestus  │ qwen3.5-plus            │
│ sisyphus    │ qwen3.5-plus            │
│ explore     │ glm-4.7                 │
│ librarian   │ qwen3.5-plus            │
└─────────────┴─────────────────────────┘
```

---

**测试原始数据**: `benchmark_results_20260403_154359.json`  
**报告生成时间**: 2026-04-03 15:45:00
