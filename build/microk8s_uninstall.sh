#!/bin/bash

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

# Uninstall Helm charts
print_info "Uninstalling Helm charts..."
helm uninstall odoo -n odoo

# Delete the microk8s namespace for the app
print_info "Deleting MicroK8s namespace for the app..."
kubectl delete namespace odoo

# Remove microk8s context
print_info "Removing microk8s context..."
kubectl config delete-context microk8s

# Remove admin-user cluster role binding
print_info "Removing admin-user cluster role binding..."
kubectl delete clusterrolebinding admin-user-cluster-admin

# Delete admin-user secret and service account
print_info "Deleting admin-user secret and service account..."
kubectl delete secret admin-user-token -n kube-system
kubectl delete serviceaccount admin-user -n kube-system

# Remove kube config
print_info "Removing kube config..."
rm -f $HOME/.kube/config

# Uninstall Helm
print_info "Uninstalling Helm..."
sudo snap remove helm

# Stop and disable MicroK8s
print_info "Stopping and disabling MicroK8s..."
sudo microk8s stop
sudo snap disable microk8s

# Remove MicroK8s permissions
print_info "Removing MicroK8s permissions..."
sudo deluser $USER microk8s

# Uninstall kubectl
print_info "Uninstalling kubectl..."
sudo snap remove kubectl

# Uninstall MicroK8s
print_info "Uninstalling MicroK8s..."
sudo snap remove --purge microk8s

# Step 2: Clean up remaining artifacts
print_info "Cleaning up remaining artifacts..."
sudo rm -rf /var/snap/microk8s

print_success "Uninstall complete!"
