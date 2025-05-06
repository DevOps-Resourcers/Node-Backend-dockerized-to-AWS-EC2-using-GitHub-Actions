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
