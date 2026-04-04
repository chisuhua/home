# RV32I Phase 3D: 外设集成

创建时间：2026-04-03 23:30 GMT+8
负责人：DevMate

## 目标
为 RV32I 处理器添加基础外设支持，可运行简单裸机程序。

## 外设清单

| 外设 | 优先级 | 功能 | 预计工作量 |
|------|--------|------|-----------|
| **UART** | 🔴 P0 | 串口输出 (printf) | 4h |
| **GPIO** | 🟡 P1 | LED/按钮控制 | 2h |
| **Timer** | 🔴 P0 | 定时器中断 | 3h |
| **PLIC** | 🟢 P2 | 外部中断控制器 | 4h |

## 任务分解

### T3D-1: UART 控制器 (🔴 P0)
**目标**: 实现 16550 兼容 UART
**输出**: `include/uart/uart16550.h`

规格:
- 波特率：115200 (可配置)
- 数据位：8
- 停止位：1
- 校验位：无
- FIFO: 16 字节 (可选)
- 接口：AXI4-Lite 从设备

**验收标准**:
- 可输出 "Hello World"
- 编译无错误无警告

### T3D-2: GPIO 控制器 (🟡 P1)
**目标**: 实现 32 位 GPIO
**输出**: `include/gpio/gpio_ctrl.h`

规格:
- 32 位输入/输出
- 方向控制 (输入/输出)
- 中断支持 (可选)
- 接口：AXI4-Lite 从设备

### T3D-3: Timer 定时器 (🔴 P0)
**目标**: 实现 CLINT 兼容定时器
**输出**: `include/timer/clint.h`

规格:
- 64 位计数器
- 比较寄存器
- 定时器中断
- 接口：AXI4-Lite 从设备

### T3D-4: SoC 集成 (🔴 P0)
**目标**: 将外设集成到 RV32I SoC
**输出**: `include/soc/rv32i_soc.h`

集成内容:
- RV32I 核心
- I-TCM (64KB)
- D-TCM (64KB)
- UART
- GPIO
- Timer
- AXI4 Interconnect

### T3D-5: 裸机测试程序 (🔴 P0)
**目标**: 运行简单 C 程序
**输出**: `examples/soc/hello_world.c`

测试内容:
- UART 输出 "Hello from RV32I!"
- GPIO 翻转 LED
- Timer 中断处理

## 执行计划

| 轮次 | 任务 | 预计时间 |
|------|------|---------|
| 第 1 轮 | UART 控制器实现 | 4h |
| 第 2 轮 | Timer 定时器实现 | 3h |
| 第 3 轮 | GPIO 控制器实现 | 2h |
| 第 4 轮 | SoC 集成 | 4h |
| 第 5 轮 | 裸机测试程序 | 2h |

## 内存映射

| 地址范围 | 外设 | 大小 |
|---------|------|------|
| 0x00000000 - 0x0000FFFF | I-TCM | 64KB |
| 0x00010000 - 0x0001FFFF | D-TCM | 64KB |
| 0x10000000 - 0x10000FFF | UART | 4KB |
| 0x10001000 - 0x10001FFF | GPIO | 4KB |
| 0x10002000 - 0x10002FFF | Timer | 4KB |
| 0x10003000 - 0x10003FFF | PLIC | 4KB |

## 参考文档
- 16550 UART 规格书
- RISC-V CLINT 规格
- AXI4-Lite 协议
