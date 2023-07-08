#!/bin/bash

# Function to enable Snap on all OS
enable_snap() {
    echo "Enabling snapd with systemd..."
    sudo systemctl enable --now snapd.socket
    sleep 10
    sudo systemctl enable snapd.service
    sudo systemctl start snapd.service
    sudo systemctl status snapd.service

    echo "Enabling apparmor with systemd..."
    sudo systemctl enable --now apparmor.service
    sudo systemctl start apparmor.service
}

# Function to install Snap on Ubuntu
install_snap_ubuntu() {
    echo "Installing Snap on Ubuntu..."
    sudo apt update
    sudo apt install -y snapd

    enable_snap
}

# Function to install Snap on Arch Linux
install_snap_arch() {
    echo "Cloning snapd git repo..."
    git clone https://aur.archlinux.org/snapd.git
    cd snapd

    echo "Making snapd..."
    yes | makepkg -si

    enable_snap

    echo "Enable classic snap..."
    sudo ln -s /var/lib/snapd/snap /snap

    echo "Removing snapd install files..."
    cd .. && rm -rf ./snapd
}

# Detect the operating system
OS=$(uname -s)

# Install Snap based on the detected OS
case $OS in
    Linux*)
        if [ -f /etc/os-release ]; then
            source /etc/os-release
            case $ID in
                ubuntu|pop)
                    install_snap_ubuntu
                    ;;
                arch)
                    install_snap_arch
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
        echo "Unsupported operating system please install manually: $OS"
        exit 1
        ;;
esac

echo "Snap installation completed!"
