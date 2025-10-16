FROM ghcr.io/tbxark/mcp-proxy:latest AS proxy

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl dumb-init nodejs npm && \
    rm -rf /var/lib/apt/lists/*

COPY --from=proxy /main /usr/local/bin/mcp-proxy

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/start.sh"]
