#!/bin/bash
set -e

export OPENCLAW_HOME=/home/ubuntu
export OPENCLAW_TRAJECTORY=0
# 加载 ubuntu 用户的 bash 配置
source /home/ubuntu/.bashrc

# 切换到工作目录

# 启动 OpenClaw
#exec sudo -u ubuntu nice -n -10 openclaw gateway run
exec openclaw gateway run
