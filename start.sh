#!/bin/sh
set -eu

PORT="${PORT:-8080}"            # Cloud Run fournit $PORT
PREFIX="${PREFIX:-/airtable/}"  # Chemin public (pour Dust)

echo "--- secrets:"
ls -l /etc/secrets || true
[ -f /etc/secrets/config.json ] || { echo "FATAL: /etc/secrets/config.json manquant"; exit 2; }

echo "--- starting mcp-proxy on 0.0.0.0:${PORT} (prefix ${PREFIX})"
exec /usr/local/bin/mcp-proxy \
  --config /etc/secrets/config.json \
  --http "0.0.0.0:${PORT}" \
  --path "${PREFIX}"
