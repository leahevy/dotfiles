export PAGER="less"
export EDITOR="nvim -p"
export VISUAL="nvim -p"

{% if (global["os"] == "osx") %}
export BROWSER="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
{% else %}
export BROWSER="chrome"
{% endif %}

alias nv="nvim -p"
alias nvim="nvim -p"
alias vim="nvim -p"
alias vi="nvim -p"
alias n="neovide --frame None"

alias vimrc="nvim -p ~/.config/nvim"
alias neovimrc="nvim -p ~/.config/nvim"

alias g="git"

alias l="ls --color=auto"
alias ls="ls -hF --color=auto"
alias ll="ls -l --color=auto"
alias lr="ls -R --color=auto"
alias la="ls -a --color=auto"
alias lla="ls -la --color=auto"

alias p="pwd"
alias pd="pwd"

alias c="clear"

alias h="history"

alias rm='rm -I'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'
alias chown='chown'
alias chmod='chmod'
alias chgrp='chgrp'

alias mkdir='mkdir -pv'
alias h='history'
alias j='jobs -l'

alias ping='ping -c 3'

alias du='du -kh'
alias df='df -kh'
alias free='free -h'

alias more="less"

alias home='cd ~; ls'
alias root='cd /; ls'
alias db='cd ~/Dropbox; ls'

alias o="open"

alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
