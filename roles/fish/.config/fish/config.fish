# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
end

zoxide init fish | source
starship init fish | source

# opencode
fish_add_path /home/lucho/.opencode/bin

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

function rbw-fzf
    if not type -q rbw
        echo "rbw not installed"
        return 1
    end
    if not type -q fzf
        echo "fzf not installed"
        return 1
    end
    if not type -q wl-copy
        echo "wl-copy not installed"
        return 1
    end

    rbw unlocked >/dev/null 2>&1; or rbw unlock; or return 1

    set -l item (rbw list | fzf --prompt='rbw> ' --height=40% --reverse)
    test -n "$item"; or return 0

    rbw get "$item" | wl-copy
    echo "Copied password for: $item"
end
