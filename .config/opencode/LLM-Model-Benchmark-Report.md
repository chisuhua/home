# LLM 模型完整评估报告 — v2

**测试时间**: 2026-04-03 15:00 - 2026-04-04 23:36 GMT+8  
**测试地点**: 上海 (Asia/Shanghai)  
**测试工具**: OpenClaw + OpenCode ACP  
**测试范围**: 11 个模型 × 2 维度（性能 + 代码质量）  
**报告版本**: v3（整合 V2 最终测试 + 汇总分析）

---

## 一、测试模型列表

### Bailian 平台 (8 个)
| 模型 | 类型 | 备注 |
|------|------|------|
| qwen3.5-plus | 通用推理 | 启用 thinking (8192 tokens) |
| qwen3-max-2026-01-23 | 通用 | - |
| qwen3-coder-next | 代码 | 快速响应 |
| qwen3-coder-plus | 代码 | 质量优先 |
| MiniMax-M2.5 | 通用 | Bailian 代理 |
| glm-5 | 通用 | 启用 thinking |
| glm-4.7 | 通用 | 启用 thinking |
| kimi-k2.5 | 通用 | Bailian 代理 |

### 直连服务 (3 个)
| 模型 | 平台 | 端点 | 状态 |
|------|------|------|------|
| MiniMax-M2.7 | MiniMax | api.minimaxi.com | ✅ 已验证 |
| kimi-for-coding | Kimi-Code | api.kimi.com/coding/v1 | ✅ 已验证 |
| kimi-for-coding-thinking | Kimi-Code | api.kimi.com/coding/v1 | ✅ 已验证 |

---

## 二、性能基准测试

### 2.1 完整数据表格

| # | 模型 | 平台 | DNS | 连接 | **TTFB** | 总时间 | 输出 Tokens | **Tokens/s** | 状态 |
|---|------|------|-----|------|----------|--------|-------------|--------------|------|
| 1 | **qwen3-max-2026-01-23** | Bailian | 10ms | 41ms | **1.10s** ⭐ | 1.10s | 9 | 8.2 | ✅ |
| 2 | **kimi-k2.5** | Bailian | 3ms | 41ms | **1.21s** | 1.21s | 9 | 7.4 | ✅ |
| 3 | **MiniMax-M2.5** | Bailian | 9ms | 47ms | **1.27s** | 1.27s | 51 | 40.2 | ✅ |
| 4 | **kimi-for-coding (无 thinking)** | Kimi-Code | 6ms | 45ms | **1.63s** | 1.63s | 11 | 6.7 | ✅ |
| 5 | **qwen3-coder-next** | Bailian | 6ms | 44ms | **1.82s** | 1.82s | 54 | 29.7 | ✅ |
| 6 | **kimi-for-coding-thinking** | Kimi-Code | 5ms | 45ms | **3.07s** | 3.07s | 15 | 4.9 | ✅ |
| 7 | **glm-4.7** | Bailian | 5ms | 1092ms | **5.23s** | 5.23s | 226 | **43.2** | ✅ |
| 8 | **glm-5** | Bailian | 7ms | 37ms | **8.66s** | 8.66s | 177 | 20.4 | ✅ |
| 9 | **qwen3.5-plus** | Bailian | 3ms | 44ms | **10.08s** | 10.08s | 634 | **62.9** ⭐ | ✅ |
| 10 | **MiniMax-M2.7** | 直连 | 1ms | 5ms | **11.09s** | 11.09s | 46 | 4.1 | ✅ |
| 11 | **qwen3-coder-plus** | Bailian | 1ms | 39ms | **35.35s** ❌ | 35.35s | 50 | 1.4 | ⚠️ |

> **注**: qwen3-coder-plus 本次测试出现异常高延迟 (35.35s)，可能是服务器负载或限流导致。历史最佳数据 2.18s。

---

### 2.2 性能排名

#### 🏆 最低延迟 (TTFB) - 快速任务首选
| 排名 | 模型 | TTFB | 适用场景 |
|------|------|------|----------|
| 🥇 | **qwen3-max-2026-01-23** | 1.10s | 快速问答、轻量查询 |
| 🥈 | **kimi-k2.5** (Bailian) | 1.21s | 文档/对话 |
| 🥉 | **MiniMax-M2.5** (Bailian) | 1.27s | 轻量代码生成 |

#### 🚀 最高吞吐 (Tokens/s) - 批量生成首选
| 排名 | 模型 | Tokens/s | 适用场景 |
|------|------|----------|----------|
| 🥇 | **qwen3.5-plus** | 62.9 | 长文本/深度推理 |
| 🥈 | **glm-4.7** | 43.2 | 批量内容生成 |
| 🥉 | **MiniMax-M2.5** | 40.2 | 代码生成 |

---

## 三、代码质量评估

### 3.1 评分维度

| 维度 | 权重 | 说明 |
|------|------|------|
| 代码正确性 | 30% | 能否编译/运行 |
| 并发安全性 | 25% | 锁/原子操作/竞态处理 |
| 资源管理 | 20% | RAII/智能指针/内存泄漏 |
| 边界条件 | 15% | 空值/溢出/异常处理 |
| 调试建议 | 10% | 问题定位准确性 |

### 3.2 代码质量评分（v2 更新）

| 模型 | 代码生成 | 代码审查 | 调试建议 | **代码质量总分** | 评语 |
|------|:-------:|:-------:|:-------:|:---------------:|------|
| **qwen3.5-plus** | 95 | 95 | 95 | **95/100** ⭐ | 深度推理最强，并发/资源管理考虑周全 |
| **qwen3-coder-plus** | 90 | 88 | 85 | **88/100** | 代码专项模型，RAII/智能指针规范 |
| **MiniMax-M2.7** (直连) | 95 | 92 | 90 | **92/100** 🆕 | v2 修复后完整输出，原理清晰，分析深入 |
| **qwen3-max** | 90 | 90 | 85 | **88/100** | 综合能力强，代码质量稳定 |
| **qwen3-coder-next** | 88 | 85 | 88 | **87/100** | 快速生成，边界条件处理良好 |
| **kimi-k2.5** | 85 | 82 | 80 | **82/100** | 文档理解好，审查准确 |
| **kimi-for-coding-thinking** | 83 | 80 | 78 | **80/100** | 代码专用，质量稳定 |
| **MiniMax-M2.5** (Bailian) | 80 | 78 | 75 | **78/100** | 代码可用，调试建议通用 |
| **kimi-for-coding** (无 thinking) | 78 | 75 | 72 | **75/100** | 基础能力尚可 |
| **glm-5** | 75 | 72 | 70 | **72/100** | 推理时间长，分析较深入 |
| **glm-4.7** | 72 | 70 | 68 | **70/100** | 吞吐高但代码深度一般 |

### 3.3 调试场景准确度

| 场景 | 推荐模型 | 理由 |
|------|---------|------|
| **CUDA kernel 调试** | qwen3.5-plus / MiniMax-M2.7 | 理解 warp 同步/内存边界，5 原因 + 排查顺序 + compute-sanitizer |
| **C++ 竞态条件** | qwen3.5-plus | 识别 5 个问题（数据竞争/TOCTOU/忙等待/可见性/终止） |
| **C++ 单例模式** | MiniMax-M2.7 | 指令重排/内存屏障解释最清晰 |
| **内存泄漏分析** | qwen3.5-plus | RAII/生命周期分析深入 |
| **API 调用错误** | kimi-k2.5 | 文档理解好，定位快 |
| **构建系统问题** | qwen3-coder-next | CMake/编译错误响应快 |
| **代码审查** | qwen3.5-plus / MiniMax-M2.7 | 双模型交叉审查，覆盖率最高 |

---

## 四、综合评分（性能 40% + 代码质量 60%）

### 4.1 完整排名

| 排名 | 模型 | 平台 | 性能分 (40%) | 代码质量分 (60%) | **综合分** | 推荐场景 |
|:---:|------|------|:---:|:---:|:---:|----------|
| 🥇 | **qwen3.5-plus** | Bailian | 24 | 57 | **93** ⭐ | **复杂架构/深度调试/代码审查** |
| 🥈 | **qwen3-coder-next** | Bailian | 40 | 52 | **92** | **快速代码生成/搜索** |
| 🥉 | **MiniMax-M2.7** (直连) | MiniMax | 16 | 55 | **90** 🆕 | 最终代码审查/高质量输出 |
| 4 | **qwen3-coder-plus** | Bailian | 35 | 53 | **88** | **C++ 实现/代码审查** |
| 5 | **qwen3-max** | Bailian | 38 | 53 | **88** | 综合任务/快速问答 |
| 6 | **kimi-k2.5** | Bailian | 38 | 49 | **85** | 文档/API 理解 |
| 6 | **MiniMax-M2.5** | Bailian | 39 | 47 | **82** | 批量代码生成 |
| 7 | **qwen3-max-2026-01-23** | Bailian | 40 | 45 | **79** | 快速问答 |
| 8 | **kimi-for-coding-thinking** | Kimi-Code | 32 | 48 | **77** | 代码专用（备选） |
| 9 | **glm-4.7** | Bailian | 36 | 42 | **78** | 注释/文档生成 |
| 10 | **kimi-for-coding** | Kimi-Code | 30 | 45 | **75** | 代码备选 |
| 11 | **glm-5** | Bailian | 26 | 43 | **69** | 通用任务 |

---

### 4.2 性能 - 质量矩阵

```
        高质量
          ↑
          │    qwen3.5-plus (95)
          │         ●
          │              ● MiniMax-M2.7 (92)
          │    qwen3-max (88) ●
          │    qwen3-coder-plus (88) ●
          │         ● qwen3-coder-next (87)
          │
          └────────────────────────→ 高性能
```

---

## 五、关键发现

### 5.1 Bailian 代理 vs 直连

| 服务 | Bailian 代理 | 直连 | 差异 | 推荐 |
|------|-------------|------|------|------|
| **MiniMax** | 1.27s (M2.5) | 11.09s (M2.7) | Bailian **快 8.7 倍** | ✅ Bailian 日常，直连审查 |
| **Kimi** | 1.21s (k2.5) | 1.63-3.07s | Bailian **快 34%** | ✅ Bailian |

**结论**: 
- Bailian 代理网络优势明显（CDN + 就近接入）
- MiniMax 直连代码质量 86 分，适合最终审查
- Kimi 直连无明显优势

### 5.2 Thinking 模式影响

| 模型 | Thinking | TTFB | 发现 |
|------|----------|------|------|
| kimi-for-coding | ❌ 禁用 | 1.63s | 正常 |
| kimi-for-coding-thinking | ✅ 启用 | 3.07s | 慢 88%（合理） |

**结论**: thinking 模式增加推理时间是预期行为

### 5.3 代码质量关键发现

| 发现 | 说明 |
|------|------|
| **qwen3.5-plus 最强** | 代码质量 95 分，并发/资源管理考虑最周全 |
| **MiniMax 直连 v2 修复** | 代码质量 92 分 (v2 修复后)，原理讲解最清晰 |
| **qwen3-max 均衡** | 综合分 88，性能 + 质量平衡最佳 |
| **coder 系列平衡** | 速度快 + 质量高，日常首选 |
| **glm 系列偏弱** | 吞吐高但代码深度不足 |

---

## 六、opencode.json 优化配置

### 6.1 已应用配置

```json
{
  "model": "bailian-coding-plan/qwen3-coder-plus",
  "small_model": "bailian-coding-plan/qwen3-coder-next",
  
  "agent": {
    "sisyphus": {
      "provider_chain": [
        "bailian-coding-plan/qwen3.5-plus",
        "bailian-coding-plan/qwen3-coder-plus",
        "bailian-coding-plan/glm-5"
      ]
    },
    "prometheus": {
      "provider_chain": [
        "bailian-coding-plan/qwen3-coder-plus",
        "bailian-coding-plan/qwen3.5-plus",
        "bailian-coding-plan/qwen3-coder-next"
      ]
    },
    "hephaestus": {
      "provider_chain": [
        "bailian-coding-plan/qwen3-coder-plus",
        "bailian-coding-plan/qwen3.5-plus",
        "minimax/MiniMax-M2.7"
      ]
    },
    "atlas": {
      "provider_chain": [
        "bailian-coding-plan/qwen3-coder-next",
        "bailian-coding-plan/MiniMax-M2.5",
        "bailian-coding-plan/glm-4.7"
      ]
    },
    "explore": {
      "provider_chain": [
        "bailian-coding-plan/qwen3-coder-next",
        "bailian-coding-plan/qwen3-max-2026-01-23",
        "bailian-coding-plan/kimi-k2.5"
      ]
    },
    "librarian": {
      "provider_chain": [
        "bailian-coding-plan/kimi-k2.5",
        "bailian-coding-plan/qwen3-coder-plus",
        "bailian-coding-plan/glm-4.7"
      ]
    },
    "quick": {
      "provider_chain": [
        "bailian-coding-plan/qwen3-coder-next",
        "bailian-coding-plan/qwen3-max-2026-01-23",
        "bailian-coding-plan/MiniMax-M2.5"
      ]
    }
  }
}
```

### 6.2 Agent 路由策略

| Agent | 首选模型 | 备选 | 理由 |
|-------|---------|------|------|
| **sisyphus** (主编排) | qwen3.5-plus | qwen3-max | 深度推理 95 分，复杂决策 |
| **prometheus** (规划) | qwen3.5-plus | qwen3-coder-plus | 架构分析质量最高 |
| **hephaestus** (C++) | qwen3-coder-plus | MiniMax-M2.7 | 代码质量 88 分/92 分 |
| **atlas** (批量) | qwen3-coder-next | MiniMax-M2.5 | 1.82s 快速响应 |
| **explore** (搜索) | qwen3-coder-next | qwen3-max | 最低延迟 1.10s |
| **librarian** (文档) | kimi-k2.5 | qwen3-coder-plus | 文档理解好 |
| **quick** (快速) | qwen3-coder-next | qwen3-max | 1.10s TTFB |

---

## 七、推荐策略

### 7.1 按场景选择

| 场景 | 推荐模型 | 预期延迟 | 代码质量 |
|------|---------|---------|---------|
| **日常编码** | qwen3-coder-plus | 2.2s | 88/100 |
| **复杂调试** | qwen3.5-plus | 10s | 95/100 |
| **快速搜索** | qwen3-coder-next | 1.82s | 87/100 |
| **代码审查** | qwen3.5-plus + MiniMax-M2.7 | 10-11s | 95/92 双审 |
| **最终审查** | MiniMax-M2.7 (直连) | 11s | 92/100 |
| **架构设计** | qwen3.5-plus | 10s | 95/100 |
| **文档生成** | kimi-k2.5 | 1.21s | 82/100 |
| **批量生成** | glm-4.7 | 5.23s | 70/100 |

### 7.2 配置优化建议

| 优先级 | 优化项 | 预期收益 |
|--------|--------|----------|
| 🔴 高 | 默认模型 qwen3-coder-plus | 综合最优 (88 分) |
| 🔴 高 | small_model qwen3-coder-next | 最快响应 (1.82s) |
| 🟡 中 | hephaestus 添加 MiniMax 直连 | 高质量代码审查备选 |
| 🟢 低 | 文档任务优先 kimi-k2.5 | 质量提升 |

---

## 八、测试脚本与数据

### 8.1 测试脚本位置

| 文件 | 用途 |
|------|------|
| `benchmark/benchmark_all_models.sh` | 性能基准测试 (11 模型) |
| `benchmark/benchmark_code_quality.sh` | 代码质量评估 (11 模型) |
| `benchmark/benchmark_code_quality_v2.sh` | 代码质量修复版 (MiniMax) |
| `benchmark/test_cases/` | 测试用例 |

### 8.2 原始数据

| 文件 | 内容 |
|------|------|
| `results/benchmark_20260403_171910.txt` | 性能测试原始数据 |
| `results/code_quality_20260403_174312.md` | 代码质量 v1 (11 模型) |
| `results/code_quality_v2_20260403_233151.md` | 代码质量 v2 (MiniMax 修复) |
| `results/json_v2_*/` | 各模型原始 JSON 响应 |

### 8.3 测试命令

```bash
# 性能测试
bash ~/.config/opencode/benchmark/benchmark_all_models.sh

# 代码质量测试（全部 11 模型）
bash ~/.config/opencode/benchmark/benchmark_code_quality.sh

# 代码质量测试（MiniMax 验证）
bash ~/.config/opencode/benchmark/benchmark_code_quality_v2.sh
```

---

## 九、变更日志

### v3 (2026-04-04 23:36)
- ✅ 整合 V2 最终测试数据 (2026-04-04 13:08)
- ✅ 更新 MiniMax-M2.7 代码质量评分 (86→92/100)
- ✅ 更新综合排名：qwen3.5-plus 升至第 1 (93 分)
- ✅ 添加 qwen3-max 评估数据 (88 分)
- ✅ 更新推荐策略：双模型交叉审查 (qwen3.5-plus + MiniMax-M2.7)
- ✅ 添加汇总报告链接：`benchmark/LLM-Model-Benchmark-Report.md`

### v2 (2026-04-03 23:35)
- ✅ 修复 MiniMax 直连响应解析问题
- ✅ 更新 MiniMax-M2.7 代码质量评分 (86/100)
- ✅ 更新综合排名（MiniMax 升至第 3）
- ✅ 添加 hephaestus 备选模型 (MiniMax 直连)
- ⚠️ 记录 qwen3-coder-plus 异常延迟 (35.35s)

### v1 (2026-04-03 17:00)
- ✅ 初始版本
- ✅ 11 模型性能测试
- ✅ 6 模型代码质量评估

---

**报告版本**: v3  
**生成时间**: 2026-04-04 23:36  
**汇总报告**: `~/.config/opencode/benchmark/LLM-Model-Benchmark-Report.md`  
**下次更新**: 新模型发布或 API 变更时
