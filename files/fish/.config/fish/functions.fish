function _virtualenv-find_activate_rec
    set -l actfile "$argv[1]/.venv/bin/activate.fish"
    if test -e "$actfile"
        echo "$actfile"
        return
    end

    set -l newdir "$(dirname "$argv[1]")"

    if [ "$newdir" = "/" ]
        return
    else
        _virtualenv-find_activate_rec "$newdir"
    end
end

function _virtualenv-find_activate
    _virtualenv-find_activate_rec "$PWD"
end

function virtualenv-activate
    set -l actfile "$(_virtualenv-find_activate)"
    if [ "$actfile" != "" ]
        set -gx VENV "$actfile"
        set_color green
        echo "++ Activate Python virtualenv ++"
        set_color normal
        source "$actfile" || true
    else
        set_color red
        echo "++ .venv directory not found. Try 'virtualenv-create' ++" >&2
        set_color normal
    end
end

function virtualenv-deactivate
	if [ "$VENV" != "" ]
        set_color red
        echo "++ Deactivate Python virtualenv ++"
        set_color normal
        set -gx VENV ""
        deactivate 2>/dev/null >/dev/null || true
    end
end

function _virtualenv-on_pwd
    set -l actfile "$(_virtualenv-find_activate)"
    if [ "$actfile" != "" ]
        if [ "$actfile" != "$VENV" ]
            virtualenv-activate
        end
    else
        if [ "$VENV" != "" ]
            virtualenv-deactivate
        end
    end
end

function __virtualenv-activate --on-variable PWD
  status --is-command-substitution; and return
    _virtualenv-on_pwd
end

function virtualenv-create
    if test -d "./.venv"
        set_color red
        echo "++ .venv directory already exists ++" >&2
        set_color normal
    else
	    python -m venv .venv
    end
end

if status is-interactive
    virtualenv-activate 2>/dev/null >/dev/null
end