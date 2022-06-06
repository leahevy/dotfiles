

if command -v pyenv &> /dev/null
    status is-login; and pyenv init --path | source
    status is-interactive; and pyenv init - | source
    alias python python3
end

if command -v rbenv &> /dev/null
    status --is-interactive; and rbenv init - fish | source
end

if command -v git &> /dev/null
    function g
        if not set -q argv[1]
            git status
        else
            git $argv
        end
    end
end

alias nv="nvim -p"
alias nvim="nvim -p"

if status is-interactive
    # Commands to run in interactive sessions can go here
end