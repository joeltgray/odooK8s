#!/bin/bash

# Uninstall Helm charts
echo "Uninstalling Helm charts..."
helm uninstall odoo -n odoo

# Delete the microk8s namespace for the app
echo "Deleting MicroK8s namespace for the app..."
kubectl delete namespace odoo

# Remove microk8s context
echo "Removing microk8s context..."
kubectl config delete-context microk8s

# Remove admin-user cluster role binding
echo "Removing admin-user cluster role binding..."
kubectl delete clusterrolebinding admin-user-cluster-admin

# Delete admin-user secret and service account
echo "Deleting admin-user secret and service account..."
kubectl delete secret admin-user-token -n kube-system
kubectl delete serviceaccount admin-user -n kube-system

# Remove kube config
echo "Removing kube config..."
rm -f $HOME/.kube/config

# Uninstall Helm
echo "Uninstalling Helm..."
sudo snap remove helm

# Stop and disable MicroK8s
echo "Stopping and disabling MicroK8s..."
sudo microk8s stop
sudo snap disable microk8s

# Remove MicroK8s permissions
echo "Removing MicroK8s permissions..."
sudo deluser $USER microk8s

# Uninstall kubectl
echo "Uninstalling kubectl..."
sudo snap remove kubectl

# Uninstall MicroK8s
echo "Uninstalling MicroK8s..."
sudo snap remove microk8s

echo "Uninstall complete!"

# Step 2: Clean up remaining artifacts
echo "Cleaning up remaining artifacts..."
sudo rm -rf /var/snap/microk8s

echo "Done!"