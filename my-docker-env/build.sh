#!/bin/bash
# build.sh - 构建 Docker 镜像（自动处理缓存破坏）
# 
# 用法：
#   ./build.sh              # 普通构建（使用缓存）
#   ./build.sh --force      # 强制构建（破坏缓存，获取最新包版本）
#   ./build.sh --no-cache   # 完全无缓存构建
#   ./build.sh --rebuild    # 重新构建并推送（如果有远程仓库）

set -e

IMAGE_NAME="my-dev-env"
DOCKERFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 解析参数
FORCE_BUILD=false
NO_CACHE=false
REBUILD=false

for arg in "$@"; do
    case $arg in
        --force)
            FORCE_BUILD=true
            shift
            ;;
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        --rebuild)
            REBUILD=true
            shift
            ;;
        *)
            echo "❌ 未知参数：$arg"
            echo "用法：$0 [--force] [--no-cache] [--rebuild]"
            exit 1
            ;;
    esac
done

echo "🔨 开始构建 Docker 镜像：$IMAGE_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 构建命令
BUILD_CMD="docker build"

if [ "$NO_CACHE" = true ]; then
    echo "📌 模式：完全无缓存构建"
    BUILD_CMD="$BUILD_CMD --no-cache"
elif [ "$FORCE_BUILD" = true ]; then
    echo "📌 模式：强制构建（破坏 bun 包缓存）"
    CACHE_BUST=$(date +%Y%m%d)
    BUILD_CMD="$BUILD_CMD --build-arg CACHE_BUST=$CACHE_BUST"
    echo "📌 CACHE_BUST=$CACHE_BUST"
else
    echo "📌 模式：普通构建（使用 Docker 缓存）"
fi

BUILD_CMD="$BUILD_CMD -t $IMAGE_NAME $DOCKERFILE_DIR"

echo ""
echo "🚀 执行：$BUILD_CMD"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 执行构建
eval $BUILD_CMD

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 构建完成！"
echo ""
echo "📋 启动容器："
echo "   docker run -d --name dev-env $IMAGE_NAME"
echo ""
echo "📋 查看镜像："
echo "   docker images | grep $IMAGE_NAME"
echo ""

# 如果是 rebuild 模式，推送到远程
if [ "$REBUILD" = true ]; then
    echo "📤 推送到远程仓库..."
    # 根据实际远程仓库地址修改
    # docker tag $IMAGE_NAME <your-registry>/my-dev-env:latest
    # docker push <your-registry>/my-dev-env:latest
    echo "⚠️  请配置远程仓库地址后取消注释推送命令"
fi
