#!/bin/bash
set -e

# 加载 ubuntu 用户的 bash 配置
source /home/ubuntu/.bashrc

# 切换到工作目录
cd /workspace

# 启动 OpenClaw
exec code-server --bind-addr 0.0.0.0:8001 --auth none
