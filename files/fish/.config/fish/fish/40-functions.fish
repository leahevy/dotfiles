function fish-reload
    clear
    for file in $(ls "$HOME/.config/fish/fish")
        source "$HOME/.config/fish/fish/$file"
    end
end