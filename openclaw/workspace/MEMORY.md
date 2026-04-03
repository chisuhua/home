# MEMORY.md — DevMate 长期记忆库

## 项目绑定配置

**加载规则**：每次会话初始化时，仅读取与当前群聊 ID 匹配的绑定项目，加载对应的项目记忆路径。

| 群聊/会话 ID | 绑定项目 | 激活模式 | 项目记忆路径 | 绑定时间 |
|-------------|---------|---------|-------------|----------|
| `chat:oc_db7e1318695cae65010c5a563471d681` | **PTX-EMU** | PTX-EMU 专家模式 | `~/.openclaw/workspace-project/PTX-EMU/session-memory.md` | 2026-04-02 |
| `chat:oc_4f9dc3f24cd00a878f759118577aae4f` | **CppHDL** | CppHDL 专家模式 | `~/.openclaw/workspace-project/CppHDL/session-memory.md` | 2026-04-03 |

### 项目记忆目录结构

```
~/.openclaw/workspace-project/
├── PTX-EMU/
│   ├── session-memory.md    # 项目级记忆（决策/进度/讨论）
│   ├── architecture/        # 架构文档
│   └── decisions/           # 技术决策记录
├── CppHDL/
│   ├── session-memory.md
│   ├── architecture/
│   └── decisions/
└── <项目名>/
    └── ...
```

### 记忆加载优先级（会话初始化时）

1. `SOUL.md` → 身份确认（全局）
2. `USER.md` → 用户偏好（全局）
3. **当前群聊绑定的项目记忆** → `~/.openclaw/workspace-project/<项目名>/session-memory.md`（仅匹配当前群聊 ID）
4. `~/.openclaw/workspace/memory/YYYY-MM-DD.md` → 今日日志（全局共享）
5. `~/.openclaw/workspace/MEMORY.md` → 长期记忆（全局共享，仅主会话）

### 记忆写入规范

| 记忆类型 | 写入位置 | 触发时机 |
|---------|---------|---------|
| 项目决策 | `<项目记忆路径>` | 决策完成后立即 |
| 技术讨论 | `<项目记忆路径>` | 讨论结束后 |
| 任务进度 | `<项目记忆路径>` | 每日收工前 |
| 日常日志 | `~/.openclaw/workspace/memory/YYYY-MM-DD.md` | 操作完成后 |
| 全局决策 | `~/.openclaw/workspace/MEMORY.md` | 跨项目决策 |

---

## 👥 参与角色

| 角色 | 职责 |
|------|------|
| CTO | 技术决策、架构守护 |
| DevMate | 代码执行、技术评审 |
| 老板 | 战略决策、最终裁决 |

---


## 技术决策与架构记录

### ACP 会话连续性维护原则（2026-04-02）
**背景**: Feishu 群聊环境下 ACP `thread: true` 模式不可用，需使用 `subagent` + `steer` 方式进行多轮对话。

### 上下文维护

由于 subagent 是隔离会话，需手动维护连续性：
1. 每轮 steer 消息中附带前轮结果摘要
2. 使用 `temp/任务名-plan.md` 跟踪整体进度
3. 使用 `memory/YYYY-MM-DD.md` 记录每日进度

📋 详细示例参考：`/workspace/acf-workflow/docs/acf-subagent-driver.md`


**适用场景**: Feishu 群聊、任何 thread binding 不可用的环境
