# MyApp Deployment on AWS

This project automates the deployment of MyApp on AWS using Terraform and Ansible. It sets up the required infrastructure resources and configures the application environment.

## Prerequisites

Before you begin, ensure that you have the following prerequisites installed:

- Terraform (version X.X.X)
- Ansible (version X.X.X)
- AWS CLI (version X.X.X)
- Python (version X.X.X)

## Deployment Steps

Follow the steps below to deploy MyApp on AWS:

1. Clone the project repository:

2. git clone https://github.com/carixe12/infra
3. 2. Change into the project directory
4. Set up the AWS credentials:
5. Provide your AWS access key, secret key, default region, and output format.

4. Update the Terraform variables:

Open the `terraform/variables.tf` file and update the variables as per your requirements. For example, you might need to specify the VPC ID, subnet IDs, and other configuration details.

5. Initialize Terraform.
6. terraform init.
7. Deploy the infrastructure:
8. Review the changes and confirm the deployment by typing "yes".

7. Wait for the Terraform deployment to complete.

8. Update the Ansible inventory:

Open the `ansible/inventory/aws_hosts` file and update the IP address or hostname of the deployed EC2 instance.

9. Deploy the application using Ansible:
10. Ansible will connect to the EC2 instance and configure the necessary dependencies, such as installing Docker and deploying the application.

10. Once the Ansible playbook completes successfully, the MyApp application should be accessible at the specified IP address or hostname.

## Clean Up

To clean up and destroy the AWS infrastructure, run the following command from the `terraform` directory:
Review the changes and confirm the destruction by typing "yes".

