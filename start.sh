#!/bin/sh
set -eu

echo "--- boot at $(date -u +%FT%TZ)"

mkdir -p /etc/secrets

write_config() {
  if [ -n "${CONFIG_JSON_B64:-}" ]; then
    echo "--- CONFIG_JSON_B64 present (len=$(printf "%s" "$CONFIG_JSON_B64" | wc -c))"
    echo "$CONFIG_JSON_B64" | base64 -d > /etc/secrets/config.json
  elif [ -n "${CONFIG_JSON_RAW:-}" ]; then
    echo "--- CONFIG_JSON_RAW present (len=$(printf "%s" "$CONFIG_JSON_RAW" | wc -c))"
    printf '%s' "$CONFIG_JSON_RAW" > /etc/secrets/config.json
  else
    echo "FATAL: no CONFIG_JSON_B64 or CONFIG_JSON_RAW"; exit 2
  fi
}

write_config

if [ ! -s /etc/secrets/config.json ]; then
  echo "FATAL: /etc/secrets/config.json empty"; exit 2
fi

echo "--- launching mcp-proxy on 0.0.0.0:8080 (expect /airtable/)"
/usr/local/bin/mcp-proxy --config /etc/secrets/config.json &
MCP_PID=$!

# Wait until the TCP port is really open (max 60s)
echo "--- waiting for :8080 to listen"
for i in $(seq 1 60); do
  if ss -ltn | awk '{print $4}' | grep -qE '(^|:)8080$'; then
    echo "--- port :8080 is LISTENING (t=${i}s)"
    break
  fi
  sleep 1
done

echo "--- ss -ltn snapshot:"
ss -ltn || true

echo "--- curl localhost sanity:"
curl -sS -o /dev/null -w "HTTP:%{http_code}\n" http://127.0.0.1:8080/airtable/ || true

echo "--- tail of process list:"
ps aux | grep mcp-proxy | grep -v grep || true

# Forward mcp-proxy exit status
wait "$MCP_PID"
