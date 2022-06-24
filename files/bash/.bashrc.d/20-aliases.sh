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

alias x="lsd"
alias l="lsd"
alias ls="lsd -hF"
alias ll="lsd -l"
alias lr="lsd -R"
alias la="lsd -a"
alias lla="lsd -la"

alias p="pwd"
alias pd="pwd"

alias cl="clear"

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

alias df='df -kh'
alias free='free -h'

alias more="bat"
alias less="bat"
alias cat="bat"

alias c="z"

alias home='z ~; lsd -l'
alias root='z /; lsd -l'
alias db='z ~/Dropbox; lsd -l'
alias src='z ~/Source/github.com/leahevy; lsd -l'
alias blog='z ~/Source/github.com/leahevy/leahevy.github.io; lsd -l'
alias dotfiles='z ~/.dotfiles; lsd -l'
alias dotf='z ~/.dotfiles; lsd -l'
alias dotfiles-private='z ~/.dotfiles-private; lsd -l'
alias dotfp='z ~/.dotfiles-private; lsd -l'

alias o="open"

alias grep="rg"
alias egrep="rg"
alias fgrep="rg"

alias find="fd"

alias du="dust"
alias ctime="hyperfine"

alias cloc="tokei"

alias top="btm"
alias htop="btm"

alias dir='cd "$(xplr --print-pwd-as-result)"'
alias list='cd "$(xplr --print-pwd-as-result)"'
alias xcd='cd "$(xplr --print-pwd-as-result)"'

alias ps="procs"

alias cmatrix="cmatrix -s -r"
alias matrix="cmatrix -s -r"
alias m="cmatrix -s -r"
alias screensaver="cmatrix -s -r"
alias ss="cmatrix -s -r"

alias python="python3"

{% if (global["os"] == "osx") %}
alias brew="arch -arm64 $HOMEBREW_PATH/brew"
alias brewARM="arch -arm64 $HOMEBREW_PATH/brew"
alias brew86="arch -x86_64 $HOMEBREW_X86_PATH/brew"
{% else %}
alias brew="$HOMEBREW_PATH/brew"
{% endif %}
