#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$SCRIPT_DIR}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.config-backups/$(date +%Y%m%d-%H%M%S)}"
INSTALL_PACKAGES=1
LINK_CONFIGS=1

log() {
  printf "\033[1;34m==>\033[0m %s\n" "$1"
}

warn() {
  printf "\033[1;33mwarning:\033[0m %s\n" "$1"
}

die() {
  printf "\033[1;31merror:\033[0m %s\n" "$1" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: ./install.sh [--link-only] [--packages-only] [--help]

Install terminal tooling and link configs from this dotfiles repo.

Options:
  --link-only      Only create config symlinks.
  --packages-only  Only install packages and helper tools.
  --help           Show this help message.
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --link-only)
        INSTALL_PACKAGES=0
        ;;
      --packages-only)
        LINK_CONFIGS=0
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        die "Unknown option: $1"
        ;;
    esac
    shift
  done
}

require_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    die "This installer currently targets macOS."
  fi
}

ensure_xcode_tools() {
  if ! xcode-select -p >/dev/null 2>&1; then
    log "Installing Xcode Command Line Tools"
    xcode-select --install
    die "Rerun this installer after Xcode Command Line Tools finish installing."
  fi
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  command -v brew >/dev/null 2>&1 || die "Homebrew was installed but brew is not on PATH."
}

brew_install_if_missing() {
  local formula="$1"
  if brew list --formula "$formula" >/dev/null 2>&1; then
    log "$formula is already installed"
  else
    log "Installing $formula"
    brew install "$formula"
  fi
}

brew_install_cask_if_missing() {
  local cask="$1"
  if brew list --cask "$cask" >/dev/null 2>&1; then
    log "$cask is already installed"
  else
    log "Installing $cask"
    brew install --cask "$cask"
  fi
}

backup_path() {
  local path="$1"

  if [[ ! -e "$path" && ! -L "$path" ]]; then
    return
  fi

  mkdir -p "$BACKUP_DIR"
  local backup_target="$BACKUP_DIR/${path#$HOME/}"
  mkdir -p "$(dirname "$backup_target")"
  mv "$path" "$backup_target"
  warn "Moved existing $path to $backup_target"
}

link_path() {
  local source="$1"
  local target="$2"

  [[ -e "$source" || -L "$source" ]] || die "Expected source does not exist: $source"

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    log "$target already links to $source"
    return
  fi

  backup_path "$target"
  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  log "Linked $target -> $source"
}

install_im_select() {
  if [[ -x /usr/local/bin/im-select ]]; then
    log "im-select is already installed"
    return
  fi

  log "Installing im-select"
  if [[ "$(uname -m)" == "arm64" ]]; then
    curl -Ls -o /tmp/im-select https://raw.githubusercontent.com/daipeihust/im-select/master/macOS/out/apple/im-select
  else
    curl -Ls -o /tmp/im-select https://raw.githubusercontent.com/daipeihust/im-select/master/macOS/out/intel/im-select
  fi
  chmod +x /tmp/im-select
  sudo mv /tmp/im-select /usr/local/bin/im-select
}

install_tpm() {
  if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    log "TPM is already installed"
  else
    log "Installing TPM"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
}

install_catppuccin_tmux() {
  if [[ -d "$HOME/.tmux/plugins/tmux" ]]; then
    log "catppuccin/tmux is already installed"
  else
    log "Installing catppuccin/tmux"
    git clone https://github.com/catppuccin/tmux.git ~/.tmux/plugins/tmux
  fi
}

install_packages() {
  ensure_homebrew
  brew update
  brew_install_cask_if_missing ghostty
  brew_install_if_missing git
  brew_install_if_missing tmux
  brew_install_if_missing neovim
  brew_install_if_missing fd
  brew_install_if_missing imagemagick
  install_im_select
  install_tpm
  install_catppuccin_tmux
  brew_install_cask_if_missing font-hack-nerd-font
  brew_install_cask_if_missing font-sarasa-gothic
}

install_configs() {
  link_path "$DOTFILES_DIR/ghostty/config.ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
  link_path "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
  link_path "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
}

main() {
  parse_args "$@"
  require_macos

  if [[ "$INSTALL_PACKAGES" -eq 1 ]]; then
    ensure_xcode_tools
    install_packages
  fi

  if [[ "$LINK_CONFIGS" -eq 1 ]]; then
    install_configs
  fi

  log "Setup complete"
  log "Run nvim to let LazyVim install plugins."
}

main "$@"
