#!/bin/bash

set -e

echo "Installing full odoo community system on microk8s..."

# Execute snap_install.sh
echo "Executing snap_install.sh..."
if ./snap_install.sh; then
    echo "Snap installation completed successfully. Proceeding with MicroK8s installation..."
else
    echo "Snap installation failed. Exiting..."
    exit 1
fi

# Execute microk8s_install.sh
echo "Executing microk8s_install.sh..."
if ./microk8s_install.sh; then
    echo "MicroK8s installation completed successfully. Proceeding with Helm chart installation..."
else
    echo "MicroK8s installation failed. Exiting..."
    exit 1
fi

# Execute helm_chart_install.sh
echo "Executing helm_chart_install.sh..."
if ./helm_chart_install.sh; then
    echo "Helm chart installation completed successfully."
else
    echo "Helm chart installation failed. Exiting..."
    exit 1
fi

echo "Installation complete!"
