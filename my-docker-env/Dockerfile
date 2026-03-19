# 即使在 CPU 机器上也能构建！
FROM nvidia/cuda:13.0.2-devel-ubuntu24.04

# 设置时区 & 非交互式安装
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    NPM_CONFIG_REGISTRY=https://registry.npmmirror.com

RUN sed -i 's|http://.*.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list

# 安装系统基础工具
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    apt-get update && \
    apt-get install -y \
        curl wget git vim nano htop tree \
        build-essential cmake g++ gdb valgrind \
        python3 python3-pip python3-venv python3-full \
        tmux unzip zip \
        libssl-dev \
	  ca-certificates gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
    ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim && \
    ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/vim && \
    rm nvim-linux-x86_64.tar.gz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#ARG USERNAME=dev
ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=1000
#RUN groupadd --gid $USER_GID $USERNAME && \
#    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
#    echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
#    chmod 0440 /etc/sudoers.d/$USERNAME
#RUN groupmod -g ${USER_GID} ${USERNAME} 2>/dev/null || groupadd --gid ${USER_GID} ${USERNAME} && \
#    usermod -u ${USER_UID} -g ${USER_GID} ${USERNAME} 2>/dev/null || \
#    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} && \
#    mkdir -p /home/${USERNAME}/.npm-global /home/${USERNAME}/.opencode/bin /home/${USERNAME}/.bun && \
#    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME} /workspace

USER $USERNAME
WORKDIR /home/$USERNAME


RUN mkdir -p ~/.npm-global && \
    npm config set prefix '~/.npm-global'

RUN curl -fsSL https://bun.sh/install | bash

#RUN curl -fsSL https://opencode.ai/install | bash

RUN ~/.bun/bin/bun install -g opencode-ai@latest
RUN ~/.bun/bin/bunx oh-my-opencode@latest install --no-tui --claude=no --gemini=no --copilot=no

RUN ~/.bun/bin/bun install -g @anthropic-ai/claude-code && \
    ~/.bun/bin/bun install -g openclaw@latest

RUN mkdir -p ~/.local/bin && \
    ln -sf ~/.bun/bin/opencode ~/.local/bin/opencode 2>/dev/null || true && \
    ln -sf ~/.bun/bin/claude-code ~/.local/bin/claude-code 2>/dev/null || true

RUN apt install -y default-jdk && \
    pkg-config libx11-dev libxkbfile-dev libsecret-1-dev \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN curl -fsSL https://code-server.dev/install.sh | sh


ENV PATH="/home/ubuntu/venv/bin:/home/ubuntu/.npm-global/bin:/home/ubuntu/.opencode/bin:/home/ubuntu/.local/bin:/usr/local/bin:$PATH"

RUN python3 -m venv $HOME/venv && \
    $HOME/venv/bin/pip install --upgrade pip && \
    $HOME/venv/bin/pip install compiledb && \
    $HOME/venv/bin/pip cache purge

WORKDIR /workspace
#RUN $HOME/venv/bin/pip install -r requirements.txt


# 默认命令
#CMD ["bash"]
CMD ["tail", "-f", "/dev/null"]
