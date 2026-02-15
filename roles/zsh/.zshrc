# Vi mode
set -o vi

# Load modules
for file in ~/.zsh/*.zsh(N); do
    source "$file"
done

eval "$(starship init zsh)"
