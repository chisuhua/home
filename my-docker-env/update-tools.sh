#!/bin/bash
# update-tools.sh - 更新 Docker 容器中的全局工具到最新版本
# 用法：在容器内运行 ./update-tools.sh

set -e

echo "🔄 更新全局工具到最新版本..."

# 先清理缓存，确保获取最新版本
echo "🧹 清理缓存..."
~/.bun/bin/bun cache clean

# 更新 bun 全局包（使用 --force 强制重新获取）
echo "📦 更新 opencode-ai..."
~/.bun/bin/bun install -g opencode-ai@latest --force

echo "📦 更新 oh-my-opencode..."
~/.bun/bin/bun install -g oh-my-opencode@latest --force

echo "📦 更新 @ission/openspec..."
~/.bun/bin/bun install -g @ission/openspec@latest --force

echo "📦 更新 @anthropic-ai/claude-code..."
~/.bun/bin/bun install -g @anthropic-ai/claude-code@latest --force

echo "📦 更新 openclaw..."
~/.bun/bin/bun install -g openclaw@latest --force

echo "📦 更新 @larksuiteoapi/node-sdk..."
~/.bun/bin/bun install -g @larksuiteoapi/node-sdk@latest --force

echo "📦 更新 pnpm..."
npm install -g pnpm@latest --force

# 显示版本信息
echo ""
echo "✅ 更新完成！当前版本："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
opencode --version 2>/dev/null || echo "opencode: (未找到)"
claude --version 2>/dev/null || echo "claude: (未找到)"
openclaw --version 2>/dev/null || echo "openclaw: (未找到)"
pnpm --version 2>/dev/null || echo "pnpm: (未找到)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
