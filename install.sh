#!/bin/bash
set -euo pipefail

if [[ ! -e "$HOME/.dotfiles" ]]; then
    ln -s "$(pwd)" "$HOME/.dotfiles"
fi

PYTHON_VERSION=3.10.3
RUBY_VERSION=3.1.2

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

echo "mydotfiles install script"
echo

OS="`uname`"

case $OS in
    'Darwin')
        OS="osx"
        ;;
    'Linux')
        OS="linux"
        ;;
esac

echo "Found operating system $OS"
echo "Starting installation"
echo

case $OS in
    'linux')
        if ! command -v apt-get &> /dev/null; then
            echo "Linux found, however, only works in Debian based systems for now."
            exit 2
        fi
        install() {
            echo "Installing $@"
            if [ "$(dpkg --list | grep "$1 ")" = "" ]; then
                DEBIAN_FRONTEND=noninteractive sudo apt-get install -qq "$@"
                echo
            fi
        }
        finalize() {
            echo "Cleaning up packages"
            DEBIAN_FRONTEND=noninteractive sudo apt-get -qq autoremove
            echo
        }
        DEBIAN_FRONTEND=noninteractive sudo apt-get update
        DEBIAN_FRONTEND=noninteractive sudo apt-get -qq upgrade
        ;;
    'osx') 
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
        echo "Install only works on Linux and MacOS"
        exit 1
        ;;
esac

linux_packages=(
    coreutils
    moreutils
    findutils
    bash
    wget
    gnupg
    grep
    screen
    ack
    git
    git-lfs
    gs
    python3
    htop
    fish
    ruby
    fontconfig
    openssl
    openvpn
    readline
    sqlite3
    npm
    curl
    subversion
    bash-completion
    vim
    texlive
    docker
    emacs
    make
    openssh-client
    build-essential
    libssl-dev
    zlib1g-dev
    libbz2-dev
    libreadline-dev
    libsqlite3-dev
    wget
    curl
    llvm
    libncurses5-dev
    xz-utils
    tk-dev
    libxml2-dev
    libxmlsec1-dev
    libffi-dev
    liblzma-dev
)

# Only run if we are on Linux desktop (not server or Mac)
if dpkg -l 2>/dev/null | grep xserver-xorg-core >/dev/null 2>&1; then
    linux_packages+=(
        firefox
    )
fi

echo "Passwords might be requested during the installation"
echo

if [ "$OS" == "osx" ]; then
	brew bundle
elif [ "$OS" == "linux" ]; then
    for package in "${linux_packages[@]}"; do
        package_array=($package)
        install "${package_array[@]}"
    done
fi

finalize

if [ "$OS" == "osx" ]; then
    "$SCRIPTPATH/macos.sh"
fi

echo "Everything done"