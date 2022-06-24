function fish-reload
    fish-reload-noclear
    clear
end

function fish-reload-noclear
    fish-clear-cache
    fish-source
end

function fish-clear-cache
    set_color green
    echo "++ Clear fish cache ++"
    set_color normal
    /bin/rm -rf /tmp/fishcache
end

function fish-source
    set_color green
    echo "++ Reload fish config ++"
    set_color normal
    set -gx _FISH_PRINT_SOURCING "true"
    source "$HOME/.config/fish/config.fish"
    set -gx _FISH_PRINT_SOURCING ""
    set_color green
    echo "++ Done ++"
    set_color normal
end