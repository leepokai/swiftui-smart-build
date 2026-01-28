#!/bin/bash

# PostToolUse hook: Auto-check Swift files after Edit/Write
# Quick checks only - full type checking via xcodebuild

DEBUG_LOG="/tmp/swift-lint-check-debug.log"

# Read JSON input from stdin
INPUT_JSON=$(cat)

echo "========== $(date) ==========" >> "$DEBUG_LOG"

# Parse JSON
TOOL_NAME=$(echo "$INPUT_JSON" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT_JSON" | jq -r '.tool_input.file_path // empty')

echo "TOOL_NAME: $TOOL_NAME" >> "$DEBUG_LOG"
echo "FILE_PATH: $FILE_PATH" >> "$DEBUG_LOG"

# Only process Edit or Write tools
if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
    exit 0
fi

# Only process .swift files
if [[ "$FILE_PATH" != *.swift ]]; then
    exit 0
fi

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

HAS_ISSUES=false
OUTPUT=""

# ============================================================
# 1. Syntax check (fast, ~0.1s)
# ============================================================
SYNTAX_OK=true
PARSE_OUTPUT=$(swiftc -parse "$FILE_PATH" 2>&1)
if [ $? -ne 0 ] && [ -n "$PARSE_OUTPUT" ]; then
    SYNTAX_OK=false
    HAS_ISSUES=true
    OUTPUT="$OUTPUT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ Syntax errors in: $(basename "$FILE_PATH")
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$PARSE_OUTPUT"
fi

# ============================================================
# 2. SwiftFormat auto-fix (only if syntax is OK)
# ============================================================
if [ "$SYNTAX_OK" = true ] && command -v swiftformat &> /dev/null; then
    # Run swiftformat to auto-fix (not just lint)
    FORMAT_OUTPUT=$(swiftformat "$FILE_PATH" 2>&1)

    # Check if file was actually changed
    if echo "$FORMAT_OUTPUT" | grep -q "1/1 files formatted"; then
        OUTPUT="$OUTPUT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ Auto-formatted: $(basename "$FILE_PATH")
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        HAS_ISSUES=true  # Not really an issue, but we want to notify
    fi
fi

# ============================================================
# Output results
# ============================================================
if [ "$HAS_ISSUES" = true ]; then
    echo "HAS_ISSUES=true, outputting..." >> "$DEBUG_LOG"
    echo "$OUTPUT" >> "$DEBUG_LOG"

    # Escape the output for JSON
    ESCAPED_OUTPUT=$(echo "$OUTPUT" | jq -Rs .)

    # Output JSON with additionalContext for Claude
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": $ESCAPED_OUTPUT
  }
}
EOF
else
    echo "No issues found" >> "$DEBUG_LOG"
fi

exit 0
