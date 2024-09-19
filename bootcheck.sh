#!/bin/sh

source variables

echo "Checking GRUB"
# Check if bootloader is installed in the partition by checking presence of files under /boot directory if not, install it either EFI or dos method, if installed  skip.
if [ $USE_EFI -eq 1 ]; then
    if [ ! -f /boot/grub/grub.cfg ]; then
        echo "Installing EFI bootloader..."
        grub-install --target=x86_64-efi --efi-directory=/mnt/boot --removable
        grub-mkconfig -o /mnt/boot/grub/grub.cfg
    fi
else
    if [ ! -f /mnt/boot/grub/grub.cfg ]; then
        echo "Installing bootloader..."
        grub-install --target=i386-pc --boot-directory=/mnt/boot
        grub-mkconfig -o /mnt/boot/grub/grub.cfg
    fi
fi

echo "Bootloader check complete."