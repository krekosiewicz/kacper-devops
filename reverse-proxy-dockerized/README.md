# 🧭 Reverse Proxy (Production)

This repository contains a production-ready **NGINX + Certbot** reverse proxy setup, running inside Docker. It handles **HTTPS termination**, **automatic certificate renewal**, and proxies incoming traffic to multiple containerized web apps on the same VPS.

---

## ✅ Features

- ✅ Centralized HTTPS via Let's Encrypt
- ✅ One reverse proxy container for all your apps
- ✅ Per-domain config via `sites/*.conf`
- ✅ Auto-renewal compatible (via cron or manual)
- ✅ Easily extensible: drop new `.conf` + issue cert
- ✅ Shared Docker network support (`reverse-proxy-net`)
- ✅ Supports bootstrapping certs via lightweight `nginx.certonly.conf`

---

## 📦 Project Structure

```
reverse-proxy-dockerized-prod/
├── Dockerfile
├── docker-compose.yml
├── nginx.conf               # Main config used in production
├── nginx.certonly.conf      # Lightweight HTTP-only config used before certs exist
├── entrypoint.sh
├── README.md
├── sites/
│   ├── example.com.conf
│   └── yourdomain.com.conf
└── data/
    └── certbot/
        ├── conf/         # /etc/letsencrypt (certs)
        └── www/          # /var/www/certbot (challenge)
```

---

## 🚀 Full Setup Flow

### 1. Set DNS A Record

Make sure your domain(s) (e.g., `yourdomain.com`, `www.yourdomain.com`) point to your VPS IP.

---

### 2. Create Shared Docker Network

Both the cert-only and production containers must be in the same Docker network:

```bash
docker network create reverse-proxy-net
```

### 2.1 Start/Connect Your App Container

Make sure your app container is running and attached to `reverse-proxy-net`.

```bash
docker network connect reverse-proxy-net your_app_container
```

Your app should expose port `3000` internally (or any other port)


---

### 3. Bootstrap Certificates (optional if certs already exist)

Before starting the production reverse proxy, use this **lightweight cert-only** nginx container:

#### Step 3.1: Start Certonly Nginx (Temporary)
```bash
docker run --rm \
  -v "$(pwd)/data/certbot/conf:/etc/letsencrypt" \
  -v "$(pwd)/data/certbot/www:/var/www/certbot" \
  -v "$(pwd)/nginx.certonly.conf:/etc/nginx/nginx.conf:ro" \
  --network reverse-proxy-net \
  -p 80:80 \
  nginx:alpine
```

> This will serve `/.well-known/acme-challenge/` for any domain.

#### Step 3.2: Issue Certificates

```bash
docker run --rm \
  -v "$(pwd)/data/certbot/conf:/etc/letsencrypt" \
  -v "$(pwd)/data/certbot/www:/var/www/certbot" \
  certbot/certbot certonly \
  --webroot --webroot-path=/var/www/certbot \
  --email your@email.com \
  --agree-tos --no-eff-email \
  -d yourdomain.com -d www.yourdomain.com
```

Certificates will be saved to:

```
./data/certbot/conf/live/yourdomain.com/
```

---

### 4. Stop Certonly Nginx

Use Ctrl+C or `docker stop` if running detached.

---

### 5. Start Production Proxy

```bash
docker compose up -d --build
```

It will now use the generated certs and proxy based on `sites/*.conf`.

---

## ➕ Adding a New App (with HTTPS)

1. Ensure your app runs inside Docker and is connected to `reverse-proxy-net`
2. Add a new `.conf` file in `sites/`
3. Use container name (not IP) in `proxy_pass`
4. Issue certs as described above
5**Symlink your config to enable it** (if container is already running):

```bash
docker compose exec reverse-proxy ln -s /etc/nginx/sites-available/example.com.conf /etc/nginx/sites-enabled/example.com.conf
docker compose exec reverse-proxy nginx -s reload
```

Alternatively, restart proxy to pick it up:
```bash
docker compose restart reverse-proxy
```


### Example `sites/yourdomain.com.conf`:

simplified, in sites/example.com.conf you'll find advanced version.

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://yourdomain.com$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://your-container-name:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## 🔄 Auto-Renewal (via cron)

Run this command manually or schedule via crontab:

```bash
docker compose run --rm certbot renew
docker compose exec reverse-proxy nginx -s reload
```

### Example Crontab:

```bash
0 3 * * * cd /home/YOUR_USER/reverse-proxy-dockerized-prod && docker compose run --rm certbot renew && docker compose exec reverse-proxy nginx -s reload
```

---

## 🧼 Stop and Clean Up

```bash
docker compose down
```

---

## 💡 Notes

- This reverse proxy owns **ports 80 and 443**.
- Container **names** can be used in `proxy_pass` as long as both containers are in the same Docker network.
- You can debug using:
  ```bash
  docker compose logs -f reverse-proxy
  ```

---

## 🛠 Todo / Ideas

- [ ] Add self-monitoring health check
- [ ] Add HTTP/2 support
- [ ] Add TLS 1.3 only option
- [ ] Integrate watchdog or failover

---

Happy hosting! 🎉
