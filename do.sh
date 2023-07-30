#!/bin/bash

REPO="pocketbase/pocketbase"
API_URL="https://api.github.com/repos/$REPO/releases"
FILE_SUFFIX="linux_arm64.zip"

# Execute Dependencies.sh
chmod +x Dependencies.sh
./Dependencies.sh

# Show the user to agree to the license
dialog --title "License" --yesno "Do you agree to the PocketBase license?" 10 60

# Check if the user agreed to the license
if [ $? -ne 0 ]; then
  dialog --title "Error" --msgbox "You must agree to the license to use PocketBase" 10 60
  exit 1
fi

# Ask for the version using a dialog box
version=$(dialog --title "PocketBase Downloader" --inputbox "Choose a version or type 'latest': " 10 60 3>&1 1>&2 2>&3 3>&-)

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

# Download the chosen asset
dialog --title "Downloading" --infobox "Downloading $file_name for version $actual_version..." 10 60
wget -q $download_url

# Check if file was downloaded
if [ ! -f $file_name ]; then
  dialog --title "Error" --msgbox "Failed to download $file_name" 10 60
  exit 1
fi

dialog --title "Success" --msgbox "Download successful: $file_name" 10 60

# Unzip the downloaded file
unzip -q $file_name

# Remove CHANGELOG.md and LICENSE.md
rm CHANGELOG.md LICENSE.md

# Copy "pocketbase" into a folder with MMDDYYHHMMam/pm
dir_name=$(date +%m%d%y%I%M%p)
mkdir -p $dir_name
cp pocketbase $dir_name

# Remove the downloaded file
rm $file_name pocketbase

dialog --title "Success" --msgbox "PocketBase successfully downloaded to: $dir_name" 10 60
