# Check the version of miguelgargallo/get-pocketbase-server in the last commit title
# Fetch the latest commit message from the GitHub repo
latest_commit_message=$(curl -s https://api.github.com/repos/miguelgargallo/get-pocketbase-server/commits | grep '"message":' | head -1 | cut -d '"' -f 4)

# Extract the version from the commit message
latest_version=$(echo $latest_commit_message | grep -o 'gh v[0-9]\+\.[0-9]\+\.[0-9]\+')

if [ -z "$latest_version" ]; then
    echo "Could not extract version from commit message: $latest_commit_message"
    exit 1
fi

echo "The latest version of get-pocketbase-server is: $latest_version."
