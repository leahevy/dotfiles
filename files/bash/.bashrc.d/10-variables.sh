export PAGER="bat"
export EDITOR="nvim"
export VISUAL="nvim"

{% if (global["os"] == "osx") %}
export BROWSER="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
{% else %}
export BROWSER="chrome"
{% endif %}

{% if (global["os"] == "osx") %}
export HOMEBREW_PATH="/opt/homebrew/bin"
export HOMEBREW_X86_PATH="/usr/local/homebrew/bin"
export HOMEBREW_SBIN_PATH="/opt/homebrew/sbin"
export HOMEBREW_X86_SBIN_PATH="/usr/local/homebrew/sbin"
{% else %}
export HOMEBREW_PATH="/home/linuxbrew/.linuxbrew/bin"
export HOMEBREW_SBIN_PATH="/home/linuxbrew/.linuxbrew/sbin"
{% endif %}

{% if (global["os"] == "osx") %}
export PATH="$HOME/bin:$HOME/dev:/usr/local/bin:$HOMEBREW_PATH:$HOMEBREW_SBIN_PATH:$HOMEBREW_X86_PATH:$HOMEBREW_X86_SBIN_PATH:$PATH"
{% else %}
export PATH="$HOME/bin:$HOME/dev:/usr/local/bin:$HOMEBREW_PATH:$HOMEBREW_SBIN_PATH:$PATH"
{% endif %}

export GCC_VERSION="gcc-11"
export CC="$($HOMEBREW_PATH/brew --prefix gcc)/bin/$GCC_VERSION"
export CFLAGS="-O2"
