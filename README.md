Here’s a complete descriptive `README.md` file for your **Ride App Backend SonarQube Analysis & Deployment to EC2** GitHub Actions workflow:

````md
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

<details>
<summary>Click to expand</summary>

```yaml
<YOUR WORKFLOW YAML FILE HERE> 
````

</details>

---

## 🔐 Required GitHub Secrets

Make sure to configure the following **repository secrets** under:

**Settings → Secrets and variables → Actions → New repository secret**

| Secret Name             | Description                                                           |
| ----------------------- | --------------------------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | Your AWS IAM access key                                               |
| `AWS_SECRET_ACCESS_KEY` | Your AWS IAM secret access key                                        |
| `AWS_REGION`            | AWS region, e.g. `us-east-1`                                          |
| `ECR_REPOSITORY`        | Amazon ECR repository name, e.g. `node-backend`                       |
| `ECR_REGISTRY`          | ECR registry URL, e.g. `123456789012.dkr.ecr.us-east-1.amazonaws.com` |
| `EC2_HOST`              | EC2 public IP or domain                                               |
| `EC2_USER`              | EC2 SSH username, e.g. `ec2-user`                                     |
| `EC2_SSH_KEY`           | Your private key (PEM) as a **Base64-encoded** string                 |
| `SONAR_TOKEN`           | SonarQube authentication token                                        |
| `HOST_URL`              | SonarQube server URL                                                  |
| `PROJECT_KEY`           | SonarQube project key                                                 |

---

## 📝 How to Encode PEM Key for `EC2_SSH_KEY`

Run the following command to Base64-encode your PEM key:

```bash
base64 -w 0 key.pem
```

Then, copy and paste the result as your `EC2_SSH_KEY` GitHub secret.

---

## 📦 Prerequisites

Before you use this workflow, ensure the following:

### 🖥️ EC2 Instance

* Docker installed and running.
* IAM role attached with access to ECR.
* Security Group allows inbound access to port `4000`.
* Your app must be listening on port `4000`.

### 📦 ECR & IAM Configuration

#### IAM User Policies (GitHub Secrets)

* `AmazonEC2ContainerRegistryFullAccess`
* `AmazonEC2FullAccess`
* `SecretsManagerReadWrite` *(if needed)*

#### EC2 IAM Role Policies

* `AmazonEC2ContainerRegistryPowerUser`
* `AmazonElasticContainerRegistryPublicReadOnly`

---

## 📊 SonarQube Analysis

This workflow runs SonarQube static code analysis and waits for the **Quality Gate** result. If the quality gate fails, the deployment step is skipped.

Make sure:

* SonarQube project is created with the matching key.
* A valid `SONAR_TOKEN` is generated for your SonarQube instance.
* Your `HOST_URL` points to the SonarQube server.

---

## 📦 Docker Image Tags

* By default, the Docker image is tagged with `latest`.
* You can customize the `IMAGE_TAG` by editing the workflow.

---

## 📡 Deployment on EC2

During deployment:

* All running containers are stopped and removed.
* Old Docker images and cache are cleaned.
* The latest image is pulled and run as `node-backend` on port `4000`.

---

## 🔍 Monitoring & Debugging

* You can monitor workflow runs under the **Actions** tab.
* Use `docker ps`, `docker logs node-backend`, and `docker inspect` on EC2 to debug.
* Ensure your EC2 server has enough storage to rebuild images.

---

## 📌 Example Run Flow

1. Developer creates a PR to `main`.
2. GitHub Actions triggers the `sonar-scanner` job.
3. If quality gate passes, `build-push-deploy` job runs.
4. EC2 server is updated with the latest Docker container.

---

## 📞 Support

If you have any issues configuring or running this workflow, feel free to open an issue on the repository.

---

## ✅ License

This repository is licensed under the [MIT License](LICENSE).

```

Would you like me to generate this file and add it to your GitHub repo directly?
```

