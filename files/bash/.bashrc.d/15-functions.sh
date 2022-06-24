{% if (global["os"] == "linux") %}
open() {
    if [ ! -z "$DISPLAY" ]; then
        xdg-open "$@"
    else
        if [ "$(echo "$1" | grep "://" )" != "" ]; then
            "$BROWSER" "$@"
        else
            "$EDITOR" "$@"
        fi
    fi
}
{% endif %}

if [ ! -z "$PS1" ]; then
    if command -v git &> /dev/null; then
        export _ORIG_GIT="/usr/bin/git"
        git() {
            if [ -z "$1" ]; then
                $_ORIG_GIT st
            else
                $_ORIG_GIT "$@"
            fi
        }
        alias g="git"
    fi

    if command -v tmux &> /dev/null; then
        tmx() {
            if [ -z "$1" ]; then
                tmux new -A -s "$(basename "$PWD")"
            else
                tmux new -A -s "$1"
            fi
        }
        alias t="tmx"
        alias screen="tmx"
    fi
fi
