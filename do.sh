#!/bin/bash

REPO="pocketbase/pocketbase"
API_URL="https://api.github.com/repos/$REPO/releases"
FILE_SUFFIX="linux_arm64.zip"

# Ask for the version
read -p "Choose a version or type 'latest': " version

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
  echo "Could not find asset for version $version"
  exit 1
fi

# Extract the filename from the URL
file_name=$(basename $download_url)

# Download the chosen asset
echo "Downloading $file_name for version $actual_version..."
wget -q $download_url

# Check if file was downloaded
if [ ! -f $file_name ]; then
  echo "Failed to download $file_name"
  exit 1
fi

echo "Download successful: $file_name"
