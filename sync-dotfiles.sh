#!/bin/bash
set -e

DOTFILES_URL="https://github.com/julienprodhon/dotfiles/archive/main.tar.gz"
CONFIG_DIR="${HOME}/.config"
PRESERVE_DIRS=(
  "niri/dms"
)
BACKUP_DIR=$(mktemp -d)
EXTRACT_DIR=$(mktemp -d)

echo "=== Syncing Dotfiles ==="

# Backup preserved directories
trap "rm -rf $BACKUP_DIR $EXTRACT_DIR" EXIT
for preserve in "${PRESERVE_DIRS[@]}"; do
  if [[ -d "$CONFIG_DIR/$preserve" ]]; then
    mkdir -p "$BACKUP_DIR/$preserve"
    cp -r "$CONFIG_DIR/$preserve"/* "$BACKUP_DIR/$preserve/" 2>/dev/null || true
    echo "Preserving $preserve/..."
  fi
done

# Stream and extract tarball
echo "Downloading dotfiles..."
curl -sL "$DOTFILES_URL" | tar xz -C "$EXTRACT_DIR" --strip-components=1

# Sync config directories
echo "Syncing config directories..."
if [[ -d "$EXTRACT_DIR/config" ]]; then
  mkdir -p "$CONFIG_DIR"
  for dir in "$EXTRACT_DIR/config"/*; do
    [[ -d "$dir" ]] || continue
    dir_name=$(basename "$dir")
    echo "  $dir_name"
    rm -rf "$CONFIG_DIR/$dir_name"
    cp -r "$dir" "$CONFIG_DIR/"
  done
fi

# Restore preserved directories
for preserve in "${PRESERVE_DIRS[@]}"; do
  if [[ -d "$BACKUP_DIR/$preserve" ]]; then
    mkdir -p "$CONFIG_DIR/$preserve"
    cp -r "$BACKUP_DIR/$preserve"/* "$CONFIG_DIR/$preserve/" 2>/dev/null || true
    echo "Restored $preserve/"
  fi
done

# Sync dotfiles to home directory
echo "Syncing home dotfiles..."
for dotfile in .bashrc .zshrc .profile; do
  if [[ -f "$EXTRACT_DIR/$dotfile" ]]; then
    echo "  $dotfile"
    cp -f "$EXTRACT_DIR/$dotfile" ~/
  fi
done

echo ""
echo "Done!"
