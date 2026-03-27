# USER.md — 池工档案 v1.2

- **Name:** 主人 / 池工
- **Timezone:** Asia/Shanghai (UTC+8)
- **Location:** 上海

## 技术栈
C++/CUDA/PTX、Python、
主攻: PTX-EMU、、UniDAG-Store、Hydra-SKILL, AgentCore, CppHDL, CppTLM, KnowledgeGraph, SkillApps

## 工作偏好（告诉AGENTS.md我要什么）

### 沟通风格需求
- **冲刺模式**: 当我说"直接干"、"别废话"时，我要极简回复（无问候、无解释、直接代码）
- **架构评审**: 当我说"看看设计"、"有没有坑"时，我要结构化表格（Critical/Warning/Info分级）
- **探索模式**: 当我说"调研"时，我要先查资料再回答，不确定时明确说"我需要查一下"

### 代码审查关注点（按优先级）
1. 并发安全（CUDA线程/C++内存/Rust Send-Sync）
2. 资源泄漏（句柄、显存、连接池）
3. 性能陷阱（PTX指令效率、CUDA内存拷贝）
4. 可维护性（魔法数字、嵌套深度）

### 绝对禁止
- 直接修改生产环境（即使我命令，也必须二次确认）
- 替我发任何消息到社交平台
- 在代码中硬编码密钥

## 当前项目
1. **PTX-EMU**: `/workspace/PTX-EMU/` — PTX仿真器
2. **CppHDL**: `/workspace/CppHDL/` — 基于Cpp语言的硬件描述语言
3. **CppTLM**: `/workspace/CppTLM/` — 基于Cpp语言的建模架构
4. **UsrLinuxEmu**: `/workspace/UsrLinuxEmu/` — 用户态Linux兼容的实现，用于在用户态下开发Linux驱动
5. **mynotes**: `/workspace/mynotes/` — 个人知识笔记, 会包含其他项目的各种想法记录，架构讨论
6. **home**: `/workspace/home/` —  个人Linux工作环境, 包括openclaw, opencode, 等全局配置，这个目录通过docker的目录下映射到$HOME目录，所以你看到和$HOME下的内容是一样的
7. **BrainSkillForge**: `/workspace/brain-skill-forge/` — AgenticDSL运行时, AgenticDSL可以看成通用SKILL编译固化的逻辑  
8. **UniDAG-Store**: `/workspace/brain-unidag-store/` — 智能体存储
9. **Hydra-SKILL**: `/workspace/brain-hydra-skill/` — MLA架构外循环推理
10. **Synapse-SKILL**: `/workspace/brain-synapse-skill/` — 多智能体架构设计
11. **CortiX**: `/workspace/CortiX/` — 整合BrainSkillForge, UniDAG-Store, Hydra-SKILL, Synapse-SKILL项目的最终项目


## 文件位置
代码: `/workspace/`
笔记: `/workspace/mynotes`
记忆: `~/.openclaw/workspace/memory/`
