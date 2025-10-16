#!/bin/sh
set -eu

echo "--- secrets:"
ls -l /etc/secrets || true

PORT="${PORT:-8080}"   # Render fournit $PORT en prod

echo "--- starting mcp-proxy on 0.0.0.0:${PORT}"
exec /usr/local/bin/mcp-proxy \
  --config /etc/secrets/config.json \
  --http "0.0.0.0:${PORT}" \
  --path "/airtable/"
