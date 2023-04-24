#!/bin/bash

# Options
REPO="https://github.com/borcean/ansible-silverblue-kiosk.git"
BRANCH=mutable
VAULT_FILE=/root/.ansible_vault_key
INVENTORY="https://raw.githubusercontent.com/borcean/ansible-silverblue-kiosk/"$BRANCH"/hosts"
REQUIREMENTS="https://raw.githubusercontent.com/borcean/ansible-silverblue-kiosk/"$BRANCH"/requirements.yml"

confirm() {
    PROMPT="$1"
    while true; do
        read -r -p "$PROMPT" CHOICE
            if [[ $CHOICE =~ ^[Yy]$ ]]; then
                return 0
            elif [[ "$CHOICE" =~ ^[Nn]$ ]]; then
                return 1
            fi
    done
}

check_hostname () {

    HOSTNAME="$(hostnamectl --static)"

    if [ "$(wget -qO- "$INVENTORY" | grep -m 1 "$HOSTNAME")" == "$HOSTNAME" ]; then
        echo -e "Host "$HOSTNAME" found in inventory."
    else
        echo -e "Host "$HOSTNAME" not found in inventory."
        if confirm "Change hostname now?  y/n: "; then
            read -p "New hostname: " NEW_HOSTNAME
            hostnamectl set-hostname "$NEW_HOSTNAME"
            check_hostname
        fi
    fi
}

# Check if run as root
if [ "$(id -u)" != "0" ]; then
   echo "Must be run as root, exiting..." 1>&2
   exit 1
fi

# Check if hostname is in inventory
check_hostname

# Update OS and install Ansible on supported distros
OS=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }' | sed 's/"//g')

if [[ "$OS" == fedora ]]; then
    dnf upgrade --refresh -y
    dnf install ansible-core -y
else
    if ! confirm "Unsupported distro detected, continue anyways?  y/n: "; then
        exit
    fi
fi

# Clean Ansible cache
rm -rf /root/.ansible/

# Install collections/roles from Ansible Galaxy
wget -O /tmp/requirements.yml "$REQUIREMENTS"
ansible-galaxy collection install -r /tmp/requirements.yml --force

# Ansible pull command
echo -e "\n"
ansible-pull -U "$REPO" -C "$BRANCH"


# Offer restart after ansible pull finished
if confirm "Reboot system now?  y/n: "; then
    systemctl reboot
fi