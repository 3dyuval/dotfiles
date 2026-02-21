#!/bin/zsh

# Smart window operations for kitty + hyprland
# Usage:
#   smart_window_send "text" [direction] [return_focus]
#   smart_window_send -v "text" [direction]  # verbose/debug mode
#
# Direction: l=left, r=right, u=up, d=down (default: l)

# Verbose mode
VERBOSE=false
if [[ "$1" == "-v" ]]; then
  VERBOSE=true
  shift
  echo "[VERBOSE MODE ON]"
fi

_log() {
  [[ "$VERBOSE" == "true" ]] && echo "[DEBUG] $*" >&2
}

_map_direction() {
  case "$1" in
    l) echo "left" ;; r) echo "right" ;;
    u) echo "top" ;; d) echo "bottom" ;;
    *) echo "left" ;;
  esac
}

_has_kitty_neighbor() {
  local DIR="$1"
  local KDIR=$(_map_direction "$DIR")
  _log "Checking kitty neighbor: $KDIR"

  local result=$(kitty @ ls 2>/dev/null | jq -r ".[].tabs[].windows[] | select(.is_active) | .neighbors.$KDIR // empty")
  _log "Neighbor result: '$result'"

  [[ -n "$result" ]]
}

_get_hypr_address() {
  local addr=$(hyprctl activewindow -j | jq -r '.address')
  _log "Current hypr address: $addr"
  echo "$addr"
}

_get_active_class() {
  local class=$(hyprctl activewindow -j | jq -r '.class')
  _log "Active window class: $class"
  echo "$class"
}

smart_window_send() {
  local TEXT="$1"
  local DIR="${2:-l}"
  local RETURN_FOCUS="${3:-true}"
  local KDIR=$(_map_direction "$DIR")

  _log "=== smart_window_send ==="
  _log "Text: '$TEXT'"
  _log "Direction: $DIR ($KDIR)"
  _log "Return focus: $RETURN_FOCUS"

  # LEVEL 1: Try kitty pane (fast path)
  _log "--- Level 1: Checking kitty panes ---"
  if _has_kitty_neighbor "$DIR"; then
    _log "Found kitty neighbor, sending via kitty @"
    # kitty @ send-text --match "neighbor:$KDIR" --dont-take-focus "$TEXT"
    kitty @ send-text --match "neighbor:$KDIR" "$TEXT"
    _log "Done (kitty pane)"
    return 0
  fi

  # LEVEL 2: Hyprland windows
  _log "--- Level 2: Falling back to hyprland ---"

  local SAVED_ADDR=$(_get_hypr_address)

  _log "Switching focus: hyprctl dispatch movefocus $DIR"
  hyprctl dispatch movefocus "$DIR"
  sleep 0.05

  local TARGET_CLASS=$(_get_active_class)
  _log "Target is $TARGET_CLASS, using clipboard paste"

  # For hyprland windows, always use clipboard (kitty @ only works within same instance)
  local OLD_CLIP=$(wl-paste 2>/dev/null)
  echo -n "$TEXT" | wl-copy
  sleep 0.05
  if [[ "$TARGET_CLASS" == "kitty" ]]; then
    wtype -M ctrl -M shift -k v -m shift -m ctrl  # Ctrl+Shift+V for kitty
  else
    wtype -M ctrl -k v -m ctrl  # Ctrl+V for others
  fi
  sleep 0.05
  [[ -n "$OLD_CLIP" ]] && echo -n "$OLD_CLIP" | wl-copy

  if [[ "$RETURN_FOCUS" == "true" ]]; then
    _log "Returning focus to: $SAVED_ADDR"
    sleep 0.1
    hyprctl dispatch focuswindow "address:$SAVED_ADDR"
  fi

  _log "Done (hyprland)"
}

smart_window_send_and_focus() {
  smart_window_send "$1" "${2:-l}" "false"
}

# CLI when run directly (zsh uses $ZSH_EVAL_CONTEXT)
if [[ -n "$ZSH_EVAL_CONTEXT" && "$ZSH_EVAL_CONTEXT" =~ :file$ ]]; then
  : # sourced in zsh
elif [[ -n "$BASH_SOURCE" && "$BASH_SOURCE" != "$0" ]]; then
  : # sourced in bash
else
  _log "[RUNNING DIRECTLY with args: $@]"
  smart_window_send "$@"
fi
