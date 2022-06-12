#!/bin/bash
set -euo pipefail

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
cd "$SCRIPTPATH"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
function echo() {
    printf "${GREEN}>>> ${RED}${@}${NC}\n"
    printf "${GREEN}"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    printf "${NC}"
}

function fatal() {
    printf "${RED}"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    printf "${NC}"
    printf "${RED}!!! ${RED}${@}!${NC}\n" >&2
    exit 1
}

echo "Installing dotfiles ($SCRIPTPATH)"

if ! command -v pip &> /dev/null; then
    fatal "pip not found on system"
fi

echo "Installing mydotfiles Python package locally"
pip install -e .

echo "Linking dotfiles directory (Run 'mydotfiles' afterwards)"
if [[ ! -e "$HOME/.dotfiles" ]]; then
    ln -s "$(pwd)" "$HOME/.dotfiles"
fi

OS="`uname`"

case $OS in
    'Darwin')
        OS="osx"
        ;;
    'Linux')
        OS="linux"
        ;;
    *)
        fatal "Invalid operating system found"
        ;;
esac

echo "Found operating system $OS"

if [ "$OS" == "linux" ]; then
    if ! command -v apt-get &> /dev/null; then
        fatal "Linux found, however, only works in Debian based systems for now."
    fi
fi

if [ "$OS" == "linux" ]; then
    readarray -t linux_packages < linux.packages
    if dpkg -l 2>/dev/null | grep xserver-xorg-core >/dev/null 2>&1; then
        readarray -t linux_desktop_packages < linux-desktop.packages
        linux_packages+=( "${linux_desktop_packages[@]}" )
    fi
fi

if [ "$OS" == "linux" ]; then
    SNAP_AVAILABLE=0
    if systemctl status >/dev/null 2>/dev/null; then
        if snap version >/dev/null 2>/dev/null; then
            SNAP_AVAILABLE=1
        fi
    fi
fi

echo "Starting installation\nPasswords might be requested during the installation"

echo "Check for Homebrew installation"
if ! command -v brew &> /dev/null; then
    echo "Installing brew"
    sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Updating brew packages"
    brew update

    echo "Upgrading brew packages"
    brew upgrade
fi

if [ "$OS" == "linux" ]; then
    echo "Updating linux packages"
    DEBIAN_FRONTEND=noninteractive sudo apt-get update

    echo "Upgrading linux packages"
    DEBIAN_FRONTEND=noninteractive sudo apt-get -qq upgrade

    if (( SNAP_AVAILABLE )); then
        echo "Updating snap packages"
        sudo snap refresh
    fi
fi


if [ "$OS" == "linux" ]; then
    echo "Installing linux packages"
    for package in "${linux_packages[@]}"; do
        cmd="$(cut -d ' ' -f 1 <<< "$package" )"
        name="$( cut -d ' ' -f 2- <<< "$package" | tr -d '"')"
        case "$cmd" in
            'pkg')
                DEBIAN_FRONTEND=noninteractive sudo apt-get install -qq "$name"
                ;;
            'snap')
                if (( SNAP_AVAILABLE )); then
                    DEBIAN_FRONTEND=noninteractive sudo snap install "$name"
                fi
                ;;
            *)
                fatal "Invalid package command found for linux package: $cmd"
                ;;
        esac
    done
fi

echo "Installing packages using Homebrew"
mkdir -p .tmp
cp Brewfile .tmp/
if [ "$OS" == "linux" ]; then
    sed -i '/^cask /d' .tmp/Brewfile
    sed -i '/^mas /d' .tmp/Brewfile
    sed -i '/^brew "mas"/d' .tmp/Brewfile
    sed -i '/^tap "homebrew\/cask"/d' .tmp/Brewfile
    sed -i '/^tap "homebrew\/cask-fonts"/d' .tmp/Brewfile
fi
(cd .tmp; brew bundle)

echo "Cleaning up old brew packages"
brew cleanup

if [ "$OS" == "linux" ]; then
    echo "Cleaning up old linux packages"
    DEBIAN_FRONTEND=noninteractive sudo apt-get -qq autoremove
fi

echo "Dotfiles"
read -p "Populate dotfiles now? [y?]" answerdotfiles
if [[ "$answerdotfiles" == "y" ]]; then
    mydotfiles populate
fi


if [ "$OS" == "osx" ]; then
    echo "MacOS defaults"
    read -p "Configure? [y?]" answermacos
    if [[ "$answermacos" == "y" ]]; then
        ./macos.sh
    fi
fi

echo "Everything done"