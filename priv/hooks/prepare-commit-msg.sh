#!/bin/bash
# Prepare-commit-msg hook to remind about attribution policy

COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2

# Only add reminder when using editor (no COMMIT_SOURCE means editor was used)
# Don't add for: -m (message), -F (file), -c (reuse), etc.
if [ -z "$COMMIT_SOURCE" ]; then
    # Add reminder as comments at the top of the commit message template
    cat > "$COMMIT_MSG_FILE.new" << 'EOF'

# ⚠️  IMPORTANT REMINDER FOR CODING AGENTS ⚠️
#
# DO NOT include Claude Code attribution in commit messages!
#
# ❌ FORBIDDEN - Remove these if auto-generated:
#    - 🤖 Generated with [Claude Code](https://claude.com/claude-code)
#    - Co-Authored-By: Claude <noreply@anthropic.com>
#
# The commit-msg hook will REJECT commits with these attributions.
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 📝 COMMIT MESSAGE GUIDELINES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# FORMAT:
#   <type>: <subject>
#
#   <body>
#
# SUBJECT LINE:
#   ✓ Use imperative mood ("Add feature" not "Added feature")
#   ✓ Start with type prefix: feat:, fix:, refactor:, docs:, test:, chore:
#   ✓ Keep under 72 characters
#   ✓ Don't end with a period
#   ✓ Capitalize first letter after colon
#
# BODY:
#   ✓ Use imperative mood ("Change" not "Changed", "Fix" not "Fixed")
#   ✓ Explain WHAT and WHY, not just HOW
#   ✓ Wrap lines at 72 characters
#   ✓ Separate paragraphs with blank lines
#   ✓ Include context: What problem does this solve?
#   ✓ Reference issue numbers if applicable
#
# EXAMPLES:
#   feat: Add webhook retry mechanism for failed deliveries
#
#   Implement exponential backoff retry logic to handle transient
#   webhook delivery failures. This prevents data loss when downstream
#   services are temporarily unavailable.
#
#   - Add retry queue with exponential backoff (1s, 2s, 4s, 8s, 16s)
#   - Store failed attempts in webhook_audit_log
#   - Add max retry limit of 5 attempts
#
#   Resolves production issue where webhook failures caused data loss.
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
    cat "$COMMIT_MSG_FILE" >> "$COMMIT_MSG_FILE.new"
    mv "$COMMIT_MSG_FILE.new" "$COMMIT_MSG_FILE"
fi

exit 0
