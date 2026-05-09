#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

HOME_DIR="$TMP_DIR/home"
DOTFILES_FIXTURE="$TMP_DIR/dotfiles"
BACKUP_DIR="$TMP_DIR/backups"

mkdir -p "$HOME_DIR" "$DOTFILES_FIXTURE/ghostty" "$DOTFILES_FIXTURE/tmux" "$DOTFILES_FIXTURE/nvim"
touch "$DOTFILES_FIXTURE/ghostty/config.ghostty"
touch "$DOTFILES_FIXTURE/tmux/.tmux.conf"
touch "$DOTFILES_FIXTURE/nvim/init.lua"

HOME="$HOME_DIR" \
DOTFILES_DIR="$DOTFILES_FIXTURE" \
BACKUP_DIR="$BACKUP_DIR" \
"$REPO_DIR/install.sh" --link-only

assert_link() {
  local target="$1"
  local expected="$2"

  if [[ ! -L "$target" ]]; then
    printf 'expected %s to be a symlink\n' "$target" >&2
    exit 1
  fi

  local actual
  actual="$(readlink "$target")"
  if [[ "$actual" != "$expected" ]]; then
    printf 'expected %s -> %s, got %s\n' "$target" "$expected" "$actual" >&2
    exit 1
  fi
}

assert_link "$HOME_DIR/Library/Application Support/com.mitchellh.ghostty/config.ghostty" "$DOTFILES_FIXTURE/ghostty/config.ghostty"
assert_link "$HOME_DIR/.tmux.conf" "$DOTFILES_FIXTURE/tmux/.tmux.conf"
assert_link "$HOME_DIR/.config/nvim" "$DOTFILES_FIXTURE/nvim"
