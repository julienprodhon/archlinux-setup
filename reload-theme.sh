#!/bin/bash
# Reload apps after DMS theme change
# DMS auto-reloads: Ghostty, Neovim, GTK, Niri

# Tmux - reload config if server is running
if tmux list-sessions &>/dev/null; then
  tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null && echo "Tmux reloaded"
fi
