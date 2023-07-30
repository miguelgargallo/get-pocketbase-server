#!/bin/bash

# Detect distro and install dialog
if ! [ -x "$(command -v dialog)" ]; then
    echo "Dialog is not installed, installing..."

    if [ -x "$(command -v pacman)" ]; then
        sudo pacman -Sy dialog
    elif [ -x "$(command -v apt-get)" ]; then
        sudo apt-get update
        sudo apt-get install dialog
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install dialog
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install dialog
    else
        echo 'Error: Could not detect distro.' >&2
        echo 'Please install dialog to continue' >&2
        exit 1
    fi
fi

# Define a function to ask and install a package
ask_and_install() {
    local package=$1
    local install_command=$2

    if ! [ -x "$(command -v $package)" ]; then
        dialog --title "Install $package" --yesno "$package is not installed, do you want to install it?" 7 60
        response=$?
        case $response in
            0) eval $install_command;;
            1) echo "$package will not be installed.";;
            255) echo "[ESC] key pressed.";;
        esac
    fi
}

# Now with dialog installed, we can continue to ask and install wget, unzip and git
ask_and_install wget 'sudo apt-get install wget'
ask_and_install unzip 'sudo apt-get install unzip'
ask_and_install git 'sudo apt-get install git'

# Check the version of miguelgargallo/get-pocketbase-server in file v.pylar
# TODO: Add your version checking logic here
