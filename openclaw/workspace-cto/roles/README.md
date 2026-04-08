# 多角色系统使用指南

## 目录结构

```
/workspace/
├── roles/
│   ├── subordinates/      # 下属角色（DevMate 管理）
│   │   ├── reviewer/      # 代码审查员
│   │   ├── tester/        # 测试专员
│   │   └── docs-writer/   # 文档专员
│   └── colleagues/        # 同事角色（平行协作者）
│       └── cto/           # CTO（技术决策代理）
│
├── projects/              # 项目共享记忆
│   ├── PTX-EMU/
│   │   └── session-memory.md
│   └── PROJECT-TEMPLATE/
│       └── session-memory.md
│
└── roles/README.md        # 本文件
```

---

## 角色类型

### 下属角色（Subordinates）
- **管理者**: DevMate
- **生命周期**: 任务级（临时）
- **记忆**: 不持久化
- **用途**: 代码审查、测试、文档等专项任务

**唤醒方式**（DevMate 执行）:
```bash
sessions_spawn --task "审查 XX 模块" \
               --label reviewer-xxx \
               --context roles/subordinates/reviewer/
```

### 同事角色（Colleagues）
- **管理者**: 老板直接配置
- **生命周期**: 长期
- **记忆**: 独立记忆 + 项目共享记忆（双写）
- **用途**: 技术决策、任务审批、架构评审

**激活方式**:
- 群聊中自动激活（根据 session 绑定项目）
- 读取 `roles/colleagues/<角色>/SOUL.md` + `memory/`

---

## 权限边界速查

| 事项 | CTO | DevMate | 下属角色 | 老板 |
|------|-----|---------|---------|------|
| 代码审查 | 建议 | 执行/委派 | 执行 | - |
| 合并批准 | ❌ | ❌ | ❌ | ✅ |
| 任务分派 | ✅ | ✅ | ❌ | ✅ |
| 技术选型（小） | ✅ | 建议 | - | - |
| 技术选型（大） | 提案 | 建议 | - | ✅ |
| 架构变更 | 提案 | 建议 | - | ✅ |
| 争议裁决 | - | - | - | ✅ |

---

## 争议升级流程

```
CTO 提案 → DevMate 评审 → (1 轮讨论) → 仍分歧 → @老板裁决
```

---

## 记忆管理

| 记忆类型 | 位置 | 可见范围 |
|---------|------|---------|
| CTO 独立记忆 | `roles/colleagues/cto/memory/` | 仅 CTO |
| 项目共享记忆 | `projects/<项目名>/session-memory.md` | 所有项目角色 |
| 下属临时记忆 | 任务结束后销毁 | - |

---

## 快速开始

### 1. 创建新项目
```bash
cp -r projects/PROJECT-TEMPLATE projects/你的项目名
```

### 2. 编辑项目记忆
```bash
# 修改 projects/你的项目名/session-memory.md
# 填写项目信息、参与角色
```

### 3. 群聊绑定
- 在群聊中@CTO 或 DevMate
- 首次发言时声明项目绑定关系

### 4. 开始协作
- CTO 和 DevMate 通过讨论推进任务
- 分歧时@老板裁决

---

**版本**: v1.0  
**创建时间**: 2026-04-01
