#!/bin/bash
# ============================================================================
# LLM 模型基准测试脚本
# 测试：Bailian 平台 + 直连服务 的性能对比
# ============================================================================

# 注意：不能用 set -e，因为 curl 遇到 HTTP 错误会返回非零状态

# 输出格式文件
FORMAT="/tmp/curl-format.txt"
echo 'dns:%{time_namelookup} connect:%{time_connect} starttransfer:%{time_starttransfer} total:%{time_total}' > "$FORMAT"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 结果文件
RESULTS_DIR="$HOME/.config/opencode/benchmark/results"
mkdir -p "$RESULTS_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="$RESULTS_DIR/benchmark_$TIMESTAMP.txt"

echo "============================================" | tee "$RESULTS_FILE"
echo "LLM 模型基准测试 - $(date)" | tee -a "$RESULTS_FILE"
echo "============================================" | tee -a "$RESULTS_FILE"
echo "" | tee -a "$RESULTS_FILE"

# 测试函数
test_model() {
  local name=$1
  local url=$2
  local auth_header=$3
  local model=$4
  local content_type=$5
  local extra_headers=$6
  
  echo -e "${YELLOW}=== Testing $name ===${NC}" | tee -a "$RESULTS_FILE"
  
  # 执行 curl，忽略错误码
  set +e
  result=$(curl -s -w "@$FORMAT" -X POST "$url" \
    -H "$auth_header" \
    -H "Content-Type: application/json" \
    $content_type \
    $extra_headers \
    -d "{\"model\":\"$model\",\"max_tokens\":100,\"messages\":[{\"role\":\"user\",\"content\":\"你好\"}]}" 2>&1)
  set -e
  
  timing=$(echo "$result" | tail -1)
  body=$(echo "$result" | head -1)
  
  # Extract tokens
  output_tokens=$(echo "$body" | grep -o '"output_tokens":[0-9]*' | head -1 | cut -d: -f2)
  [ -z "$output_tokens" ] && output_tokens=$(echo "$body" | grep -o '"output_tokens": [0-9]*' | head -1 | cut -d: -f2 | tr -d ' ')
  [ -z "$output_tokens" ] && output_tokens="N/A"
  
  # Check for error
  if echo "$body" | grep -q '"error"'; then
    err_msg=$(echo "$body" | grep -o '"message":"[^"]*"' | cut -d'"' -f4 || echo "Unknown error")
    echo -e "${RED}ERROR: $err_msg${NC} | $timing" | tee -a "$RESULTS_FILE"
  else
    echo -e "${GREEN}OK${NC} | tokens: $output_tokens | $timing" | tee -a "$RESULTS_FILE"
  fi
  echo "" | tee -a "$RESULTS_FILE"
  # sleep 1  # 避免速率限制 - 注释掉以加快测试
}

# ============================================================================
# API Keys (从配置文件读取或手动设置)
# ============================================================================

# Bailian (阿里云)
BAILIAN_KEY="${BAILIAN_KEY:-sk-sp-e0fb34a4c65a429fbd9e5c263a4d6f2e}"
BAILIAN_URL="https://coding.dashscope.aliyuncs.com/apps/anthropic/v1/messages"
ANTHROPIC_HEADER='-H "anthropic-version: 2023-06-01"'

# MiniMax 直连
MINIMAX_KEY="${MINIMAX_KEY:-sk-cp-9kxXVZxjL8WgTODQD5tbNYgAQdop7_FMDfqQYp59LNMcswWTTa_onzrWykHSD1nUcrVrf8qDtJ4fzOkXYfTcLhJdbySCbM0-pjGmLshKBwuQRh0wUnjoIjw}"
MINIMAX_URL="https://api.minimaxi.com/anthropic/v1/messages"

# Kimi-Code 直连
KIMI_CODE_KEY="${KIMI_CODE_KEY:-sk-kimi-EoeCdgjLAcXJdUeq9vovLSWhOkitEKzWbEgN1CHhJtnmKQgfQxjkbmyJjhgw4idT}"
KIMI_CODE_URL="https://api.kimi.com/coding/v1/messages"

# ============================================================================
# 开始测试
# ============================================================================

echo -e "${BLUE}========== BAILIAN 平台 (8 个模型) ==========${NC}" | tee -a "$RESULTS_FILE"
test_model "qwen3.5-plus" "$BAILIAN_URL" "Authorization: Bearer $BAILIAN_KEY" "qwen3.5-plus" "$ANTHROPIC_HEADER" ""
test_model "qwen3-max-2026-01-23" "$BAILIAN_URL" "Authorization: Bearer $BAILIAN_KEY" "qwen3-max-2026-01-23" "$ANTHROPIC_HEADER" ""
test_model "qwen3-coder-next" "$BAILIAN_URL" "Authorization: Bearer $BAILIAN_KEY" "qwen3-coder-next" "$ANTHROPIC_HEADER" ""
test_model "qwen3-coder-plus" "$BAILIAN_URL" "Authorization: Bearer $BAILIAN_KEY" "qwen3-coder-plus" "$ANTHROPIC_HEADER" ""
test_model "MiniMax-M2.5" "$BAILIAN_URL" "Authorization: Bearer $BAILIAN_KEY" "MiniMax-M2.5" "$ANTHROPIC_HEADER" ""
test_model "glm-5" "$BAILIAN_URL" "Authorization: Bearer $BAILIAN_KEY" "glm-5" "$ANTHROPIC_HEADER" ""
test_model "glm-4.7" "$BAILIAN_URL" "Authorization: Bearer $BAILIAN_KEY" "glm-4.7" "$ANTHROPIC_HEADER" ""
test_model "kimi-k2.5" "$BAILIAN_URL" "Authorization: Bearer $BAILIAN_KEY" "kimi-k2.5" "$ANTHROPIC_HEADER" ""

echo -e "${BLUE}========== MiniMax 直连 ==========${NC}" | tee -a "$RESULTS_FILE"
MINIMAX_AUTH_HEADER="x-api-key: $MINIMAX_KEY"
test_model "MiniMax-M2.7 (直连)" "$MINIMAX_URL" "$MINIMAX_AUTH_HEADER" "MiniMax-M2.7" "$ANTHROPIC_HEADER" ""

echo -e "${BLUE}========== Kimi-Code 直连 ==========${NC}" | tee -a "$RESULTS_FILE"
KIMI_AUTH_HEADER="x-api-key: $KIMI_CODE_KEY"
test_model "kimi-for-coding (无 thinking)" "$KIMI_CODE_URL" "$KIMI_AUTH_HEADER" "kimi-for-coding" "$ANTHROPIC_HEADER" ""
test_model "kimi-for-coding-thinking" "$KIMI_CODE_URL" "$KIMI_AUTH_HEADER" "kimi-for-coding-thinking" "$ANTHROPIC_HEADER" ""

# ============================================================================
# 完成
# ============================================================================

echo -e "${GREEN}============================================${NC}" | tee -a "$RESULTS_FILE"
echo -e "${GREEN}测试完成！结果已保存到：$RESULTS_FILE${NC}" | tee -a "$RESULTS_FILE"
echo -e "${GREEN}============================================${NC}" | tee -a "$RESULTS_FILE"
