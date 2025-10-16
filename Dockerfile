# Stage 1 : on récupère le binaire du proxy MCP (HTTP bridge)
FROM ghcr.io/tbxark/mcp-proxy:latest AS proxy

# Stage 2 : front HTTP Nginx
FROM nginx:alpine

# On ajoute le binaire mcp-proxy
COPY --from=proxy /main /usr/local/bin/mcp-proxy

# Template Nginx (on doit templater le $PORT de Render)
COPY nginx.conf /etc/nginx/templates/default.conf.template

# Render injecte $PORT au runtime
ENV PORT=8080
EXPOSE 8080

# 1) Lance le MCP proxy en interne sur 9090
# 2) Génère la conf Nginx en substituant $PORT
# 3) Lance Nginx en foreground
CMD ["/bin/sh","-c","/usr/local/bin/mcp-proxy --config /etc/secrets/config.json & exec nginx -g 'daemon off;'"]
