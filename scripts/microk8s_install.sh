#!/bin/bash

# Ensure Snap is installed and systemd service snapd.apparmor is enabled

# Install mk8s
echo "Installing MicroK8s..."
if ! sudo snap install microk8s --classic; then
    echo "Failed to install MicroK8s"
    echo "This is probably a snap issue, check your logs"
    echo "Exiting!"
    exit 1
fi
# Give mk8s permissions
echo "Giving MicroK8s permissions..."
sudo usermod -a -G microk8s $USER

echo "Setting permissions..."
sudo chown -f -R $USER ~/.kube

# echo "Creating microk8s group.."
# newgrp microk8s

#check mk8s is running
echo "Checking MicroK8s status..."
microk8s status --wait-ready

#make kubectl available
echo "Making kubectl command available..."
# Check Linux distribution
if [[ $(cat /etc/os-release) =~ "Ubuntu" ]]; then
    echo "Detected Ubuntu"
    sudo apt-get install -y kubectl
elif [[ $(cat /etc/os-release) =~ "Arch" ]]; then
    echo "Detected Arch Linux"
    sudo pacman -S --noconfirm kubectl
else
    echo "Unsupported Linux distribution. Exiting..."
    exit 1
fi

#check if kubectl installed:
echo "Checking kubectl version..."
kubectl version --output=json

#save kube config
echo "Saving kube config..."
microk8s.kubectl config view --raw > $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

#import CA certs
echo "Importing CA certs..."
sudo cp /var/snap/microk8s/current/certs/ca.crt /usr/local/share/ca-certificates/microk8s.crt
# Run the trust command on Arch Linux
sudo trust extract-compat

# # Run the update-ca-certificates command on Debian-based systems
# sudo update-ca-certificates

#print microk8s cluster info
echo "Printing MicroK8s cluster info..."
microk8s config

#enable addons
echo "Enabling MicroK8s addons..."
microk8s enable dashboard

#create admin-user
echo "Creating admin-user with token and secrets..."
kubectl create sa admin-user -n kube-system
perform_sleep 10
kubectl create secret generic admin-user-token --from-literal=token=$(microk8s kubectl create token admin-user -o jsonpath='{.token}') -n kube-system
kubectl -n kube-system patch serviceaccount admin-user -p '{"imagePullSecrets": [{"name": "admin-user-token"}]}'

#set context
echo "Setting microk8s context..."
kubectl config set-context microk8s --cluster=microk8s-cluster --user=admin-user
kubectl config use-context microk8s
kubectl create clusterrolebinding admin-user-cluster-admin --clusterrole=cluster-admin --serviceaccount=odoo:admin-user

#install helm
echo "Installing Helm..."
sudo snap install helm --classic

#create microk8s namespace for our app
echo "Creating MicroK8s namespace for our app..."
kubectl create namespace odoo

#install helm charts
echo "Installing Helm charts..."
cd ../charts
helm install odoo . -n odoo

#check all namespaces
echo "Checking items in all namespaces you may need to check again as pods may still be coming up..."

#check pods
echo "Checking pods..."
kubectl get pods --all-namespaces

#check services
echo "Checking all services..."
kubectl get services --all-namespaces

#check deployments
echo "Checking all deployments..."
kubectl get deployments --all-namespaces

#install complete
echo "Install complete!"


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