# Odoo Community Deployment on Kubernetes
This repository provides all the necessary files and instructions to **deploy the Odoo Community system and it's Postgres DB on Kubernetes using Helm charts**. By following the steps below, you can easily set up and run your own Odoo Community instance for free.

This is primarily for deploying Odoo Community from source, but if you wish to use the official docker image see the **'Official Docker Image Install`** section.


## Prerequisites
To get started with the Odoo Community deployment, you will need:

**Linux Environment:** Ensure you have a Linux-based environment to run the deployment scripts, these scripts supports Arch and also Debian distros like Ubuntu.
**Docker:** Ensure you have docker installed, and the correct user permissions to user it as non-root user.
**Git:** Ensure you have git installed as it's needed to clone the repo.


## Installation Steps
Follow the steps below to deploy Odoo Community on Kubernetes:

**Clone the Repository:** Start by cloning this repository to your local machine:

```
git clone https://github.com/joeltgray/odooK8s.git
```
**Navigate to the Directory:** Change into the cloned repository directory:

```
cd odooK8s
```
**Run the Setup Script:** Execute the setup script to install all the necessary dependencies and set up the system:

```
./build/full_system_install.sh
```
This script will automatically install Snap, MicroK8s, Helm, and set up the Odoo deployment using Helm charts. It will handle all the required installations and configurations.

**Access the Odoo Application:** Once the script completes successfully, you can access the Odoo application by opening a web browser and entering the following URL:

```
http://localhost:30000
```
You should now see the Odoo login page, where you can create a new database and start using Odoo.
Note: Odoos default port is 8069 but as we're exposing it through microk8s it need a nodePort number which begins at 30000.

**That's it! You have successfully deployed Odoo Community on Kubernetes using the provided scripts. Enjoy using Odoo for your business needs!**


## Additional Information
### Making Changes to the Source Code
If you need to make changes to the Odoo source code after the initial installation, **you can make changes in the source file and then run the `odoo_helm_reinstall.sh` script**. This script will rebuild and redeploy the Odoo Kubernetes deployment. However, please note that running this script will tear down the existing PostgreSQL database, resulting in data loss. Make sure to back up any critical data before running this script.


### Customization
If you need to customize any configuration settings, **you can modify the values.yaml** file located in the helm/odoo directory. This file contains various options such as image repository, tags, service ports, and database credentials.


## Uninstalling Odoo
If you ever need to **uninstall the Odoo deployment**, you can use the uninstall script provided:

```
./build/full_system_uninstall.sh
```
This script will remove all the deployed components and clean up the system. This will also remove Snap, so be careful using this command if you are using Snap for other things on your system, if you don't use Snap for anything else or the host machine is solely for Odoo deployment then you should be fine.


## Official Docker Image Install
If you prefer to use the official Odoo Docker image instead of building it from source, **you can modify the deployment to use the official image**. Follow the steps below to deploy Odoo using the official Docker image:

1. Open the `values.yaml` file located in the `helm` directory.

2. Find the `image` section and update the `repository` and `tag` fields to match the official Odoo Docker image. For example:

```
image:
  repository: odoo
  tag: 16.0
```
3. Replace 14.0 with the desired Odoo version.
4. Save the values.yaml file.
5. Open the `odoo-deployment.yaml` file located in the `helm/templates` directory.
6. Change the `imagePullPolicy` from `Never` to either `IfNotPresent` or `Always`
7. Save the `odoo-deployment.yaml`` file.
8. Run the odoo_helm_reinstall.sh script to apply the changes and redeploy Odoo
This script will rebuild and redeploy the Odoo Kubernetes deployment using the official Odoo Docker image.

Please note that when using the official Docker image, you won't be able to make direct changes to the Odoo source code. 


## Possible Issues and Troubleshooting

### Issues with Snap Installation

The installation of Snap packages, such as MicroK8s and Helm, can sometimes encounter issues. If you face any problems during the installation process, you can try one or both of the following approachs:

1. **Re-run the Full System Install Script**: Execute the full system install script again to ensure a clean installation:

   ```
   ./build/full_system_install.sh
   ```
This will reinstall all the dependencies, including Snap packages, and set up the Odoo deployment.

2. Run Snap Uninstall and Install Scripts Separately
If the full system install script fails to install the Snap packages, you can try running the Snap uninstall and install scripts separately:

```
./build/snap_uninstall.sh
./build/snap_install.sh
```
Running these scripts individually can help ensure a proper installation of Snap packages.

Please note that these troubleshooting steps are provided as general guidance. It is always recommended to investigate and address specific errors or issues based on your system configuration and requirements.

### Calico-Node Issues
In some cases, the Calico-Node pod may encounter issues during deployment. If you face any networking or connectivity problems, ensure that your /etc/hosts file contains the correct mapping for the hostname localhost. You can add the following line to the file if it doesn't already exist:

```
127.0.0.1 localhost
```

## Todo

1. Add liveness and readiness probes

## Contribute

If you would like to contribute please raise an issue an create a PR against it or you can email me at joel@graycode.ie.


## Disclaimer

Please note that this is a basic setup for deploying Odoo Community on Kubernetes. It is essential to review and ensure that it fits your specific needs and requirements. Additionally, it is your responsibility to back up your own data (including databases) and monitor the system for any issues. I am not responsible for any data loss or problems that may arise from using this setup. If you are unsure about anything please read through the scripts they are not complicated, if you are still unsure about anything please raise an issue or email at joel@graycode.ie.