#!/bin/bash
set -e

DOTFILES_URL="https://github.com/julienprodhon/dotfiles/archive/main.tar.gz"
CONFIG_DIR="${HOME}/.config"
PRESERVE_DIRS=("dms")
EXTRACT_DIR=$(mktemp -d)

trap "rm -rf $EXTRACT_DIR" EXIT

echo "=== Syncing Dotfiles ==="

# Download and extract
echo "Downloading dotfiles..."
curl -sL "$DOTFILES_URL" | tar xz -C "$EXTRACT_DIR" --strip-components=1

# Build exclude flags
EXCLUDE_FLAGS=("${PRESERVE_DIRS[@]/#/--exclude=}")

# Sync config directories
echo "Syncing config directories..."
[[ -d "$EXTRACT_DIR/config" ]] && 
  find "$EXTRACT_DIR/config" -mindepth 1 -maxdepth 1 -type d -printf '%f\0' |
  xargs -0 -I {} rsync -a --delete "${EXCLUDE_FLAGS[@]}" "$EXTRACT_DIR/config/{}" "$CONFIG_DIR/"

# Sync home dotfiles
echo "Syncing home dotfiles..."
rsync -a "$EXTRACT_DIR/.zshrc" ~/ 2>/dev/null || true

echo "Done!"
