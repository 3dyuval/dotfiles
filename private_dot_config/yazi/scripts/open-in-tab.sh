#!/bin/bash
# Yazi opener script - open file in new kitty tab with prepopulated prompt

FILE="$1"
FILENAME="$(basename "$FILE")"
DIRNAME="$(dirname "$FILE")"

kitten @ launch --type=tab --cwd="$DIRNAME" zsh -c "
source ~/.zshrc
print -z '$FILENAME'
exec zsh
"