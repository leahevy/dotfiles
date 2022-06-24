# Source all files in fish directory
for file in $(ls "$HOME/.config/fish/fish")
    if [ "$_FISH_PRINT_SOURCING" = "true" ]
        set_color yellow
        echo "++ Source '$file' ++"
        set_color normal
    end
    source "$HOME/.config/fish/fish/$file"
end