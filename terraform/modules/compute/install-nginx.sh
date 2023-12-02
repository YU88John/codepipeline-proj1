#!/bin/bash

# Install Node.js
sudo yum update -y
sudo yum install -y nodejs
sudo yum install -y git

# Clone your Node.js application repository (replace <your-repo-url> with the actual URL)
git clone https://github.com/YU88John/codepipeline-proj1.git
cd codepipeline-proj1/app/

# Install application dependencies
npm install

# Fetch RDS endpoint from Terraform output (replace <your-terraform-output-name> with the actual output name)
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)

# Set environment variable for RDS endpoint
echo "export RDS_ENDPOINT=${RDS_ENDPOINT}" >> ~/.bashrc
source ~/.bashrc

# Start your Node.js application (replace app.js with the actual entry point of your app)
node app.js
