open() {
{% if (global["os"] == "linux") %}
    export _ORIG_OPEN="xdg-open"
{% else %}
    export _ORIG_OPEN="/usr/bin/open"
{% endif %}
    filetype="$(file -0 "$1" | cut -f2- -d :)"
    if [ "$(echo "$1" | grep ".txt")" != "" ]; then
        echo "  Open in '$EDITOR' ($filetype)"
        "$EDITOR" "$@"
    elif [ "$(echo "$filetype" | grep "text")" != "" ]; then
        echo "  Open in '$EDITOR' ($filetype)"
        "$EDITOR" "$@"
    elif [ "$(echo "$filetype" | grep "JSON data")" != "" ]; then
        echo "  Open in '$EDITOR' ($filetype)"
        "$EDITOR" "$@"
    elif [ "$(echo "$filetype" | grep "empty")" != "" ]; then
        echo "  Open empty file in '$EDITOR'"
        "$EDITOR" "$@"
    else
        echo "  Open in desktop ($_ORIG_OPEN)"
        $_ORIG_OPEN "$@"
    fi
}

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
                tmux -u new -A -s "$(basename "$PWD")"
            else
                tmux -u new -A -s "$1"
            fi
        }
        alias t="tmx"
        alias screen="tmx"
    fi
fi

c() {
    z "$@"
    ll
}
