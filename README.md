# Odoo Community Deployment on Kubernetes

This repository contains the necessary files to deploy Odoo Community on Kubernetes using Helm charts. The deployment separates the Odoo project and the PostgreSQL database into separate pods/services.

## Repository Structure

The repository is organized as follows:

|- charts/
   |- odoo/
      |- Chart.yaml
      |- values.yaml
      |- templates/
         |- odoo-deployment.yaml
         |- postgres-deployment.yaml
         |- service.yaml
|- scripts/
   |- setup.sh
|- README.md


- The `charts` directory contains the Helm chart files for Odoo deployment.
- The `scripts` directory holds the setup script for automating the installation and setup process.
- The `README.md` file provides an overview, instructions, and details about the deployment.

## Prerequisites

Before running the setup script, ensure you have the following prerequisites:

1. MicroK8s install via Snap
2. Kubernetes cluster: Set up a Kubernetes cluster where you will deploy Odoo.
3. Helm: Install Helm on your local machine or cluster to manage the deployment using Helm charts.

## Deployment

To deploy Odoo Community on Kubernetes, follow these steps:
Optional: Make changes to helm charts
Run the setup.sh script.