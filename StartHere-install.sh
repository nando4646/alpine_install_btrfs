#!/bin/sh

# Set up Alpine Linux
echo
echo

cat logo.txt

echo
echo

echo "Setting up Alpine Linux..."

# Set version
echo "You can skip this passage, if you already have set /etc/repositeries file."
echo "this doesn't prompt setup-apkrepos"
sh version.sh

# Set up setups.sh
echo "Setups..."
sh setups.sh

# Setup requirements
echo "Setting up requirements..."
sh requirements.sh

# Install btrfs-grub
sh btrfs-grub.sh

# Install snapper
sh snapper/snapper.sh

# Load variables from the temporary file
source variables

# Setup efi if USE_EFI is 1
if [ "$USE_EFI" -eq 1 ]; then
    read -p "Create EFI partition on this disk? (y/n): " choice
    if [ "$choice" = "y" ]; then
        sh efi.sh
    fi
fi

# check if /mnt is mounted
sh check-mnt.sh

# call script to set up disk
echo "Setting up disk for install"

while true; do
    read -p "Pick disk for fresh install (1), or Pick partition if you already partitioned your disk or have EFI partitioned (2): " choice
    case $choice in
        1) sh disk.sh; break ;;
        2) sh part.sh; break ;;
        *) echo "Invalid option. Try again." ;;
    esac
done

# create btrfs subvolumes
sh btrfssub.sh

#  setup-disk verbose mode
echo "Installing Alpine Linux..."
setup-disk -v /mnt

read -p " Do you wanna check bootloader is installed? (y/n): " choice
if [ "$choice" = "y" ]; then
    sh bootcheck.sh
fi

echo "Done. You can now reboot your system."

# END OF SCRIPT