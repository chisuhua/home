#!/bin/bash
# build.sh - 高效构建 Docker 镜像（支持 BuildKit 与智能缓存）
#
# 核心改进：
# 1. 默认启用 BuildKit，利用并行构建和高级缓存功能。
# 2. 引入 --update-tools 参数，替代暴力的 --force，精准控制工具更新。
# 3. 自动清理构建上下文，避免无关文件拖慢构建。
#
# 用法：
#   ./build.sh                # 极速构建（利用层缓存 + 挂载缓存）
#   ./build.sh --update       # 更新全局工具（触发 TOOLS_UPDATE 参数）
#   ./build.sh --no-cache     # 彻底重置（不使用任何缓存）
#   ./build.sh --clean        # 清理悬空镜像
#   ./build.sh --push         # 构建并推送到远程仓库

set -e

# ================= 配置区域 =================
IMAGE_NAME="my-dev-env"
IMAGE_TAG="v0.1"
DOCKERFILE_PATH="Dockerfile"
# 如果有远程仓库，在此配置，例如：registry.cn-hangzhou.aliyuncs.com/myrepo/my-dev-env
REMOTE_REGISTRY="" 
# =============================================

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 参数解析
UPDATE_TOOLS=false
NO_CACHE=false
PUSH_IMAGE=false
CLEAN_UP=false

for arg in "$@"; do
    case $arg in
        --update|-u)
            UPDATE_TOOLS=true
            shift
            ;;
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        --push|-p)
            PUSH_IMAGE=true
            shift
            ;;
        --clean)
            CLEAN_UP=true
            shift
            ;;
        -h|--help)
            echo "用法：$0 [选项]"
            echo "选项:"
            echo "  --update, -u    更新全局工具 (触发 Dockerfile 中的 TOOLS_UPDATE)"
            echo "  --no-cache      不使用 Docker 缓存 (完全重新构建)"
            echo "  --push, -p      构建成功后推送到远程仓库"
            echo "  --clean         清理构建产生的悬空镜像"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ 未知参数：$arg${NC}"
            exit 1
            ;;
    esac
done

# 如果请求清理，则执行清理并退出
if [ "$CLEAN_UP" = true ]; then
    echo -e "${BLUE}🧹 正在清理悬空镜像...${NC}"
    docker image prune -f
    exit 0
fi

echo -e "${BLUE}🔨 开始构建镜像：${IMAGE_NAME}:${IMAGE_TAG}${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. 检查 Docker 服务
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker 服务未启动，请先启动 Docker。${NC}"
    exit 1
fi

# 2. 构建命令组装
BUILD_CMD="docker build"

# 启用 BuildKit (关键加速)
#export DOCKER_BUILDKIT=1

# 基础参数
BUILD_CMD="$BUILD_CMD -t ${IMAGE_NAME}:${IMAGE_TAG} -f $DOCKERFILE_PATH"

# 处理缓存策略
if [ "$NO_CACHE" = true ]; then
    echo -e "${YELLOW}📌 模式：完全无缓存构建 (Full Rebuild)${NC}"
    BUILD_CMD="$BUILD_CMD --no-cache"
elif [ "$UPDATE_TOOLS" = true ]; then
    # 对应 Dockerfile 中的 ARG TOOLS_UPDATE
    # 每次更新时，Docker 会重新运行安装命令，但 --mount=type=cache 依然能利用本地包缓存
    CURRENT_TS=$(date +%s)
    echo -e "${YELLOW}📌 模式：工具更新构建 (Cache Busting: $CURRENT_TS)${NC}"
    BUILD_CMD="$BUILD_CMD --build-arg TOOLS_UPDATE=$CURRENT_TS"
else
    echo -e "${GREEN}📌 模式：极速增量构建 (利用层缓存 + 挂载缓存)${NC}"
fi

# 推送逻辑
if [ "$PUSH_IMAGE" = true ]; then
    BUILD_CMD="$BUILD_CMD --push"
    # 如果有配置远程仓库，自动打标签
    if [ -n "$REMOTE_REGISTRY" ]; then
        FULL_REMOTE_NAME="${REMOTE_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        echo -e "${BLUE}ℹ️  将推送到：$FULL_REMOTE_NAME${NC}"
        # 注意：docker build --push 会自动处理标签，但为了保险也可以手动 tag
        docker tag ${IMAGE_NAME}:${IMAGE_TAG} $FULL_REMOTE_NAME
    fi
fi

# 3. 执行构建
echo "$BUILD_CMD"
echo -e "${GREEN}🚀 执行构建命令...${NC}"
# 使用 eval 执行拼接的命令
eval $BUILD_CMD .

# 4. 后续处理
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ 构建成功！${NC}"

if [ "$PUSH_IMAGE" = false ]; then
    echo ""
    echo "📋 常用操作："
    echo "   启动容器：docker run -d --name dev-env -p 8001:8001 $IMAGE_NAME"
    echo "   进入容器：docker exec -it dev-env bash"
    echo "   查看日志： docker logs -f dev-env"
    echo "   停止容器： docker stop dev-env && docker rm dev-env"
fi
