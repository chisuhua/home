#!/bin/bash
# 全局 clangd 初始化脚本
# 用途：在任何 C++ 项目中生成 compile_commands.json 并触发 clangd 索引

set -e

PROJECT_ROOT="${1:-$(pwd)}"
cd "$PROJECT_ROOT"

echo "=========================================="
echo "clangd 索引初始化"
echo "项目：$PROJECT_ROOT"
echo "=========================================="
echo ""

# 1. 检查 clangd
if ! command -v clangd &> /dev/null; then
    echo "❌ clangd 未安装!"
    echo "   请运行：sudo apt install clangd-18"
    exit 1
fi
echo "✅ clangd: $(clangd --version | head -1)"

# 2. 设置环境 (如果存在 env.sh)
if [ -f "env.sh" ]; then
    echo "设置环境..."
    . env.sh
fi

# 3. 生成 compile_commands.json
if [ -f "CMakeLists.txt" ]; then
    echo "生成 compile_commands.json..."
    cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON > /dev/null 2>&1
    if [ -f "build/compile_commands.json" ]; then
        ln -sf build/compile_commands.json .
        echo "✅ compile_commands.json: $(readlink -f compile_commands.json)"
    fi
fi

# 4. 触发索引
LARGE_FILE=$(find . -maxdepth 3 \( -name "*.cpp" -o -name "*.cu" -o -name "*.cc" \) -type f | head -1)
if [ -n "$LARGE_FILE" ]; then
    echo "触发索引 (通过 $LARGE_FILE)..."
    cat "$LARGE_FILE" > /dev/null
    echo "✅ clangd 索引已触发"
fi

# 5. 状态
echo ""
if pgrep -x clangd > /dev/null; then
    echo "clangd 运行中 (PID: $(pgrep -x clangd | head -1))"
else
    echo "clangd 将在首次打开文件时启动"
fi

echo ""
echo "完成!"
