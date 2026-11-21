[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/swagger-editor?utm_medium=integration&utm_source=button&utm_campaign=swagger-editor)

# Swagger Editor on Railway

One-click [Swagger Editor](https://github.com/swagger-api/swagger-editor) for [Railway](https://railway.com): the browser editor for OpenAPI and AsyncAPI definitions, with live documentation preview and validation.

## What this deploys

| Service | Source | What it does |
| --- | --- | --- |
| Swagger Editor | this repo (`Dockerfile`) | nginx serving the official Swagger Editor build on Railway's `PORT`, with a `/healthz` check and optional HTTP basic auth |

- Upstream version: **Swagger Editor v5.11.1**
- Image: `swaggerapi/swagger-editor:v5.11.1@sha256:63ca789b8eb565dcf9174b7fc615ceedf48a9f795edf77cb1b8d532270d7ab18` (pinned by version and digest)
- The wrapper only adds an nginx config hook (`rootfs/40-railway.sh`) and pre-compresses the large JavaScript bundles at build time.

No database and no volume: Swagger Editor runs entirely in the browser and keeps the spec you are editing in that browser's local storage. Save a copy from the editor's File menu to keep it.

## Variables

| Variable | Default in the template | Meaning |
| --- | --- | --- |
| `BASIC_AUTH_PASSWORD` | generated (`${{secret(24)}}`) | Password for the browser login. Delete the variable to make the editor public. |
| `BASIC_AUTH_USERNAME` | `admin` | User name for the browser login. |
| `PORT` | `8080` | Port nginx listens on. |

After the deploy, open the service's **Variables** tab to read `BASIC_AUTH_PASSWORD`, then open the public URL and log in as `admin`. `/healthz` answers without a login, for Railway's health check.

## Updates

Railway builds this template from this repo's `main` branch. When we bump the Swagger Editor version here, Railway shows deployers an "update available" notice and you choose when to apply it. Read [CHANGELOG.md](CHANGELOG.md) first; breaking changes are listed at the top of each entry.

## Run it locally

```sh
docker compose -f compose.test.yaml up --build   # public mode, http://localhost:8080
```

## License

Swagger Editor is Apache-2.0 licensed (SmartBear Software, [swagger-api/swagger-editor](https://github.com/swagger-api/swagger-editor)).
