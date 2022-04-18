#!/bin/bash
set -euo pipefail

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
            if [ "$(dpkg --list | grep "$1")" = "" ; then
                sudo apt-get install "$@"
                echo
            fi
        }
        finalize() {
            echo "Cleaning up packages"
            sudo apt-get autoremove
            echo
        }
        sudo apt-get update
        sudo apt-get upgrade
        ;;
    'osx') 
        install() {
            echo "Installing $@"
            if ! brew list "$1" >/dev/null 2>&1; then
                brew install "$@"
                echo
            fi
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
    svn
    coreutils
    moreutils
    findutils
    bash
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
    rbenv
    ruby-build
    fontconfig
    openssl
    openvpn
    readline
    sqlite3
    xz
    zlib
)

linux_packages=(
    bash-completion
    vim
    texlive
    docker
    emacs
)

osx_packages=(
    font-source-code-pro
    bash-completion@2
    iterm2
    gnu-sed
    homebrew/cask/macvim
    mactex
    homebrew/cask/docker
    homebrew/cask/emacs
    homebrew/cask/firefox
    homebrew/cask/spotify
    homebrew/cask/discord
    homebrew/cask/skype
    homebrew/cask/gimp
    homebrew/cask/vlc
    homebrew/cask/visual-studio-code
    homebrew/cask/balenaetcher
    homebrew/cask/whatsapp
    homebrew/cask/the-unarchiver
    homebrew/cask/telegram
    homebrew/cask/teamspeak-client
    homebrew/cask/steam
    homebrew/cask/battle-net
    homebrew/cask/slack
    homebrew/cask/microsoft-teams
    homebrew/cask/microsoft-remote-desktop
    homebrew/cask/messenger
    homebrew/cask/webex-meetings
    homebrew/cask/adobe-acrobat-reader
    homebrew/cask/1password
    homebrew/cask/google-drive
    homebrew/cask/alfred
)

# Only run if we are on Linux desktop (not server or Mac)
if dpkg -l 2>/dev/null | grep xserver-xorg-core >/dev/null 2>&1; then
    linux_packages+=(
        firefox
    )
fi

echo "Passwords might be requested during the installation"
echo

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

echo "Check shells"
FISH_CMD="$(whereis -b fish | cut -f 2 -d : | xargs)"
if [ "$FISH_CMD" != "" ]; then
    if [ "$(cat /etc/shells | grep "$FISH_CMD")" = "" ]; then
        echo "Configure fish as login shell"
        echo "Set shell to fish"
        echo "$FISH_CMD" | sudo tee -a /etc/shells
        chsh -s "$FISH_CMD"
    fi
fi

if [ ! -d "$HOME/.local/share/omf" ]; then
    echo "Install Oh My Fish"
    curl -L https://get.oh-my.fish | fish
fi

echo "Check Python installation"
if ! pyenv versions | grep "$PYTHON_VERSION" >/dev/null 2>&1; then
    echo "Install Python$PYTHON_VERSION with pyenv"
    pyenv install "$PYTHON_VERSION"
    pyenv global "$PYTHON_VERSION"
    echo
fi

echo "Check Ruby installation"
if ! rbenv versions | grep "$RUBY_VERSION" >/dev/null 2>&1; then
    echo "Install Ruby$RUBY_VERSION with rbenv"
    rbenv install "$RUBY_VERSION"
    rbenv global "$RUBY_VERSION"
    echo
fi

finalize

if [ "$OS" == "osx" ]; then
    "$SCRIPTPATH/macos.sh"
fi

echo "Everything done"