#!/bin/sh
set -eu

echo "--- secrets:"
ls -l /etc/secrets || true

PORT="${PORT:-8080}"

# IMPORTANT : si ton config.json a une entrée "airtable" en stdio,
# mcp-proxy va lancer "npx airtable-mcp-server" lui-même.
# Ici on expose en HTTP pour Render.
echo "--- starting mcp-proxy (stdio client + http server on :${PORT})"
exec /usr/local/bin/mcp-proxy \
  --config /etc/secrets/config.json \
  --http "0.0.0.0:${PORT}" \
  --path "/airtable/"
