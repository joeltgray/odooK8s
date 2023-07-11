#!/bin/bash

# Functions to print with colors and separators
print_info() {
    echo -e "\033[0;34m\n###############################################################################"
    echo -e "\033[0;34m### $1"
    echo -e "\033[0;34m###############################################################################\033[0m"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS] $1\033[0m"
}

print_error() {
    echo -e "\033[0;31m[ERROR] $1\033[0m"
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

check_squashfs() {
    print_info "Checking squashfs support..."
    if lsmod | grep -q "squashfs"; then
        print_success "System supports squashfs."
    else
        print_error "System does not support squashfs."
        print_info "Trying to install squashfs-tools..."
        sudo pacman -S --noconfirm squashfs-tools
        print_info "Loading squashfs module..."
        sudo modprobe squashfs
        if ! lsmod | grep -q "squashfs"; then
            print_error "Failed to load squashfs module. You may need to reboot the system, failing that update your kernel"
            exit 1
        else
            print_success "Squashfs module loaded successfully."
        fi
    fi
}

clone_odoo() {
    print_info "Cloning Odoo Community git repo..."
    cd ..
    git clone https://github.com/odoo/odoo.git
    cd ./build
}

install_microk8s() {
    # Add check for SquashFS support on Arch, as it is not enabled by default unlike Ubuntu
    if grep -q "Arch" /etc/os-release; then
            check_squashfs
        fi

    print_info "Checking if local host is in /etc/hosts, this is needed for microK8s to function correctly..."
    # Check if the line already exists in /etc/hosts
    if grep -qxF "127.0.0.1 localhost" /etc/hosts; then
        echo "The line '127.0.0.1 localhost' already exists in /etc/hosts."
    else
    # Append "127.0.0.1 localhost" to /etc/hosts
        echo "127.0.0.1 localhost" | sudo tee -a /etc/hosts
    echo "The line '127.0.0.1 localhost' has been appended to /etc/hosts."
    fi

    # Install mk8s
    print_info "Installing MicroK8s... This may take a few minutes..."
    print_info "Ensuring snap is in a good state..."
    sudo systemctl restart snapd
    sudo snap refresh

    # Remove microk8s if it exists so we have a total clean install
    print_info "Checking if microk8s exists..."
    if sudo snap list | grep -q microk8s; then
        echo "MicroK8s currently exists..."
        print_info "Removing existing microk8s..."
        sudo snap remove microk8s
    fi

    perform_sleep "30"
    print_info "Installing..."
    if ! sudo snap install microk8s --classic; then
        print_error "Failed to install MicroK8s. Try the install again and/or check your logs."
        exit 1
    fi
    
    # Check mk8s is running
    print_info "Checking MicroK8s status..."
    microk8s status --wait-ready

    # Make kubectl available
    print_info "Making kubectl command available..."
    sudo snap install kubectl --classic

    # Save kube config and set context
    print_info "Saving kube config and setting microk8s context..."
    mkdir -p "$HOME/.kube"
    microk8s.kubectl config view --raw > "$HOME/.kube/config"

    # Check kubectl version
    print_info "Checking kubectl version..."
    kubectl version --output=json | cat
    kubectl config use-context microk8s

    # Import CA certs
    print_info "Importing CA certs..."
    sudo cp /var/snap/microk8s/current/certs/ca.crt /usr/local/share/ca-certificates/microk8s.crt
    if grep -q "Ubuntu" /etc/os-release; then
        sudo update-ca-certificates
    elif grep -q "Arch" /etc/os-release; then
        sudo trust extract-compat
    fi

    # Print microk8s cluster info
    print_info "Printing MicroK8s cluster info..."
    microk8s config

    # Enable addons
    print_info "Enabling MicroK8s addons..."
    microk8s enable dashboard
    microk8s enable registry

    # Create microk8s namespace for our app
    print_info "Creating MicroK8s namespace for our app..."
    kubectl create namespace odoo

    # Installation complete
    print_success "Microk8s install complete!"
}

clone_odoo
install_microk8s
