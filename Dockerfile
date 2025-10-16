# Stage 1 : récupérer le binaire du MCP proxy
FROM ghcr.io/tbxark/mcp-proxy:latest AS proxy

# Stage 2 : Nginx en front
FROM nginx:alpine

# Binaire MCP proxy
COPY --from=proxy /main /usr/local/bin/mcp-proxy

# Notre conf Nginx (template avec ${PORT})
COPY nginx.conf.template /etc/nginx/nginx.conf.template

# Render expose $PORT ; on fait écouter Nginx dessus
ENV PORT=8080
EXPOSE 8080

# Démarrage :
# 1) MCP proxy sur 127.0.0.1:8080 (on force PORT=8080 pour être sûr)
# 2) On génère /etc/nginx/nginx.conf depuis le template (substitution ${PORT})
# 3) On lance Nginx en foreground
CMD ["/bin/sh","-c","set -eux; \
  echo '--- secrets:'; ls -l /etc/secrets || true; \
  echo '--- starting mcp-proxy on :9090'; \
  PORT=9090 /usr/local/bin/mcp-proxy --config /etc/secrets/config.json 2>&1 & \
  sleep 1; \
  echo '--- ps:'; ps aux | grep mcp-proxy | grep -v grep || true; \
  echo '--- starting nginx'; \
  exec nginx -g 'daemon off;'"]
