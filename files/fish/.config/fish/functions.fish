function pyenv-activate
    source "$HOME/.pyenv/versions/$argv[1]/bin/activate.fish"
end

function virtualenv-activate
    set in_venv "$(pyenv virtualenvs 2>/dev/null | cut -f 1 -d "(" | grep -v "/" | grep -v "*" | grep "$(echo "$PWD/" | tr "/" "#" | tr " " "-" )" | head -n 1 | xargs)"
    if test "$in_venv" != ""
        pyenv-activate "$in_venv"
        set -gx VENV "$in_venv"
    else if test "$VENV" != ""
        pyenv deactivate 2>&1 >/dev/null
        set -gx VENV ""
    end
end

if status is-interactive
    virtualenv-activate 2>&1 >/dev/null
end

function __virtualenv-activate --on-variable PWD
  status --is-command-substitution; and return
    virtualenv-activate 2>&1 >/dev/null
end

function virtualenv-init
    if test "$VENV" != ""
        pyenv deactivate 2>&1 >/dev/null
    end
    set -gx VENV "$(echo "$PWD" | tr "/" "#" | tr " " "-" )#"
    pyenv virtualenv "$VENV"
    pyenv-activate "$VENV"
end