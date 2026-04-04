#!/bin/bash
# ============================================================================
# 代码质量基准测试脚本 - v2 修复版
# 修复：MiniMax 响应解析问题
# ============================================================================

set -u

RESULTS_DIR="$HOME/.config/opencode/benchmark/results"
mkdir -p "$RESULTS_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="$RESULTS_DIR/code_quality_v2_$TIMESTAMP.md"
JSON_DIR="$RESULTS_DIR/json_v2_$TIMESTAMP"
mkdir -p "$JSON_DIR"

# API Keys
BAILIAN_KEY="${BAILIAN_KEY:-sk-sp-e0fb34a4c65a429fbd9e5c263a4d6f2e}"
BAILIAN_URL="https://coding.dashscope.aliyuncs.com/apps/anthropic/v1/messages"
MINIMAX_KEY="${MINIMAX_KEY:-sk-cp-9kxXVZxjL8WgTODQD5tbNYgAQdop7_FMDfqQYp59LNMcswWTTa_onzrWykHSD1nUcrVrf8qDtJ4fzOkXYfTcLhJdbySCbM0-pjGmLshKBwuQRh0wUnjoIjw}"
MINIMAX_URL="https://api.minimaxi.com/anthropic/v1/messages"
KIMI_CODE_KEY="${KIMI_CODE_KEY:-sk-kimi-EoeCdgjLAcXJdUeq9vovLSWhOkitEKzWbEgN1CHhJtnmKQgfQxjkbmyJjhgw4idT}"
KIMI_CODE_URL="https://api.kimi.com/coding/v1/messages"

# 初始化报告
cat > "$RESULTS_FILE" << HEADER
# 代码质量基准测试报告 - v2

**测试时间**: $(date)
**修复内容**: MiniMax 响应解析、max_tokens 增加

---

## 测试任务

### Task 1: C++ 代码生成
用 C++17 实现一个线程安全的单例模式，支持懒加载和防止双重检查锁定问题。

### Task 2: 代码审查
找出以下代码中的并发安全问题（至少 3 个）

### Task 3: CUDA 调试
CUDA kernel 启动后返回 cudaErrorInvalidConfiguration，列出 5 个最常见原因和排查顺序。

---

## 测试结果

HEADER

# 文本提取函数 - 使用 Python 统一处理
extract_text() {
  local json="$1"
  
  echo "$json" | python3 -c '
import sys, json

try:
    data = json.loads(sys.stdin.read())
    content = data.get("content", [])
    
    # 处理 content 数组（MiniMax/Bailian 格式）
    if isinstance(content, list):
        texts = []
        for item in content:
            if isinstance(item, dict) and item.get("type") == "text":
                texts.append(item.get("text", ""))
        if texts:
            print("\n".join(texts))
            sys.exit(0)
    
    # 直接 text 字段
    if "text" in data:
        print(data["text"])
        sys.exit(0)
    
    print("[⚠️ 无法解析响应]")
except Exception as e:
    print(f"[⚠️ 错误：{e}]")
'
}

# 测试函数
test_code_quality() {
  local name=$1
  local url=$2
  local auth_type=$3
  local api_key=$4
  local model=$5
  local model_id=$6
  local max_tokens=${7:-2000}  # 默认 2000 tokens
  
  echo "🧪 测试：$name ($model) [max_tokens=$max_tokens]..."
  
  local model_dir="$JSON_DIR/$model_id"
  mkdir -p "$model_dir"
  
  echo "### $name" >> "$RESULTS_FILE"
  echo "**模型**: $model | **max_tokens**: $max_tokens" >> "$RESULTS_FILE"
  echo "" >> "$RESULTS_FILE"
  
  local auth_header
  if [ "$auth_type" = "bearer" ]; then
    auth_header="Authorization: Bearer $api_key"
  else
    auth_header="x-api-key: $api_key"
  fi
  
  # Task 1: 代码生成 (2000 tokens)
  echo "**Task 1: C++ 单例模式**" >> "$RESULTS_FILE"
  local response1
  response1=$(curl -s -X POST "$url" \
    -H "$auth_header" \
    -H "Content-Type: application/json" \
    -H "anthropic-version: 2023-06-01" \
    -d "{\"model\":\"$model\",\"max_tokens\":$max_tokens,\"messages\":[{\"role\":\"user\",\"content\":\"用 C++17 实现一个线程安全的单例模式，支持懒加载和防止双重检查锁定问题。要求：使用 std::call_once 或 Meyer's Singleton，说明原理。\"}]}")
  
  echo "$response1" > "$model_dir/task1_raw.json"
  local code1
  code1=$(extract_text "$response1")
  echo '```cpp' >> "$RESULTS_FILE"
  echo "$code1" >> "$RESULTS_FILE"
  echo '```' >> "$RESULTS_FILE"
  echo "" >> "$RESULTS_FILE"
  
  # Task 2: 代码审查 (1500 tokens)
  echo "**Task 2: 代码审查**" >> "$RESULTS_FILE"
  local response2
  response2=$(curl -s -X POST "$url" \
    -H "$auth_header" \
    -H "Content-Type: application/json" \
    -H "anthropic-version: 2023-06-01" \
    -d "{\"model\":\"$model\",\"max_tokens\":1500,\"messages\":[{\"role\":\"user\",\"content\":\"找出以下代码中的并发安全问题（至少 3 个）：std::queue<int> sharedQueue; void producer() { for (int i = 0; i < 100; i++) { if (sharedQueue.size() < 100) { sharedQueue.push(i); } } } void consumer() { while (true) { if (!sharedQueue.empty()) { int val = sharedQueue.front(); sharedQueue.pop(); } } }\"}]}")
  
  echo "$response2" > "$model_dir/task2_raw.json"
  local code2
  code2=$(extract_text "$response2")
  echo "$code2" >> "$RESULTS_FILE"
  echo "" >> "$RESULTS_FILE"
  
  # Task 3: CUDA 调试 (1500 tokens)
  echo "**Task 3: CUDA 调试**" >> "$RESULTS_FILE"
  local response3
  response3=$(curl -s -X POST "$url" \
    -H "$auth_header" \
    -H "Content-Type: application/json" \
    -H "anthropic-version: 2023-06-01" \
    -d "{\"model\":\"$model\",\"max_tokens\":1500,\"messages\":[{\"role\":\"user\",\"content\":\"CUDA kernel 启动后返回 cudaErrorInvalidConfiguration，列出 5 个最常见原因和排查顺序。\"}]}")
  
  echo "$response3" > "$model_dir/task3_raw.json"
  local code3
  code3=$(extract_text "$response3")
  echo "$code3" >> "$RESULTS_FILE"
  echo "" >> "$RESULTS_FILE"
  
  echo "---" >> "$RESULTS_FILE"
  echo "" >> "$RESULTS_FILE"
  
  echo "✅ 完成：$name"
  sleep 2
}

echo "============================================"
echo "代码质量基准测试 v2 - 修复 MiniMax 解析"
echo "============================================"
echo ""

# 只测试之前失败的模型
echo "【测试 MiniMax 直连 + 抽样验证】"
test_code_quality "MiniMax-M2.7 (直连)" "$MINIMAX_URL" "x-api-key" "$MINIMAX_KEY" "MiniMax-M2.7-highspeed" "minimax-m2-7-direct-highspeed" 2000
#test_code_quality "qwen3.5-plus (验证)" "$BAILIAN_URL" "bearer" "$BAILIAN_KEY" "qwen3.5-plus" "qwen3-5-plus" 2000

echo ""
echo "============================================"
echo "✅ 测试完成！"
echo "报告：$RESULTS_FILE"
echo "============================================"
