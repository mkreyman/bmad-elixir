#!/bin/bash
# Post-checkout hook - check for migration changes when switching branches

PREV_COMMIT=$1
NEW_COMMIT=$2
BRANCH_CHECKOUT=$3

# Only run on branch checkout (not file checkout)
if [ "$BRANCH_CHECKOUT" = "1" ]; then
    echo "🔍 Checking for changes after branch switch..."

    # Check if migrations changed
    if git diff --name-only $PREV_COMMIT $NEW_COMMIT | grep -q "priv/repo/migrations"; then
        echo ""
        echo "⚠️  Database migrations changed!"
        echo "📝 Remember to run: MIX_ENV=test mix ecto.migrate"
        echo ""
    fi

    # Check if mix.lock changed
    if git diff --name-only $PREV_COMMIT $NEW_COMMIT | grep -q "mix.lock"; then
        echo ""
        echo "📦 Dependencies changed (mix.lock updated)"
        echo "💡 Consider running: mix deps.get"
        echo ""
    fi
fi

exit 0
