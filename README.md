<div align="center">

<img src="https://raw.githubusercontent.com/flixermedia/flixer/main/resources/logo/flixer-logo.png" alt="Flixer logo" width="112" />

# Flixer Invites

**Standalone invite management for Flixer, Jellyfin, Emby and Plex.**

[![Stars](https://img.shields.io/github/stars/flixermedia/flixer-invites?style=flat-square)](https://github.com/flixermedia/flixer-invites/stargazers) [![Issues](https://img.shields.io/github/issues/flixermedia/flixer-invites?style=flat-square)](https://github.com/flixermedia/flixer-invites/issues)

[Flixer](https://github.com/flixermedia/flixer) · [Documentation](https://docs.flixer.dev) · [Report an issue](https://github.com/flixermedia/flixer-invites/issues)

</div>

---

> [!WARNING]
> **Under active development.** Flixer components and integration contracts may change. Check current source and release notes before upgrading production installations.

> [!NOTE]
> **Role in Flixer:** Run **only** the Flixer invite system as a standalone two-container stack (`flixer` + `postgres`), without the media server, streamer, indexer, AI, search, or updater containers. For the full media platform, start with the [Flixer backend repository](https://github.com/flixermedia/flixer).

## ✨ What's included

| Container  | What it runs                                                                 |
| ---------- | ---------------------------------------------------------------------------- |
| `flixer`   | Flixer API + Flixer web app (nginx) + a private Redis the setup wizard needs |
| `postgres` | PostgreSQL 16                                                                |

## 🚀 Quick start

```bash
git clone https://github.com/flixermedia/flixer-invites && cd flixer-invites
cp .env.example .env          # set POSTGRES_PASSWORD (and HTTP_PORT if 8080 is taken)
docker compose up -d
```

Open <http://localhost:8080>, finish the setup wizard (the database and Redis steps are pre-configured), then add your media servers and create invites under **Admin → Invites**.

Put it behind your usual HTTPS reverse proxy and set the public URL in the wizard so invite links and emails are correct.

## 🔄 How it stays in sync with Flixer

This repository contains **no Flixer source code**. [`Dockerfile`](Dockerfile) assembles the image from the official upstream images:

- `flixermedia/flixer` / `ghcr.io/flixermedia/flixer` (API, and its own `processes.config.cjs`, which is reused as-is)
- `flixermedia/flixer-web` / `ghcr.io/flixermedia/flixer-web` (the built web app)

[`.github/workflows/sync.yml`](.github/workflows/sync.yml) triggers on upstream `repository_dispatch` (`upstream-release`) events from `flixer` and `flixer-web`, and also runs hourly as a fallback. It compares the digests of upstream `:latest` (and `:invites`) for both images and, when either changed (or when this repo's own files change), builds and publishes a new multi-arch `flixermedia/flixer-invites` (and `ghcr.io/<owner>/flixer-invites`) image tagged `latest`, the upstream API version, and `up-<api>-<web>-<self>`. Unchanged upstream means no rebuild.

## ⬆️ Updating

```bash
docker compose pull && docker compose up -d
```

_(The in-dashboard updater is not part of this stack because it needs the Docker socket.)_

## 💾 Backups

Everything lives in two named volumes: `postgres-data` (database) and `flixer-data` (config, secrets, Redis).

## 🧩 Flixer ecosystem

| Repository                                                        | Purpose                                                                                   |
| ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| [Flixer](https://github.com/flixermedia/flixer)                   | The self-hosted backend API, authentication, libraries, and administration service.       |
| [Flixer Web](https://github.com/flixermedia/flixer-web)           | The Vue 3 application that powers browsing, sign-in, discovery, and playback interfaces.  |
| [Flixer Streamer](https://github.com/flixermedia/flixer-streamer) | The Go service responsible for authorised media delivery and FFmpeg processing.           |
| [Flixer Indexer](https://github.com/flixermedia/flixer-indexer)   | The Go worker and API service for discovering, identifying, probing, and enriching media. |
| [Flixer Updater](https://github.com/flixermedia/flixer-updater)   | The Go sidecar that orchestrates Docker Compose updates and restores.                     |
| [Flixer Plugins](https://github.com/flixermedia/flixer-plugins)   | The official versioned catalogue of Flixer plugins and plugin schemas.                    |
| [Flixer Docs](https://github.com/flixermedia/flixer-docs)         | The Docusaurus source for Flixer platform documentation.                                  |

## 🤝 Contributing

Contributions, bug reports and documentation improvements are welcome. Open an [issue](https://github.com/flixermedia/flixer-invites/issues) with reproduction steps or a focused proposal, then submit a pull request against the repository. Keep configuration, examples and documentation aligned with implemented code. For backend contributions, also see the [main contribution guidelines](https://github.com/flixermedia/flixer/blob/main/CONTRIBUTING.md).

## 📄 Licence

Check this repository's [`LICENSE`](LICENSE) file, if present, for the authoritative licensing terms. The [main Flixer backend](https://github.com/flixermedia/flixer/blob/main/LICENSE) uses MIT; licensing for separate components should be verified individually before redistribution.

---

<div align="center">

**Your media. Your server. Your rules.**

Made for the [Flixer](https://github.com/flixermedia) ecosystem.

</div>
