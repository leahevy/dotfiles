# Source all files in fish directory
for file in $(ls "$HOME/.config/fish/fish")
    source "$HOME/.config/fish/fish/$file"
end