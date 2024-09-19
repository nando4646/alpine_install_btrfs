#!/bin/sh

source variables

# Ask user mount option for btrfs
while true; do
    echo
    echo
    echo "h=HDD, s=SSD, m=Manual"
    echo
    read -p "Enter mount option for btrfs (h,s,m): " btrfs_mount_options
    case "$btrfs_mount_options" in
        h)
            btrfs_mount_options="defaults,compress-force=zstd:2,autodefrag"
            break
            ;;
        s)
            btrfs_mount_options="defaults,compress-force=zstd:2,ssd,commit=120,discard=async"
            break
            ;;
        m)
            read -p "Enter mount options for btrfs (comma separated): " btrfs_mount_options
            btrfs_mount_options="defaults,compress-force=zstd:2,${btrfs_mount_options}"
            break
            ;;
        *)
            echo "Invalid option. Try again."
            ;;
    esac
done

# create btrfs subvolumes on rootfs partition
echo "Creating Btrfs subvolumes..."
mount -t btrfs -o "$btrfs_mount_options" "$rootfs" /mnt
if [ "$USE_EFI" -eq 1 ]; then
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@var
    btrfs subvolume create /mnt/@snapshots
else
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@boot
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@var
    btrfs subvolume create /mnt/@snapshots
fi

sleep 1
umount "$rootfs"
partprobe -s "$rootfs"

# Mount "@" to /mnt and rest subvolumes
echo "Mounting Btrfs subvolumes..."
mount -o "$btrfs_mount_options",subvol=@ "$rootfs" /mnt

if [ "$USE_EFI" -eq 1 ]; then
    mkdir /mnt/boot /mnt/home /mnt/var /mnt/.snapshots
    mount -t vfat "$efi_part" /mnt/boot
else
    mkdir /mnt/boot /mnt/home /mnt/var /mnt/.snapshots
    mount -o "$btrfs_mount_options",subvol=@boot "$rootfs" /mnt/boot
fi

mount -o "$btrfs_mount_options",subvol=@home "$rootfs" /mnt/home
mount -o "$btrfs_mount_options",subvol=@var "$rootfs" /mnt/var
mount -o "$btrfs_mount_options",subvol=@snapshots "$rootfs" /mnt/.snapshots

echo "Partitions created."