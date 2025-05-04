#!/bin/sh

# Auto-enable all configs (optional for simplicity)
for file in /etc/nginx/sites-available/*.conf; do
  ln -sf "$file" /etc/nginx/sites-enabled/$(basename "$file")
done


# Start nginx in foreground
exec nginx -g 'daemon off;'
