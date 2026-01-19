#!/bin/bash
set -e

DOTFILES_REPO="https://github.com/julienprodhon/dotfiles.git"
DOTFILES_DIR="${HOME}/dotfiles"
CONFIG_DIR="${HOME}/.config"

echo "=== Syncing Dotfiles ==="

# Clone or update dotfiles repo
if [[ -d "$DOTFILES_DIR" ]]; then
  echo "Updating dotfiles repository..."
  cd "$DOTFILES_DIR"
  git pull
else
  echo "Cloning dotfiles repository..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

echo ""
echo "Syncing config directories..."

# Files to preserve during sync (machine-specific configs)
PRESERVE_FILES=(
  "niri/dms/outputs.kdl"
)

if [[ -d "$DOTFILES_DIR/config" ]]; then
  mkdir -p "$CONFIG_DIR"

  # Backup preserved files
  BACKUP_DIR=$(mktemp -d)
  for preserve in "${PRESERVE_FILES[@]}"; do
    if [[ -f "$CONFIG_DIR/$preserve" ]]; then
      mkdir -p "$BACKUP_DIR/$(dirname "$preserve")"
      cp "$CONFIG_DIR/$preserve" "$BACKUP_DIR/$preserve"
      echo "Preserving $preserve..."
    fi
  done

  for dir in "$DOTFILES_DIR/config"/*; do
    [[ -d "$dir" ]] || continue
    dir_name=$(basename "$dir")
    echo "Syncing $dir_name..."
    rm -rf "$CONFIG_DIR/$dir_name"
    cp -r "$dir" "$CONFIG_DIR/"
  done

  # Restore preserved files
  for preserve in "${PRESERVE_FILES[@]}"; do
    if [[ -f "$BACKUP_DIR/$preserve" ]]; then
      mkdir -p "$CONFIG_DIR/$(dirname "$preserve")"
      cp "$BACKUP_DIR/$preserve" "$CONFIG_DIR/$preserve"
      echo "Restored $preserve"
    fi
  done
  rm -rf "$BACKUP_DIR"
fi

echo ""
echo "Syncing dotfiles to home directory..."
for dotfile in .bashrc .zshrc .profile; do
  if [[ -f "$DOTFILES_DIR/$dotfile" ]]; then
    echo "Syncing $dotfile..."
    cp -f "$DOTFILES_DIR/$dotfile" ~/
  fi
done

echo ""
echo "✓ Dotfiles synced successfully!"
echo "Dotfiles cloned to: $DOTFILES_DIR"
