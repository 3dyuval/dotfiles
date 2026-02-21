#!/bin/bash
# Git functions and aliases
# Dependencies: git, gum (optional for interactive)

# Aliases
alias g='git'
alias gla='git pull --autostash'
alias glz='lazygit'
alias gloz='lazygit log'

# Interactive branch checkout with gum
gbc() {
  git branch --format='%(refname:short)' --sort=-committerdate | gum choose | xargs git checkout
}

# Clone repo to temp directory and cd into it
git-clone-temp() {
  local tmp
  tmp=$(mktemp -d)
  git clone "$1" "$tmp" && cd "$tmp"
}

# Pull updates for config repos with changes
update_configs() {
  local repos=("$OMARCHY_PATH" "$HOME/.config/nvim")
  local changed=()
  local r

  for r in "${repos[@]}"; do
    [[ -n $(git -C "$r" status --short) ]] && changed+=("$r")
  done

  [[ ${#changed[@]} -eq 0 ]] && {
    echo "No changes"
    return
  }

  local selects
  mapfile -t selects < <(printf '%s\n' "${changed[@]}" | gum choose --no-limit)

  for r in "${selects[@]}"; do
    git -C "$r" pull --autostash
  done
}

gitdir() {
  echo $(dirname $(git rev-parse --git-dir))
}
