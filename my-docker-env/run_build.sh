# === 配置区（请修改为你自己的信息）===
IMAGE_NAME="my-aidev"
VERSION="v1.0.0"

# 构建镜像
echo "🏗️  Building Docker image..."
docker build -t $IMAGE_NAME:$VERSION .


