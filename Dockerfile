# Stage 1 : récupérer le binaire du proxy MCP
FROM ghcr.io/tbxark/mcp-proxy:latest AS proxy

# Stage 2 : front HTTP (Caddy) + reverse proxy
FROM caddy:alpine

# Binaire MCP proxy
COPY --from=proxy /main /usr/local/bin/mcp-proxy

# Config Caddy
COPY Caddyfile /etc/caddy/Caddyfile

# Render fournira $PORT au runtime
ENV PORT=8080
EXPOSE 8080

# Lance MCP proxy sur 9090 + Caddy en front sur $PORT
CMD ["/bin/sh","-c","PORT=9090 /usr/local/bin/mcp-proxy --config /etc/secrets/config.json & exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile"]
