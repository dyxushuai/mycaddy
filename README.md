# mycaddy

## Overview
Custom Caddy image for L4 (TCP/UDP) proxying with Cloudflare DNS support. Published as ghcr.io/dyxushuai/mycaddy. Built from the official Caddy image with the caddy-l4 and caddy-dns/cloudflare modules. This is not an official Caddy image. Intended for Docker and Docker Compose. Provide your Caddyfile at runtime. Multi-arch image for linux/amd64 and linux/arm64. A scheduled workflow checks upstream versions and publishes a GitHub Release. Each release triggers a multi-arch build to GHCR with a semver tag and `latest`.

## Features
- L4 TCP/UDP proxying via `caddy-l4`
- Cloudflare DNS integration via `caddy-dns/cloudflare`
- Multi-arch images for `linux/amd64` and `linux/arm64`
- Automated upstream checks with Release publishing; each release triggers a multi-arch build with semver tags and `latest`
- Minimal runtime image (Caddy binary only)
- Ready for Docker and Docker Compose

## Included Modules & Versions
- Caddy: `v2.10.2`
- caddy-l4: `040d25cc886ab41afe5a3e25a7cb33a2fcafa202`
- caddy-dns/cloudflare: `v0.2.2`

## Quick Start (Docker)
Create a `Caddyfile` in the current directory, then run:

```bash
docker run --rm \
  -p 80:80 \
  -p 443:443 \
  -p 443:443/udp \
  -p 2019:2019 \
  -v caddy_data:/data \
  -v caddy_config:/config \
  -v "$(pwd)/Caddyfile:/etc/caddy/Caddyfile:ro" \
  ghcr.io/dyxushuai/mycaddy:latest
```

Notes:
- Map only the ports you actually use for L4 listeners.
- Admin API on 2019 is optional; remove it if not needed.
- Persist `/data` and `/config` to keep certificates and autosave state.
- If you use Cloudflare DNS-01, pass `CLOUDFLARE_API_TOKEN` as an env var.

## Docker Compose
```yaml
services:
  caddy:
    image: ghcr.io/dyxushuai/mycaddy:latest
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
      - "2019:2019"
    environment:
      - CLOUDFLARE_API_TOKEN=your_token_here # optional
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_data:
  caddy_config:
```

## Configuration (Caddyfile)
Example L4 TCP proxy:

```caddyfile
{
  layer4 {
    :9000 {
      proxy {
        to 127.0.0.1:9001
      }
    }
  }
}
```

Example L4 UDP proxy:

```caddyfile
{
  layer4 {
    :5353 {
      proxy {
        to 1.1.1.1:53
        transport udp
      }
    }
  }
}
```

Example Cloudflare DNS-01 (HTTP/HTTPS certificates):

```caddyfile
example.com {
  tls {
    dns cloudflare {env.CLOUDFLARE_API_TOKEN}
  }
  respond "ok"
}
```

See also: https://github.com/mholt/caddy-l4
Cloudflare DNS module: https://github.com/caddy-dns/cloudflare

## Image Tags
- `vX.Y.Z`: GitHub Release tag
- `latest`: always points to the most recent release
- Tag scheme: `v<major>.<minor>.<patch>` where major/minor follow Caddy and patch increments on each automated update.

Example:
```bash
docker pull ghcr.io/dyxushuai/mycaddy:v0.0.1
docker pull ghcr.io/dyxushuai/mycaddy:latest
```
