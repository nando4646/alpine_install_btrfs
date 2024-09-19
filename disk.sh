#!/bin/sh

source variables

echo "Setting up disk..."

blkid
read -p "Enter disk (e.g. /dev/sda): " disk

if [ "$USE_EFI" -eq 1 ]; then
    parted -a optimal -s "$disk" mklabel gpt
    parted -a optimal -s "$disk" mkpart ESP fat32 0% 300M set 1 esp on mkpart primary 300M 100%
    mkfs.vfat -F32 -n ESP "$disk"1
    mkfs.btrfs -f "$disk"2
else
    parted -a optimal -s "$disk" mklabel msdos
    parted -a optimal -s "$disk" mkpart primary 1MiB 100%
    mkfs.btrfs -f "$disk"1
fi

partprobe -s "$disk"

if [ "$USE_EFI" -eq 1 ]; then
    printf "efi_part=%s1\n" "$disk" >> variables
    printf "rootfs=%s2\n" "$disk" >> variables
else
    printf "rootfs=%s1\n" "$disk" >> variables
fi

echo "Disk setup complete."