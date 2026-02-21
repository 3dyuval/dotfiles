#!/bin/bash
set -euo pipefail

echo "==> Loading zi plugins (first run)..."

# Source only zi and run update, skip full .zshrc to avoid hangs
if command -v zsh &>/dev/null && [[ -f "$HOME/.zi/bin/zi.zsh" ]]; then
    timeout 120 zsh -c '
        typeset -A ZI
        ZI[BIN_DIR]="${HOME}/.zi/bin"
        source "${ZI[BIN_DIR]}/zi.zsh"
        zi update --all --quiet
    ' 2>/dev/null || true
fi

echo "==> zi plugins loaded."
