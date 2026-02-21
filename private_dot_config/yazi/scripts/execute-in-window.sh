#!/bin/bash
# Execute shell script in new kitty window

FILE="$1"
FILENAME="$(basename "$FILE")"
DIRNAME="$(dirname "$FILE")"

kitten @ launch --type=window --cwd="$DIRNAME" zsh -c "
source ~/.zshrc
echo \"Executing: $FILENAME\"
chmod +x \"$FILE\"
\"$FILE\"
echo \"Script finished. Press Enter to continue...\"
read
exec zsh
"