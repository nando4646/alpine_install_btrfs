#!/bin/sh

# Load variables from the temporary file
source variables

# Ask the user if they have EFI partition and if they do, store its name in the efi_part variable.
# Ask user if they want to format the partition, Or ask user if they want to use the entire disk to EFI.
echo "You can skip this passage, if you wish to create EFI in same disk."
echo "Picking EFI partition or creating one on another disk..."
if [ $USE_EFI -eq 1 ]; then
    read -p "Do you have EFI partition? (y/n): " efi_exist
    if [ "$efi_exist" = "y" ]; then
        read -p "Enter efi partition (e.g. /dev/sda1): " efi_part
        read -p "Do you want to format the EFI partition? (y/n): " format_efi
        if [ "$format_efi" = "y" ]; then
            # make sure the efi_part is umounted before formatting it
            if mount | grep -q "$efi_part"; then
                umount $efi_part
            fi
            mkfs.vfat -F32 -n ESP $efi_part
            # partprobe the disk of efi_part to update the partition table.
            partprobe -s $efi_part
        fi
    else
        read -p "Do you want to select a disk for EFI? (y/n): " format_efi
        if [ "$format_efi" = "y" ]; then
            read -p "Enter disk for EFI (e.g. /dev/sda): " efi_part
            if mount | grep -q "$efi_part"; then
                umount $efi_part
            fi
            # make a partition of 300mb for EFI
            parted -a optimal -s $efi_part mklabel gpt mkpart ESP fat32 0% 300M set 1 esp on mkpart primary 300M 100%
            # partprobe the disk of disk to update the partition table.
            partprobe -s $efi_part
        fi
    fi
fi

# check if efivars is mounted when EFI method is used, if not mount it
if [ $USE_EFI -eq 1 ]; then
    if [ ! -d /sys/firmware/efi/efivars ]; then
        mount -o remount,rw,nosuid,nodev,noexec --types efivarfs efivarfs /sys/firmware/efi/efivars
    fi
fi

# write variable to temporary file "variables"
printf "efi_part=%s\n" "$efi_part" >> variables

echo "EFI config done."