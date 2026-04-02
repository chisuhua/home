# CppHDL 项目技能化分析报告

**分析日期**: 2026-04-01  
**分析人**: DevMate  
**项目状态**: Phase 1 完成，Phase 2 进行中

---

## 📊 项目概览

| 指标 | 数值 |
|------|------|
| 头文件数量 | 128 个 |
| 技能目录 | 1 个 (`cpphdl-shift-fix`) |
| TODO/FIXME | 7 个 |
| 已知架构问题 | 2 个 |
| 测试通过率 | 94% (59/63) |

---

## 🔴 已识别技能场景

### 1. 位移操作 UB 修复 ✅ 已创建技能
**技能文件**: `skills/cpphdl-shift-fix/SKILL.md`

**触发条件**:
```
error: right operand of shift expression '(1 << 32)' is greater than or equal 
to the precision 32 of the left operand
```

**修复方案**: 使用 `static_cast<uint64_t>(1) << N` 替代 `1 << N`

**涉及文件**:
- `include/core/operators.h:758`
- `include/chlib/fifo.h` (多处)
- `include/chlib/axi4lite.h:116`

---

### 2. FIFO 时序逻辑缺陷 🆕 建议创建技能

**触发条件**:
- FIFO 数据无法正确写入
- 写使能条件判断基于过时的计数值
- `sync_fifo` 示例行为异常

**问题根因**:
```cpp
// ❌ 错误模式
write_enable = wren && !is_full(count);  // count 是寄存器，组合逻辑中是旧值
```

**修复方案**:
1. 将写使能逻辑改为时序逻辑
2. 在 `describe()` 中明确指定写使能时序

**建议技能名**: `cpphdl-fifo-timing-fix`

---

### 3. 内存初始化数据流 🆕 建议创建技能

**触发条件**:
- `ch_mem` 初始化数据传递问题
- `initialize_memory` 参数理解困难
- 仿真时内存内容为 0 或非预期值

**问题根因**:
- `init_data` 从用户代码 → `ch_mem` → `context` → `memimpl` → `instr_mem` 的传递链路复杂
- `sdata_type` 位宽计算容易出错

**建议技能名**: `cpphdl-mem-init-dataflow`

**核心数据流**:
```
用户代码 (vector<uint32_t>)
    ↓ create_init_data()
sdata_type (大 bitvector)
    ↓ context::create_memory()
memimpl::init_data_
    ↓ create_instruction()
instr_mem::initialize_memory()
    ↓
memory_[] 数组 (仿真用)
```

---

### 4. 断言宏静态析构检查 🆕 建议创建技能

**触发条件**:
```
!(condition) && !ch::detail::in_static_destruction()) { \
```

**问题根因**:
- 断言宏在静态析构期间行为异常
- 需要添加 `in_static_destruction()` 检查

**修复方案**:
参考 `CHREQUIRE` 宏实现，添加静态析构检查

**建议技能名**: `cpphdl-assert-static-destruction`

---

### 5. ch_op 操作符类型安全 🆕 建议创建技能

**触发条件**:
- 编译时操作符类型不匹配
- `ch_op::shl`, `ch_op::concat` 等操作使用错误
- 模板元编程中的类型推导失败

**涉及操作符**:
| 操作符 | 用途 | 常见错误 |
|--------|------|---------|
| `ch_op::shl` | 左移 | 位移量 UB |
| `ch_op::shr` | 右移 | 位移量 UB |
| `ch_op::concat` | 拼接 | 位宽计算错误 |
| `ch_op::sext` | 符号扩展 | 目标位宽 < 源位宽 |
| `ch_op::zext` | 零扩展 | 目标位宽 < 源位宽 |
| `ch_op::and_reduce` | 与规约 | 空操作数 |
| `ch_op::or_reduce` | 或规约 | 空操作数 |
| `ch_op::xor_reduce` | 异或规约 | 空操作数 |

**建议技能名**: `cpphdl-chop-type-safety`

---

### 6. sdata_type 位宽计算 🆕 建议创建技能

**触发条件**:
- `bitwidth()` 与 `compute_bitwidth()` 混淆
- 位宽为 0 或 1 的边界情况处理错误
- `std::bit_width()` 使用不当

**核心类型**:
```cpp
struct sdata_type {
    uint32_t bitwidth() const;        // 返回 bv_.size()
    uint32_t compute_bitwidth() const; // 计算实际有效位宽
    bool is_zero() const;
};
```

**常见错误**:
```cpp
// ❌ 错误：混淆 bitwidth() 和 compute_bitwidth()
uint32_t w = data.bitwidth();  // 返回声明位宽
uint32_t w = data.compute_bitwidth();  // 返回实际有效位宽

// ❌ 错误：未处理 0 值
uint32_t w = std::bit_width(0);  // 返回 0，但位宽应为 1
```

**建议技能名**: `cpphdl-sdata-bitwidth`

---

### 7. 时钟域交叉 (CDC) 检查 🆕 建议创建技能

**触发条件**:
- 多时钟域设计
- FIFO 跨时钟域数据传输
- `FIXME: 目前暂不支持，因为需要两个不同的时钟域`

**涉及文件**:
- `include/chlib/fifo.h:183` (async_fifo)
- `include/chlib/sequential.h`

**检查清单**:
- [ ] 格雷码计数器用于跨时钟域指针
- [ ] 多级同步器用于控制信号
- [ ] 异步 FIFO 深度为 2 的幂次
- [ ] 写时钟域和读时钟域独立

**建议技能名**: `cpphdl-cdc-check`

---

### 8. RAII 内存安全模式 🆕 建议创建技能

**触发条件**:
- 技术债务清理计划 Phase 1.3
- 原始指针未正确释放
- 需要 Valgrind/ASan 检查

**修复方案**:
```cpp
// ❌ 错误：原始指针
T* ptr = new T();
// ... 可能忘记 delete

// ✅ 正确：RAII
auto ptr = std::make_unique<T>();
// 自动释放
```

**涉及文件**:
- `src/component.cpp` (已修复部分)
- `src/core/context.cpp` (已修复部分)
- 其他核心实现文件

**建议技能名**: `cpphdl-raii-memory`

---

### 9. CMake 构建系统反模式 🆕 建议创建技能

**触发条件**:
- 技术债务清理计划 Phase 2.1
- `file(GLOB_RECURSE)` 使用
- 依赖版本未锁定

**修复方案**:
```cmake
# ❌ 错误：GLOB 反模式
file(GLOB_RECURSE SOURCES "*.cpp")

# ✅ 正确：显式文件列表
set(SOURCES
    src/core/context.cpp
    src/core/operators.cpp
    # ...
)
```

**建议技能名**: `cpphdl-cmake-patterns`

---

### 10. SpinalHDL 移植模式 🆕 建议创建技能

**触发条件**:
- 从 SpinalHDL 移植代码到 CppHDL
- `examples/spinalhdl-ported/` 目录
- Stream 操作符转换

**涉及文件**:
- `docs/SpinalHDL_Stream_Operators_Implementation.md`
- `include/chlib/stream.h`
- `include/chlib/stream_builder.h`

**转换模式**:
| SpinalHDL | CppHDL |
|-----------|--------|
| `Stream[T]` | `ch_stream<T>` |
| `valid` | `valid` |
| `ready` | `ready` |
| `fire` | `fire()` |
| `<<` | `<<` |

**建议技能名**: `cpphdl-spinalhdl-porting`

---

## 📋 技能创建优先级

| 优先级 | 技能名 | 触发频率 | 影响范围 | 工作量 |
|--------|--------|---------|---------|--------|
| 🔴 P0 | `cpphdl-shift-fix` | 高 | 核心 | ✅ 已完成 |
| 🔴 P0 | `cpphdl-fifo-timing-fix` | 高 | FIFO 模块 | 2 小时 |
| 🟡 P1 | `cpphdl-mem-init-dataflow` | 中 | 内存模块 | 3 小时 |
| 🟡 P1 | `cpphdl-assert-static-destruction` | 中 | 全局 | 1 小时 |
| 🟡 P1 | `cpphdl-chop-type-safety` | 中 | 核心 | 4 小时 |
| 🟢 P2 | `cpphdl-sdata-bitwidth` | 低 | 核心 | 2 小时 |
| 🟢 P2 | `cpphdl-cdc-check` | 低 | CDC 设计 | 4 小时 |
| 🟢 P2 | `cpphdl-raii-memory` | 低 | 全局 | 6 小时 |
| 🟢 P3 | `cpphdl-cmake-patterns` | 低 | 构建系统 | 2 小时 |
| 🟢 P3 | `cpphdl-spinalhdl-porting` | 低 | 移植 | 4 小时 |

---

## 🎯 下一步行动

### 立即执行 (Today)
1. ✅ 位移操作技能已创建
2. ⏳ 创建 `cpphdl-fifo-timing-fix` 技能
3. ⏳ 创建 `cpphdl-assert-static-destruction` 技能

### 本周执行
4. 创建 `cpphdl-mem-init-dataflow` 技能
5. 创建 `cpphdl-chop-type-safety` 技能
6. 修复 `operators.h` 第 758 行位移 UB

### 本月执行
7. 完成技术债务清理 Phase 1
8. 启动 Phase 2 (构建系统现代化)
9. 添加 CI/CD 集成技能检查

---

## 📚 相关文档

- 技术债务计划: `.sisyphus/plans/cpphdl-debt-cleanup.md`
- 架构问题记录: `.acf/status/arch-issues-found.md`
- 编码记忆: `docs/coding_mem.md`
- Phase 报告: `docs/PHASE1-PHASE2-FINAL-REPORT.md`

---

**分析人**: DevMate  
**版本**: v1.0  
**最后更新**: 2026-04-01
