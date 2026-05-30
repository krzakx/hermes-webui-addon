#!/bin/bash
set -e

cd /opt/hermes-webui

export VIRTUAL_ENV=/opt/venv
export PATH="/opt/venv/bin:$PATH"
export HERMES_WEBUI_HOST=0.0.0.0
export HERMES_WEBUI_PORT=8787
export HERMES_WEBUI_STATE_DIR=/config/.hermes/webui
export HERMES_WEBUI_DEFAULT_WORKSPACE=/config
# HAOS always maps /config from host — hermes-agent lives at /config/.hermes/hermes-agent
export HERMES_HOME=/config/.hermes

# Read add-on options from HA
if [ -f /data/options.json ]; then
    PASSWORD=$(python3 -c "import json,sys; d=json.load(open('/data/options.json')); print(d.get('password',''))" 2>/dev/null || true)
    GATEWAY_URL=$(python3 -c "import json,sys; d=json.load(open('/data/options.json')); print(d.get('gateway_url',''))" 2>/dev/null || true)
    HERMES_HOME_OPT=$(python3 -c "import json,sys; d=json.load(open('/data/options.json')); print(d.get('hermes_home',''))" 2>/dev/null || true)

    [ -n "$PASSWORD" ] && export HERMES_WEBUI_PASSWORD="$PASSWORD"
    [ -n "$GATEWAY_URL" ] && export HERMES_GATEWAY_URL="$GATEWAY_URL"
    [ -n "$HERMES_HOME_OPT" ] && export HERMES_HOME="$HERMES_HOME_OPT"
fi

mkdir -p "$HERMES_WEBUI_STATE_DIR"

echo "========================================="
echo "  Hermes WebUI starting on port 8787"
echo "  State dir: $HERMES_WEBUI_STATE_DIR"
echo "  Workspace: $HERMES_WEBUI_DEFAULT_WORKSPACE"
echo "========================================="

exec python3 server.py
