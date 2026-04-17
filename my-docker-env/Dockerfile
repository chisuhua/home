FROM nvidia/cuda:13.0.2-devel-ubuntu24.04

# 设置时区 & 非交互式安装
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    NPM_CONFIG_REGISTRY=https://registry.npmmirror.com

RUN sed -i 's|http://.*.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list

# 【修改点 1】安装系统基础工具
# 新增了: cmake-curses-gui clang lldb lld clangd
# 移除了末尾重复的 default-jdk 安装，统一在这里处理
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    apt-get update && \
    apt-get install -y \
        curl wget git vim nano htop tree \
        build-essential cmake cmake-curses-gui g++ gdb valgrind \
        clang lldb lld clangd \
        python3 python3-pip python3-venv python3-full \
        tmux unzip zip \
        libssl-dev \
        ca-certificates gnupg \
        pkg-config libx11-dev libxkbfile-dev libsecret-1-dev \
        sqlite3 jq \
        default-jdk && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
    ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim && \
    ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/vim && \
    rm nvim-linux-x86_64.tar.gz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -fsSL https://code-server.dev/install.sh | sh 

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

RUN apt-get update && apt-get install -y sudo ripgrep && \
    apt-get install gh && \
    apt-get install ccache && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# 切换到普通用户
ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=1000

RUN usermod -aG sudo ubuntu
RUN echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo 'Defaults:ubuntu !requiretty' >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME

RUN mkdir -p ~/.npm-global && \
    npm config set prefix '~/.npm-global'

RUN curl -fsSL https://bun.sh/install | bash

ENV PATH="/home/${USERNAME}/.bun/bin:${PATH}"

# https://github.com/anomalyco/opencode
# https://github.com/code-yeongyu/oh-my-opencode
# https://github.com/anthropics/claude-code/releases
# 
# 【缓存破坏机制】确保 @latest 包能真正更新：
# 1. 使用 ARG CACHE_BUST 构建参数，需要更新时改变值：docker build --build-arg CACHE_BUST=$(date +%Y%m%d)
# 2. 安装前清理 bun 缓存
# 3. 使用 --force 强制重新获取
#
# 用法：
#   - 自动更新：docker build --build-arg CACHE_BUST=$(date +%Y%m%d) -t my-dev-env .
#   - 强制更新：docker build --no-cache -t my-dev-env .
#
ARG CACHE_BUST=1

RUN ~/.bun/bin/bun cache clean && \
    ~/.bun/bin/bun install -g opencode-ai@latest --force && \
    ~/.bun/bin/bun install -g oh-my-opencode@latest --force && \
    ~/.bun/bin/bun install -g @ission/openspec@latest --force && \
    ~/.bun/bin/bun install -g @anthropic-ai/claude-code@latest --force && \
    npm install -g pnpm@latest --force && \
    ~/.bun/bin/bun cache clean && \
    curl -fsSL https://openclaw.bot/install.sh | bash

#RUN mkdir -p ~/.opencode && \
#    echo '{\n  \"ui\": \"cli\",\n  \"providers\": {\n    \"claude\": false,\n    \"gemini\": false,\n    \"copilot\": false\n  }\n}' > ~/.opencode/config.json
# ~/.bun/bin/bunx oh-my-opencode@latest install --no-tui --claude=no --gemini=no --copilot=no


RUN mkdir -p ~/.local/bin && \
    ln -sf ~/.bun/bin/opencode ~/.local/bin/opencode 2>/dev/null || true && \
    ln -sf ~/.bun/bin/claude ~/.local/bin/claude 2>/dev/null || true

# 【修改点 2】删除了原文件末尾那个单独安装 JDK 和 code-server 且未清理缓存的 RUN 指令
# 因为上面已经在 root 阶段统一处理了，这样镜像更干净、层数更少。

ENV PATH="/home/${USERNAME}/.local/bin:/home/${USERNAME}/.bun/bin:/home/${USERNAME}/venv/bin:/home/${USERNAME}/.npm-global/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

EXPOSE 8001
EXPOSE 18789
EXPOSE 50080


RUN python3 -m venv $HOME/venv && \
    $HOME/venv/bin/pip install --upgrade pip && \
    $HOME/venv/bin/pip install compiledb PyMuPDF python-docx requests beautifulsoup4 pdfplumber openpyxl && \
    $HOME/venv/bin/pip cache purge

WORKDIR /workspace

# 默认命令
CMD ["tail", "-f", "/dev/null"]
