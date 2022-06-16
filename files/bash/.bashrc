export PAGER="less"
export EDITOR="nvim"
export VISUAL="nvim"

{% if (global["os"] == "osx") %}
export BROWSER="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
{% else %}
export BROWSER="chrome"
{% endif %}

alias nv="nvim"
alias nvim="nvim"
alias vim="nvim"
alias vi="nvim"
alias n="neovide --frame None"

alias vimrc="nvim -p ~/.config/nvim"
alias neovimrc="nvim -p ~/.config/nvim"

alias g="git"
alias ga="git addp"

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

{% if (global["os"] == "osx") %}
export HOMEBREW_PATH="/opt/homebrew/bin"
export HOMEBREW_X86_PATH="/usr/local/homebrew/bin"
export HOMEBREW_SBIN_PATH="/opt/homebrew/sbin"
export HOMEBREW_X86_SBIN_PATH="/usr/local/homebrew/sbin"
alias brew="arch -arm64 $HOMEBREW_PATH/brew"
alias brewARM="arch -arm64 $HOMEBREW_PATH/brew"
alias brew86="arch -x86_64 $HOMEBREW_X86_PATH/brew"
{% else %}
export HOMEBREW_PATH="/home/linuxbrew/.linuxbrew/bin"
export HOMEBREW_SBIN_PATH="/home/linuxbrew/.linuxbrew/sbin"
alias brew="$HOMEBREW_PATH/brew"
{% endif %}


export PATH="$HOME/bin:$HOME/dev:/usr/local/bin:$HOMEBREW_PATH:$HOMEBREW_SBIN_PATH:$HOMEBREW_X86_PATH:$HOMEBREW_X86_SBIN_PATH:$PATH"
