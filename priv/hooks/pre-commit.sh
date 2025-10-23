#!/bin/bash
# Pre-commit hook to enforce quality checks

# Check if being bypassed (limited effectiveness but adds friction)
if [ -n "$GIT_COMMIT_NO_VERIFY" ]; then
    echo "❌ ERROR: Pre-commit bypass detected"
    echo "Bypassing pre-commit hooks is not allowed"
    echo "Please fix the issues instead of bypassing checks"
    exit 1
fi

echo "🔍 Running pre-commit quality checks..."
echo "================================================"

# Source asdf to ensure mix is available
if [ -f "/usr/local/opt/asdf/libexec/asdf.sh" ]; then
  source /usr/local/opt/asdf/libexec/asdf.sh
elif [ -f "$HOME/.asdf/asdf.sh" ]; then
  source "$HOME/.asdf/asdf.sh"
fi

cd "$(git rev-parse --show-toplevel)"

# Capture list of staged files before running precommit
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

if ! mix precommit; then
    echo "❌ Pre-commit checks FAILED!"
    exit 1
fi

# Re-stage files that were modified by mix format (or other precommit tasks)
UNSTAGED_FILES=$(git diff --name-only)
MODIFIED_STAGED_FILES=""

for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        # Check if this staged file now has unstaged changes (use grep -F for literal matching)
        if echo "$UNSTAGED_FILES" | grep -Fxq "$file"; then
            MODIFIED_STAGED_FILES="$MODIFIED_STAGED_FILES $file"
        fi
    fi
done

# Automatically re-add formatted files
if [ -n "$MODIFIED_STAGED_FILES" ]; then
    echo ""
    echo "📝 Re-staging files modified by mix format:"
    echo "$MODIFIED_STAGED_FILES" | tr ' ' '\n' | grep -v '^$'
    git add $MODIFIED_STAGED_FILES
    echo "✅ Formatted files have been re-staged"
fi

echo "✅ All pre-commit checks passed!"
exit 0
