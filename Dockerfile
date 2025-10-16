FROM ghcr.io/tbxark/mcp-proxy:latest

# Si ton serveur MCP Airtable est en Node, on garde Node pour npx, sinon enlève
RUN apk add --no-cache nodejs npm

COPY start.sh /start.sh
RUN chmod +x /start.sh

# Render va lancer ce CMD; le process doit écouter sur $PORT
CMD ["/start.sh"]
