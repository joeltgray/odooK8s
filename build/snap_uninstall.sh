#!/bin/bash

# Function to remove Snap files on all OS
remove_snap_files() {
    echo "Removing snap from system..."
    sudo systemctl disable snapd.service
    sudo systemctl stop snapd.service
    sudo umount -l /var/lib/snapd/snap
    sudo rm -rf /var/lib/snapd
    sudo rm -rf ~/snap
    sudo rm -rf /snap
}

# Function to remove Snap on Ubuntu
remove_snap_ubuntu() {
    remove_snap_files
    sudo apt purge -y snapd
}

# Function to remove Snap on Arch Linux
remove_snap_arch() {
    remove_snap_files
    sudo pacman -Rns snapd
}

# Detect the operating system
OS=$(uname -s)

# Remove Snap based on the detected OS
case $OS in
    Linux*)
        if [ -f /etc/os-release ]; then
            source /etc/os-release
            case $ID in
                ubuntu|pop)
                    remove_snap_ubuntu
                    ;;
                arch)
                    remove_snap_arch
                    ;;
                *)
                    echo "Unsupported operating system: $ID"
                    exit 1
                    ;;
            esac
        else
            echo "Unable to detect the operating system."
            exit 1
        fi
        ;;
    *)
        echo "Unsupported operating system: $OS"
        exit 1
        ;;
esac

echo "Snap removal completed!"
