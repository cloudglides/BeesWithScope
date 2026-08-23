# BeesWithScope 🐝

A Slack bot that turns `/workflow/<name>` links into interactive unfurls — DM someone a
link, they see an embed with a **Join** button, and clicking it invites them to your
private channel.

## How it works

1. You send someone `http://cloudglides.hackclub.app:4000/workflow/kidnap`
2. Slack fires a `link_shared` event at the bot (Socket Mode)
3. The bot attaches an unfurl with a **Join** button via `chat.unfurl`
4. Clicking **Join** invites the clicker to the target channel (`C08TLJR2HD1`)
5. `POST /workflow/<name>` also posts the button message directly into the channel

## Setup

### 1. Slack app (api.slack.com/apps)

- **Socket Mode**: enable, generate an app-level token (`connections:write`) → `SLACK_APP_TOKEN`
- **OAuth & Permissions → Bot token scopes**:
  - `chat:write`, `links:read`, `links:write`, `channels:write.invites`
- **Event Subscriptions → Subscribe to bot events**: add `link_shared`
- **App Unfurl domains** (on the Event Subscriptions page): add `cloudglides.hackclub.app`
- **Interactivity & Shortcuts**: enabled
- Install the app to the workspace (**reinstall after any scope/domain change**) → `SLACK_BOT_TOKEN` (`xoxb-...`)
- Invite the bot user into the target channel (it can only invite others if it's a member)

### 2. Local DNS (for testing before deploying)

```bash
echo "127.0.0.1  cloudglides.hackclub.app" | sudo tee -a /etc/hosts
```

### 3. Environment

Create `.env` in the repo root:

```bash
SLACK_APP_TOKEN=xapp-...
SLACK_BOT_TOKEN=xoxb-...
WORKFLOW_CHANNEL=C0...        # channel to invite people into / post buttons to
UNFURL_DOMAINS=cloudglides.hackclub.app   # comma-separated
PORT=4000                     # optional, defaults to 4000
```

## Running

Local development (via Nix):

```bash
make dev
```

Containers (Podman):

```bash
make build   # build the image
make run     # run with .env on port 4000
```

Then send a fresh link in any DM or channel:

```
http://cloudglides.hackclub.app:4000/workflow/kidnap
```

## Testing

```bash
nix develop -c mix test
```

## Deploying

Run behind a reverse proxy that forwards `cloudglides.hackclub.app` → port 4000.
No code changes needed — the same URL works locally (hosts file) and in prod.

```bash
make build && make run -e PORT=4000 ...
# or on the server:
podman run -d --name bees --env-file .env -p 127.0.0.1:4000:4000 localhost/bees
```
