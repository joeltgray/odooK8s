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

# Install Helm if not installed
print_info "Installing Helm..."
if ! command -v helm >/dev/null 2>&1; then
    sudo snap install helm --classic
    if [ $? -eq 0 ]; then
        print_success "Helm installed successfully."
    else
        print_error "Failed to install Helm."
        exit 1
    fi
fi

# Build Docker image and save as tar file
print_info "Building Odoo Docker image... This could take a while, image is ~8GB, go get a coffee..."
cd ..
docker build --no-cache -t odoo-source . -f Dockerfile-Odoo

print_info "Tagging Odoo Docker image as microk8s local images..."
docker tag odoo-source localhost:32000/odoo-source:local
echo "Tagged Odoo Docker image as localhost:32000/odoo-source:local"

print_info "Pushing Odoo Docker image to microk8s local registry... This could take a while go get another coffee.."
docker push localhost:32000/odoo-source:local

print_info "Foce a refresh of the local microk8s registry..."
microk8s ctr images pull localhost:32000/odoo-source:local

# Install Helm charts
print_info "Uninstalling and installing Odoo Helm chart..."
cd ./helm
helm uninstall odoo -n odoo
sleep 10
helm install odoo . -n odoo

# Check all namespaces
print_info "Checking items in all namespaces. You may need to check again as pods may still be coming up..."

# Check pods
print_info "Checking pods..."
kubectl get pods --all-namespaces

# Check services
print_info "Checking all services..."
kubectl get services --all-namespaces

# Check deployments
print_info "Checking all deployments..."
kubectl get deployments --all-namespaces
