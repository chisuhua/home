docker run -d \
  --name aidev \
  --restart always \
  -w /workspace \
  -p 18789:18789 \
  -p 50080:50080 \
  -v ~/workspace/home/.config:/home/ubuntu/.config \
  -v ~/workspace/home/.openclaw:/home/ubuntu/.openclaw \
  -v ~/workspace/home/.claude:/home/ubuntu/.claude \
  -v ~/workspace/home/.claude.json:/home/ubuntu/.claude.json \
  -v ~/workspace/home/.ssh:/home/ubuntu/.ssh \
  -v ~/workspace/home/.tmux:/home/ubuntu/.tmux \
  -v ~/workspace/home/.tmuxinator:/home/ubuntu/.tmuxinator \
  -v ~/workspace/home/.tmux.conf:/home/ubuntu/.tmux.conf \
  -v ~/workspace/home/.local/share:/home/ubuntu/.local/share \
  -v ~/workspace:/workspace \
  my-aidev:v1.0.0 \
  /bin/bash -c "tail -f /dev/null"

#  -u "$(id -u):$(id -g)" \

echo "
# 初始化 oh-my-opencode（仅需一次）
omo init --yes
omo config set default_agent sisyphus
omo config set planner_enabled true

# 验证双引擎
claude --version
opencode --version
openclaw --version

# 创建 C++ 项目示例
cd /workspace
setup-cpp-project myproject  # 使用容器内置命令（见下方）
"
