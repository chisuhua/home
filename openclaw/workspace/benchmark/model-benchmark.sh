#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

BAILIAN_KEY="sk-sp-e0fb34a4c65a429fbd9e5c263a4d6f2e"
MINIMAX_KEY="sk-cp-9kxXVZxjL8WgTODQD5tbNYgAQdop7_FMDfqQYp59LNMcswWTTa_onzrWykHSD1nUcrVrf8qDtJ4fzOkXYfTcLhJdbySCbM0-pjGmLshKBwuQRh0wUnjoIjw"
MOONSHOT_KEY="sk-kimi-O7ogfShgNdDovd6iC0OSUQPIYTuNB6QcYVhBcN4FhrhXBrQBQXn9idtuiKtULnAE"

PROMPT="你好，请用一句话介绍你自己。"
FORMAT_FILE="$(dirname "$0")/curl-format.txt"

test_model() {
    local endpoint=$1
    local model=$2
    local display=$3
    local auth_key=$4
    local format=$5
    
    local result=$(curl -s -w "@$FORMAT_FILE" -X POST "$endpoint" \
        -H "Authorization: Bearer $auth_key" \
        -H "Content-Type: application/json" \
        -d "{\"model\":\"$model\",\"max_tokens\":100,\"messages\":[{\"role\":\"user\",\"content\":\"$PROMPT\"}]}")
    
    local ttfb=$(echo "$result" | grep -oP 'ttfb:\K[0-9.]+')
    local total=$(echo "$result" | grep -oP 'total:\K[0-9.]+')
    local response=$(echo "$result" | sed 's/[[:space:]]*dns:.*//')
    
    local status=""
    local tokens=""
    if [ "$format" == "anthropic" ]; then
        status=$(echo "$response" | jq -r '.stop_reason // "ERROR"' 2>/dev/null)
        tokens=$(echo "$response" | jq -r '.usage.output_tokens // 0' 2>/dev/null)
    else
        status=$(echo "$response" | jq -r '.choices[0].finish_reason // "ERROR"' 2>/dev/null)
        tokens=$(echo "$response" | jq -r '.choices[0].message.content | length' 2>/dev/null)
    fi
    
    local tokens_per_sec="N/A"
    if [ -n "$total" ] && [ "$total" != "0" ]; then
        tokens_per_sec=$(awk "BEGIN {printf \"%.1f\", $tokens / $total}")
    fi
    
    local time_ms=$(awk "BEGIN {printf \"%.0f\", $total * 1000}")
    local ttfb_ms=$(awk "BEGIN {printf \"%.0f\", $ttfb * 1000}")
    
    if [ "$status" == "end_turn" ] || [ "$status" == "stop" ]; then
        printf "${GREEN}%-25s${NC} | %-6s | %8s ms | %8s ms | %8s | %8s tokens/s\n" \
            "$display" "$status" "$time_ms" "$ttfb_ms" "$tokens" "$tokens_per_sec"
    else
        printf "${RED}%-25s${NC} | %-6s | %8s ms | %8s ms | %8s | %8s\n" \
            "$display" "$status" "$time_ms" "$ttfb_ms" "ERROR" "N/A"
    fi
}

echo -e "${BLUE}${BOLD}========================================${NC}"
echo -e "${BLUE}${BOLD}   Model Benchmark Test${NC}"
echo -e "${BLUE}${BOLD}   $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${BLUE}${BOLD}========================================${NC}"
echo ""

echo -e "${BOLD}Model                     | Status | Total(ms) |    TTFB(ms) |   Tokens | Tokens/s${NC}"
echo "------------------------------------------------------------------------------------------"

test_model "https://coding.dashscope.aliyuncs.com/apps/anthropic/v1/messages" \
    "qwen3.5-plus" "Qwen3.5-Plus" "$BAILIAN_KEY" "anthropic"

test_model "https://coding.dashscope.aliyuncs.com/apps/anthropic/v1/messages" \
    "qwen3-max-2026-01-23" "Qwen3-Max-2026-01-23" "$BAILIAN_KEY" "anthropic"

test_model "https://coding.dashscope.aliyuncs.com/apps/anthropic/v1/messages" \
    "qwen3-coder-next" "Qwen3-Coder-Next" "$BAILIAN_KEY" "anthropic"

test_model "https://coding.dashscope.aliyuncs.com/apps/anthropic/v1/messages" \
    "qwen3-coder-plus" "Qwen3-Coder-Plus" "$BAILIAN_KEY" "anthropic"

test_model "https://coding.dashscope.aliyuncs.com/apps/anthropic/v1/messages" \
    "glm-5" "GLM-5" "$BAILIAN_KEY" "anthropic"

test_model "https://coding.dashscope.aliyuncs.com/apps/anthropic/v1/messages" \
    "glm-4.7" "GLM-4.7" "$BAILIAN_KEY" "anthropic"

test_model "https://api.minimaxi.com/v1/chat/completions" \
    "MiniMax-M2.7" "MiniMax-M2.7 (Direct)" "$MINIMAX_KEY" "openai"

test_model "https://api.moonshot.cn/v1/chat/completions" \
    "moonshot-v1-8k" "Moonshot-v1-8k" "$MOONSHOT_KEY" "openai"

echo ""
echo -e "${BLUE}${BOLD}========================================${NC}"
echo -e "${BLUE}${BOLD}   Benchmark Complete${NC}"
echo -e "${BLUE}${BOLD}   $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${BLUE}${BOLD}========================================${NC}"
