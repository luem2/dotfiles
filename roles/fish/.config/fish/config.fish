# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
end

zoxide init fish | source
starship init fish | source

# opencode
fish_add_path "$HOME/.opencode/bin"

alias zed zeditor
alias bat batcat
alias cat bat

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# fnm
if type -q fnm
    fnm env --use-on-cd --shell fish | source
end
