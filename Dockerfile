ARG CADDY_VERSION=2.11.2

FROM docker.io/library/caddy:${CADDY_VERSION}-builder AS builder

RUN xcaddy build \
	--with github.com/caddy-dns/cloudflare

FROM docker.io/library/alpine:3.22

RUN apk add --no-cache \
    ca-certificates \
    mailcap

RUN addgroup -S -g 800 caddy && \
    adduser -S -D -H -G caddy -s /sbin/nologin -u 800 caddy

RUN mkdir -p \
    /config/caddy \
    /data/caddy \
    /etc/caddy \
    /usr/share/caddy

RUN chown -R caddy:caddy /config /data /etc/caddy /usr/share/caddy

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN apk add --no-cache --virtual .setcap-deps libcap && \
    setcap cap_net_bind_service=+ep /usr/bin/caddy && \
    chmod +x /usr/bin/caddy && \
    apk del .setcap-deps

ENV CADDY_VERSION=v${CADDY_VERSION}
ENV XDG_CONFIG_HOME=/config
ENV XDG_DATA_HOME=/data

# Add labels (copied from official file)
LABEL org.opencontainers.image.version=${CADDY_VERSION}
LABEL org.opencontainers.image.title="Caddy (Cloudflare)"
LABEL org.opencontainers.image.description="Caddy for cloudflare dns running as a rootless service"
LABEL org.opencontainers.image.url=https://caddyserver.com
LABEL org.opencontainers.image.documentation=https://caddyserver.com/docs
LABEL org.opencontainers.image.licenses=Apache-2.0
LABEL org.opencontainers.image.source="https://github.com/N0tAI/caddy-cloudflare"

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

WORKDIR /srv

USER caddy

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
