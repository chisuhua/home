# MEMORY.md — DevMate 长期记忆库

> **职责**：存储动态数据和配置表，不包含执行规则
> 
> **内容**：项目绑定、技术决策记录、跨会话共享状态

---

## 项目绑定配置

| 群聊/会话 ID | 绑定项目 | 激活模式 | 项目记忆路径 | 绑定时间 |
|-------------|---------|---------|-------------|----------|
| `chat:oc_db7e1318695cae65010c5a563471d681` | **PTX-EMU** | PTX-EMU 专家模式 | `~/.openclaw/workspace-project/PTX-EMU/session-memory.md` | 2026-04-02 |
| `chat:oc_4f9dc3f24cd00a878f759118577aae4f` | **AgentCore** | AgentCore 专家模式 | `~/.openclaw/workspace-project/AgentCore/session-memory.md` | 2026-04-04 |
| `chat:oc_fb2f4d1b53f1637f11f41116d7328de6` | **TaskRunner** | Cuda/Vulkan 驱动专家模式 | `~/.openclaw/workspace-project/TaskRunner/session-memory.md` | 2026-04-04 |
| `chat:oc_a9db8fbdec81c7fa279fb264ae418682` | **UsrLinuxEmu** | UsrLinuxEmu 专家模式 | `~/.openclaw/workspace-project/UsrLinuxEmu/session-memory.md` | 2026-04-07 |
| `chat:oc_6a048de8c1eecbeb732eab7e98ed8ace` | **CppTLM** | CppTLM 专家模式 | `~/.openclaw/workspace-project/CppTLM/session-memory.md` | 2026-04-07 |
| `chat:oc_fc8449f272a1266e14685b8fa6cd017d` | **acf-workflow** | 智能体工作流专家模式 | `~/.openclaw/workspace-project/acf-workflow/session-memory.md` | 2026-04-07 |
| `chat:oc_44401bdbcb1c7d76577e5a29acade50c` | **CppHDL** | CppHDL 专家模式 | `~/.openclaw/workspace-project/CppHDL/session-memory.md` | 2026-04-08 |
| `chat:oc_a1075829be1b03f1a41ff11b7b56e7f4` | **PKGM-Web** | Web 开发专家模式 | `~/.openclaw/workspace-project/PKGM-Web/session-memory.md` | 2026-04-16 |
| `chat:oc_bc05fc0ff12e5c816c216cb999e0d1d6` | **PKGM-Wiki** | PKGM-Wiki 专家模式 | `~/.openclaw/workspace-project/PKGM-Wiki/session-memory.md` | 2026-04-16 |
| `chat:oc_d14ed9432f63d82f80098d402a29b5bf` | **Halcyon-HV + Halcyon-Arch** | 分布式 Hypervisor 专家模式 | `~/.openclaw/workspace-project/Halcyon-HV/session-memory.md` | 2026-04-25 |

---

## 技术决策记录

### 编码任务统一使用 OpenCode 多轮对话
**时间**: 2026-04-07  
**影响范围**: 所有编码任务  
**决策内容**: 所有编码任务必须通过 `opencode run` + `subagent + steer` 多轮对话逐步推进  
**详细记录**: 见 AGENTS.md §0.3 快循环规范

### UsrLinuxEmu 测试框架选型 (Catch2)
**时间**: 2026-04-07  
**影响范围**: UsrLinuxEmu 项目  
**决策内容**: 继续使用 **Catch2** 作为测试框架（而非 GTest），已有 21 个测试用例  
**理由**: 
- 项目已基于 Catch2 构建（`tests/` 目录）
- Catch2 轻量级、header-only、适合 C++17
- 迁移 GTest 无显著收益，增加不必要工作量
**详细记录**: 见 `UsrLinuxEmu/session-memory.md` ADR-010

### CUDA/Vulkan Runtime 架构决策（TaskRunner 项目）
**时间**: 2026-04-07  
**影响范围**: TaskRunner + UsrLinuxEmu 项目  
**决策内容**: 
- D5: 独立调度器 + 统一接口（替代 D1）
- D6: 分层同步（Barrier+Fence+Event）
- D7: 细粒度 ioctl（逐步演进）
- D8: Runtime Stub 完全独立
- D9: 分阶段演进（Phase 1 CUDA 专用 → Phase 2 统一 GPU）
**详细设计**: `/workspace/TaskRunner/docs/DDS-CUDA-Vulkan-Runtime-v1.2-final.md`
**状态**: ✅ 架构已批准（v1.2-final），进入 Phase 1 实施

---

## 跨会话共享状态

### 活跃任务
- [ ] 任务 A（项目：XXX）
- [ ] 任务 B（项目：YYY）

### 待老板决策
- [ ] 事项 1（截止：YYYY-MM-DD）

---

**最后更新**: 2026-04-16 00:51
