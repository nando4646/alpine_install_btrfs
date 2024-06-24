Alpine Linux btrfs installation script, v3.20 tested

This script automates the installation of Alpine Linux with btrfs.

It guides the user through the process of setting up Alpine Linux, partitioning the disk, creating subvolumes, setting up the environment, and installing the necessary packages.

The main script is install.sh

NOTE : Check if file variables is present before running the script

The script includes the following files:
- version.sh: A script that prompts the user to select the Alpine Linux version.
- efi.sh: A script that handles the EFI boot mode configuration in case you have an EFI partition in another disk or want to use it in this install.
- setups.sh: A script that call setup scripts of alpine, sets up keyboard layout, network interfaces, NTP, and SSH...
- requirements.sh: A script that installs the necessary packages for btrfs support.
- part.sh: A script that sets up the partition.
- btrfssub.sh: A script that creates btrfs subvolumes.
- bootcheck.sh: A script that checks if the bootloader is installed.
- disk.sh: A script that sets up the disk.
- btrfs-grub.sh: A script that installs btrfs-grub. Can be used alone or to remove with --remove option.
- check-mnt.sh: A script that checks if /mnt is mounted.

Before running the script, make sure to have:
- A computer with Internet access.

Instructions:
1. Run the script by executing the following command:
   sh or ash install.sh
2. Follow the prompts and instructions provided by the script.

ENJOY!