# LLM 代码能力基准测试汇总报告

**最后更新**: 2026-04-04 22:00 CST  
**测试范围**: 代码生成、代码审查、CUDA 调试  
**测试模型**: 11+ 个（Bailian 系列、Kimi-Code、MiniMax）

---

## 测试任务定义

| Task | 类型 | 要求 | 验收标准 |
|------|------|------|---------|
| **Task 1** | C++ 代码生成 | 线程安全单例模式（C++17） | 使用 `std::call_once` 或 Meyer's Singleton，说明原理 |
| **Task 2** | 代码审查 | 识别并发安全问题 | 至少找出 3 个问题，附带修复建议 |
| **Task 3** | CUDA 调试 | `cudaErrorInvalidConfiguration` 排查 | 列出 5 个最常见原因 + 排查顺序 |

---

## 测试轮次概览

| 轮次 | 时间 | 测试模型数 | 报告文件 | 备注 |
|------|------|-----------|---------|------|
| **V1-初测** | 2026-04-03 17:23 | 11 | `code_quality_20260403_172351.md` | 首次全量测试 |
| **V1-扩展** | 2026-04-03 17:43 | 11 | `code_quality_20260403_174312.md` | 增加详细输出 |
| **V1-抽样** | 2026-04-03 19:42 | 1 | `code_quality_20260403_194240.md` | 快速验证 |
| **V2-修复 1** | 2026-04-03 19:49 | 1 | `code_quality_v2_20260403_194903.md` | MiniMax 解析修复 |
| **V2-完整** | 2026-04-03 23:31 | 1 | `code_quality_v2_20260403_233151.md` | MiniMax 完整测试 |
| **V2-最终** | 2026-04-04 13:08 | 1 | `code_quality_v2_20260404_130804.md` | max_tokens 调优 |

---

## 模型评分汇总

### 综合评分（满分 10 分）

| 排名 | 模型 | Task1 | Task2 | Task3 | 总分 | 评级 |
|------|------|-------|-------|-------|------|------|
| 1 | **qwen3.5-plus** | 9.5 | 9.0 | 9.0 | **27.5** | S |
| 2 | **qwen-max** | 9.0 | 9.0 | 8.5 | **26.5** | S |
| 3 | **qwen3-coder-plus** | 9.0 | 8.5 | 8.5 | **26.0** | A+ |
| 4 | **MiniMax-M2.7-highspeed** | 9.0 | 8.5 | 9.0 | **26.5** | S |
| 5 | **kimi-code-v2** | 8.5 | 8.0 | 8.0 | **24.5** | A |
| 6 | **qwen3-32b** | 8.0 | 8.0 | 7.5 | **23.5** | A |
| 7 | **qwen2.5-coder-32b** | 7.5 | 7.5 | 7.0 | **22.0** | B+ |
| 8 | **qwen-plus** | 7.0 | 7.0 | 7.0 | **21.0** | B |

> **评分标准**:  
> - **Task1**: 代码正确性 (40%) + 原理解释 (30%) + 代码规范 (30%)  
> - **Task2**: 问题识别数量 (30%) + 准确性 (40%) + 修复建议 (30%)  
> - **Task3**: 原因覆盖度 (40%) + 排查顺序合理性 (30%) + 实用性 (30%)

---

## 详细测试结果

### Task 1: C++ 单例模式

#### 优秀答案特征
✅ 使用 Meyer's Singleton（静态局部变量）  
✅ 明确说明 C++11/17 标准保证（guard variable）  
✅ 禁止拷贝/移动语义（`= delete`）  
✅ 对比 DCLP（双重检查锁定）的问题

#### 模型对比

| 模型 | 实现方式 | 原理解释 | 代码规范 | 备注 |
|------|---------|---------|---------|------|
| qwen3.5-plus | Meyer + call_once | ✅ 详细 | ✅ 完美 | 提供两种方案对比 |
| MiniMax-M2.7 | Meyer + call_once | ✅ 详细 | ✅ 完美 | 指令重排解释清晰 |
| qwen-max | Meyer | ✅ 完整 | ✅ 优秀 | 简洁明了 |
| kimi-code-v2 | Meyer | ⚠️ 简略 | ✅ 良好 | 缺少标准引用 |

#### 参考代码（Meyer's Singleton）
```cpp
class Singleton {
public:
    static Singleton& getInstance() {
        static Singleton instance;  // C++11 起线程安全
        return instance;
    }
    
    Singleton(const Singleton&) = delete;
    Singleton& operator=(const Singleton&) = delete;
    
private:
    Singleton() = default;
    ~Singleton() = default;
};
```

---

### Task 2: 代码审查

#### 标准答案要点
1. 🔴 **数据竞争** - `std::queue` 非线程安全
2. 🔴 **Check-Then-Act 竞态** - 检查与执行非原子
3. 🟡 **忙等待** - 消费者占用 100% CPU
4. 🟡 **缺少终止条件** - 无限循环
5. 🟡 **内存可见性** - 缺少内存屏障

#### 模型表现

| 模型 | 问题数量 | 准确性 | 修复建议 | 评级 |
|------|---------|--------|---------|------|
| qwen3.5-plus | 5 | ✅ 精准 | ✅ 完整代码 | S |
| MiniMax-M2.7 | 6 | ✅ 精准 | ✅ 详细解释 | S |
| qwen-max | 4 | ✅ 准确 | ✅ 良好 | A+ |
| kimi-code-v2 | 3 | ✅ 准确 | ⚠️ 简略 | A |

---

### Task 3: CUDA 调试

#### 标准答案要点
1. Block 大小超出 `maxThreadsPerBlock`
2. Grid/Block 维度为 0 或超限
3. 动态共享内存超限
4. CUDA Stream 不合法
5. Kernel 函数签名不匹配（`__device__` vs `__global__`）

#### 模型表现

| 模型 | 原因数量 | 排查顺序 | 实用性 | 评级 |
|------|---------|---------|--------|------|
| qwen3.5-plus | 5 | ✅ 合理 | ✅ 附带代码 | S |
| MiniMax-M2.7 | 5 | ✅ 合理 | ✅ 详细工具 | S |
| qwen-max | 5 | ✅ 合理 | ✅ 良好 | A+ |
| kimi-code-v2 | 4 | ⚠️ 一般 | ⚠️ 基础 | A |

---

## 关键发现

### 1. 模型能力分层
- **S 级 (26-28 分)**: qwen3.5-plus, qwen-max, MiniMax-M2.7  
  → 适合复杂代码任务、架构设计、代码审查
- **A 级 (23-26 分)**: qwen3-coder-plus, kimi-code-v2  
  → 适合日常编码、Bug 排查
- **B 级 (20-23 分)**: qwen3-32b, qwen2.5-coder-32b  
  → 适合简单代码生成、文档辅助

### 2. MiniMax 特殊问题
**问题**: 响应解析失败（content 数组格式）  
**修复**: 统一 Python 提取器处理多种 JSON 格式  
**状态**: ✅ 已修复（v2 测试通过）

### 3. max_tokens 影响
- **<1000**: 回答被截断，Task1 代码不完整
- **1500-2000**: 完整回答，包含原理解释
- **推荐设置**: 代码任务 ≥2000 tokens

---

## 成本效益分析

| 模型 | 价格 (元/1M tokens) | 质量评分 | 性价比 | 推荐场景 |
|------|-------------------|---------|--------|---------|
| qwen3.5-plus | ~4 | 9.2 | ⭐⭐⭐⭐ | 核心开发 |
| qwen-max | ~8 | 8.8 | ⭐⭐⭐ | 关键任务 |
| MiniMax-M2.7 | ~2 | 8.8 | ⭐⭐⭐⭐⭐ | 日常编码 |
| kimi-code-v2 | ~3 | 8.2 | ⭐⭐⭐⭐ | 快速原型 |

---

## 推荐配置

### 开发环境推荐
```yaml
# 日常编码（性价比优先）
default_model: minimax-m2-7-highspeed
max_tokens: 2000

# 代码审查（质量优先）
review_model: qwen3.5-plus
max_tokens: 3000

# 架构设计（深度思考）
architecture_model: qwen-max
thinking: enabled
```

### 阈值建议
- **简单任务**（<100 行代码）: MiniMax-M2.7
- **复杂任务**（并发/性能优化）: qwen3.5-plus
- **关键审查**（生产代码）: qwen-max + qwen3.5-plus 双审

---

## 附录：测试脚本

- **V1 脚本**: `benchmark_code_quality.sh` (已废弃)
- **V2 脚本**: `benchmark_code_quality_v2.sh` (当前使用)
- **JSON 输出**: `results/json_v2_*/` 目录

---

## 后续计划

- [ ] 增加 Python 代码生成测试
- [ ] 增加 Rust 内存安全检查测试
- [ ] 增加系统设计与架构评审测试
- [ ] 测试更多模型（DeepSeek-Coder, StarCoder2）

---

**报告维护者**: DevMate  
**数据源**: `/home/ubuntu/.config/opencode/benchmark/results/`
