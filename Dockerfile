# Flixer Invites: the Flixer API + web app in ONE image (plus a bundled Redis), meant to run next to PostgreSQL.
#
# Nothing from the Flixer repos is copied into this repository. The image is assembled from the official,
# already-published images, so it is always exactly what upstream shipped (see .github/workflows/sync.yml).
ARG FLIXER_VERSION=latest
ARG WEB_VERSION=invites

FROM flixermedia/flixer-web:${WEB_VERSION} AS web

FROM flixermedia/flixer:${FLIXER_VERSION}
ARG FLIXER_VERSION
ARG WEB_VERSION
LABEL org.opencontainers.image.title="Flixer Invites" \
      org.opencontainers.image.description="Flixer invite system (API + web + Redis) for Flixer, Jellyfin, Emby and Plex" \
      org.flixer.upstream.api="${FLIXER_VERSION}" \
      org.flixer.upstream.web="${WEB_VERSION}"

USER root
RUN apk add --force-overwrite --no-cache nginx redis \
    && mkdir -p /srv/web /data/redis /var/lib/flixer/config /run/flixer-secrets /tmp/nginx \
    && chown -R node:node /data /var/lib/flixer /run/flixer-secrets /tmp/nginx

# The web build (including version.json) straight from the upstream web image.
COPY --from=web /usr/share/nginx/html /srv/web
COPY rootfs/nginx.conf /etc/nginx/nginx.conf
COPY rootfs/processes.config.cjs /opt/invites.config.cjs

USER node
ENV PORT=8081 \
    DATA_PATH=/data \
    APP_SECRET_FILE=/data/config/app-secret \
    REDIS_URL=redis://127.0.0.1:6379 \
    WEB_INTERNAL_URL=http://127.0.0.1:8080 \
    FLIXER_MODE=invites \
    STANDALONE_INVITES=true
EXPOSE 8080
VOLUME ["/data"]
HEALTHCHECK --interval=15s --timeout=5s --start-period=60s --retries=5 \
    CMD wget -q --spider http://127.0.0.1:8080/healthz || exit 1
CMD ["pm2-runtime", "start", "/opt/invites.config.cjs", "--env", "production"]
