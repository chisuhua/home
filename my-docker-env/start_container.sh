docker run -d \
  --name aidev2 \
  --restart always \
  --memory="6g" \
  --memory-swap="6g" \
  --cpus="1.7" \
  --oom-kill-disable \
  -p 18789:18789 \
  -p 50080:50080 \
  -w /workspace \
  -v ~/workspace/home/.config:/home/ubuntu/.config \
  -v ~/workspace/home/.bashrc:/home/ubuntu/.bashrc \
  -v ~/workspace/home/.openclaw:/home/ubuntu/.openclaw \
  -v ~/workspace/home/.claude:/home/ubuntu/.claude \
  -v ~/workspace/home/.claude.json:/home/ubuntu/.claude.json \
  -v ~/workspace/home/.ssh:/home/ubuntu/.ssh \
  -v ~/workspace/home/.tmux:/home/ubuntu/.tmux \
  -v ~/workspace/home/.tmuxinator:/home/ubuntu/.tmuxinator \
  -v ~/workspace/home/.tmux.conf:/home/ubuntu/.tmux.conf \
  -v ~/workspace/home/.local/share:/home/ubuntu/.local/share \
  -v ~/workspace/home/.gitconfig:/home/ubuntu/.gitconfig \
  -v ~/workspace:/workspace \
  my-aidev:v1.0.2 \
  /bin/bash -c "tail -f /dev/null"

#  -u "$(id -u):$(id -g)" \

echo "
run exec_container.sh
"
