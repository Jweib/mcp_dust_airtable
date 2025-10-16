# Stage 1 : récupérer le binaire du proxy MCP
FROM ghcr.io/tbxark/mcp-proxy:latest AS proxy

# Stage 2 : Nginx en front + Node pour npx
FROM nginx:alpine

# Ajoute Node + npm (donc npx) pour lancer airtable-mcp-server
RUN apk add --no-cache nodejs npm

# Binaire MCP proxy
COPY --from=proxy /main /usr/local/bin/mcp-proxy

# Notre conf Nginx (template avec ${PORT})
COPY nginx.conf.template /etc/nginx/nginx.conf.template

# Render donne $PORT au runtime
ENV PORT=8080
EXPOSE 8080

# Démarrage verbeux (debug-friendly) :
# 1) Affiche les secrets montés
# 2) Remplace ${PORT} dans nginx.conf
# 3) Lance mcp-proxy en 9090 (où Nginx ira proxifier)
# 4) Montre 'ps' pour confirmer que mcp-proxy tourne
# 5) Lance Nginx en foreground
# on ajoute netcat pour tester l'ouverture du port
RUN apk add --no-cache nodejs npm netcat-openbsd

CMD ["/bin/sh","-c","set -eux; \
  echo '--- secrets:'; ls -l /etc/secrets || true; \
  echo '--- writing /etc/nginx/nginx.conf from template'; \
  envsubst '$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf; \
  echo '--- starting mcp-proxy (default :8080)'; \
  /usr/local/bin/mcp-proxy --config /etc/secrets/config.json 2>&1 & \
  echo '--- waiting for 127.0.0.1:8080 to be ready'; \
  for i in $(seq 1 60); do nc -z 127.0.0.1 8080 && break; sleep 1; done; \
  echo '--- ps:'; ps aux | grep mcp-proxy | grep -v grep || true; \
  echo '--- starting nginx'; \
  exec nginx -g 'daemon off;'"]
