#!/bin/bash
set -euo pipefail

echo "==> Building bat theme cache..."

if command -v bat &>/dev/null; then
    bat cache --build
elif command -v batcat &>/dev/null; then
    batcat cache --build
fi

echo "==> bat cache built."
