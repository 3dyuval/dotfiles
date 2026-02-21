#!/bin/bash
# Yazi opener script - open file in new kitty window with prepopulated prompt

FILE="$1"
FILENAME="$(basename "$FILE")"
DIRNAME="$(dirname "$FILE")"

kitten @ launch --type=window --cwd="$DIRNAME" zsh -c "
source ~/.zshrc
print -z '$FILENAME'
exec zsh
"