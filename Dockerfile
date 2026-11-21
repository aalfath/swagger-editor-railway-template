# Swagger Editor for Railway
# Official image, pinned by version and digest. Bump both together (see CHANGELOG.md).
FROM swaggerapi/swagger-editor:v5.11.1@sha256:63ca789b8eb565dcf9174b7fc615ceedf48a9f795edf77cb1b8d532270d7ab18

# worker_processes is fixed at 2: "auto" would start one worker per host CPU on Railway.
# Pre-compress the large JS/CSS/WASM bundles once at build time, so nginx can serve
# the .gz files directly (gzip_static) instead of 14 MB of raw JavaScript.
RUN find /usr/share/nginx/html -type f \( -name '*.js' -o -name '*.css' -o -name '*.wasm' -o -name '*.svg' -o -name '*.json' -o -name '*.yml' -o -name '*.html' -o -name '*.ttf' \) \
      -size +1k -exec gzip -9 -k {} \; \
 && rm /etc/nginx/conf.d/default.conf \
 && sed -i 's/^worker_processes .*/worker_processes 2;/' /etc/nginx/nginx.conf

# Start-up hook run by the image's own /docker-entrypoint.sh: writes the nginx
# server block for Railway's PORT, a /healthz path and optional basic auth.
COPY --chmod=0755 rootfs/40-railway.sh /docker-entrypoint.d/40-railway.sh

ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
