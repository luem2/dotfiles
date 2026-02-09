#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO_URL="https://github.com/luem2/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
INSTALL_PATH="$HOME/.local/bin/dotfiles"

if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
  BOLD="$(tput bold)"
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  RESET="$(tput sgr0)"
else
  BOLD=""
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  RESET=""
fi

ICON_INFO="*"
ICON_OK="+"
ICON_WARN="!"
ICON_ERROR="x"

log_info() { printf "%b\n" "${BLUE}${ICON_INFO}${RESET} ${BLUE}[INFO]${RESET} $*"; }
log_ok() { printf "%b\n" "${GREEN}${ICON_OK}${RESET} ${GREEN}[OK]${RESET} $*"; }
log_warn() { printf "%b\n" "${YELLOW}${ICON_WARN}${RESET} ${YELLOW}[WARN]${RESET} $*"; }
log_error() { printf "%b\n" "${RED}${ICON_ERROR}${RESET} ${RED}[ERROR]${RESET} $*"; }
die() { log_error "$*"; exit 1; }

require_sudo() {
  if ! sudo -v; then
    die "sudo authentication failed. Aborting."
  fi
}

ensure_dnf() {
  if ! command -v dnf >/dev/null 2>&1; then
    die "dnf not found. This setup is Fedora-only."
  fi
}

ensure_git() {
  if ! command -v git >/dev/null 2>&1; then
    log_info "Installing git"
    sudo dnf install -y git
  fi
}

ensure_repo() {
  if [ -d "$DOTFILES_DIR/.git" ]; then
    log_info "Updating dotfiles repo"
    git -C "$DOTFILES_DIR" pull --quiet --ff-only
  else
    log_info "Cloning dotfiles repo"
    git clone --quiet "$DOTFILES_REPO_URL" "$DOTFILES_DIR"
  fi
}

install_dotfiles_binary() {
  mkdir -p "$(dirname "$INSTALL_PATH")"
  install -m 0755 "$DOTFILES_DIR/bin/dotfiles" "$INSTALL_PATH"
  log_ok "Installed dotfiles to $INSTALL_PATH"
}

main() {
  log_info "Bootstrapping dotfiles"
  require_sudo
  ensure_dnf
  ensure_git
  ensure_repo
  install_dotfiles_binary
  log_ok "Running dotfiles"
  exec "$INSTALL_PATH"
}

main "$@"
