

if command -v pyenv &> /dev/null
    status is-login; and pyenv init --path | source
    status is-interactive; and pyenv init - | source
    alias python python3
end

if command -v rbenv &> /dev/null
    status --is-interactive; and rbenv init - fish | source
end

if command -v git &> /dev/null
	set ORIG_GIT /usr/bin/git
    function git
        if not set -q argv[1]
            $ORIG_GIT status
        else
            $ORIG_GIT $argv
        end
    end
	alias g="git"
end

alias nv="nvim -p"
alias nvim="nvim -p"
alias vim="nvim -p"
alias vi="nvim -p"
alias n="neovide --frame None"

if status is-interactive
    # Commands to run in interactive sessions can go here
end