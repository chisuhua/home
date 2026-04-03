# RV32I Phase 3C: 5 级流水线优化

创建时间:2026-04-03 12:40 GMT+8
负责人:DevMate

## 目标
将当前单周期 RV32I 核心升级为 5 级流水线,目标 IPC ≥ 0.8

## 5 级流水线划分

| 阶段 | 名称 | 功能 | 延迟 |
|------|------|------|------|
| **IF** | Instruction Fetch | 从 I-TCM 取指令 | 1 cycle |
| **ID** | Instruction Decode | 译码 + 寄存器读取 | 1 cycle |
| **EX** | Execute | ALU 计算/有效地址生成 | 1 cycle |
| **MEM** | Memory | 数据存储器访问 | 1 cycle |
| **WB** | Write Back | 结果写回寄存器 | 1 cycle |

## 任务分解

### T3C-1: 流水线寄存器设计 (🔴 P0)
**目标**: 设计 4 个流水线寄存器
**输出**: `include/riscv/rv32i_pipeline_regs.h`

| 寄存器 | 位置 | 传递信号 |
|--------|------|---------|
| IF/ID | IF → ID | PC, 指令 |
| ID/EX | ID → EX | 控制信号,RS1/RS2 数据,立即数,目的寄存器 |
| EX/MEM | EX → MEM | ALU 结果,写数据,控制信号,目的寄存器 |
| MEM/WB | MEM → WB | 读数据/ALU 结果,控制信号,目的寄存器 |

### T3C-2: 数据冒险检测与前推 (🔴 P0)
**目标**: 实现数据前推单元
**输出**: `include/riscv/rv32i_forwarding.h`

**冒险类型**:
- RAW (Read After Write): 需要前推
- WAW (Write After Write): RV32I 顺序执行,不会发生
- WAR (Write After Read): RV32I 顺序执行,不会发生

**前推路径**:
- EX → EX: ALU 结果前推到 ALU 输入
- MEM → EX: 访存结果前推到 ALU 输入
- WB → EX: 写回结果前推到 ALU 输入

### T3C-3: 控制冒险处理 (🟡 P1)
**目标**: 实现分支预测
**输出**: `include/riscv/rv32i_branch_predict.h`

**策略**:
- 静态预测:分支永远不跳转 (BNT)
- 或:简单动态预测 (1-bit saturating counter)

**气泡生成**:
- 分支指令在 ID 阶段检测
- 预测错误时 flush IF/ID 寄存器

### T3C-4: 结构冒险处理 (🟡 P1)
**目标**: 处理资源冲突
**输出**: 集成到核心

**潜在冲突**:
- 指令/数据存储器同时访问 → 已分离 I-TCM/D-TCM ✅
- 寄存器文件同时读写 → 使用边沿触发 + 前半周期读/后半周期写

### T3C-5: 流水线核心集成 (🔴 P0)
**目标**: 整合所有模块
**输出**: `include/riscv/rv32i_core_pipeline.h`

**验收标准**:
- 编译无错误无警告
- 测试通过率 ≥ 90%
- IPC ≥ 0.8 (使用标准 benchmark)

## 风险预案

| 风险 | 概率 | 影响 | 应对措施 |
|------|------|------|---------|
| 前推逻辑复杂导致时序违例 | 中 | 高 | 简化前推路径,必要时插入 bubble |
| 分支预测准确率低 | 高 | 中 | 先用静态预测,后续优化为动态 |
| 测试覆盖率不足 | 中 | 中 | 增加冒险检测测试用例 |

## 执行计划

| 轮次 | 任务 | 预计时间 | 状态 |
|------|------|---------|------|
| 第 1 轮 | 流水线寄存器设计 | 30 min | ✅ 完成 |
| 第 2 轮 | 数据前推单元实现 | 45 min | ⏳ 等待中 |
| 第 3 轮 | 控制冒险处理 | 30 min | ⏳ 等待中 |
| 第 4 轮 | 核心集成 + 测试 | 60 min | ⏳ 等待中 |

## 第 1 轮完成摘要

**完成时间**: 2026-04-03 13:00 GMT+8

**交付物**:
- `include/riscv/rv32i_pipeline_regs.h` - 4 个流水线寄存器结构体和组件
- `tests/test_pipeline_regs.cpp` - 编译测试

**验收结果**:
- ✅ 编译无错误
- ✅ 编译无警告（新文件）
- ✅ 测试通过 (2/2 test cases)

**设计细节**:
- `IfIdRegs` / `IfIdPipelineReg`: PC, 指令，指令有效标志
- `IdExRegs` / `IdExPipelineReg`: 控制信号，RS1/RS2 数据，立即数，目的寄存器，PC，funct3
- `ExMemRegs` / `ExMemPipelineReg`: ALU 结果，写数据，控制信号，目的寄存器，PC
- `MemWbRegs` / `MemWbPipelineReg`: 读数据，ALU 结果，控制信号，目的寄存器

**下一步**: 等待第 2 轮指令（数据前推单元）

## 参考文档
- Hennessy & Patterson: Computer Architecture (流水线章节)
- RISC-V Spec v2.2
- `/workspace/CppHDL/include/riscv/rv32i_core.h` (当前单周期实现)
