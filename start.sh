#!/bin/sh
set -eu

echo "--- boot at $(date -u +%FT%TZ)"

mkdir -p /etc/secrets

# 1) Ecrire la conf depuis la variable
if [ -n "${CONFIG_JSON_B64:-}" ]; then
  echo "--- CONFIG_JSON_B64 present (len=$(printf "%s" "$CONFIG_JSON_B64" | wc -c))"
  echo "$CONFIG_JSON_B64" | base64 -d > /etc/secrets/config.json
elif [ -n "${CONFIG_JSON_RAW:-}" ]; then
  echo "--- CONFIG_JSON_RAW present (len=$(printf "%s" "$CONFIG_JSON_RAW" | wc -c))"
  printf '%s' "$CONFIG_JSON_RAW" > /etc/secrets/config.json
else
  echo "FATAL: no CONFIG_JSON_B64 or CONFIG_JSON_RAW"; exit 2
fi

[ -s /etc/secrets/config.json ] || { echo "FATAL: /etc/secrets/config.json empty"; exit 2; }

echo "--- launching mcp-proxy on 0.0.0.0:8080 (expect /airtable/)"
/usr/local/bin/mcp-proxy --config /etc/secrets/config.json &
MCP_PID=$!

# 2) Attendre que le port soit ouvert (via nc)
echo "--- waiting TCP 127.0.0.1:8080"
ok=0
for i in $(seq 1 90); do
  if nc -z 127.0.0.1 8080 2>/dev/null; then
    echo "--- tcp open after ${i}s"
    ok=1
    break
  fi
  sleep 1
done
[ "$ok" = "1" ] || echo "*** WARN: tcp not open after 90s (may still be starting)"

# 3) Tester HTTP (on accepte 200/404/405/500 = serveur répond)
echo "--- curl localhost sanity:"
HTTP_CODE=$(curl -sS -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/airtable/ || true)
echo "HTTP:${HTTP_CODE}"

# 4) Laisser mcp-proxy au premier plan
wait "$MCP_PID"
