#!/bin/bash

# Define dependencies and the command to install them
dependencies=(dialog wget unzip git)
install_commands=("sudo apt-get install" "sudo pacman -Sy" "sudo dnf install" "sudo yum install")

# Detect distro and install dependencies
for dependency in "${dependencies[@]}"; do
  if ! [ -x "$(command -v $dependency)" ]; then
    for install_command in "${install_commands[@]}"; do
      if $install_command $dependency >/dev/null 2>&1; then
        break
      fi
    done
  fi
done

REPO="pocketbase/pocketbase"
API_URL="https://api.github.com/repos/$REPO/releases"
FILE_SUFFIX="linux_arm64.zip"
# Detect the OS
OS=$(uname | tr '[:upper:]' '[:lower:]')

# Detect the architecture
if [ "$(uname -m)" = "x86_64" ]; then
  ARCH="amd64"
else
  ARCH="arm64"
fi

FILE_SUFFIX="${OS}_${ARCH}.zip"

# Show the user to agree to the license
dialog --title "License" --yesno "Do you agree to the Pylar AI Creative ML Free License?" 10 60

# Check if the user agreed to the license
if [ $? -ne 0 ]; then
  dialog --title "Error" --msgbox "You must agree to the Pylar AI Creative ML Free License to use PocketBase" 10 60
  exit 1
fi

# Get the latest 10 release versions from GitHub
release_versions=$(curl -s $API_URL | grep -m 10 "tag_name" | cut -d '"' -f 4)

# Check if there are any versions available
if [ -z "$release_versions" ]; then
  dialog --title "Error" --msgbox "No versions found for the PocketBase project" 10 60
  exit 1
fi

# Convert release versions into dialog options
options=()
for version in $release_versions; do
  options+=("$version" "-")
done

# Ask for the version using a dialog box
version=$(dialog --title "PocketBase Downloader" --menu "Choose a version from the list or type 'latest': " 20 60 10 "${options[@]}" 3>&1 1>&2 2>&3 3>&-)

if [ "$version" = "latest" ]; then
  # Get the latest release data from GitHub
  release_data=$(curl -s ${API_URL}/latest)
else
  # Get the specified release data from GitHub
  release_data=$(curl -s ${API_URL}/tags/$version)
fi

# Extract the version of the release
actual_version=$(echo "$release_data" | grep tag_name | cut -d '"' -f 4)

# Get the URL of the appropriate asset
download_url=$(echo "$release_data" | grep browser_download_url | cut -d '"' -f 4 | grep $FILE_SUFFIX)

if [ -z "$download_url" ]; then
  dialog --title "Error" --msgbox "Could not find asset for version $version" 10 60
  exit 1
fi

# Extract the filename from the URL
file_name=$(basename $download_url)

# Download the chosen asset into $actual_version/$file_name
dialog --title "Downloading" --infobox "Downloading $file_name for version $actual_version..." 10 60

# Create if not a folder with $actual_version/$(date +%mm-$dd-%yy_%H-%M-%S)
mkdir -p "./pb/$actual_version/$(date +%m-%d-%y_%H-%M-%S)"
cd "./pb/$actual_version/$(date +%m-%d-%y_%H-%M-%S)"
wget -q --show-progress $download_url

# Check if file was downloaded
if [ ! -f $file_name ]; then
  dialog --title "Error" --msgbox "Failed to download $file_name" 10 60
  exit 1
fi

# unzip with bar progress
dialog --title "Unzipping" --infobox "Unzipping $file_name..." 10 60
# Unzip the downloaded file
unzip -q $file_name && rm CHANGELOG.md LICENSE.md

# Get the actual file name after unzip
actual_file=$(unzip -l $file_name | awk '/inflating:/{print $NF}')

# Remove the downloaded file
rm $file_name && cd ../../..

# Remove the unzipped folder
rm -rf $actual_file

dialog --title "Success" --msgbox "PocketBase successfully downloaded to: ./pb/$actual_version" 10 60
