# 📚 NGINX for Secure Reverse Proxy

This short guide summarizes key security and performance concepts found in a production-grade `nginx.conf` file used for containerized apps behind a reverse proxy. It's focused on HTTPS, Let's Encrypt, and best security practices.

---

## 🌍 Basic Structure

```nginx
user nginx;
worker_processes auto;
```

- **`user nginx`**: runs the worker processes with the `nginx` user for security.
- **`worker_processes auto`**: uses all available CPU cores.

```nginx
events {
    worker_connections 1024;
}
```

- Limits how many simultaneous connections each worker can handle.

---

## 📄 Logging & File Types

```nginx
log_format main ...;
access_log /var/log/nginx/access.log main;
include /etc/nginx/mime.types;
default_type application/octet-stream;
```

- Defines log format and output.
- MIME types for handling file extensions like `.html`, `.css`, `.png`.

---

## 🚀 Performance

```nginx
sendfile on;
keepalive_timeout 65;
```

- **`sendfile`**: speeds up file serving.
- **`keepalive_timeout`**: how long to keep connections open.

---

## 🔐 Server Blocks

### HTTP Server (Port 80)

```nginx
server {
    listen 80;
    server_name example.com www.example.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
        try_files $uri =404;
    }

    location / {
        return 301 https://example.com$request_uri;
    }
}
```

- Handles **HTTP** traffic.
- Lets Certbot handle `/.well-known/acme-challenge/` for Let's Encrypt.
- Redirects all other traffic to **HTTPS**.

---

### HTTPS Server (Port 443)

```nginx
server {
    listen 443 ssl;
    server_name example.com;

    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
```

- TLS certificates served via **Let's Encrypt**.
- Each domain needs its own `ssl_certificate` and `ssl_certificate_key`.

---

## ✅ HTTPS Best Practices

### HSTS (HTTP Strict Transport Security)

```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
```

- Forces browsers to always use HTTPS, even on first visit.
- `preload` allows you to submit to browser preload lists (optional, irreversible).

---

### OCSP Stapling

```nginx
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 valid=300s;
resolver_timeout 5s;
```

- Speeds up and **secures SSL validation**.
- Prevents visitors from querying the certificate authority directly.

---

### SSL Session Cache

```nginx
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1h;
```

- Speeds up repeat SSL connections.
- Reduces handshake overhead.

---

### Cipher Suites

```nginx
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:...';
ssl_prefer_server_ciphers on;
```

- Specifies **strong modern encryption algorithms**.
- Prioritizes server-preferred ciphers (over client's).

---

## 🔁 DNS CAA Record

> _This is not in NGINX but a DNS setting._

- A **CAA record** allows you to specify **which Certificate Authorities (CAs)** can issue certs for your domain.
- Helps prevent unauthorized certs.
- Example CAA record (set via your DNS provider):

```
example.com.  CAA 0 issue "letsencrypt.org"
```

---

## 🧠 Summary

| Concept         | Purpose                                    |
|-----------------|--------------------------------------------|
| HTTP Block      | Allow Certbot + redirect to HTTPS          |
| HSTS Header     | Force HTTPS even on first visit            |
| OCSP Stapling   | Improve SSL verification privacy/perf      |
| Cipher Suites   | Use only modern, secure algorithms         |
| Certbot Support | Automatically issue/renew certs            |
| Session Cache   | Speed up repeated secure connections       |

This config is an excellent base for production. You can now reuse this logic in reverse proxies or per-app configs with minimal changes.
