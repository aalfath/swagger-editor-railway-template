#!/bin/sh
# Writes /etc/nginx/conf.d/default.conf for Railway.
#   PORT                 port to listen on (Railway sets it; default 8080)
#   BASIC_AUTH_PASSWORD  when set, the editor asks for HTTP basic auth (the template generates one)
#   BASIC_AUTH_USERNAME  basic auth user name (default: admin)
# Remove BASIC_AUTH_PASSWORD to make the editor public. /healthz never asks for auth.
set -eu

PORT="${PORT:-8080}"
case "$PORT" in ''|*[!0-9]*) echo "40-railway.sh: PORT must be a number, got '$PORT'" >&2; exit 1;; esac

AUTH_BLOCK=""
BASIC_AUTH_USERNAME="${BASIC_AUTH_USERNAME:-admin}"
case "$BASIC_AUTH_USERNAME" in *:*) echo "40-railway.sh: BASIC_AUTH_USERNAME must not contain ':'" >&2; exit 1;; esac
if [ -n "${BASIC_AUTH_PASSWORD:-}" ]; then
  SALT="$(head -c 12 /dev/urandom | od -An -tx1 | tr -d ' \n' | cut -c1-16)"
  HASH="$(mkpasswd -m sha512 "$BASIC_AUTH_PASSWORD" "$SALT")"
  printf '%s:%s\n' "$BASIC_AUTH_USERNAME" "$HASH" > /etc/nginx/.htpasswd
  chmod 0640 /etc/nginx/.htpasswd
  chown root:nginx /etc/nginx/.htpasswd
  AUTH_BLOCK='auth_basic "Swagger Editor"; auth_basic_user_file /etc/nginx/.htpasswd;'
  echo "40-railway.sh: basic auth enabled for user '$BASIC_AUTH_USERNAME'"
else
  echo "40-railway.sh: BASIC_AUTH_PASSWORD is empty, so the editor is public (no login)"
fi

# Listen on IPv6 too when the kernel has it (Railway's private network is IPv6).
LISTEN6=""
[ -f /proc/net/if_inet6 ] && LISTEN6="listen [::]:${PORT};"

cat > /etc/nginx/conf.d/default.conf <<CONF
server {
    listen ${PORT};
    ${LISTEN6}
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    gzip_static on;
    gzip on;
    gzip_types text/css application/javascript application/json application/wasm image/svg+xml text/yaml;
    gzip_min_length 1024;

    # Health check for Railway (no auth, no logging).
    location = /healthz {
        access_log off;
        default_type text/plain;
        return 200 "ok\n";
    }

    location / {
        ${AUTH_BLOCK}
        try_files \$uri \$uri/ /index.html;
    }

    # Content-hashed bundles: safe to cache for a long time.
    location ~ ^/static/(js|css)/ {
        ${AUTH_BLOCK}
        add_header Cache-Control "public, max-age=31536000, immutable";
        try_files \$uri =404;
    }

    location = /index.html {
        ${AUTH_BLOCK}
        add_header Cache-Control "no-cache";
    }
}
CONF

echo "40-railway.sh: Swagger Editor listening on port ${PORT}"
