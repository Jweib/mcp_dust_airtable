#!/bin/sh
set -eu

# Recrée le fichier de config si tu es sur Railway (Option A/B qu’on a vue)
# Ici on suppose qu'il est déjà à /etc/secrets/config.json
[ -f /etc/secrets/config.json ] || { echo "FATAL: /etc/secrets/config.json manquant"; exit 2; }

exec /usr/local/bin/mcp-proxy \
  --config /etc/secrets/config.json
