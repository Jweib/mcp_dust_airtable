# On récupère juste le binaire mcp-proxy depuis l'image officielle
FROM ghcr.io/tbxark/mcp-proxy:latest AS proxy

# Image runtime Debian (pas Alpine → pas d'apk)
FROM debian:bookworm-slim

# Déps utiles (certifs, curl), et init propre
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl dumb-init && \
    rm -rf /var/lib/apt/lists/*

# Copier le binaire mcp-proxy
COPY --from=proxy /main /usr/local/bin/mcp-proxy

# Script de démarrage
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Render lancera ce CMD; mcp-proxy DOIT écouter sur $PORT
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/start.sh"]
