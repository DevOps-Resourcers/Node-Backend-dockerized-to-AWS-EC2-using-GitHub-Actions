#!/bin/bash

# Update the package list and install prerequisites
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up the stable repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the package list again
sudo apt-get update

# Install Docker CE
sudo apt-get install -y docker-ce

# Check Docker version
docker --version

# Check Docker status (non-interactive)
if systemctl is-active --quiet docker; then
    echo "Docker is running."
else
    echo "Docker is not running. Attempting to start Docker..."
    sudo systemctl start docker
    if systemctl is-active --quiet docker; then
        echo "Docker started successfully."
    else
        echo "Failed to start Docker."
        exit 1
    fi
fi

# Add the docker group if it doesn't already exist
sudo groupadd docker

# Add the current user to the docker group
sudo usermod -aG docker ${USER}

# Apply the new group membership without re-login
exec sg docker newgrp `id -gn`

# Run a test Docker container
docker run hello-world

# Print a message indicating completion
echo "Docker installation and setup completed successfully."




# Update packages
sudo apt update -y

# Install unzip and curl
sudo apt install -y unzip curl

# Download AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip the installer
unzip awscliv2.zip

# Run the installer
sudo ./aws/install

# Verify installation
aws --version
