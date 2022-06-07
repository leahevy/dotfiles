set fish_greeting ""

if command -v pyenv &> /dev/null
    status is-login; and pyenv init --path | source
    status is-interactive; and pyenv init - | source
    alias python python3
end

if command -v rbenv &> /dev/null
    status --is-interactive; and rbenv init - fish | source
end
