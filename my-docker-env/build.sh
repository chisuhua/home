#!/bin/bash
set -e

# === 配置区（请修改为你自己的信息）===
ACR_REGION="cn-shanghai"          # 华东上海
ACR_NAMESPACE="your-namespace"    # 替换为你的 ACR 命名空间
IMAGE_NAME="my-aidev"
VERSION="v1.0.0"

# 构建镜像
echo "🏗️  Building Docker image..."
docker build -t $IMAGE_NAME:$VERSION .

# 登录 ACR（使用 RAM 子账号 AccessKey）
echo "🔑 Logging into ACR..."
# ⚠️ 请先设置环境变量：export ACR_USERNAME=xxx ACR_PASSWORD=yyy
# 或使用阿里云 CLI: aliyun cr GetAuthorizationToken
echo "$ACR_PASSWORD" | docker login --username "$ACR_USERNAME" --password-stdin registry.$ACR_REGION.aliyuncs.com

# 打标签 & 推送
FULL_TAG="registry.$ACR_REGION.aliyuncs.com/$ACR_NAMESPACE/$IMAGE_NAME:$VERSION"
docker tag $IMAGE_NAME:$VERSION $FULL_TAG
echo "📤 Pushing to ACR: $FULL_TAG"
docker push $FULL_TAG

# 同时推送 latest（可选）
docker tag $IMAGE_NAME:$VERSION registry.$ACR_REGION.aliyuncs.com/$ACR_NAMESPACE/$IMAGE_NAME:latest
docker push registry.$ACR_REGION.aliyuncs.com/$ACR_NAMESPACE/$IMAGE_NAME:latest

echo "✅ Done! Image available at: $FULL_TAG"
