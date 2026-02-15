# Show the current directory folders & files when navigate
function chpwd() {
  emulate -L zsh
  ls
}

# Pick a Bitwarden item with fzf and copy its password to the Wayland clipboard.
function rbw-fzf() {
  if ! command -v rbw >/dev/null 2>&1; then
    echo "rbw not installed"
    return 1
  fi
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not installed"
    return 1
  fi
  if ! command -v wl-copy >/dev/null 2>&1; then
    echo "wl-copy not installed"
    return 1
  fi

  if ! rbw unlocked >/dev/null 2>&1; then
    rbw unlock || return 1
  fi

  local item
  item="$(rbw list | fzf --prompt='rbw> ' --height=40% --reverse)"
  [ -n "$item" ] || return 0

  rbw get "$item" | wl-copy
  echo "Copied password for: $item"
}
