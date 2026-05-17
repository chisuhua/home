# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## 开发环境

`/worksapce/DevMate_WorkDir/`目录，做为你的临时脚本生成和执行目录

---

## 飞书群聊 Chat ID 列表

| 群聊名称 | Chat ID | 用途 |
|---------|---------|------|
| PTX-EMU | `oc_1a4d6efab29f92943a9ad7ee1660a307` | 早安问候定时任务 |

**使用格式**: `chat:oc_1a4d6efab29f92943a9ad7ee1660a307`

**获取方法**: 在群聊中 @CTO → 读取消息元数据 → 提取 chatId 字段

**技能文件**: `skills/feishu-chat-id-finder/SKILL.md`

---

## Gateway 认证配置

**Token**：`0cccbedfb661cefb0cea5ad3b866b75d1106fdcdccc12fdd`

**auth.mode 选择**：
| 模式 | 适用场景 | openclaw tui 用法 |
|---|---|---|
| `token` | 生产环境/远程访问 | `openclaw tui --token <token>` |
| `none` | 本地开发（仅受信任网络） | `openclaw tui`（无需 token） |

---

## Web UI 访问方式（浏览器）

**SSH 隧道 + 本地浏览器**：
```bash
# SSH 隧道
ssh -L 18789:localhost:18789 <gateway-host>

# 浏览器访问
http://localhost:18789#token=<gateway-auth-token>
```

**配置要求**：
- `gateway.bind: "lan"` 或 `"local"` ✅
- `controlUi.allowedOrigins` 必须包含 `http://localhost:18789` ✅
- Gateway auth token 需要从配置中获取（`gateway.auth.token`）

---

## 多会话管理 (tmux + openclaw tui)

**创建/连接会话**：
```bash
# tmux 新窗口
tmux new-window -n <会话名>

# 启动会话（用 --session 指定会话名）
openclaw tui --session <会话名>
```

**示例：MyNotes-KnowledgeGraph 会话**：
```bash
tmux new-window -n MyNotes
openclaw tui --session MyNotes-KnowledgeGraph
```

**重新连接已有会话**：
```bash
# 用相同 session 名启动会连接到同一会话
openclaw tui --session MyNotes-KnowledgeGraph
```

**查看会话列表**：
```bash
openclaw sessions list
```

**会话文件位置**：
- 会话记录：`~/.openclaw/agents/main/sessions/<session-id>.jsonl`

**最佳实践**：
| 场景 | Label 命名 |
|---|---|
| 项目长期会话 | `<项目名>-<模块>` 如 `MyNotes-KnowledgeGraph` |
| 临时任务 | `<任务>-<日期>` 如 `debug-ptx-20260323` |
| 代码审查 | `review-<PR 或文件名>` |

---

Add whatever helps you do your job. This is your cheat sheet.
