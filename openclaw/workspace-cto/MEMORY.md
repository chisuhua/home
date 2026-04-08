# MEMORY.md — DevMate 长期记忆库

## 项目绑定配置
| 群聊/会话 ID | 绑定项目 | 激活模式 | 绑定时间 |
|-------------|---------|---------|----------|
| `chat:oc_db7e1318695cae65010c5a563471d681` | **PTX-EMU** | PTX-EMU 专家模式 | 2026-04-02 |

---

## 项目记忆持久化 ✅

- **位置**：`~/.openclaw/workspace-project/<项目名>/session-memory.md`
- **内容**：
  - 项目信息、群聊绑定
  - 待决策事项
  - 技术讨论记录
  - 任务进度跟踪
- **优势**：不依赖 session 文件，记忆持久化保存

### 记忆写入规范

| 记忆类型 | 写入位置 | 触发时机 |
|---------|---------|---------|
| 项目决策 | `session-memory.md` | 决策完成后立即 |
| 技术讨论 | `session-memory.md` | 讨论结束后 |
| 任务进度 | `session-memory.md` | 每日收工前 |
| 日常日志 | `~/.openclaw/workspace/memory/YYYY-MM-DD.md` | 操作完成后 |

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
