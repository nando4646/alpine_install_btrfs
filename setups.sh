#!/bin/sh

# Check keyboard layout
if [ -f "/etc/conf.d/loadkmap" ] && grep -q "/etc/keymap/.*" "/etc/conf.d/loadkmap"; then
    echo "Keyboard layout has already been set to /etc/keymap/."
else
    read -p "Enter keyboard layout (e.g. fr fr): " key
    if [ -z "$key" ]; then
        echo "Invalid keyboard layout entered."
        exit 1
    fi
    # Set up keyboard layout
    setup-keymap "$key"
fi

# Check interfaces
if ping -c 1 1.1.1.1 &> /dev/null; then
    echo "Interfaces have already been set up."
else
    # Set up interfaces
    setup-interfaces
fi

# Check NTP
if service chronyd status >/dev/null 2>&1; then
    echo "NTP has already been set up."
else
    # Set up NTP
    setup-ntp
fi

# Check if SSH service is running
if service sshd status >/dev/null 2>&1; then
    echo "SSH service is already running."
else
    # Set up SSH
    setup-sshd
    if [ $? -eq 0 ]; then
        echo "SSH has been set up."
        echo "Please change the password for the root user."
        passwd
    else
        echo "Failed to set up SSH."
        # go back to check ssh service
        exit 1
    fi
fi

# Check if timezone folder /etc/zoneinfo exists if not set it with script, Prompt user to choose timezone like "Europe/Paris"
if [ -d /etc/zoneinfo ]; then
    echo "Timezone has already been set."
else
    read -p "Enter timezone (e.g. Europe/Paris): " time
    # Set up timezone
    setup-timezone $time
fi

# Check hostname in host file and if its local or localhost, then set it by using setup-hostname script and restart service
if [[ -n "$(grep -E '^(local|localhost)$' /etc/hostname)" ]]; then
    read -p "Current hostname is $(cat /etc/hostname). Do you want to change it? (y/n): " change_hostname
    if [[ "$change_hostname" == "y" ]]; then
        setup-hostname
        rc-service hostname --quiet restart
        # wait for hostname service to restart
        sleep 1
    else
        echo "No changes made to the hostname."
    fi
else
    echo "Hostname is already set to $(cat /etc/hostname)."
fi

# Prompt user to chose run setup-apkrepos
while true; do
    read -p "Do you wanna start setup-apkrepos? y/n: " choice
    case $choice in
        y)
            setup-apkrepos
            break
            ;;
        n)
            break
            ;;
        *)
            echo "Invalid option. Try again."
            ;;
    esac
done

echo "Setup complete."