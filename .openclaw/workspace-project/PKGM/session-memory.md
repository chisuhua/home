# PKGM 项目记忆

**绑定群聊**: `chat:oc_bc05fc0ff12e5c816c216cb999e0d1d6`（MyNotes）  
**绑定时间**: 2026-04-14  
**激活模式**: PKGM 架构设计模式

---

## 项目信息

**全称**: Personal Knowledge Graph Management（个人知识图谱管理）  
**位置**: `/workspace/mynotes/`  
**定位**: Agent 驱动的自动化知识摄取、图谱构建、Wiki 生成引擎  
**技术栈**: Markdown + YAML + 知识图谱 Schema + LLM Agent + OpenClaw

---

## 当前阶段

**ADR 阶段完成** — 全部 6 个 ADR 已确认并落盘，架构设计文档已创建

---

## 已确认决策（PRD D-01 ~ D-12 + 新增）

| # | 决策点 | 结果 |
|---|--------|------|
| D-01 | 04_Knowledge 目录组织 | 按知识领域划分，12 个一级目录，子目录动态扩展 |
| D-02 | 图谱存储方式 | Phase 1 纯 Markdown，YAML frontmatter 存储关系 |
| D-03 | Agent 触发方式 | Cron 定时 + 手动 @/命令随时触发 |
| D-04 | 语义检索 | Phase 1 不做，先纯图谱关系 |
| D-05 | 现有项目文档 | 不迁移，不创建符号链接 |
| D-06 | Wiki 页面格式 | YAML frontmatter + Obsidian 兼容 `[[wikilink]]` |
| D-07 | 新增 06_Mynotes 目录 | 原创思考独立存储 |
| D-08 | 溯源信息存放位置 | 全部放在 YAML frontmatter 中 |
| D-09 | transformation_chain | Phase 1 简化为 created_by + updated_by |
| D-10 | 置信度默认策略 | Agent 自动计算初值，人工可覆盖 |
| D-11 | 证据引用粒度 | Phase 1 文件级，Phase 2 页码/表格级 |
| D-12 | 来源分类级数 | 保留四级（original/primary/secondary/tertiary） |
| **D-13** | **两阶段消化模型** | **04_Knowledge (初步) → 01_Wiki (深度)** |
| **D-14** | **Graphify 集成** | **Phase 2 作为补充工具，交叉验证** |

---

## ADR 文档列表

| ADR | 主题 | 状态 | 落盘位置 |
|-----|------|------|---------|
| ADR-001 | 知识图谱 Schema 设计（12 实体、15 关系） | ✅ 已确认 | `PKGM/ADR/ADR-001.md` |
| ADR-002 | 溯源体系（Provenance Schema） | ✅ 已确认 | `PKGM/ADR/ADR-002.md` |
| ADR-003 | 存储格式（Markdown + frontmatter + wikilink） | ✅ 已确认 | `PKGM/ADR/ADR-003.md` |
| ADR-004 | 目录结构与文件组织（修订版：两阶段消化 + 原创分离） | ✅ 已确认 | `PKGM/ADR/ADR-004.md` |
| ADR-005 | Agent 触发与执行策略 | ✅ 已确认 | `PKGM/ADR/ADR-005.md` |
| ADR-006 | 检索策略（分阶段规划） | ✅ 已确认 | `PKGM/ADR/ADR-006.md` |
| ADR-007 | 两阶段抽取（Analysis → Generation） | 📝 草稿 | `PKGM/ADR/ADR-007.md` |
| ADR-008 | SHA256 增量缓存 | 📝 草稿 | `PKGM/ADR/ADR-008.md` |
| ADR-009 | 热缓存（跨会话记忆） | 📝 草稿 | `PKGM/ADR/ADR-009.md` |
| ADR-010 | purpose.md（方向意图定义） | 📝 草稿 | `PKGM/ADR/ADR-010.md` |
| ADR-011 | 审查队列（人机协同） | 📝 草稿 | `PKGM/ADR/ADR-011.md` |

---

## 架构文档

| 文档 | 说明 | 位置 |
|------|------|------|
| **ARCHITECTURE.md** | 架构设计总览 + 同类项目对比 | `PKGM/ARCHITECTURE.md` |
| **IMPLEMENTATION_PLAN.md** | 实施计划（3 阶段，5-8 周） | `PKGM/IMPLEMENTATION_PLAN.md` |
| **PHASE2_SUMMARY.md** | Phase 2 工作总结（5 技能创建） | `PKGM/PHASE2_SUMMARY.md` |

---

## 待决策事项

无 — ADR 阶段已完成

---

## 任务进度跟踪

### In Progress
- [x] 创建 `02_System/schema.yaml`
- [x] 创建 `02_System/provenance-schema.md`
- [x] 创建 04_Knowledge 二级目录骨架
- [x] 创建 05_Project 目录骨架
- [x] 创建 06_Mynotes 目录骨架
- [x] 生成 Wiki 页面模板
- [x] 重命名 `SIMT_Research` → `simt-research`
- [x] **pkgm-ingest 技能创建完成（研究地图版）**
- [x] **RESEARCH_MAP.md 研究地图创建**
- [x] **pkgm-extract 技能创建完成**
- [x] **pkgm-link 技能创建完成**
- [x] **pkgm-wiki-gen 技能创建完成**
- [x] **pkgm-scan 技能创建完成**
- [ ] Phase 2: Agent 管线端到端测试

### Completed
- [x] PRD V1.1 确认
- [x] ADR-001 确认并落盘
- [x] ADR-002 确认并落盘
- [x] ADR-003 确认并落盘
- [x] ADR-004 确认并落盘（修订版）
- [x] ADR-005 确认并落盘
- [x] ADR-006 确认并落盘
- [x] ARCHITECTURE.md 架构设计文档创建
- [x] IMPLEMENTATION_PLAN.md 实施计划创建
- [x] **Phase 1 基础建设完成**
- [x] ARCHITECTURE.md 更新 Phase 2 技能组合架构
- [x] ARCHITECTURE.md 更新研究地图理念
- [x] **Phase 2 技能创建完成（5/5）**

---

**最后更新**: 2026-04-15 00:18 — ADR-007~011 草稿创建完成
