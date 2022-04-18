#!/bin/bash
set -euo pipefail
echo "mydotfiles install script"
echo

OS="`uname`"
echo "Found operating system $OS"
echo "Starting installation"
echo

case $OS in
    'Linux')
        OS='linux'
        if ! command -v apt-get &> /dev/null; then
            echo "Linux found, however, only works in Debian based systems for now."
            exit 2
        fi
        install() {
            echo "Installing $@"
            sudo apt-get install "$@"
            echo
        }
        ;;
    'Darwin') 
        OS='osx'
        install() {
            echo "Installing $@"
            brew install "$@"
            echo
        }
        if ! command -v brew &> /dev/null; then
            echo "Installing brew"
            sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            echo
        fi
        echo "Updating brew..."
        brew update
        echo
        ;;
    *)
        echo "Install only working on Linux and MacOS"
        exit 1
        ;;
esac

packages=(
    git
    python3
    htop
    docker
    fish
    graphviz
    pyenv-virtualenv
    ruby
    fontconfig
)

osx_packages=(
    iterm2
)

for package in "${packages[@]}"; do
   install "$package"
done

if [ "$OS" == "osx" ]; then
    for package in "${osx_packages[@]}"; do
        install "$package"
    done
fi

echo "Everything done"