#!/bin/bash
# ============================================================================
# 代码质量基准测试脚本 - 修复版
# 测试：所有 11 个模型的代码生成和调试能力
# ============================================================================

set -u

# 结果文件
RESULTS_DIR="$HOME/.config/opencode/benchmark/results"
mkdir -p "$RESULTS_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="$RESULTS_DIR/code_quality_$TIMESTAMP.md"
JSON_DIR="$RESULTS_DIR/json_$TIMESTAMP"
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
# 代码质量基准测试报告

**测试时间**: $(date)
**测试模型**: 11 个（8 个 Bailian + 2 个 Kimi-Code + 1 个 MiniMax 直连）

---

## 测试任务

### Task 1: C++ 代码生成
用 C++17 实现一个线程安全的单例模式，支持懒加载和防止双重检查锁定问题。
要求：使用 std::call_once 或 Meyer's Singleton，说明原理。

### Task 2: 代码审查
找出以下代码中的并发安全问题（至少 3 个）：
\`\`\`cpp
std::queue<int> sharedQueue;
void producer() {
    for (int i = 0; i < 100; i++) {
        if (sharedQueue.size() < 100) {
            sharedQueue.push(i);
        }
    }
}
void consumer() {
    while (true) {
        if (!sharedQueue.empty()) {
            int val = sharedQueue.front();
            sharedQueue.pop();
        }
    }
}
\`\`\`

### Task 3: CUDA 调试
CUDA kernel 启动后返回 cudaErrorInvalidConfiguration，列出 5 个最常见原因和排查顺序。

---

## 测试结果

HEADER

# 测试函数 - 改进版（处理不同 API 格式）
test_code_quality() {
  local name=$1
  local url=$2
  local auth_type=$3  # "bearer" 或 "x-api-key"
  local api_key=$4
  local model=$5
  local model_id=$6  # 用于文件名的 ID
  
  echo "🧪 测试：$name ($model)..."
  
  # 创建模型输出目录
  local model_dir="$JSON_DIR/$model_id"
  mkdir -p "$model_dir"
  
  # 写入模型信息
  echo "### $name" >> "$RESULTS_FILE"
  echo "**模型**: $model" >> "$RESULTS_FILE"
  echo "**平台**: $([ "$auth_type" = "bearer" ] && echo "Bailian" || echo "直连")" >> "$RESULTS_FILE"
  echo "" >> "$RESULTS_FILE"
  
  # 通用请求头
  local auth_header
  if [ "$auth_type" = "bearer" ]; then
    auth_header="Authorization: Bearer $api_key"
  else
    auth_header="x-api-key: $api_key"
  fi
  
  # Task 1: 代码生成
  echo "**Task 1: C++ 单例模式**" >> "$RESULTS_FILE"
  local response1
  response1=$(curl -s -X POST "$url" \
    -H "$auth_header" \
    -H "Content-Type: application/json" \
    -H "anthropic-version: 2023-06-01" \
    -d "{\"model\":\"$model\",\"max_tokens\":1000,\"messages\":[{\"role\":\"user\",\"content\":\"用 C++17 实现一个线程安全的单例模式，支持懒加载和防止双重检查锁定问题。要求：使用 std::call_once 或 Meyer's Singleton，说明原理。\"}]}")
  
  echo "$response1" > "$model_dir/task1_raw.json"
  
  # 提取文本（处理不同格式）
  local code1
  code1=$(extract_text "$response1")
  echo '```cpp' >> "$RESULTS_FILE"
  echo "$code1" >> "$RESULTS_FILE"
  echo '```' >> "$RESULTS_FILE"
  echo "" >> "$RESULTS_FILE"
  
  # Task 2: 代码审查
  echo "**Task 2: 代码审查**" >> "$RESULTS_FILE"
  local response2
  response2=$(curl -s -X POST "$url" \
    -H "$auth_header" \
    -H "Content-Type: application/json" \
    -H "anthropic-version: 2023-06-01" \
    -d "{\"model\":\"$model\",\"max_tokens\":800,\"messages\":[{\"role\":\"user\",\"content\":\"找出以下代码中的并发安全问题（至少 3 个）：std::queue<int> sharedQueue; void producer() { for (int i = 0; i < 100; i++) { if (sharedQueue.size() < 100) { sharedQueue.push(i); } } } void consumer() { while (true) { if (!sharedQueue.empty()) { int val = sharedQueue.front(); sharedQueue.pop(); } } }\"}]}")
  
  echo "$response2" > "$model_dir/task2_raw.json"
  
  local code2
  code2=$(extract_text "$response2")
  echo "$code2" >> "$RESULTS_FILE"
  echo "" >> "$RESULTS_FILE"
  
  # Task 3: CUDA 调试
  echo "**Task 3: CUDA 调试**" >> "$RESULTS_FILE"
  local response3
  response3=$(curl -s -X POST "$url" \
    -H "$auth_header" \
    -H "Content-Type: application/json" \
    -H "anthropic-version: 2023-06-01" \
    -d "{\"model\":\"$model\",\"max_tokens\":800,\"messages\":[{\"role\":\"user\",\"content\":\"CUDA kernel 启动后返回 cudaErrorInvalidConfiguration，列出 5 个最常见原因和排查顺序。\"}]}")
  
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

# 文本提取函数（处理不同 API 格式和 Unicode 转义）
extract_text() {
  local json="$1"
  
  # 尝试多种格式
  local text
  
  # 格式 1: Bailian/Anthropic - content 数组中的 text 字段
  text=$(echo "$json" | grep -o '"text":"[^"]*"' | head -1 | cut -d'"' -f4)
  
  # 格式 2: MiniMax - content 数组（可能为空）
  if [ -z "$text" ]; then
    text=$(echo "$json" | python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())
    content = data.get('content', [])
    if isinstance(content, list):
        for item in content:
            if isinstance(item, dict) and item.get('type') == 'text':
                print(item.get('text', ''))
                break
    elif isinstance(content, str):
        print(content)
except: pass
" 2>/dev/null)
  fi
  
  # 格式 3: 直接 message 字段
  if [ -z "$text" ]; then
    text=$(echo "$json" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
  fi
  
  # 解码 Unicode 转义
  if [ -n "$text" ]; then
    text=$(echo "$text" | python3 -c "
import sys
text = sys.stdin.read()
# 处理 Unicode 转义
text = text.replace('\\\\u003c', '<').replace('\\\\u003e', '>').replace('\\\\u0026', '&')
text = text.replace('\\\\n', '\n').replace('\\\\t', '\t')
text = text.replace('\\\\\"', '\"').replace('\\\\\\\\', '\\\\')
print(text)
" 2>/dev/null || echo "$text")
  fi
  
  # 如果还是空，返回错误信息
  if [ -z "$text" ]; then
    text="[⚠️ 无法解析响应 - 查看原始 JSON 文件]"
    echo "$json" | head -c 500
  fi
  
  echo "$text"
}

# ============================================================================
# 开始测试 - 所有 11 个模型
# ============================================================================

echo "============================================"
echo "代码质量基准测试 - 11 个模型"
echo "结果保存到：$RESULTS_FILE"
echo "原始 JSON: $JSON_DIR/"
echo "============================================"
echo ""

# Bailian 平台 (8 个)
echo "【Bailian 平台 - 8 个模型】"
#test_code_quality "qwen3.5-plus" "$BAILIAN_URL" "bearer" "$BAILIAN_KEY" "qwen3.5-plus" "qwen3-5-plus"
#test_code_quality "qwen3-max-2026-01-23" "$BAILIAN_URL" "bearer" "$BAILIAN_KEY" "qwen3-max-2026-01-23" "qwen3-max"
#test_code_quality "qwen3-coder-plus" "$BAILIAN_URL" "bearer" "$BAILIAN_KEY" "qwen3-coder-plus" "qwen3-coder-plus"
#test_code_quality "qwen3-coder-next" "$BAILIAN_URL" "bearer" "$BAILIAN_KEY" "qwen3-coder-next" "qwen3-coder-next"
#test_code_quality "MiniMax-M2.5" "$BAILIAN_URL" "bearer" "$BAILIAN_KEY" "MiniMax-M2.5" "minimax-m2-5"
#test_code_quality "glm-5" "$BAILIAN_URL" "bearer" "$BAILIAN_KEY" "glm-5" "glm-5"
#test_code_quality "glm-4.7" "$BAILIAN_URL" "bearer" "$BAILIAN_KEY" "glm-4.7" "glm-4-7"
#test_code_quality "kimi-k2.5" "$BAILIAN_URL" "bearer" "$BAILIAN_KEY" "kimi-k2.5" "kimi-k2-5"

# Kimi-Code 直连 (2 个)
echo ""
echo "【Kimi-Code 直连 - 2 个模型】"
#test_code_quality "kimi-for-coding (无 thinking)" "$KIMI_CODE_URL" "x-api-key" "$KIMI_CODE_KEY" "kimi-for-coding" "kimi-coding"
#test_code_quality "kimi-for-coding-thinking" "$KIMI_CODE_URL" "x-api-key" "$KIMI_CODE_KEY" "kimi-for-coding-thinking" "kimi-coding-thinking"

# MiniMax 直连 (1 个)
echo ""
echo "【MiniMax 直连 - 1 个模型】"
test_code_quality "MiniMax-M2.7 (直连)" "$MINIMAX_URL" "x-api-key" "$MINIMAX_KEY" "MiniMax-M2.7" "minimax-m2-7-direct"

# ============================================================================
# 完成
# ============================================================================

echo ""
echo "============================================"
echo "✅ 代码质量测试完成！"
echo "============================================"
echo ""
echo "📄 Markdown 报告：$RESULTS_FILE"
echo "📁 原始 JSON 数据：$JSON_DIR/"
echo ""
echo "💡 提示：使用以下命令查看报告："
echo "   cat $RESULTS_FILE | less"
echo "   或打开 Markdown 文件查看"
echo "============================================"
