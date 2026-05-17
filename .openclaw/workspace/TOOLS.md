# TOOLS.md - Local Notes

> **职责**：环境特定配置（不含密钥）
> 
> **内容**：SSH 主机、摄像头、API 端点、设备别名

---

## 开发环境

**临时工作目录**: `/workspace/project/tmp/`

---

## SSH 主机

| 别名 | 地址 | 用户 | 用途 |
|------|------|------|------|
| dev-aliyun | 47.100.102.207 | dev | 阿里云服务器（OpenClaw 容器运行在此机器上） |

---

## 本机运行环境

**运行环境**：OpenClaw 运行在 Docker 容器内，容器名为 `openclaw`

**容器定义**：`/mnt/nas/project/PKGM-Web/docker-compose.yml`

**重启命令**：
```bash
# SSH 到宿主机
ssh dev@47.100.102.207

# 进入项目目录
cd /mnt/nas/project/PKGM-Web

# 重启 openclaw 容器
docker compose restart openclaw
# 或
docker compose restart
```

**OpenClaw 服务日志**：
- `/var/log/supervisor/openclaw-gateway.out.log` — 标准输出日志
- `/var/log/supervisor/openclaw-gateway.err.log` — 错误日志

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
ssh -L 18789:localhost:18789 dev@47.100.102.207
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
