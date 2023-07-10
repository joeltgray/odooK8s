#!/bin/bash

# Install Helm if not installed
echo "Installing Helm..."
if ! command -v helm >/dev/null 2>&1; then
    sudo snap install helm --classic
fi

# Build Docker image and save as tar file
echo "Building Docker image..."
echo "This could take a while, image is ~8GB, go get a coffee..."
cd ..
docker build --no-cache -t odoo-source:local .

echo "Saving Docker image as tar file..."
echo "This could also take a while, go get a biscuit for your coffee..."
docker save odoo-source:local > odoo-source.tar

# Load image tar into microk8s
echo "Loading image tar into microk8s..."
echo "Last coffee break, I promise..."
microk8s ctr image import odoo-source.tar

# Install Helm charts
echo "Installing Helm charts..."
cd ./helm

echo "Uninstalling and installing Odoo Helm chart..."
helm uninstall odoo -n odoo
sleep 10
helm install odoo . -n odoo

# Check all namespaces
echo "Checking items in all namespaces. You may need to check again as pods may still be coming up..."

# Check pods
echo "Checking pods..."
kubectl get pods --all-namespaces

# Check services
echo "Checking all services..."
kubectl get services --all-namespaces

# Check deployments
echo "Checking all deployments..."
kubectl get deployments --all-namespaces
