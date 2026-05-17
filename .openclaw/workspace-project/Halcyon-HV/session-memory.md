# Halcyon-HV + Halcyon-Arch 项目记忆

**最后更新**: 2026-04-26 00:28
**关联群聊**: `chat:oc_d14ed9432f63d82f80098d402a29b5bf`

---

## 研究论文管理计划

### 背景决策

| 决策 | 内容 |
|------|------|
| **论文存储** | `/workspace/project/mynotes/00_Raw_Sources/papers/`（已复制 8 篇 Halcyon 论文） |
| **研究地图** | 每个子目录的 README.md 作为 research-map |
| **PKGM 集成** | 论文 ingest 后通过 R15 (USED_IN) 关联回项目 |
| **项目隔离** | research-map 放在项目目录，不放在 PKGM |

### 三阶段实施计划

#### Phase 1: 现状整理

| 任务 | 操作 | 产出 | 状态 |
|------|------|------|------|
| 1.1 确认论文存储 | 统一到 `research/papers/` | 单一论文库 | ✅ |
| 1.2 完善 research-map | 每个子目录补充"关联知识点"和"用途" | 9 个 research-map | ✅ 2026-04-25 |

#### Phase 2: PKGM 集成

| 任务 | 操作 | 产出 | 状态 |
|------|------|------|------|
| 2.1 论文放入 PKGM | ✅ 已复制到 mynotes | 8 篇论文 | ✅ 2026-04-26 |
| 2.2 purpose.md 扩充 | ✅ 扩充 D11/D12 支持 Halcyon | purpose.md V1.2 | ✅ 2026-04-26 |
| 2.3 触发 ingest | 执行 `pkgm-pipeline` | 预期生成 D11/D12 草稿 | ⏳ |

#### Phase 3: 日常维护

| 动作 | 时机 |
|------|------|
| 发现新论文 | 先加 research-map，再 ingest |
| 代码设计决策 | 在 ADR 引用 research-map 中的论文 |
| 定期审查 | 每 2 周 review research-map 覆盖度 |

### 现有资源

- **论文位置**: `/workspace/project/mynotes/00_Raw_Sources/papers/`
- **研究主题**: 1.virtualization, 2.memory-virtualization, 3.cache-coherency, 4.interconnect, 5.os-support, 6.distributed-systems, 7.hypervisor-impl, 8.hardware-modeling, 9.security-isolation
- **已下载论文**: 8 篇（见 `Halcyon-Arch/research/1.virtualization/README.md`）

### purpose.md 变更记录

| 日期 | 版本 | 变更 |
|------|------|------|
| 2026-04-26 | V1.2 | 扩充 D11（OS/Hypervisor）、D12（分布式系统/NUMA）支持 Halcyon-HV，新增 T05/T06 |

---

## 架构关系

```
Halcyon-HV/         → Hypervisor 软件
Halcyon-Arch/       → 支撑架构（research/ 包含论文地图）
    └── research/
        ├── 1.virtualization/     ← research-map
        ├── papers/               ← 论文 PDF
        └── ...
mynotes/            → PKGM 知识库
    ├── 00_Raw_Sources/papers/    ← 论文存储
    ├── 02_System/purpose.md     ← V1.2，含 D11/D12
    └── 04_Knowledge/            ← 提取的知识
```

---

*本文件由 DevMate 自动维护*
