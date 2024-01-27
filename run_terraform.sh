#!/bin/zsh

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Create a Terraform plan
echo "Creating Terraform plan..."
terraform plan -out=tfplan

# Apply the Terraform plan
echo "Applying Terraform plan..."
terraform apply "tfplan"
