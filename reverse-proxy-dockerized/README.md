# 🧭 Reverse Proxy (Production)

This repository contains a production-ready **NGINX + Certbot** reverse proxy setup, running inside Docker. It handles **HTTPS termination**, **automatic certificate renewal**, and proxies incoming traffic to multiple containerized web apps on the same VPS.

---

## ✅ Features

- ✅ Centralized HTTPS via Let's Encrypt
- ✅ One reverse proxy container for all your apps
- ✅ Per-domain config via `sites/*.conf`
- ✅ Auto-renewal compatible (via cron or manual)
- ✅ Easily extensible: drop new `.conf` + issue cert

---

## 📦 Project Structure

```
reverse-proxy-dockerized-prod/
├── Dockerfile
├── docker-compose.yml
├── nginx.conf
├── entrypoint.sh
├── README.md
├── sites/
│   ├── example.com.conf
│   └── another-app.com.conf
└── data/
    └── certbot/
        ├── conf/         # /etc/letsencrypt (certs)
        └── www/          # /var/www/certbot (challenge)
```

---

## 🚀 Getting Started

### 1. Set DNS A Record

Point your domain(s) to your VPS IP address (e.g., `example.com` and `www.example.com`).

---

### 2. Start the Proxy

```bash
docker compose up -d --build
```

---

### 3. Issue Certificates

Run this only **after DNS is set** and the proxy is running:

```bash
docker compose run --rm certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email your@email.com \
  --agree-tos \
  --no-eff-email \
  --domain example.com \
  --domain www.example.com
```

Certificates will be saved to:

```
./data/certbot/conf/live/example.com/
```

---

## ➕ Adding a New App (with HTTPS)

1. Choose a new internal app port (e.g., `3002`)
2. Ensure your app is reachable at `localhost:3002`
3. Add a site config file in `sites/yourdomain.com.conf`

#### Example:

> simplified, in sites/example.com.conf you'll find advanced version.

```nginx
server {
    listen 80;
    server_name yourdomain.com;

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
        proxy_pass http://host.docker.internal:3002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

> All configs in `sites-available/` are auto-symlinked to `sites-enabled/` on startup. Delete the `.conf` file or remove the symlink to disable a domain.


4. Reload NGINX:

```bash
docker compose exec reverse-proxy nginx -s reload
```

---

## 🔄 Auto-Renewal (via cron)

Use this command manually or in crontab:

```bash
docker compose run --rm certbot renew
docker compose exec reverse-proxy nginx -s reload
```

### Example crontab:

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

- This reverse proxy owns **ports 80 and 443**. Your apps should expose only internal ports (like `3001`, `3002`).
- Certbot uses `webroot` mode to handle Let's Encrypt challenges.
- You can inspect logs with:
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