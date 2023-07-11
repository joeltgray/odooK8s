#!/bin/bash

# Function to enable Snap on all OS
enable_snap() {
    echo "Enabling snapd socket with systemd..."
    sudo systemctl enable --now snapd.socket
    perform_sleep "10"

    echo "Enabling snapd service with systemd..."
    sudo systemctl enable snapd.service
    sudo systemctl start snapd.service
    sudo systemctl status snapd.service | cat

    echo "Enabling apparmor with systemd..."
    sudo systemctl enable --now snapd.apparmor
    sudo systemctl start apparmor.service
}

# Function to install Snap on Ubuntu
install_snap_ubuntu() {
    echo "Installing Snap on Ubuntu..."
    sudo apt update
    sudo apt-get install squashfs-tools
    sudo modprobe squashfs
    sudo apt install -y snapd

    enable_snap
}

# Function to install Snap on Arch Linux
install_snap_arch() {
    sudo pacman -S --noconfirm squashfs-tools
    sudo modprobe squashfs

    echo "Cloning snapd git repo..."
    git clone https://aur.archlinux.org/snapd.git
    cd snapd

    echo "Making snapd..."
    yes | makepkg -si

    enable_snap

    echo "Enable classic snap..."
    sudo ln -s /var/lib/snapd/snap /snap

    # echo "Removing snapd install files..."
    # cd .. && rm -rf ./snapd
}

perform_sleep() {
    local secs=$1
    echo "Sleeping for $secs seconds..."
    local chars="/-\|"
    local animation_speed=0.1
    local start_time=$(date +%s)
    local end_time=$((start_time + secs))
    local i=0
    while [ "$(date +%s)" -lt "$end_time" ]; do
        printf "\r%s" "${chars:$((i % ${#chars})):1}"
        sleep $animation_speed
        ((i++))
    done
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
