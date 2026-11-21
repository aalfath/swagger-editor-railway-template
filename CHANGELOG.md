# Changelog

## v5.11.1-railway.1 (2026-11-21)

First release.

- Swagger Editor v5.11.1, official image `swaggerapi/swagger-editor:v5.11.1@sha256:63ca789b8eb565dcf9174b7fc615ceedf48a9f795edf77cb1b8d532270d7ab18`.
- nginx listens on Railway's `PORT` (IPv4 and IPv6), `/healthz` health check without login.
- Optional HTTP basic auth: on when `BASIC_AUTH_PASSWORD` is set (the template generates one), user `BASIC_AUTH_USERNAME` (default `admin`).
- JavaScript, CSS and WASM bundles pre-compressed at build time and served with `gzip_static`.
