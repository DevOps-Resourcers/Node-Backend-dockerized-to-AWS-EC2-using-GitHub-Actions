# -----------------------------------------------------------------------------
# |                          Ride App Backend Deployment                      |
# -----------------------------------------------------------------------------
# |                          Configurations and Secrets                       |
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Secrets Configuration                                                       |
# -----------------------------------------------------------------------------
# To use this workflow, you need to set up the following secrets in your GitHub

# SonarQube Server secrets:
# AWS IAM User secrets:
# AWS IAM Role policies:
# Deploying EC2 instance secrets:

# export ECR_REGISTRY=aws_account_id.dkr.ecr.region.amazonaws.com
# export ECR_REPO=your-repository-name
# export IMAGE_TAG=your-tag

# -----------------------------------------------------------------------------
# Secret Key            | Description                                         |
# -----------------------------------------------------------------------------
# AWS_ACCESS_KEY_ID     | Your AWS access key                                 |
# AWS_SECRET_ACCESS_KEY | Your AWS secret key                                 |
# AWS_REGION            | e.g. us-east-1                                      |
# ECR_REPOSITORY        | e.g. node-backend                                   |
# ECR_REGISTRY          | e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com   |
# EC2_HOST              | EC2 Public IP or DNS                                |
# EC2_USER              | SSH username (e.g., ec2-user)                       |
# EC2_SSH_KEY           | Base64-encoded private SSH key                      |
# HOST_URL              | SonarQube server URL                                |
# PROJECT_KEY           | SonarQube project key                               |
# SONAR_TOKEN           | SonarQube authentication token                      |
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# AWS IAM User Permissions
# -----------------------------------------------------------------------------

# 1. AmazonEC2FullAccess
#    - Required to interact with EC2 instances (e.g., SSH access, managing instances).

# 2. AmazonEC2ContainerRegistryFullAccess
#    - Required to create, manage, and push Docker images to Amazon Elastic Container Registry (ECR).

# 3. SecretsManagerReadWrite (or specific permissions for secrets)
#    - Required to retrieve secrets from AWS Secrets Manager for use in the container.

# 4. CloudWatchLogsFullAccess (Optional)
#    - Recommended for logging and monitoring purposes.

# -----------------------------------------------------------------------------
# I am role policies
# -----------------------------------------------------------------------------
# 1. AmazonEC2ContainerRegistryPowerUse
# 2. AmazonElasticContainerRegistryPublicReadOnly
# 3. SecretsManagerReadWrite

# -----------------------------------------------------------------------------
# Pre requisites
# -----------------------------------------------------------------------------

# - EC2 instance should have an IAM role with permissions to access ECR
# - EC2 instance should have Docker installed and running
# - Ensure the security group of the EC2 instance allows inbound traffic on port 4000
