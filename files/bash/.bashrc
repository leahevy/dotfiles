# Source all files in bashrc.d directory
for file in $(ls "$HOME/.bashrc.d"); do
    source "$HOME/.bashrc.d/$file"
done
