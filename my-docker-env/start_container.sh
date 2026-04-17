docker run -d \
  --privileged \
  --name aidev2 \
  --restart always \
  --memory="5.5g" \
  --memory-swap="9g" \
  --cpus="1.7" \
  --oom-score-adj=500 \
  -p 127.0.0.1:18789:18789 \
  -p 127.0.0.1:50080:50080 \
  -p 127.0.0.1:8001:8001 \
  -p 127.0.0.1:8002:8002 \
  -p 127.0.0.1:8003:8003 \
  -w /workspace \
  -v ~/workspace/home/.config:/home/ubuntu/.config \
  -v ~/workspace/home/.bashrc:/home/ubuntu/.bashrc \
  -v ~/workspace/home/.openclaw:/home/ubuntu/.openclaw \
  -v ~/workspace/home/.claude:/home/ubuntu/.claude \
  -v ~/workspace/home/.claude.json:/home/ubuntu/.claude.json \
  -v ~/workspace/home/.ssh:/home/ubuntu/.ssh \
  -v ~/workspace/home/.agents:/home/ubuntu/.agents \
  -v ~/workspace/home/.tmux:/home/ubuntu/.tmux \
  -v ~/workspace/home/.tmuxinator:/home/ubuntu/.tmuxinator \
  -v ~/workspace/home/.tmux.conf:/home/ubuntu/.tmux.conf \
  -v ~/workspace/home/.local/share:/home/ubuntu/.local/share \
  -v ~/workspace/home/.gitconfig:/home/ubuntu/.gitconfig \
  -v ~/workspace/home/venv:/home/ubuntu/venv \
  -v ~/workspace/home/.bun/bin:/home/ubuntu/.bun/bin \
  -v ~/workspace/home/.bun/install/global:/home/ubuntu/.bun/install/global \
  -v ~/workspace:/workspace \
  -v /mnt/nas/project:/workspace/project \
  my-aidev:v1.0.2 \
  /bin/bash -c "tail -f /dev/null"

#  -u "$(id -u):$(id -g)" \

echo "
run exec_container.sh
"
