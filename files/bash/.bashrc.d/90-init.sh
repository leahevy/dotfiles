# If interactive shell
if [ ! -z "$PS1" ]; then
    :
fi

# Always
if test "$(umask)" = "0000"; then
    umask 027
fi
