#!/bin/bash

# Smart window navigation that tries to wrap to other kitty instances
# Usage: smart_focus.sh [left|right|up|down]

direction="${1:-right}"

# First try to move within current kitty instance
if kitty @ focus-window --match "neighbor:$direction" 2>/dev/null; then
    exit 0
fi

# If that failed, we're at the edge - try to find other kitty instances
# Get all kitty windows using wmctrl
kitty_windows=$(wmctrl -l | grep -i kitty | wc -l)

if [ "$kitty_windows" -gt 1 ]; then
    # There are other kitty windows, cycle to the next one
    wmctrl -a kitty
else
    # No other kitty instances, maybe open a new one?
    # Or just do nothing (stay at current position)
    echo "No other kitty instances found"
fi