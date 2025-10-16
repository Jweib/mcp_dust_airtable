#!/bin/sh
set -eu

mkdir -p /etc/secrets

write_config() {
  if [ -n "${CONFIG_JSON_B64:-}" ]; then
    # log debug safe (longueur, pas le contenu)
    echo "--- CONFIG_JSON_B64 présent (len=$(printf "%s" "$CONFIG_JSON_B64" | wc -c))"
    echo "$CONFIG_JSON_B64" | base64 -d > /etc/secrets/config.json
    return 0
  fi

  if [ -n "${CONFIG_JSON_RAW:-}" ]; then
    echo "--- CONFIG_JSON_RAW présent (len=$(printf "%s" "$CONFIG_JSON_RAW" | wc -c))"
    # pas d'echo (risque d’interpréter \n), on passe par printf
    printf '%s' "$CONFIG_JSON_RAW" > /etc/secrets/config.json
    return 0
  fi

  echo "FATAL: ni CONFIG_JSON_B64 ni CONFIG_JSON_RAW n'est défini"
  exit 2
}

write_config

# sanity check très léger
if [ ! -s /etc/secrets/config.json ]; then
  echo "FATAL: /etc/secrets/config.json vide"
  exit 2
fi

echo "--- launching mcp-proxy with /etc/secrets/config.json"
echo '--- ports listening:'
ss -ltn || true

exec /usr/local/bin/mcp-proxy --config /etc/secrets/config.json
