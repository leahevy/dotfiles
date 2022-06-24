alias nv="nvim"
alias nvim="nvim"
alias vim="nvim"
alias vi="nvim"
alias n="neovide --frame None"

alias vimrc="nvim -p ~/.config/nvim"
alias neovimrc="nvim -p ~/.config/nvim"

alias g="git"
alias ga="git addp"
alias gl="git l"

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
alias src='cd ~/Source/github.com/leahevy; ls'
alias blog='cd ~/Source/github.com/leahevy/leahevy.github.io; ls'
alias dotfiles='cd ~/.dotfiles; ls'
alias dotf='cd ~/.dotfiles; ls'
alias dotfiles-private='cd ~/.dotfiles-private; ls'
alias dotfp='cd ~/.dotfiles-private; ls'

{% if (global["os"] == "osx") %}
alias o="open"
{% else %}
alias o="xdg-open"
alias open="xdg-open"
{% endif %}

alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"

alias cmatrix="cmatrix -s -r"
alias matrix="cmatrix -s -r"
alias m="cmatrix -s -r"
alias screensaver="cmatrix -s -r"
alias ss="cmatrix -s -r"

{% if (global["os"] == "osx") %}
alias brew="arch -arm64 $HOMEBREW_PATH/brew"
alias brewARM="arch -arm64 $HOMEBREW_PATH/brew"
alias brew86="arch -x86_64 $HOMEBREW_X86_PATH/brew"
{% else %}
alias brew="$HOMEBREW_PATH/brew"
{% endif %}