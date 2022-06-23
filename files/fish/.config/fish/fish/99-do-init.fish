function _fish_do_always_init
    if status is-interactive
        _fish_always_interactive_init
    else
        _fish_always_noninteractive_init
    end
end

function _fish_do_global_init
    _fish_global_init
    if status is-interactive
        _fish_global_interactive_init
    else
        _fish_global_noninteractive_init
    end
end

function _fish_do_local_init
    _fish_local_init
    if status is-interactive
        _fish_local_interactive_init
    else
        _fish_local_noninteractive_init
    end
end

if [ "$FISH_INITIALISED" != "true" ]
    if ! test -e /tmp/fish_initialised_global
        _fish_do_global_init
        touch /tmp/fish_initialised_global
    end
    _fish_do_local_init
end
_fish_do_always_init

set -x FISH_INITIALISED "true"
