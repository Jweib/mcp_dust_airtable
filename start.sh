#!/bin/sh
set -eu

# Emplacement type "secret"
mkdir -p /etc/secrets

# Reconstituer /etc/secrets/config.json depuis la variable base64
if [ -n "${CONFIG_JSON_B64:-}" ]; then
  echo "$CONFIG_JSON_B64" | base64 -d > /etc/secrets/config.json
else
  echo "FATAL: CONFIG_JSON_B64 manquant"; exit 2
fi

PORT="${PORT:-8080}"
PREFIX="${PREFIX:-/airtable/}"

echo "--- starting mcp-proxy on 0.0.0.0:${PORT} (prefix ${PREFIX})"
exec /usr/local/bin/mcp-proxy \
  --config /etc/secrets/config.json \
  --http "0.0.0.0:${PORT}" \
  --path "${PREFIX}"
