ARG CADDY_VERSION=2.11.2

FROM docker.io/library/caddy:${CADDY_VERSION}-builder AS builder

RUN xcaddy build \
	--with github.com/caddy-dns/cloudflare

FROM docker.io/library/caddy:${CADDY_VERSION}

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

LABEL org.opencontainers.image.title="Caddy (Cloudflare)"
LABEL org.opencontainers.image.source="https://github.com/N0tAI/caddy-cloudflare"

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
