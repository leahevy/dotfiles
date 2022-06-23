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
        set_color green
        echo "++ [ $actfile ] ++"
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
        set_color red
        echo "++ [ $VENV ] ++"
        set_color normal
        set -gx VENV ""
        deactivate 2>/dev/null >/dev/null || true
    end
end

function virtualenv-reload
    set -l actfile "$(_virtualenv-find_activate)"
    if [ "$actfile" != "" ]
        if [ "$actfile" != "$VENV" ]
            virtualenv-activate
        end
    else
        if [ "$VENV" != "" ]
            virtualenv-deactivate
        else
            if [ -e setup.py -o -e setup.cfg -o -e pyproject.toml -o -e requirements.txt -o -e tox.ini ]
                set_color yellow
                echo "++ Python project found but no virtualenv configured ++"
                echo -n "++ You might want to run: "
                set_color blue
                echo -n "'virtualenv-create'"
                set_color yellow
                echo " ++"
                set_color normal
            end
        end
    end
end

function __virtualenv-activate --on-variable PWD
  status --is-command-substitution; and return
    virtualenv-reload
end

function virtualenv-create
    set -l actfile "$(_virtualenv-find_activate)"
    if [ "$actfile" != "" -o "$VENV" != "" ]
        set_color red
        echo "++ Cannot create virtualenv inside virtualenv ++"
        set_color normal
        return 1
    end
    if ! command -v virtualenv &> /dev/null
        pip install virtualenv || return 1
    end
    if test -d "./.venv"
        set_color red
        echo "++ .venv directory already exists ++" >&2
        set_color normal
    else
        if set -q argv[1]
            if ! test -e "$(pyenv root)/versions/$argv[1]/bin/python"
                set_color red
                echo "++ Python version $argv[1] is not installed ++"
                echo "++ Try 'pyenv install $argv[1]' ++"
                set_color normal
                return 1
            end
        end
        set_color green
        echo "++ Create Python virtualenv ++"
        set_color normal
        if not set -q argv[1]
            virtualenv .venv >/dev/null
        else
            virtualenv .venv --python="$(pyenv root)/versions/$argv[1]/bin/python" >/dev/null
        end
        virtualenv-activate
    end
end