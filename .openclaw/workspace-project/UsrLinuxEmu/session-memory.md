# UsrLinuxEmu 项目记忆

**绑定群聊**: `chat:oc_a9db8fbdec81c7fa279fb264ae418682`  
**激活模式**: UsrLinuxEmu 专家模式  
**绑定时间**: 2026-04-07

---

## 项目状态

### 当前版本
- **版本**: v0.1
- **阶段**: 基础设施完善 → Linux 兼容层开发过渡期

### 完成度概览
| 模块 | 完成度 | 状态 |
|------|--------|------|
| 核心框架 | 90% | ✅ 基本完成 |
| 设备驱动 | 70% | 🔄 进行中 |
| GPU 驱动 | 50% | 🔄 进行中 |
| Linux 兼容层 | 20% | ⚠️ 需要加强 |
| 测试框架 | 40% | ✅ Catch2 (21 个测试用例) |
| 文档系统 | 100% | ✅ 完成 |

---

## 架构决策记录 (关键 ADR)

| ADR | 决策 | 状态 |
|-----|------|------|
| ADR-001 | 用户态模拟而非内核模块 | 已接受 |
| ADR-002 | C++17 作为开发语言 | 已接受 |
| ADR-003 | 插件化架构 (动态库加载) | 已接受 |
| ADR-004 | Buddy Allocator 管理 GPU 内存 | 已接受 |
| ADR-005 | Ring Buffer 管理 GPU 命令队列 | 已接受 |
| ADR-006 | 四层分层架构 | 已接受 |
| ADR-007 | CMake 构建系统 | 已接受 |
| ADR-008 | Linux 内核 API 兼容层 | 已接受 |
| ADR-009 | 单例模式实现核心服务 | 已接受 |
| ADR-010 | 使用 Catch2 测试框架 | 已接受 |
| ADR-011 | CUDA/Vulkan Runtime 独立调度器模式 | 已接受 (2026-04-07) |
| ADR-012 | 分层同步：Barrier+Fence+Event | 已接受 (2026-04-07) |
| ADR-013 | 细粒度 ioctl：逐步演进 | 已接受 (2026-04-07) |
| ADR-014 | Runtime Stub 完全独立 | 已接受 (2026-04-07) |
| ADR-015 | 分阶段演进：Phase 1 CUDA 专用 → Phase 2 统一 GPU | 已接受 (2026-04-07) |

---

## 当前任务

### In Progress
- [x] **ACF-Workflow 慢循环**: 架构调研与设计 (2026-04-07 启动 → 完成)
- [x] **架构批准**: DDS-CUDA-Vulkan-Runtime-v1.1-final (2026-04-07)
- [ ] **Phase 0**: 环境准备（Week 1）

### Completed
- [x] 项目绑定配置 (MEMORY.md)
- [x] 项目记忆文件创建
- [x] TaskRunner 架构文档阅读
- [x] DDS 详细设计文档创建

### Pending - UsrLinuxEmu 项目（底层框架）
- [ ] **Phase 1**: 基础架构 + ioctl (4 周) - 优先
  - 现有 `cuda_ioctl.h` 可用
  - 需实现 `compat_ioctl()` 转译层
- [ ] **Phase 2**: Linux 兼容层 (6 周)
- [ ] **Phase 3**: GPU 插件化 (6 周)
- [ ] 测试用例扩展 (目标 50+)

### Pending - TaskRunner 项目（上层 Runtime）
- [ ] **Phase 1**: CUDA Runtime MVP（4 周）
  - CudaScheduler 实现
  - 分层同步（Fence/Barrier）
  - vector_add PoC 验证
- [ ] **Phase 2**: Vulkan 集成（4 周）
- [ ] **Phase 3**: 高级特性（Graph/Batch）

**DDS 文档**: `../TaskRunner/docs/DDS-CUDA-Vulkan-Runtime-v1.2-final.md`

---

## 技术栈

- **语言**: C++17
- **构建**: CMake ≥ 3.14
- **测试**: Catch2 (已采用，21 个用例)
- **目标**: Linux 用户态，无需 root

---

## 核心架构

```
┌─────────────────────────────────────────┐
│        用户应用层                          │
│  (CUDA Apps, Test Programs, CLI Tools) │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│       内核模拟框架层                        │
│  VFS | Plugin Manager | Service Registry│
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│         设备驱动层                          │
│  GPGPU Driver | Serial | Memory | PCIe │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│        硬件模拟层                          │
│  GPU Simulator | Memory | Registers    │
└─────────────────────────────────────────┘
```

---

## 关键里程碑 (2026)

| 版本 | 目标日期 | 主要目标 |
|------|----------|----------|
| **v0.2** | 2026-Q2 | 测试框架、Linux 兼容层 50% |
| **v0.5** | 2026-Q3 | GPU 插件、兼容层 80% |
| **v1.0** | 2026-Q4 | 生产级质量、稳定 API |

---

## 项目路径
- **代码**: `/workspace/UsrLinuxEmu/`
- **文档**: `/workspace/UsrLinuxEmu/docs/`
- **计划**: `/workspace/UsrLinuxEmu/plans/`

---

**最后更新**: 2026-04-07 00:31
