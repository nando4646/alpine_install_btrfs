#!/bin/sh

touch variables

# Prompt user to choose EFI boot mode
while true; do
    read -p "Use EFI boot mode? (0 - No, 1 - Yes): " use_efi
    case $use_efi in
        0|1)
            echo "USE_EFI=$use_efi" >> variables
            break
            ;;
        *)
            echo "Invalid option. Try again."
            ;;
    esac
done

if [ $use_efi -eq 1 ]; then
    printf 'DISKLABEL=gpt\nBOOTFS=vfat\nROOTFS=btrfs' >> variables
    GRUB_PKG="grub-efi efibootmgr"
else
    printf 'DISKLABEL=dos\nBOOTLOADER=grub' >> variables
    GRUB_PKG="grub"
fi

apk update

# Check if necessary packages are already installed
if apk info | grep -q "btrfs-progs"; then
    echo "btrfs-progs already installed"
else
    echo "Installing btrfs-progs"
    apk add btrfs-progs
fi

if apk info | grep -q "parted"; then
    echo "parted already installed"
else
    echo "Installing parted"
    apk add parted
fi

if apk info | grep -q "zstd"; then
    echo "zstd already installed"
else
    echo "Installing zstd"
    apk add zstd
fi

if apk info | grep -q "e2fsprogs"; then
    echo "e2fsprogs already installed"
else
    echo "Installing e2fsprogs"
    apk add e2fsprogs
fi

if apk info | grep -q "nano"; then
    echo "nano already installed"
else
    echo "Installing nano"
    apk add nano
fi

if apk info | grep -q "$GRUB_PKG"; then
    echo "$GRUB_PKG already installed"
else
    echo "Installing $GRUB_PKG"
    apk add $GRUB_PKG
fi

if apk info | grep -q "syslinux"; then
    apk del syslinux
fi

modprobe btrfs

# refresh mkinitfs config file
if ! grep -q "btrfs" /etc/mkinitfs/mkinitfs.conf; then
    sed -i 's/features="\(.*\)"/features="\1 btrfs"/g' /etc/mkinitfs/mkinitfs.conf
    mkinitfs -C zstd -f /etc/mkinitfs/mkinitfs.conf
fi

echo "End of requirements."