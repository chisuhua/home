# AgentCore 项目记忆

**绑定群聊**: `chat:oc_4f9dc3f24cd00a878f759118577aae4f`  
**绑定时间**: 2026-04-03  
**激活模式**: AgentCore 专家模式  
**最后更新**: 2026-04-07 01:21

---

## 项目信息

**目标**: AgentCore 项目 — 自修正型分层智能体平台  
**项目路径**: `/workspace/AgentCore`  
**架构提案路径**: `/workspace/mynotes/CortiX/AgentCore`  
**技术栈**: C++20 协程 + SQLite + BrainSkillForge DSL 运行时

---

## 架构决策记录

### [决策 001] 架构收敛方向 — AOS-Nexus 为基线
**时间**: 2026-04-07 (待确认)  
**状态**: 待决策  
**影响范围**: AgentCore 整体架构  

**选项对比**:
| 方案 | 定位 | 语言 | 状态 | 推荐度 |
|------|------|------|------|--------|
| **AOS-Nexus** | 浏览器 + 工业网关 | C++20 协程 | 四层模型 | ✅ 推荐 |
| **BAFA** | 浏览器专用 | C++20 协程 | 三层模型 | ⚠️ 作为参考 |
| **AOS-u** | MCU→Linux 全谱系 | C 内核+C++ 协程 | 五层模型 | ❌ 过度复杂 |

**决策内容**: 以 AOS-Nexus 四层模型为统一基线，BAFA 作为 Browser Adapter 参考

---

### [决策 002] BrainSkillForge 集成方案
**时间**: 2026-04-07 (待确认)  
**状态**: 待决策  
**影响范围**: AgentCore ↔ BrainSkillForge 接口  

**选项对比**:
| 方案 | 描述 | 优点 | 缺点 | 推荐度 |
|------|------|------|------|--------|
| **A** | AgentCore 调用 BrainSkillForge 作为 DSL 执行后端 | 职责清晰，复用现有运行时 | 增加依赖复杂度 | ✅ 推荐 |
| **B** | BrainSkillForge 作为 AgentCore 的 Tool 之一 | 灵活，可支持多后端 | 接口复杂 | ⚠️ 备选 |
| **C** | 两者独立，通过 UniDAG-Store 共享状态 | 松耦合 | 状态同步复杂 | ❌ 不推荐 |

**决策内容**: 采用方案 A，定义错误处理职责边界

---

### [决策 003] 自修正能力优先级
**时间**: 2026-04-07 (待确认)  
**状态**: 待决策  
**影响范围**: Phase 0-5 实施路线  

**能力清单**:
| 能力 | 优先级 | 对应指标 | Phase |
|------|--------|---------|-------|
| 基础错误处理 + 错误分类 | P0 | 指标 3(持久化) | Phase 1 |
| 自动重试 + LLM 自我修正 | P0 | 指标 1(LLM 可抢占) | Phase 2 |
| 认知层监控 + 干预接口 | P0 | 指标 6(目标优先级) | Phase 3 |
| Reflexion Memory | P1 | — | Phase 4 |
| DSL 扩展 (reflection 节点) | P1 | 指标 2(Token 时间片) | Phase 5 |

---

## 会话议程记录

### 会话 1: 架构与集成决策 (2026-04-07)
**状态**: 进行中  
**预计时长**: 60-90 分钟

**议程**:
```
【15 分钟】背景回顾：AgentCore 文档梳理 + Harness 模式分析

【30 分钟】议题 1.1: 架构收敛决策
├─ AOS-Nexus vs BAFA vs AOS-u 对比
├─ Layer 3 元认知层职责扩展 (增加监控/错误分析)
└─ 决策：确认基线架构

【30 分钟】议题 1.2: BrainSkillForge 集成方案
├─ 方案 A/B/C 对比
├─ 错误处理职责边界 (DSLEngine vs CognitiveEngine)
└─ 决策：确认集成方案 + 接口契约草案

【15 分钟】议题 1.3: 能力优先级
├─ 自修正能力 vs 六项工业指标
├─ Phase 0-5 初步路线图
└─ 决策：确认 P0 能力清单

【输出】架构决策文档 + 集成接口草案 + Phase 0 行动计划
```

**依赖关系**:
```
会话 1 (战略层) → 会话 2 (战术层) → 会话 3 (实现层)
    ↓                   ↓                   ↓
架构收敛            监控接口            DSL 扩展
集成方案            错误分类            实施路线
能力优先级          Reflexion Memory
```

---

## 待决策事项

- [ ] **决策 001**: 确认 AOS-Nexus 为架构基线
- [ ] **决策 002**: 确认 BrainSkillForge 集成方案 A
- [ ] **决策 003**: 确认自修正能力 P0 优先级
- [ ] 确认技术栈和核心依赖
- [ ] 确认项目启动方式（从零创建/克隆现有仓库）

---

## 技术讨论记录

### 2026-04-07: AgentCore 文档梳理
**参与**: DevMate + 老板  
**主题**: AgentCore 文档结构 + 架构演进路线  

**关键发现**:
1. 文档中存在 3 套并行架构方案 (BAFA/AOS-u/AOS-Nexus)，需收敛
2. BrainSkillForge 集成方案待决策 (INTEGRATION_TODO.md)
3. 六项工业级指标 (AOS-Gateway) 需与自修正能力整合

**Harness 模式分析**:
- Reflexion (Shinn et al.): 执行后反思，将错误写入记忆
- Self-Refine (Madaan et al.): 迭代式输出改进
- LangGraph: 有向图支持循环，条件边 + 重试节点
- 核心洞察：认知层对任务层进行动态监控和调整

**输出**: 会话 1 议程 (见上)

---

## 任务进度跟踪

### In Progress
- [x] 梳理 `/workspace/mynotes/AgentCore` 文档结构
- [x] 分析 Harness 相关模式 (Reflexion/Self-Refine/LangGraph)
- [x] 制定会话 1 议程并写入记忆
- [ ] 推进会话 1 三项决策

### Completed
- [x] AgentCore 文档索引建立 (2026-04-04)

---

## 架构文档索引

| 文档 | 路径 | 状态 |
|------|------|------|
| 架构基线 | `/workspace/mynotes/CortiX/AgentCore/README.md` | ✅ 已梳理 |
| BAFA 三层 | `/workspace/mynotes/CortiX/AgentCore/Browser/浏览器智能体架构.md` | ✅ 已梳理 |
| AOS-Nexus | `/workspace/mynotes/CortiX/AgentCore/AgentLoop/AOS-Nexus_RT.md` | ✅ 已梳理 |
| AOS-Gateway | `/workspace/mynotes/CortiX/AgentCore/AgentLoop/AOS-Gateway.md` | ✅ 已梳理 |
| 集成 TODO | `/workspace/mynotes/CortiX/AgentCore/INTEGRATION_TODO.md` | ✅ 已梳理 |
| BrainSkillForge 上下文 | `/workspace/mynotes/CortiX/AgentCore/BrainSkillForge_上下文.md` | ✅ 已梳理 |

---

## 下一步行动

| 行动 | 负责人 | 截止时间 | 状态 |
|------|--------|---------|------|
| 推进会话 1 三项决策 | DevMate + 老板 | 本次会话 | 🟡 进行中 |
| 创建架构决策文档 (决策 001-003) | DevMate | 会话 1 结束后 | ⏳ 待开始 |
| 定义 CognitiveEngine ↔ DSLEngine 接口契约 | DevMate | 会话 2 前 | ⏳ 待开始 |

---

// -- 🦊 DevMate | AgentCore 项目记忆更新完成 --
