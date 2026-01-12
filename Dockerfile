# syntax=docker/dockerfile:1

FROM caddy:2-builder AS builder

ARG CADDY_VERSION=v2.10.2
ARG L4_COMMIT=97fa8c1b6618de1d33dd3021bfa62459e74b016e
ARG CLOUDFLARE_VERSION=v0.2.2

RUN xcaddy build ${CADDY_VERSION} \
  --with github.com/mholt/caddy-l4@${L4_COMMIT} \
  --with github.com/caddy-dns/cloudflare@${CLOUDFLARE_VERSION}

FROM caddy:2
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
