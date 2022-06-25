# Global init (once on first shell
#   initialisation after boot)
# --------------------------------
function _fish_global_init
end

function _fish_global_noninteractive_init
end

function _fish_global_interactive_init
    if command -v neofetch &> /dev/null
        neofetch 2>/dev/null || true
    end
end

# Local init (First initialisation of each shell instance.
#   Not executed when reloading fish configuration)
# --------------------------------------------------------
function _fish_local_init
end

function _fish_local_noninteractive_init
end

function _fish_local_interactive_init
    fish_vi_key_bindings
end

# Always init (on each fish configuration reload)
# -----------------------------------------------
function _fish_always_init
    if command -v pyenv &> /dev/null
        status is-login; and pyenv init --path | source
        status is-interactive; and pyenv init - | source
    end
    
    if command -v rbenv &> /dev/null
        set -gx GEM_HOME "$HOME/.gems"
        status --is-interactive; and rbenv init - fish | source
    end
end

function _fish_always_noninteractive_init
end

function _fish_always_interactive_init
    set fish_greeting ""

    zoxide init fish | source
    alias cd="z"
    alias zz="z -"

    virtualenv-activate 2>/dev/null >/dev/null
end
