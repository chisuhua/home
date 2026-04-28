FROM crpi-u4ojg4pfqmxu81z0.cn-shanghai.personal.cr.aliyuncs.com/chisuhua/my-dev-base:v1.0 AS app

ARG USERNAME=ubuntu
ENV NPM_CONFIG_REGISTRY=https://registry.npmmirror.com

RUN sudo apt-get update && sudo apt-get install -y supervisor llvm-dev clang-dev

# ==========================================
# 1. 缓存破坏机制与全局工具安装
# ==========================================
# 默认值设为 1，如果需要强制更新所有工具，构建时传入新值即可
# 例如: docker build --build-arg TOOLS_UPDATE=2 ...
ARG TOOLS_UPDATE=1

RUN ~/.bun/bin/bun install -g opencode-ai@latest && \
    ~/.bun/bin/bun install -g oh-my-opencode@latest && \
    ~/.bun/bin/bun install -g @anthropic-ai/claude-code@latest

ENV PNPM_HOME="/home/${USERNAME}/.local/share/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"

RUN mkdir -p ~/.ssh && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
    chmod 600 ~/.ssh/known_hosts

RUN npm install -g pnpm@latest && \
    mkdir -p /home/${USERNAME}/.local/share/pnpm && \
    pnpm config set global-bin-dir ${PNPM_HOME} && \
    pnpm add -g openclaw@latest --registry=https://registry.npmmirror.com && \
    openclaw doctor --fix


RUN mkdir -p ~/.local/bin && \
    ln -sf ~/.bun/bin/opencode ~/.local/bin/opencode 2>/dev/null || true && \
    ln -sf ~/.bun/bin/claude ~/.local/bin/claude 2>/dev/null || true

#RUN chown -R ubuntu:ubuntu /var/log/supervisor


EXPOSE 8001 18789 50080

#USER root
RUN curl -fsSL --retry 5 --retry-delay 5 https://code-server.dev/install.sh | sh#

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY --chmod=644 supervisord.conf /etc/supervisor/conf.d/supervisord.conf
#COPY --chmod=644 my_services.conf /etc/supervisor/conf.d/my_services.conf


CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf", "-n"]

