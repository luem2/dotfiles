export VISUAL=zed
export EDITOR=$VISUAL

# Color
export TERM=xterm-256color
export COLORTERM=truecolor

# fnm
export FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --use-on-cd --shell zsh)"
fi
