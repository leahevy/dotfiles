function fish-reload
    /bin/rm -rf /tmp/fishcache
    clear
    for file in $(ls "$HOME/.config/fish/fish")
        source "$HOME/.config/fish/fish/$file"
    end
end

function fish-reload-noclear
    /bin/rm -rf /tmp/fishcache
    for file in $(ls "$HOME/.config/fish/fish")
        source "$HOME/.config/fish/fish/$file"
    end
end