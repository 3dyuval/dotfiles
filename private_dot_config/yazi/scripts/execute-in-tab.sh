#!/bin/bash
# Execute shell script in new kitty tab, or in adjacent window
# Usage: execute-in-tab.sh <file> [direction]
# Direction: l=left, r=right, u=up, d=down (omit for new tab)

FILE="$1"
DIRECTION="$2"
FILENAME="$(basename "$FILE")"
DIRNAME="$(dirname "$FILE")"

if [[ -n "$DIRECTION" ]]; then
    # Send file path to adjacent window
    ~/.config/kitty/smart_window_send.sh "$FILE" "$DIRECTION"
else
    # Execute in new tab (original behavior)
    kitten @ launch --type=tab --cwd="$DIRNAME" zsh -c "
source ~/.zshrc
echo \"Executing: $FILENAME\"
chmod +x \"$FILE\"
\"$FILE\"
echo \"Script finished. Press Enter to continue...\"
read
exec zsh
"
fi
