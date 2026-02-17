# syntax=docker/dockerfile:1

FROM caddy:2-builder AS builder

ARG CADDY_VERSION=v2.10.2
ARG L4_COMMIT=eca560d759c9378bda81445b9f0f1a3aaec98b5f
ARG CLOUDFLARE_VERSION=v0.2.3

RUN xcaddy build ${CADDY_VERSION} \
  --with github.com/mholt/caddy-l4@${L4_COMMIT} \
  --with github.com/caddy-dns/cloudflare@${CLOUDFLARE_VERSION}

FROM caddy:2
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
