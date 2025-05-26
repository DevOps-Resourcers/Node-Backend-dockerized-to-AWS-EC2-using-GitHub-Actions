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

#### ⚙️ Add Inbound Rule in AWS Security Group for HTTP and HTTPS ⚙️

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
