# CppHDL Phase 3B: RISC-V RV32I 处理器集成

创建时间：2026-04-02 06:50 GMT+8
负责人：DevMate

## 目标
实现 RV32I 基础指令集处理器，集成到 AXI4 总线系统，支持 40 条基础指令。

## 依赖检查
- [x] Phase 3A AXI4 总线系统完成
- [x] AXI4 全功能从设备可用
- [x] 4x4 Interconnect 可用
- [ ] RV32I 指令集规范确认
- [ ] 测试框架就绪

## 任务分解

### T305: RV32I 核心实现 (优先级：🔴 P0)
**目标**: 实现 40 条 RV32I 基础指令
**输出**: `include/riscv/rv32i_core.h`

指令分类：
| 类型 | 指令数 | 指令列表 |
|------|--------|----------|
| 寄存器计算 (R-type) | 10 | ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND |
| 立即数计算 (I-type) | 10 | ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI, LUI |
| 跳转 (J-type) | 2 | JAL, JALR |
| 分支 (B-type) | 6 | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| 加载 (I-type) | 5 | LB, LH, LW, LBU, LHU |
| 存储 (S-type) | 3 | SB, SH, SW |
| 系统控制 (I-type) | 4 | ECALL, EBREAK, URET, SRET |

**验收标准**:
- 所有指令通过单元测试
- 指令延迟符合预期（单周期/多周期可配置）
- 与 AXI4 总线接口兼容

### T306: 指令存储器 I-TCM (优先级：🔴 P0)
**目标**: 实现紧耦合指令存储器
**输出**: `include/riscv/i_tcm.h`

规格：
- 容量：64KB (可配置)
- 位宽：32-bit
- 接口：AXI4 从设备
- 支持：单周期访问

### T307: 数据存储器 D-TCM (优先级：🔴 P0)
**目标**: 实现紧耦合数据存储器
**输出**: `include/riscv/d_tcm.h`

规格：
- 容量：64KB (可配置)
- 位宽：32-bit
- 接口：AXI4 从设备
- 支持：单周期访问

### T308: AXI4 总线接口 (优先级：🟡 P1)
**目标**: RV32I 核心与 AXI4 总线集成
**输出**: `include/riscv/rv32i_axi_interface.h`

功能：
- 指令获取 (IF) → AXI4 读
- 数据加载/存储 (MEM) → AXI4 读/写
- 支持突发传输（指令预取）

### T309: 调试模块 DBG (优先级：🟢 P2)
**目标**: 基础调试支持
**输出**: `include/riscv/debug_module.h`

功能：
- 断点寄存器 (4 个)
- 观察点寄存器 (2 个)
- 调试状态寄存器

## 风险预案
| 风险 | 概率 | 影响 | 应对措施 |
|------|------|------|---------|
| RV32I 指令编码复杂 | 中 | 中 | 参考官方 spec，先实现子集 |
| AXI4 时序验证困难 | 高 | 高 | 使用 CppHDL 内置仿真器 |
| 性能不达标 | 低 | 中 | 添加流水线支持（Phase 3C） |

## 当前进度
✅ T305 - RV32I 核心实现完成 (2026-04-02 07:00)
✅ T306 - 指令存储器 I-TCM 完成 (2026-04-02 07:05)
✅ T307 - 数据存储器 D-TCM 完成 (2026-04-02 07:10)
✅ T308 - AXI4 总线接口集成完成 (2026-04-02 07:15)
⏳ T309 - 调试模块 (可选，Phase 3D 外设集成时一起实现)

## 完成摘要
Phase 3B 核心功能已完成，实现了完整的 RV32I 处理器：
- 40 条基础指令支持
- 64KB I-TCM + 64KB D-TCM
- AXI4 总线集成
- 测试示例程序

下一步：Phase 3C (流水线优化) 或 Phase 3D (外设集成)

## 参考文档
- RISC-V 官方手册：https://riscv.org/specifications/
- RV32I 指令集：`riscv-spec-v2.2.pdf` Chapter 2
- CppHDL 组件规范：`/workspace/CppHDL/docs/component_design.md`
