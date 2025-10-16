#!/bin/sh
set -eu

echo "--- secrets:"
ls -l /etc/secrets || true

export PORT="${PORT:-8080}"   # Render renseigne $PORT automatiquement

echo "--- starting mcp-proxy on :$PORT"

# Option A (souvent OK) :
exec /usr/local/bin/mcp-proxy \
  --config /etc/secrets/config.json \
  --http "0.0.0.0:${PORT}" \
  --path "/airtable/"

# ----- si A ne démarre pas (flags différents), commente A et essaie B :

# Option B (variantes fréquentes) :
# exec /usr/local/bin/mcp-proxy \
#   --config /etc/secrets/config.json \
#   --addr "0.0.0.0:${PORT}" \
#   --base-path "/airtable/"
