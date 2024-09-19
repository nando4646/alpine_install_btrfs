#!/bin/sh

echo "Setting up btrfs-grub..."

builddir="/opt"
gbtrfsdir="$builddir/grub-btrfs"

if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo "Usage: $0 [--help|-h] | [--remove|-r] | [--update|-u] [--nolimit]"
    exit 0
fi

if [ "$1" = "--remove" -o "$1" = "-r" ]; then
    cd $gbtrfsdir
    rc-service grub-btrfsd stop
    rc-config remove grub-btrfsd boot
    make SYSTEMD=false OPENRC=true BOOT_DIR_DEBIAN=/boot/grub uninstall
    rm -rf /opt/grub-btrfs
    exit 0
fi

if [ "$1" = "--update" -o "$1" = "-u" ]; then
    cd $gbtrfsdir
    git pull
    make SYSTEMD=false OPENRC=true BOOT_DIR_DEBIAN=/boot/grub install
    exit 0
fi

dependencies=(btrfs-progs btrfs-progs bash gawk inotify-tools git)

for dep in "${dependencies[@]}"; do
    if apk info | grep -q "$dep"; then
        echo "$dep already installed"
    else
        echo "Installing $dep"
        apk add "$dep"
    fi
done

if [ ! -d "$gbtrfsdir" ]; then
    git clone https://github.com/Antynea/grub-btrfs.git "$builddir"
fi

if [ "$1" != "--nolimit" ]; then
    echo
    echo
    echo "You can change this value in /etc/conf.d/grub-btrfsd, check the documentation of Antynea/grub-btrfs."
    echo
    echo
    read -p "Enter number of snapshots to keep: " limit

    printf \
    "
    GRUB_BTRFS_LIMIT=$limit
    GRUB_BTRFS_MKCONFIG_LIB=/usr/share/grub/grub-mkconfig_lib
    " > config
fi

cd "$gbtrfsdir"
make SYSTEMD=false OPENRC=true BOOT_DIR_DEBIAN=/boot/grub install
rc-service grub-btrfsd start
rc-config add grub-btrfsd boot
sed -i 's/features="\(.*\)"/features="\1 btrfs-overlayfs"/g' /etc/mkinitfs/mkinitfs.conf
mkinitfs -C zstd -f /etc/mkinitfs/mkinitfs.conf
rm -r "$gbtrfsdir"

echo "End of btrfs-grub."