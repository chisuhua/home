#!/bin/bash
# ============================================================
# 启动所有容器内服务 (OpenClaw + Code-Server + OpenCode)
# ============================================================
# ⚠️ 此脚本必须在宿主机上执行！(不能在容器内运行)
#
# 用法 (在宿主机执行):
#   cd /home/dev/workspace/home
#   ./start-all-services.sh
#
# 或者从任何位置:
#   /home/dev/workspace/home/start-all-services.sh
# ============================================================

set -e

#CONTAINER="aidev2"
CONTAINER="openclaw"
# 统一使用同一个 token 认证所有服务
AUTH_TOKEN="0cccbedfb661cefb0cea5ad3b866b75d1106fdcdccc12fdd"

echo "🦊 启动所有服务..."

# 1. 启动 OpenClaw Gateway (端口 18789)
echo "   [1/3] 启动 OpenClaw..."
#tmux new -s openclaw "openclaw gateway"
#sleep 1

# 2. 启动 Code-Server (使用统一 token 密码认证)
echo "   [2/3] 启动 Code-Server..."
tmux new -d -s code-server "PASSWORD=$AUTH_TOKEN code-server --bind-addr 0.0.0.0:8001 --auth none"

# 3. 启动 OpenCode Server (使用统一 token 认证)
echo "   [3/3] 启动 OpenCode..."
tmux new -d -s opencode "OPENCODE_SERVER_PASSWORD=$AUTH_TOKEN opencode serve --port 50080 --hostname 0.0.0.0"

# 等待服务启动
sleep 3

echo ""
echo "✅ 所有服务已启动!"
echo ""
echo "📌 访问方式 (统一 Token: $AUTH_TOKEN):"
echo "   ┌─────────────┬────────────────────────────────────────────────────────────┐"
echo "   │ 服务        │ 访问链接                                                     │"
echo "   ├─────────────┼────────────────────────────────────────────────────────────┤"
echo "   │ OpenClaw    │ http://localhost:18789#token=$AUTH_TOKEN                   │"
echo "   │ Code-Server │ http://localhost:8001/?password=$AUTH_TOKEN                │"
echo "   │ OpenCode    │ http://opencode:$AUTH_TOKEN@localhost:50080                │"
echo "   └─────────────┴────────────────────────────────────────────────────────────┘"
echo ""
echo "📌 SSH 隧道 (从远程访问):"
echo "   ssh -NL 18789:127.0.0.1:18789 -NL 8080:127.0.0.1:8080 -NL 50080:127.0.0.1:50080 user@server_ip"
echo ""
echo "📌 查看日志:"
echo "   docker exec -t $CONTAINER tmux capture-pane -pt openclaw"
echo "   docker exec -t $CONTAINER tmux capture-pane -pt code-server"
echo "   docker exec -t $CONTAINER tmux capture-pane -pt opencode"
echo ""
echo "📌 停止服务:"
echo "   docker exec -t $CONTAINER tmux kill-session -t openclaw"
echo "   docker exec -t $CONTAINER tmux kill-session -t code-server"
echo "   docker exec -t $CONTAINER tmux kill-session -t opencode"
