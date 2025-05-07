# 🚗 Ride App Backend - CI/CD Pipeline with SonarQube & EC2 Deployment

This repository implements a complete CI/CD pipeline for the **Ride App Backend** using **GitHub Actions**. It includes **SonarQube analysis**, **Docker image creation**, **push to Amazon ECR**, and **automated deployment to an EC2 instance**.

---

## 📌 Workflow Overview

This workflow performs the following steps on every **pull request to `main` or `master`**:

### ✅ SonarQube Code Quality Analysis
1. Checkout the project repository.
2. Install Node.js and dependencies.
3. Download and run the SonarQube Scanner CLI.
4. Check and verify the **Quality Gate** status.

### 🐳 Docker Image Build & EC2 Deployment
1. Build the Docker image for the backend.
2. Push the image to **Amazon ECR**.
3. SSH into an **EC2 instance**, clean existing Docker containers and images.
4. Pull the new image and run the container on port `4000`.

---

## 📁 Workflow File: `.github/workflows/ci-cd.yml`

```yaml
name: Ride App Backend SonarQube Analysis & Deployment to EC2

on:
  pull_request:
    branches:
      - main
      - master

env:
  AWS_REGION: ${{ secrets.AWS_REGION }}
  ECR_REPO: ${{ secrets.ECR_REPOSITORY }}
  ECR_REGISTRY: ${{ secrets.ECR_REGISTRY }}
  IMAGE_TAG: latest

jobs:
  sonar-scanner:
    name: 🧩 SonarQube Analysis
    runs-on: ubuntu-latest
    steps:
      - name: 📥 Checkout repository
        uses: actions/checkout@v3

      - name: 🛠️ Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "20.9.0"

      - name: 📦 Install dependencies
        run: npm install

      - name: 📡 Download SonarQube Scanner CLI
        run: |
          wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
          unzip sonar-scanner-cli-5.0.1.3006-linux.zip
          mv sonar-scanner-5.0.1.3006-linux sonar-scanner

      - name: 🧪 Run SonarQube Analysis
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          HOST_URL: ${{ secrets.HOST_URL }}
          PROJECT_KEY: ${{ secrets.PROJECT_KEY }}
        run: |
          ./sonar-scanner/bin/sonar-scanner \
            -Dsonar.projectKey=$PROJECT_KEY \
            -Dsonar.sources=. \
            -Dsonar.host.url=$HOST_URL \
            -Dsonar.login=$SONAR_TOKEN
      - name: ⏳ Wait for SonarQube Analysis and Check Quality Gate
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          HOST_URL: ${{ secrets.HOST_URL }}
          PROJECT_KEY: ${{ secrets.PROJECT_KEY }}
        run: |
          sleep 5  # Give SonarQube time to process
          ANALYSIS_ID=$(curl -s -u $SONAR_TOKEN: "$HOST_URL/api/ce/component?component=$PROJECT_KEY" | jq -r '.queue[0].id')

          STATUS="PENDING"
          while [ "$STATUS" == "PENDING" ]; do
            sleep 5
            STATUS=$(curl -s -u $SONAR_TOKEN: "$HOST_URL/api/ce/task?id=$ANALYSIS_ID" | jq -r '.task.status')
          done

          QUALITY_STATUS=$(curl -s -u $SONAR_TOKEN: "$HOST_URL/api/qualitygates/project_status?projectKey=$PROJECT_KEY" | jq -r '.projectStatus.status')

          echo "Quality Gate Status: $QUALITY_STATUS"
          if [ "$QUALITY_STATUS" != "OK" ]; then
            echo "::error::Quality gate failed with status: $QUALITY_STATUS"
            exit 1
          fi

  build-push-deploy:
    name: 🌏 Build, Push and Deploy Ride App Backend
    runs-on: ubuntu-latest
    needs: sonar-scanner

    steps:
      - name: 📥 Checkout code
        uses: actions/checkout@v3

      - name: 🔐 Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: 🔑 Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: 🏗️ Build Docker image
        run: |
          docker build -t $ECR_REPO:$IMAGE_TAG .
          docker tag $ECR_REPO:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG

      - name: 📤 Push Docker image to ECR
        run: |
          docker push $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG

      - name: 🗝️ Setup SSH Key for EC2 Access
        run: |
          echo "${{ secrets.EC2_SSH_KEY }}" > key.pem
          chmod 600 key.pem

      - name: 🚀 Deploy on EC2 Instance
        run: |
          ssh -o StrictHostKeyChecking=no -i key.pem ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }} << EOF
            
            sudo usermod -aG docker $USER
            
            echo "-------------------------------------"
            echo "Waiting for Docker cache cleaning..."
            echo "-------------------------------------"

            # Stop and remove all running containers
            docker ps -aq | xargs -r docker stop
            docker ps -aq | xargs -r docker rm

            # Remove all images
            docker images -aq | xargs -r docker rmi -f

            # Remove build cache
            docker builder prune -af

            echo "--------------------"
            echo "Docker cache removed"
            echo "--------------------"

            echo "--------------------"
            echo "Docker Login to ECR"
            echo "--------------------"

            sudo docker login -u AWS -p \$(aws ecr get-login-password --region $AWS_REGION) $ECR_REGISTRY

            echo "--------------------"
            echo "Docker Pulling Image"
            echo "--------------------"

            sudo docker pull $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG

            echo "-------------------------"
            echo "Docker Starting Container"
            echo "-------------------------"
            sudo docker stop node-backend || true
            sudo docker rm node-backend || true
            sudo docker run -d --restart always --name node-backend -p 4000:4000 $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG

            echo "------------------------"
            echo "Docker Container Running"
            echo "------------------------"

          EOF



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

```

Here's your production-ready step-by-step guide in a nicely formatted Markdown file with eye-catching icons:

```markdown
# 🚀 Production-Ready Setup for Ride App Backend (Docker + Nginx + SSL)

## 🔹 1. Run Docker Container on Port `9000`

```bash
docker run -d -p 9000:9000 --name ride-backend your-image-name
```

> ✅ Ensure your backend container exposes **port 9000**

---

## 🌐 2. Map Domain to EC2

🔧 **DNS A Record Setup**  
- **Type:** A  
- **Host:** `api`  
- **Value:** `<EC2 Elastic IP>`  

➡️ This maps `api.myrideapp.com` to your EC2 instance.

---

## 🔐 3. Update EC2 Security Group Rules

✅ Allow **Inbound Traffic** on:

- **Port 80** (HTTP)  
- **Port 443** (HTTPS)

---

## 🛠️ 4. Install Nginx on EC2

```bash
sudo apt update
sudo apt install nginx -y
```

---

## ⚙️ 5. Configure Nginx to Proxy Requests to Docker

```bash
sudo vi /etc/nginx/sites-available/rideapp
```

🔻 Paste the following config:

```nginx
server {
    listen 80;
    server_name api.myrideapp.com;

    location / {
        proxy_pass http://localhost:9000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

🔗 Enable the config:

```bash
sudo ln -s /etc/nginx/sites-available/rideapp /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 🔒 6. Secure with HTTPS via Certbot

```bash
sudo apt install certbot python3-certbot-nginx -y
```

🔐 Run Certbot:

```bash
sudo certbot --nginx -d api.myrideapp.com
```

✨ It will:
- Automatically fetch an SSL certificate
- Update your Nginx config
- Enable HTTPS redirection

---

## ❌ Uninstall Nginx (Optional)

If you ever want to **remove Nginx completely**, follow these steps:

1️⃣ **Stop Nginx**
```bash
sudo systemctl stop nginx
```

2️⃣ **Uninstall Nginx packages**
```bash
sudo apt remove nginx nginx-common -y
sudo apt remove nginx-full nginx-core -y  # if installed
```

3️⃣ **Purge config files**
```bash
sudo apt purge nginx nginx-common -y
```

4️⃣ **Delete remaining Nginx directories**
```bash
sudo rm -rf /etc/nginx
sudo rm -rf /var/www/html
sudo rm -rf /var/log/nginx
```

---

✅ **You now have a production-grade backend setup with Docker, Nginx reverse proxy, and HTTPS enabled!**

```

Would you like this in a downloadable `.md` file?

