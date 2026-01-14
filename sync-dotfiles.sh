#!/bin/bash
set -e

DOTFILES_REPO="https://github.com/yourusername/dotfiles.git"
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
if [[ -d "$DOTFILES_DIR/config" ]]; then
  mkdir -p "$CONFIG_DIR"
  for dir in "$DOTFILES_DIR/config"/*; do
    [[ -d "$dir" ]] || continue
    dir_name=$(basename "$dir")
    echo "Syncing $dir_name..."
    rm -rf "$CONFIG_DIR/$dir_name"
    cp -r "$dir" "$CONFIG_DIR/"
  done
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
echo "Updating .zshrc with plugin configuration..."
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

echo ""
echo "✓ Dotfiles synced successfully!"
echo "Dotfiles cloned to: $DOTFILES_DIR"
