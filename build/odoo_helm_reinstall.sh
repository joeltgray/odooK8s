#!/bin/bash

echo "Uninstalling Helm charts from microk8s cluster..."
cd ../helm
helm uninstall odoo -n odoo

echo "Sleeping for 10 seconds to allow pods to terminate..."
sleep 10

echo "Reinstalling Helm charts to microk8s cluster..."
helm install odoo . -n odoo

echo "Complete!"

kubectl get pods -n odoo

