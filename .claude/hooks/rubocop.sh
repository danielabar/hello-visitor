#!/bin/bash
FILE=$(python3 -c "import sys,json; print(json.load(sys.stdin)['tool_input']['file_path'])" 2>/dev/null) || exit 0
[[ "$FILE" == *.rb ]] || exit 0

OUTPUT=$(bin/rubocop --format simple "$FILE" 2>&1)
[ $? -eq 0 ] && exit 0

python3 -c "import sys,json; print(json.dumps({'hookSpecificOutput':{'hookEventName':'PostToolUse','additionalContext':sys.argv[1]}}))" "$OUTPUT"
exit 2
