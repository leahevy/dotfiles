alias nv="nvim"
alias nvim="nvim"
alias vim="nvim"
alias vi="nvim"
alias n="neovide --frame None"

alias browser="$BROWSER -o"

alias cdvimrc="cd ~/.config/nvim"
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

alias home='cd ~'
alias root='cd /'

{% if private['dirs']['cloud'] %}
alias db='cd "{{ private['dirs']['cloud'] }}"'
alias cloud='cd "{{ private['dirs']['cloud'] }}"'
{% endif %}

{% if private['dirs']['src'] %}
alias src='cd "{{ private['dirs']['src'] }}"'
{% endif %}

{% if private['dirs']['projects'] %}
alias prjs='cd "{{ private['dirs']['projects'] }}"'
alias projects='cd "{{ private['dirs']['projects'] }}"'
{% endif %}

{% if private['dirs']['website'] %}
alias website='cd "{{ private['dirs']['website'] }}"'
alias blog='cd "{{ private['dirs']['website'] }}"'
{% endif %}

alias dotfiles='cd ~/.dotfiles'
alias dotf='cd ~/.dotfiles'

alias dotfiles-private='cd ~/.dotfiles-private'
alias dotfp='cd ~/.dotfiles-private'

alias o="open"

alias grep="rg"
alias egrep="rg"
alias fgrep="rg"

alias find="fd"

alias du="dust"
alias ctime="hyperfine"

alias cloc="tokei"

alias top="htop"
alias bottom="btm"

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

alias fzf='fzf --preview "cat {1}"'
alias vimfzf='vim "$(fzf --multi --preview "cat {1}")"'

alias python="python3"

{% if (global["os"] == "osx") %}
alias brew='arch -arm64 $HOMEBREW_PATH/brew'
alias brewARM='arch -arm64 $HOMEBREW_PATH/brew'
alias brew86='arch -x86_64 $HOMEBREW_X86_PATH/brew'
{% else %}
alias brew='$HOMEBREW_PATH/brew'
{% endif %}

alias brew-install='cat $HOME/.brew-packages.cache | fzf --multi --preview "brew info {1}" | xargs -ro brew install'
