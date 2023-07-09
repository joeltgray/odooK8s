#!/bin/bash

# Install Helm if not installed
echo "Installing Helm..."
if ! command -v helm >/dev/null 2>&1; then
    sudo snap install helm --classic
fi

# Build Docker image and save as tar file
echo "Building Docker image and saving as tar file..."
docker build -t odoo-source .
docker save odoo-source:local > odoo-source.tar

# Load image tar into microk8s
echo "Loading image tar into microk8s..."
microk8s ctr image import odoo-source.tar

# Install Helm charts
echo "Installing Helm charts..."
cd ../charts
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
