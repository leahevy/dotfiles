function fish-reload
    rm -rf /tmp/fishcache
    clear
    for file in $(ls "$HOME/.config/fish/fish")
        source "$HOME/.config/fish/fish/$file"
    end
end