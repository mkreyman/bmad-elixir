#!/bin/bash
# Post-merge hook - check for migration changes

echo "🔍 Checking for changes after merge..."

# Check if migrations changed
if git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD | grep -q "priv/repo/migrations"; then
    echo ""
    echo "⚠️  Database migrations changed!"
    echo "📝 Remember to run: MIX_ENV=test mix ecto.migrate"
    echo ""
fi

# Check if mix.lock changed
if git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD | grep -q "mix.lock"; then
    echo ""
    echo "📦 Dependencies changed (mix.lock updated)"
    echo "💡 Consider running: mix deps.get"
    echo ""
fi

exit 0
