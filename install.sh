#!/bin/bash
set -euo pipefail

PYTHON_VERSION=3.10.3

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
        finalize() {
            :
        }
        sudo apt-get update
        sudo apt-get upgrade
        ;;
    'Darwin') 
        OS='osx'
        install() {
            echo "Installing $@"
            brew install "$@"
            echo
        }
        finalize() {
            echo "Cleaning up brew"
            brew cleanup
            echo
        }
        if ! command -v brew &> /dev/null; then
            echo "Installing brew"
            sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            echo
        else
            echo "Updating brew"
            brew update
            echo

            echo "Upgrading packages"
            brew upgrade
            echo
        fi
        ;;
    *)
        echo "Install only working on Linux and MacOS"
        exit 1
        ;;
esac

packages=(
    coreutils
    moreutils
    findutils
    bash
    bash-completion@2
    wget
    gnupg
    grep
    openssh
    screen
    ack
    git
    git-lfs
    gs
    python3
    htop
    fish
    graphviz
    pyenv
    pyenv-virtualenv
    ruby
    fontconfig
    openssl
    readline
    sqlite3
    xz
    zlib
    emacs
)

linux_packages=(
    gvim
    texlive
    docker
)

osx_packages=(
    iterm2
    gnu-sed
    homebrew/cask/macvim
    mactex
    homebrew/cask/docker
)

for package in "${packages[@]}"; do
   package_array=($package)
   install "${package_array[@]}"
done

if [ "$OS" == "osx" ]; then
    for package in "${osx_packages[@]}"; do
        package_array=($package)
        install "${package_array[@]}"
    done
elif [ "$OS" == "linux" ]; then
    for package in "${linux_packages[@]}"; do
        package_array=($package)
        install "${package_array[@]}"
    done
fi

echo "Check Python installation"
if ! pyenv versions | grep "$PYTHON_VERSION" >/dev/null 2>&1; then
    echo "Install Python$PYTHON_VERSION with pyenv"
    pyenv install "$PYTHON_VERSION"
    pyenv global "$PYTHON_VERSION"
fi
echo

finalize

echo "Everything done"