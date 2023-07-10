#!/bin/bash

install_microk8s() {
    # Install mk8s
    echo "Installing MicroK8s..."
    echo "This may take a few minutes..."
    echo "Ensuring snap is in a good state..."
    sudo systemctl restart snapd
    sudo snap refresh

    # Remove microk8s if it exists
    echo "Removing microk8s if it exists..."
    if sudo snap list | grep -q microk8s; then
        echo "Removnig existing microk8s..."
        sudo snap remove microk8s
    fi

    echo "About to sleep"
    perform_sleep "30"

    if ! sudo snap install microk8s --classic; then
        echo "Failed to install MicroK8s,"
        echo "Try the install again and/or check your logs"
        echo "Exiting!"
        exit 1
    fi

    # Give mk8s permissions
    echo "Giving MicroK8s permissions..."
    sudo usermod -a -G microk8s "$USER"
    sudo chown -f -R "$USER" ~/.kube

    # Check mk8s is running
    echo "Checking MicroK8s status..."
    microk8s status --wait-ready

    # Make kubectl available
    echo "Making kubectl command available..."
    sudo snap install kubectl --classic

    # Save kube config and set context
    echo "Saving kube config and setting microk8s context..."
    mkdir -p "$HOME/.kube"
    microk8s.kubectl config view --raw > "$HOME/.kube/config"

#    Check kubectl version
    echo "Checking kubectl version..."
    kubectl version --output=json | cat
    kubectl config use-context microk8s

    # Import CA certs
    echo "Importing CA certs..."
    sudo cp /var/snap/microk8s/current/certs/ca.crt /usr/local/share/ca-certificates/microk8s.crt
    if grep -q "Ubuntu" /etc/os-release; then
        sudo update-ca-certificates
    elif grep -q "Arch" /etc/os-release; then
        sudo trust extract-compat
    fi

    # Print microk8s cluster info
    echo "Printing MicroK8s cluster info..."
    microk8s config

    # Enable addons
    echo "Enabling MicroK8s addons..."
    microk8s enable dashboard
    microk8s enable registry

    # Create microk8s namespace for our app
    echo "Creating MicroK8s namespace for our app..."
    kubectl create namespace odoo

    # Installation complete
    echo "Install complete!"
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

install_microk8s