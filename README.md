# Terraform - Fluwd App - AWS Test Environment

## Overview

This IaC will generate the AWS infrastructure with the following resources:

- VPC
- Subnet
- Internet Gateway
- Security Group
- Route Table
- Elastic IP
- EC2 instance
- MySQL RDS

## How to use this

1. Install Terraform
2. Modify the **env.var.tf** and set the value of the following variables:

   - AWS_ACCESS_KEY
   - AWS_SECRET_KEY
   - AWS_REGION
   - AWS_AVAILABILITY_ZONE
   - AWS_INSTANCE_TYPE
   - DB_NAME
   - DB_USER
   - DB_PW

3. Setup the SSH Keypair in your local machine. [Generate a New SSH Key](https://www.ssh.com/academy/ssh/keygen)

4. Start to initialize the terraform. Type **terraform init**

5. Validate the configuration. Type **terraform plan**

6. Build the infrastructure. Type **terraform apply** , to skip the approval. append **--auto-approve**

7. Login to ec2 instance connect and run the scripts. Check first if the mysql server are already started. Type systemctl list-units --type=service --state=inactive

8. Execute the **dataload.sh** script

9. Type env to check if the environment variable DB_HOST contain :3306. Remove the port if exist then execute the **django_dependencies.sh**

10. Once done on testing. Destroy the infrastructure. Type **terraform destroy**

## Terraform Commands

- **terraform init** (initialize)
- **terraform plan** (validate the settings)
- **terraform apply** (deploy to aws)
- **terraform destroy** (remove the created resources of terraform on aws)

## Reminder

- To prevent the challenges of destroying infrastructure, refrain from deleting the **terraform.tfstate, terraform.tfstate.backup** files.

## Todo

- Enrich the data loading and installation of django application
- Dockerize the django application.

## Reference

- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
- https://developer.hashicorp.com/terraform/install
- https://developer.hashicorp.com/terraform/tutorials/aws-get-started
- https://www.ssh.com/academy/ssh/keygen
