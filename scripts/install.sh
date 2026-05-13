#!/usr/bin/env bash

set -euo pipefail

# Repo root = parent of scripts/
HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

chmod +x "$HARNESS_DIR/bin/ai-harness"

LINE="export PATH=\"$HARNESS_DIR/bin:\$PATH\""
SHELL_NAME="$(basename "${SHELL:-}")"

case "$SHELL_NAME" in
  bash)
    PROFILE="$HOME/.bashrc"
    ;;
  zsh|"")
    PROFILE="$HOME/.zshrc"
    ;;
  *)
    PROFILE="$HOME/.profile"
    ;;
esac

touch "$PROFILE"

if ! grep -Fxq "$LINE" "$PROFILE"; then
  echo "" >> "$PROFILE"
  echo "# AI Dev Harness" >> "$PROFILE"
  echo "$LINE" >> "$PROFILE"
fi

echo "AI Harness installed globally."
echo ""
echo "Now run:"
echo "source \"$PROFILE\""
echo ""
echo "Then test with:"
echo "ai-harness doctor"