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

# Explicit paths so WebUI finds agent + config without heuristics
export HERMES_WEBUI_AGENT_DIR=/config/.hermes/hermes-agent
export HERMES_CONFIG_PATH=/config/.hermes/config.yaml

# Read add-on options from HA
if [ -f /data/options.json ]; then
    PASSWORD=$(python3 -c "import json,sys; d=json.load(open('/data/options.json')); print(d.get('password',''))" 2>/dev/null || true)
    GATEWAY_URL=$(python3 -c "import json,sys; d=json.load(open('/data/options.json')); print(d.get('gateway_url',''))" 2>/dev/null || true)
    GATEWAY_API_KEY=$(python3 -c "import json,sys; d=json.load(open('/data/options.json')); print(d.get('gateway_api_key',''))" 2>/dev/null || true)
    HERMES_HOME_OPT=$(python3 -c "import json,sys; d=json.load(open('/data/options.json')); print(d.get('hermes_home',''))" 2>/dev/null || true)

    [ -n "$PASSWORD" ] && export HERMES_WEBUI_PASSWORD="$PASSWORD"
    [ -n "$HERMES_HOME_OPT" ] && export HERMES_HOME="$HERMES_HOME_OPT"

    # Gateway mode: enable gateway backend + correct env var names
    if [ -n "$GATEWAY_URL" ]; then
        # Strip trailing /v1 if user included it — code appends /v1/chat/completions itself
        GATEWAY_URL_CLEAN="${GATEWAY_URL%/v1}"
        GATEWAY_URL_CLEAN="${GATEWAY_URL_CLEAN%/}"
        export HERMES_WEBUI_CHAT_BACKEND=gateway
        export HERMES_WEBUI_GATEWAY_BASE_URL="$GATEWAY_URL_CLEAN"
        [ -n "$GATEWAY_API_KEY" ] && export HERMES_WEBUI_GATEWAY_API_KEY="$GATEWAY_API_KEY"
        echo "  [ok] Gateway mode: $GATEWAY_URL_CLEAN"
    fi
fi

mkdir -p "$HERMES_WEBUI_STATE_DIR"

echo "========================================="
echo "  Hermes WebUI starting on port 8787"
echo "  State dir: $HERMES_WEBUI_STATE_DIR"
echo "  Workspace: $HERMES_WEBUI_DEFAULT_WORKSPACE"
echo "========================================="

# Diagnostic: check agent dir visibility
if [ -f "$HERMES_WEBUI_AGENT_DIR/run_agent.py" ]; then
    echo "  [ok] Agent dir found: $HERMES_WEBUI_AGENT_DIR"
else
    echo "  [!!] Agent dir NOT found at $HERMES_WEBUI_AGENT_DIR"
    echo "       Make sure map: config:rw is set in addon config.yaml"
fi

# Diagnostic: check config file visibility
if [ -f "$HERMES_CONFIG_PATH" ]; then
    echo "  [ok] Config file found: $HERMES_CONFIG_PATH"
else
    echo "  [!!] Config file NOT found at $HERMES_CONFIG_PATH"
    echo "       WebUI will use defaults. Make sure map: config:rw is set."
fi

exec python3 server.py
