# LLM Model Benchmark Report

**最后更新**: 2026-04-04 23:36 CST  
**测试范围**: 代码生成、代码审查、CUDA 调试  
**测试模型**: 11+ 个（Bailian 系列、Kimi-Code、MiniMax）

---

## 执行摘要

本报告汇总了 2026-04-03 至 2026-04-04 期间对多个 LLM 模型的代码能力基准测试结果。测试覆盖 C++ 代码生成、并发安全审查、CUDA 调试三大核心场景。

**核心发现**:
- 🏆 **最佳综合模型**: qwen3.5-plus (27.5/30)
- 💰 **最佳性价比**: MiniMax-M2.7-highspeed (26.5/30, 价格 ~2 元/1M tokens)
- 🔧 **修复问题**: MiniMax 响应解析 (v2 脚本已修复)

---

## 测试任务定义

| Task | 类型 | 难度 | 验收标准 |
|------|------|------|---------|
| **Task 1** | C++ 代码生成 | 中级 | 线程安全单例模式，使用 `std::call_once` 或 Meyer's Singleton |
| **Task 2** | 代码审查 | 中高级 | 识别≥3 个并发安全问题，附带修复建议 |
| **Task 3** | CUDA 调试 | 高级 | 列出 5 个 `cudaErrorInvalidConfiguration` 原因 + 排查顺序 |

---

## 测试轮次历史

| 轮次 | 时间 | 模型数 | 报告文件 | 状态 |
|------|------|--------|---------|------|
| V1-初测 | 2026-04-03 17:23 | 11 | `results/code_quality_20260403_172351.md` | ✅ 完成 |
| V1-扩展 | 2026-04-03 17:43 | 11 | `results/code_quality_20260403_174312.md` | ✅ 完成 |
| V1-抽样 | 2026-04-03 19:42 | 1 | `results/code_quality_20260403_194240.md` | ✅ 完成 |
| V2-修复 1 | 2026-04-03 19:49 | 1 | `results/code_quality_v2_20260403_194903.md` | ✅ 完成 |
| V2-完整 | 2026-04-03 23:31 | 1 | `results/code_quality_v2_20260403_233151.md` | ✅ 完成 |
| V2-最终 | 2026-04-04 13:08 | 1 | `results/code_quality_v2_20260404_130804.md` | ✅ 完成 |
| **汇总** | **2026-04-04 23:36** | **-** | **本报告** | **✅ 最新** |

---

## 综合评分排名

### 总分排名（满分 30 分）

| 排名 | 模型 | Task1<br>(10 分) | Task2<br>(10 分) | Task3<br>(10 分) | 总分 | 评级 |
|:---:|------|:---:|:---:|:---:|:---:|:---:|
| 1 | **qwen3.5-plus** | 9.5 | 9.0 | 9.0 | **27.5** | 🥇 S |
| 2 | **qwen-max** | 9.0 | 9.0 | 8.5 | **26.5** | 🥈 S |
| 3 | **MiniMax-M2.7-highspeed** | 9.0 | 8.5 | 9.0 | **26.5** | 🥈 S |
| 4 | **qwen3-coder-plus** | 9.0 | 8.5 | 8.5 | **26.0** | 🥉 A+ |
| 5 | **kimi-code-v2** | 8.5 | 8.0 | 8.0 | **24.5** | A |
| 6 | **qwen3-32b** | 8.0 | 8.0 | 7.5 | **23.5** | A |
| 7 | **qwen2.5-coder-32b** | 7.5 | 7.5 | 7.0 | **22.0** | B+ |
| 8 | **qwen-plus** | 7.0 | 7.0 | 7.0 | **21.0** | B |

### 评分标准

```
Task1 (代码生成): 代码正确性 (40%) + 原理解释 (30%) + 代码规范 (30%)
Task2 (代码审查): 问题识别数量 (30%) + 准确性 (40%) + 修复建议 (30%)
Task3 (CUDA 调试): 原因覆盖度 (40%) + 排查顺序 (30%) + 实用性 (30%)

评级: S (26-30) | A (23-25) | B (20-22) | C (<20)
```

---

## Task 1: C++ 单例模式 - 详细对比

### 测试题目
> 用 C++17 实现一个线程安全的单例模式，支持懒加载和防止双重检查锁定问题。

### 评分细则

| 评分项 | 分值 | 说明 |
|--------|------|------|
| 正确实现 Meyer's Singleton | 4 分 | 使用静态局部变量 |
| 或正确实现 std::call_once | 4 分 | 使用 once_flag |
| 解释 DCLP 问题 | 2 分 | 指令重排/内存屏障 |
| 解释 C++ 标准保证 | 2 分 | guard variable 机制 |
| 代码规范 (delete 拷贝等) | 2 分 | 完整类定义 |

### 模型表现

| 模型 | 实现方式 | DCLP 解释 | 标准引用 | 代码完整 | 得分 |
|------|---------|----------|---------|---------|------|
| qwen3.5-plus | Meyer + call_once | ✅ 详细 | ✅ C++11 §6.7 | ✅ 完美 | 9.5 |
| qwen-max | Meyer | ✅ 完整 | ✅ 提及 | ✅ 优秀 | 9.0 |
| MiniMax-M2.7 | Meyer + call_once | ✅ 指令重排 | ✅ C++11/17 | ✅ 完美 | 9.0 |
| qwen3-coder-plus | Meyer | ✅ 完整 | ⚠️ 简略 | ✅ 良好 | 9.0 |
| kimi-code-v2 | Meyer | ⚠️ 简略 | ❌ 无 | ✅ 良好 | 8.5 |
| qwen3-32b | Meyer | ⚠️ 基础 | ❌ 无 | ✅ 良好 | 8.0 |

### 参考答案 (Meyer's Singleton)

```cpp
// singleton.hpp
#pragma once

class Singleton {
public:
    // 全局访问点 - 线程安全，懒加载
    static Singleton& getInstance() {
        static Singleton instance;  // C++11 起保证线程安全
        return instance;
    }
    
    // 禁止拷贝和移动
    Singleton(const Singleton&) = delete;
    Singleton& operator=(const Singleton&) = delete;
    Singleton(Singleton&&) = delete;
    Singleton& operator=(Singleton&&) = delete;
    
    // 业务接口
    void doSomething() { /* ... */ }

private:
    Singleton() = default;
    ~Singleton() = default;
};
```

---

## Task 2: 代码审查 - 详细对比

### 测试题目
> 找出以下代码中的并发安全问题（至少 3 个）

```cpp
std::queue<int> sharedQueue;
void producer() {
    for (int i = 0; i < 100; i++) {
        if (sharedQueue.size() < 100) {
            sharedQueue.push(i);
        }
    }
}
void consumer() {
    while (true) {
        if (!sharedQueue.empty()) {
            int val = sharedQueue.front();
            sharedQueue.pop();
        }
    }
}
```

### 标准答案要点

| 问题 | 风险等级 | 描述 |
|------|---------|------|
| 数据竞争 | 🔴 高危 | `std::queue` 非线程安全，并发读写导致 UB |
| Check-Then-Act 竞态 | 🔴 高危 | 检查与执行非原子，状态可能变化 |
| 忙等待 (Busy Wait) | 🟡 中危 | 消费者空转占用 100% CPU |
| 缺少终止条件 | 🟡 中危 | `while(true)` 无法退出 |
| 内存可见性 | 🟡 中危 | 缺少内存屏障，缓存一致性问题 |

### 模型表现

| 模型 | 问题数量 | 高危识别 | 中危识别 | 修复代码 | 得分 |
|------|---------|---------|---------|---------|------|
| MiniMax-M2.7 | 6 | ✅ 2/2 | ✅ 4/4 | ✅ 完整 | 8.5 |
| qwen3.5-plus | 5 | ✅ 2/2 | ✅ 3/4 | ✅ 完整 | 9.0 |
| qwen-max | 4 | ✅ 2/2 | ✅ 2/4 | ✅ 良好 | 9.0 |
| qwen3-coder-plus | 4 | ✅ 2/2 | ✅ 2/4 | ⚠️ 简略 | 8.5 |
| kimi-code-v2 | 3 | ✅ 2/2 | ⚠️ 1/4 | ⚠️ 基础 | 8.0 |

---

## Task 3: CUDA 调试 - 详细对比

### 测试题目
> CUDA kernel 启动后返回 `cudaErrorInvalidConfiguration`，列出 5 个最常见原因和排查顺序。

### 标准答案要点

| 排名 | 原因 | 检查方法 |
|------|------|---------|
| 1 | Block 大小超出 `maxThreadsPerBlock` | `cudaGetDeviceProperties` |
| 2 | Grid/Block 维度为 0 或超限 | 验证 `dim3` 参数 |
| 3 | 动态共享内存超限 | 检查 `sharedMemPerBlock` |
| 4 | CUDA Stream 不合法 | 验证 stream 创建/销毁 |
| 5 | Kernel 函数签名不匹配 | 确认 `__global__` vs `__device__` |

### 模型表现

| 模型 | 原因数量 | 排查顺序 | 代码示例 | 工具提及 | 得分 |
|------|---------|---------|---------|---------|------|
| qwen3.5-plus | 5 | ✅ 合理 | ✅ 完整 | ✅ compute-sanitizer | 9.0 |
| MiniMax-M2.7 | 5 | ✅ 合理 | ✅ 完整 | ✅ compute-sanitizer | 9.0 |
| qwen-max | 5 | ✅ 合理 | ✅ 良好 | ⚠️ 基础 | 8.5 |
| qwen3-coder-plus | 5 | ✅ 合理 | ✅ 良好 | ⚠️ 基础 | 8.5 |
| kimi-code-v2 | 4 | ⚠️ 一般 | ⚠️ 简略 | ❌ 无 | 8.0 |

---

## 成本效益分析

### 价格对比（参考公开定价）

| 模型 | 输入价格<br>(元/1M tokens) | 输出价格<br>(元/1M tokens) | 质量评分 | 性价比 |
|------|--------------------------|--------------------------|---------|--------|
| MiniMax-M2.7-highspeed | ~1.0 | ~2.0 | 8.8 | ⭐⭐⭐⭐⭐ |
| qwen3.5-plus | ~2.0 | ~4.0 | 9.2 | ⭐⭐⭐⭐ |
| qwen3-coder-plus | ~1.5 | ~3.0 | 8.7 | ⭐⭐⭐⭐ |
| kimi-code-v2 | ~1.5 | ~3.0 | 8.2 | ⭐⭐⭐ |
| qwen-max | ~4.0 | ~8.0 | 8.8 | ⭐⭐⭐ |
| qwen3-32b | ~0.5 | ~1.0 | 7.8 | ⭐⭐⭐ |

### 推荐配置

```yaml
# 日常开发（性价比优先）
default:
  model: minimax-m2-7-highspeed
  max_tokens: 2000

# 代码审查（质量优先）
code_review:
  model: qwen3.5-plus
  max_tokens: 3000

# 架构设计（深度思考）
architecture:
  model: qwen-max
  thinking: enabled
  max_tokens: 4000

# 快速原型（速度优先）
prototype:
  model: qwen3-32b
  max_tokens: 1500
```

---

## 关键发现与问题修复

### 1. MiniMax 响应解析问题 (已修复)

**问题**: MiniMax API 返回的 `content` 是数组格式，初始脚本无法正确提取。

**修复前**:
```json
{"content": [{"type": "text", "text": "..."}]}
```

**修复方案**: 统一 Python 提取器处理多种 JSON 格式

**修复后脚本** (`benchmark_code_quality_v2.sh`):
```python
def extract_text(json_data):
    content = data.get("content", [])
    if isinstance(content, list):
        texts = [item["text"] for item in content if item.get("type") == "text"]
        return "\n".join(texts)
    return data.get("text", "[无法解析]")
```

### 2. max_tokens 对输出质量的影响

| max_tokens | Task1 完成度 | Task2 完成度 | Task3 完成度 |
|-----------|-------------|-------------|-------------|
| <1000 | ❌ 代码截断 | ⚠️ 缺少修复 | ⚠️ 缺少示例 |
| 1500 | ✅ 代码完整 | ✅ 完整 | ✅ 完整 |
| 2000+ | ✅ 代码 + 原理 | ✅ 完整 + 解释 | ✅ 完整 + 工具 |

**建议**: 代码任务设置 `max_tokens ≥ 2000`

### 3. 模型能力分层

```
S 级 (26-30 分) → 复杂代码任务、架构设计、生产代码审查
A 级 (23-26 分) → 日常编码、Bug 排查、功能开发
B 级 (20-23 分) → 简单代码生成、文档辅助、学习用途
```

---

## 测试基础设施

### 测试脚本

| 脚本 | 状态 | 说明 |
|------|------|------|
| `benchmark_code_quality.sh` | 🚫 废弃 | V1 版本，MiniMax 解析有问题 |
| `benchmark_code_quality_v2.sh` | ✅ 当前 | 修复 MiniMax 解析，统一提取器 |

### 数据目录结构

```
/home/ubuntu/.config/opencode/benchmark/
├── LLM-Model-Benchmark-Report.md    # 本报告（汇总）
├── LLM_BENCHMARK_SUMMARY.md         # 简版汇总
├── benchmark_code_quality_v2.sh     # 测试脚本
└── results/
    ├── code_quality_v2_20260404_130804.md  # 最新测试
    ├── code_quality_v2_20260403_233151.md
    ├── code_quality_20260403_174312.md
    └── json_v2_*/                            # 原始 JSON 响应
        ├── minimax-m2-7-direct-highspeed/
        │   ├── task1_raw.json
        │   ├── task2_raw.json
        │   └── task3_raw.json
        └── ...
```

---

## 后续计划

| 优先级 | 任务 | 预计时间 |
|--------|------|---------|
| 🔴 P0 | 增加 Python 代码生成测试 | 2026-04-05 |
| 🟡 P1 | 增加 Rust 内存安全测试 | 2026-04-06 |
| 🟡 P1 | 增加系统设计/架构评审测试 | 2026-04-07 |
| 🟢 P2 | 测试更多模型 (DeepSeek-Coder, StarCoder2) | 2026-04-10 |
| 🟢 P2 | 增加长上下文测试 (32K+ tokens) | 2026-04-15 |

---

## 附录：快速参考

### 模型选择决策树

```
需要生成/审查代码？
├─ 生产环境关键代码 → qwen-max 或 qwen3.5-plus
├─ 日常开发 → MiniMax-M2.7-highspeed
├─ 快速原型 → qwen3-32b
└─ 预算有限 → MiniMax-M2.7-highspeed (性价比最高)

需要 CUDA/系统编程？
├─ 是 → qwen3.5-plus 或 MiniMax-M2.7
└─ 否 → 任意 A 级以上模型

需要架构设计？
└─ qwen-max (深度思考模式)
```

### 联系方式

**报告维护者**: DevMate  
**数据源**: `/home/ubuntu/.config/opencode/benchmark/results/`  
**测试脚本**: `/home/ubuntu/.config/opencode/benchmark/benchmark_code_quality_v2.sh`

---

*最后更新: 2026-04-04 23:36 CST*
