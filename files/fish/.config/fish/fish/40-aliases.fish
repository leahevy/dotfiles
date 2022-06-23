if status is-interactive
    if command -v git &> /dev/null
        set ORIG_GIT /usr/bin/git
        function git
            if not set -q argv[1]
                $ORIG_GIT st
            else
                $ORIG_GIT $argv
            end
        end
        alias g="git"
    end

    if command -v tmux &> /dev/null
        function tmx
            if not set -q argv[1]
                tmux new -A -s "tmux-$USER"
            else
                tmux $argv
            end
        end
        alias t="tmx"
        alias screen="tmx"
    end
end
