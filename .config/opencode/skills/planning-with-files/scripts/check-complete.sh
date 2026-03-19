#!/bin/bash
# check-complete.sh - Verify all phases are complete

PROJECT_DIR="${1:-$(pwd)}"
PLAN_FILE="$PROJECT_DIR/task_plan.md"

if [ ! -f "$PLAN_FILE" ]; then
    echo "No task_plan.md found in $PROJECT_DIR"
    exit 0
fi

echo "Checking task plan completion..."
echo ""

# Check for incomplete phases
INCOMPLETE=$(grep -E "^\s*-\s*\[\s*\]" "$PLAN_FILE" | wc -l)

if [ "$INCOMPLETE" -gt 0 ]; then
    echo "⚠️  Found $INCOMPLETE incomplete task(s)"
    echo ""
    echo "Incomplete tasks:"
    grep -E "^\s*-\s*\[\s*\]" "$PLAN_FILE" | head -10
    echo ""
    echo "Please complete remaining tasks or update the plan."
    exit 1
else
    echo "✅ All tasks marked complete!"
    echo ""
    
    # Check for errors section
    if grep -q "Errors Encountered" "$PLAN_FILE"; then
        ERRORS=$(grep -A 100 "Errors Encountered" "$PLAN_FILE" | grep -E "^\|" | wc -l)
        if [ "$ERRORS" -gt 1 ]; then
            echo "📝 Note: $((ERRORS-1)) error(s) were logged. Review resolutions."
        fi
    fi
    
    exit 0
fi
