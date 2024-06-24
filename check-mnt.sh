#!/bin/sh

# check if /mnt directorys are being used, unmount everything inside and the /mnt folder, then erase everything inside /mnt.
if mountpoint -q "/mnt"; then
    # Terminate processes that are using files within /mnt
    processes=$(lsof -t /mnt)
    for pid in $processes; do
        kill -TERM "$pid" 2>/dev/null || true
    done
    # Wait for all the processes to terminate or timeout after 10 seconds
    timeout 10s bash -c 'while kill -0 "$1"; do sleep 1; done' _ "$processes"
    # Unmount the directory and update partition table
    umount -f /mnt
    partprobe
fi

if [ -n "$(ls -A /mnt)" ]; then
    # Remove all files recursively from /mnt
    find /mnt -mindepth 1 -delete
fi

echo "/mnt check complete."