# Global init
# -----------
function _fish_global_init
    if test "$(umask)" = "0000"
        umask 027
    end
end

function _fish_global_noninteractive_init
end

function _fish_global_interactive_init
    if command -v neofetch &> /dev/null
        neofetch 2>/dev/null || true
    end
end

# Local init
# ----------
function _fish_local_init
end

function _fish_local_noninteractive_init
end

function _fish_local_interactive_init
    fish_vi_key_bindings
end

# Always init
# -----------
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

    if command -v pyenv &> /dev/null
        alias python python3
    end

    virtualenv-activate 2>/dev/null >/dev/null
end
