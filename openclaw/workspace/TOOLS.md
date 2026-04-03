# TOOLS.md - Local Notes

> **职责**：环境特定配置（不含密钥）
> 
> **内容**：SSH 主机、摄像头、API 端点、设备别名

---

## 开发环境

**临时工作目录**: `temp/`

---

## SSH 主机

| 别名 | 地址 | 用户 | 用途 |
|------|------|------|------|
| home-server | 192.168.1.100 | admin | 家庭服务器 |

---

## 多会话管理 (tmux + openclaw tui)

**创建/连接会话**：
```bash
tmux new-window -n <会话名>
openclaw tui --session <会话名>
```

**最佳实践**：
| 场景 | Label 命名 |
|------|-----------|
| 项目长期会话 | `<项目名>-<模块>` 如 `MyNotes-KnowledgeGraph` |
| 临时任务 | `<任务>-<日期>` 如 `debug-ptx-20260323` |
| 代码审查 | `review-<PR 或文件名>` |

---

## Web UI 访问

**SSH 隧道**：
```bash
ssh -L 18789:localhost:18789 <gateway-host>
```

**浏览器访问**: `http://localhost:18789`

**配置要求**：
- `gateway.bind: "lan"` 或 `"local"`
- `controlUi.allowedOrigins` 包含 `http://localhost:18789`

---

## TTS

**默认声音**: Nova（温暖，略带英式）

---

Add whatever helps you do your job. This is your cheat sheet.
