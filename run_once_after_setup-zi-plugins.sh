#!/bin/bash
set -euo pipefail

echo "==> Loading zi plugins (first run)..."

# Source zshrc in a non-interactive zsh to trigger plugin downloads
# zi plugins are lazy-loaded, so we need to give them a moment
if command -v zsh &>/dev/null && [[ -f "$HOME/.zi/bin/zi.zsh" ]]; then
    zsh -ic 'zi update --all --quiet; exit' 2>/dev/null || true
fi

echo "==> zi plugins loaded."
