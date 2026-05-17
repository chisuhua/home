#!/bin/bash
set -e

# 加载 ubuntu 用户的 bash 配置
source /home/ubuntu/.bashrc

# 切换到工作目录
cd /workspace

# 启动 OpenClaw
exec /home/ubuntu/.npm-global/bin/opencode serve --port 50080 --hostname 0.0.0.0
