#!/bin/bash
# Navigation functions with yazi and zoxide
# Dependencies: yazi, zoxide, fzf

# Yazi with cd on exit
y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r cwd <"$tmp"
  [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# Zoxide action helper (yazi or nvim)
_zoxide_action() {
  local action="$1"
  shift
  local dir

  if [[ $# -eq 0 ]]; then
    dir=$(zoxide query -l | fzf --height=40% --reverse)
  else
    dir=$(zoxide query "$@")
  fi

  [[ -z "$dir" ]] && return

  case "$action" in
  yazi)
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$dir" --cwd-file="$tmp"
    IFS= read -r cwd <"$tmp"
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
    ;;
  nvim)
    cd "$dir" && nvim .
    ;;
  esac
}

yz() {
  echo "Oops. Did you mean zy?"
  return 1
}
# Yazi + zoxide
zy() { _zoxide_action yazi "$@"; }

# Nvim + zoxide
znv() { _zoxide_action nvim "$@"; }

cdg() {
  cd $(gitdir) || echo "no git dir found "$(type gitdir)"" && return 1
}
