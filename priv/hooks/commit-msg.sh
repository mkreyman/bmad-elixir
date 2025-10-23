#!/bin/bash
# Commit message hook to block Claude Code attributions

COMMIT_MSG_FILE=$1

# Check for Claude Code attributions in commit message (ignore comment lines starting with #)
if grep -v '^#' "$COMMIT_MSG_FILE" | grep -q "Co-Authored-By: Claude" || \
   grep -v '^#' "$COMMIT_MSG_FILE" | grep -q "Generated with.*Claude Code"; then
    echo "❌ Commit message contains Claude Code attribution!"
    echo "Please remove the following lines from your commit message:"
    echo "  - 🤖 Generated with [Claude Code](https://claude.com/claude-code)"
    echo "  - Co-Authored-By: Claude <noreply@anthropic.com>"
    exit 1
fi

exit 0
