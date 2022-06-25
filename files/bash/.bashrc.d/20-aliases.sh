alias nv="nvim"
alias nvim="nvim"
alias vim="nvim"
alias vi="nvim"
alias n="neovide --frame None"

alias browser="$BROWSER -o"

alias vimrc="nvim -p ~/.config/nvim"
alias neovimrc="nvim -p ~/.config/nvim"

alias g="git"
alias ga="git addp"
alias gl="git l"

alias x="lsd --group-dirs=first"
alias l="lsd --group-dirs=first"
alias ls="lsd -hF --group-dirs=first"
alias ll="lsd -l --header --group-dirs=first"
alias lr="lsd -R --group-dirs=first"
alias la="lsd -a --group-dirs=first"
alias lla="lsd -la --header --group-dirs=first"
alias tree="lsd --header --group-dirs=first --tree"

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
alias cat="bat -p"

alias home='z ~; lsd -l --header --group-dirs=first'
alias root='z /; lsd -l --header --group-dirs=first'

{% if private['dirs']['cloud'] %}
alias db='z {{ private['dirs']['cloud'] }}; lsd -l --header --group-dirs=first'
alias cloud='z {{ private['dirs']['cloud'] }}; lsd -l --header --group-dirs=first'
{% endif %}

{% if private['dirs']['src'] %}
alias src='z {{ private['dirs']['src'] }}; lsd -l --header --group-dirs=first'
{% endif %}

{% if private['dirs']['projects'] %}
alias prjs='z {{ private['dirs']['projects'] }}; lsd -l --header --group-dirs=first'
alias projects='z {{ private['dirs']['projects'] }}; lsd -l --header --group-dirs=first'
{% endif %}

{% if private['dirs']['website'] %}
alias website='z {{ private['dirs']['website'] }}; lsd -l --header --group-dirs=first'
alias blog='z {{ private['dirs']['website'] }}; lsd -l --header --group-dirs=first'
{% endif %}

alias dotfiles='z ~/.dotfiles; lsd -l --header --group-dirs=first'
alias dotf='z ~/.dotfiles; lsd -l --header --group-dirs=first'

alias dotfiles-private='z ~/.dotfiles-private; lsd -l --header --group-dirs=first'
alias dotfp='z ~/.dotfiles-private; lsd -l --header --group-dirs=first'

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

alias dir='z "$(xplr --print-pwd-as-result)"'
alias list='z "$(xplr --print-pwd-as-result)"'
alias xcd='z "$(xplr --print-pwd-as-result)"'
alias d='z "$(xplr --print-pwd-as-result)"'

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
