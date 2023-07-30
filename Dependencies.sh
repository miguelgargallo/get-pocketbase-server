# Print line to ask to install dialog, then user accept by detecting if arch, ubuntu, debian, fedora, centos

# Ask the user print line if dialog is not installed
if ! [ -x "$(command -v dialog)" ]; then
    echo 'Error: dialog is not installed.' >&2
    echo 'Please install dialog to continue' >&2
fi

# Detect distro and install dialog
if [ -x "$(command -v pacman)" ]; then
    sudo pacman -S dialog
elif [ -x "$(command -v apt-get)" ]; then
    sudo apt-get install dialog
elif [ -x "$(command -v dnf)" ]; then
    sudo dnf install dialog
elif [ -x "$(command -v yum)" ]; then
    sudo yum install dialog
else
    echo 'Error: Could not detect distro.' >&2
    echo 'Please install dialog to continue' >&2
fi

# Now with dialog installed, we can continue to ask and install wget, unzip and git
if ! [ -x "$(command -v wget)" ]; then
    dialog --title "Install wget" --yesno "wget is not installed, do you want to install it?" 7 60
    response=$?
    case $response in
        0) sudo apt-get install wget;;
        1) echo "wget will not be installed.";;
        255) echo "[ESC] key pressed.";;
    esac
fi

if ! [ -x "$(command -v unzip)" ]; then
    dialog --title "Install unzip" --yesno "unzip is not installed, do you want to install it?" 7 60
    response=$?
    case $response in
        0) sudo apt-get install unzip;;
        1) echo "unzip will not be installed.";;
        255) echo "[ESC] key pressed.";;
    esac
fi

if ! [ -x "$(command -v git)" ]; then
    dialog --title "Install git" --yesno "git is not installed, do you want to install it?" 7 60
    response=$?
    case $response in
        0) sudo apt-get install git;;
        1) echo "git will not be installed.";;
        255) echo "[ESC] key pressed.";;
    esac
fi

# check the version of miguelgargallo/get-pocketbase-server in file v.pylar is the value, compared with 