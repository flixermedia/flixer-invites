# Flixer Invites

Run **only** the Flixer invite system, as a standalone service for inviting people to **Flixer, Jellyfin, Emby or Plex**.
No media server, streamer, indexer, AI, search or updater containers: just two containers.

| Container  | What it runs                                                              |
| ---------- | ------------------------------------------------------------------------- |
| `flixer`   | Flixer API + Flixer web app (nginx) + a private Redis the setup wizard needs |
| `postgres` | PostgreSQL 16                                                             |

## Quick start

```bash
git clone https://github.com/flixermedia/flixer-invites && cd flixer-invites
cp .env.example .env          # set POSTGRES_PASSWORD (and HTTP_PORT if 8080 is taken)
docker compose up -d
```

Open <http://localhost:8080>, finish the setup wizard (the database and Redis steps are pre-configured), then add your
media servers and create invites under **Admin → Invites**.

Put it behind your usual HTTPS reverse proxy and set the public URL in the wizard so invite links and emails are correct.

## How it stays in sync with Flixer

This repository contains **no Flixer source code**. `Dockerfile` assembles the image from the official upstream images:

* `ghcr.io/flixermedia/flixer` (API, and its own `processes.config.cjs`, which is reused as-is)
* `ghcr.io/flixermedia/flixer-web` (the built web app)

`.github/workflows/sync.yml` runs hourly. It compares the digests of upstream `:latest` for both images and, when either
changed (or when this repo's own files change), builds and publishes a new multi-arch `ghcr.io/<owner>/flixer-invites`
image tagged `latest`, the upstream API version, and `up-<api>-<web>-<self>`. Unchanged upstream means no rebuild.

Instant sync (optional): add a last step to the upstream publish workflows and create a `INVITES_DISPATCH_TOKEN` secret
(a PAT with `repo` scope on this repository):

```yaml
- name: Notify flixer-invites
  run: |
    curl -fsS -X POST -H "Authorization: Bearer ${{ secrets.INVITES_DISPATCH_TOKEN }}" \
      -H "Accept: application/vnd.github+json" \
      https://api.github.com/repos/flixermedia/flixer-invites/dispatches \
      -d '{"event_type":"upstream-release"}'
```

## Updating

```bash
docker compose pull && docker compose up -d
```

(The in-dashboard updater is not part of this stack because it needs the Docker socket.)

## Backups

Everything lives in two named volumes: `postgres-data` (database) and `flixer-data` (config, secrets, Redis).
