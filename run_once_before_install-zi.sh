#!/bin/bash
set -euo pipefail

echo "==> Installing zi (zsh plugin manager)..."

ZI_HOME="${HOME}/.zi"
if [[ ! -d "$ZI_HOME/bin" ]]; then
    mkdir -p "$ZI_HOME"
    git clone https://github.com/z-shell/zi.git "${ZI_HOME}/bin"
fi

# Set zsh as default shell if it isn't already
if [[ "$SHELL" != */zsh ]]; then
    echo "==> Setting zsh as default shell..."
    ZSH_PATH=$(which zsh)
    # Ensure zsh is in /etc/shells
    grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
    sudo chsh -s "$ZSH_PATH" "$(whoami)"
fi

echo "==> zi installation complete."
