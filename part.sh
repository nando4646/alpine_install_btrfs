#!/bin/sh

source variables

echo "Setting up partition..."

echo
blkid
echo
read -p "Enter partition (e.g. /dev/sda1): " part
echo

if mountpoint -q "$part"; then
    echo "Unmounting $part..."
    umount "$part"
fi

partprobe -s "$part"

mkfs.btrfs -f "$part"

partprobe -s "$part"

printf "rootfs=%s\n" "$part" >> variables

echo "Partition setup complete."