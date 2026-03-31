#!/bin/bash
# sync-arch-to-encoding.sh
# 用途：将提案仓库的定稿文档同步到编码仓库
# 触发：DevMate 手动执行 /zcf:sync-to-encoding

set -e

PROPOSAL_ROOT="/workspace/mynotes/SkillApps/ecommerce/docs/architecture"
ENCODING_ROOT="/workspace/ecommerce/docs/architecture"
SYNC_LIST="/tmp/arch-sync-list.txt"
DRY_RUN=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --list)
            cat "$SYNC_LIST" 2>/dev/null || echo "无同步列表"
            exit 0
            ;;
        *)
            echo "未知参数：$1"
            echo "用法：$0 [--dry-run] [--list]"
            exit 1
            ;;
    esac
done

echo "=== 架构文档同步 ==="
echo "源目录：$PROPOSAL_ROOT"
echo "目标目录：$ENCODING_ROOT"
echo "模式：$([ "$DRY_RUN" = true ] && echo 'DRY-RUN' || echo 'EXECUTE')"
echo ""

# 检查源目录
if [ ! -d "$PROPOSAL_ROOT" ]; then
    echo "❌ 错误：提案仓库目录不存在：$PROPOSAL_ROOT"
    exit 1
fi

# 检查同步列表是否存在，不存在则生成
if [ ! -f "$SYNC_LIST" ]; then
    echo "⚠️  同步列表不存在，生成默认列表..."
    
    # 默认同步所有 .md 文件
    find "$PROPOSAL_ROOT" -name "*.md" -type f > "$SYNC_LIST"
    
    echo "✅ 生成同步列表，共 $(wc -l < "$SYNC_LIST") 个文件"
fi

# 逐文件同步
SYNC_COUNT=0
while IFS= read -r file; do
    if [ ! -f "$file" ]; then
        echo "⚠️  跳过（文件不存在）：$file"
        continue
    fi
    
    rel_path="${file#$PROPOSAL_ROOT/}"
    target_file="$ENCODING_ROOT/$rel_path"
    target_dir="$(dirname "$target_file")"
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] 同步：$rel_path"
        ((SYNC_COUNT++)) || true
        continue
    fi
    
    mkdir -p "$target_dir"
    cp "$file" "$target_file"
    
    echo "✅ 同步：$rel_path"
    ((SYNC_COUNT++)) || true
done < "$SYNC_LIST"

# 生成同步报告
if [ "$DRY_RUN" = false ]; then
    cat > "$ENCODING_ROOT/SYNC-REPORT.md" << EOF
# 架构文档同步报告

**同步时间**: $(date +'%Y-%m-%d %H:%M:%S')
**同步文件数**: $SYNC_COUNT
**源目录**: $PROPOSAL_ROOT
**目标目录**: $ENCODING_ROOT

## 同步文件列表

$(cat "$SYNC_LIST" | sed "s|$PROPOSAL_ROOT/||")

## 源仓库版本

\`\`\`
$(cd "$PROPOSAL_ROOT" && git log -1 --oneline 2>/dev/null || echo "非 Git 仓库")
\`\`\`

## 下一步

1. **验证同步**: 检查目标目录文件是否完整
2. **提交变更**: 
   \`\`\`bash
   cd $ENCODING_ROOT/..
   git add .
   git commit -m "sync: 架构文档更新 $(date +'%Y-%m-%d')"
   \`\`\`
3. **通知编程助手**: @OpenCode 架构文档已更新，请重新读取

---
**执行人**: DevMate
**触发方式**: /zcf:sync-to-encoding
EOF

    echo ""
    echo "✅ 同步完成！"
    echo "📊 同步文件数：$SYNC_COUNT"
    echo "📄 同步报告：$ENCODING_ROOT/SYNC-REPORT.md"
    echo ""
    echo "下一步:"
    echo "  1. 验证同步：ls -la $ENCODING_ROOT/"
    echo "  2. 提交变更：cd /workspace/ecommerce && git add . && git commit -m 'sync: 架构文档更新'"
else
    echo ""
    echo "✅ DRY-RUN 完成！"
    echo "📊 预计同步文件数：$SYNC_COUNT"
    echo ""
    echo "执行真实同步：$0 (不加 --dry-run)"
fi
