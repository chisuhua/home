#!/bin/bash
# init-session.sh - Initialize planning files for a new session

PROJECT_DIR="${1:-$(pwd)}"
TEMPLATES_DIR="$(dirname "$0")/../templates"

echo "Initializing planning files in: $PROJECT_DIR"

# Check if templates exist
if [ ! -d "$TEMPLATES_DIR" ]; then
    echo "Error: Templates directory not found: $TEMPLATES_DIR"
    exit 1
fi

# Copy template files
for file in task_plan.md findings.md progress.md; do
    if [ -f "$PROJECT_DIR/$file" ]; then
        echo "Warning: $file already exists. Creating backup..."
        cp "$PROJECT_DIR/$file" "$PROJECT_DIR/${file}.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    
    cp "$TEMPLATES_DIR/$file" "$PROJECT_DIR/$file"
    echo "Created: $PROJECT_DIR/$file"
done

echo ""
echo "Planning files initialized successfully!"
echo "Next steps:"
echo "1. Edit task_plan.md to define your goal and phases"
echo "2. Update findings.md as you discover information"
echo "3. Log progress in progress.md throughout the session"
