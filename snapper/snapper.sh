#!/bin/sh

echo "Downloading snapper and components..."

arch=$(uname -m)
url=https://dl-cdn.alpinelinux.org/alpine/edge/testing
snappu=/opt/snapper

if grep -Fxq "/opt/packages" /etc/apk/repositories; then
    echo "/opt/packages already present in /etc/apk/repositories"
else
    sudo sh -c "echo '/opt/packages' >> /etc/apk/repositories"
fi

sudo mkdir -p /opt/packages
sudo apk update

curl -s $url/$arch/ | grep snapper | grep -vE "snapper-zsh-completion|snapper-doc|snapper-dev" | awk -F">" '{print $2}' | awk -F"<" '{print $1}' | sed 's/\/a//g' > templist
for package in $(cat templist); do
    sudo curl -s -o "$snappu/$package" "$url/$arch/$package"
done

echo "Installing snapper and components..."

sudo apk add --allow-untrusted --repository $snappu/ $package

sudo rc-update dbus default
sudo rc-service --quiet dbus start

rm templist

sudo snapper --config home create-config /home ALLOW_USERS=${LOGNAME} SYNC_ACL=yes
sudo snapper --config root create-config / ALLOW_USERS=${LOGNAME} SYNC_ACL=yes

sudo chown -R :${LOGNAME} /.snapshots
sudo chown -R :${LOGNAME} /home/.snapshots

sudo cp snapper/cachyos-home /etc/snapper/configs/home
sudo cp snapper/cachyos-root /etc/snapper/configs/root

echo "End of snapper."
