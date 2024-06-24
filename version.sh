#!/bin/sh

# Select the Alpine Linux version based on user input
echo "Select the Alpine Linux version:"
echo "1. 3.19"
echo "2. 3.20"
read -p "Enter the number of the selected version: " version

case $version in
    1)
        alpine_version="v3.19"
        ;;
    2)
        alpine_version="v3.20"
        ;;
    *)
        echo "Invalid selection. Exiting..."
        exit 1
        ;;
esac

# Check if /etc/apk/repositories file exists. If so, remove it.
if [ -f /etc/apk/repositories ]; then
    rm /etc/apk/repositories
fi

# Create a new /etc/apk/repositories file with the selected Alpine Linux version.
printf \
"http://dl-cdn.alpinelinux.org/alpine/${alpine_version}/main
http://dl-cdn.alpinelinux.org/alpine/${alpine_version}/community
/media/cdrom/apks
" > /etc/apk/repositories

echo "Alpine Linux version $alpine_version selected."