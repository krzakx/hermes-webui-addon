# Hermes WebUI Add-on for Home Assistant

Browser interface for [Hermes Agent](https://github.com/nousresearch/hermes-agent).

## Features
- Full Hermes Agent management from your HA sidebar
- Session management, skills, memory, cron jobs
- Workspace browser
- Ingress support (no port exposure needed)

## Installation
1. Add this repository to HA: Settings → Add-ons → Add-on Store → ⋮ → Repositories
2. Enter: `https://github.com/krzakx/hermes-webui-addon`
3. Install "Hermes WebUI"
4. Open from HA sidebar

## Configuration
| Option | Default | Description |
|--------|---------|-------------|
| log_level | info | Log verbosity |
| hermes_home | /config/.hermes | Hermes config directory |
| workspace | /config | Default workspace path |
