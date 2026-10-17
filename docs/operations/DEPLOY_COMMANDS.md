# pcore-server deploy commands (NATIVE)

**Rewritten 2026-10-18.** Copy-paste sheet for the native runtime. The narrative
version, with the evidence and the rollback reasoning, is
[`DEPLOY_RUNBOOK.md`](DEPLOY_RUNBOOK.md). Every command here is either verified or
marked; nothing here uses Docker, because Docker is not the runtime
(`docker ps -a` is empty on pcore-server, operator-measured 2026-10-18).

## 1. Prerequisites

- `ssh pcore-server true` works **non-interactively** (the script's preflight uses `BatchMode`).
- `systemctl` on the host; `zolai-core-dev.service` + `zolai-studio-dev.service` exist.
- `sudo` for `/var/www` — `sudo -n true` must succeed. **(not verified whether NOPASSWD is configured)**
- `bun` where the Studio is built. `git` on the server checkout.
- No Docker. No Compose. No container runtime.

## 2. The one command

```bash
# run from this root checkout; add --dry-run to print instead of run
scripts/native-deploy.sh core          # zolai-core: fetch+merge origin/main, restart, poll /health
scripts/native-deploy.sh studio        # Studio: bun run build, backup, rsync dist/, verify HTTPS
scripts/native-deploy.sh mcp-landing   # landing page generator -> /var/www/zolai-mcp/index.html
scripts/native-deploy.sh status        # unit state + /health for all three hosts
scripts/native-deploy.sh --help
```

Flags: `--host <ssh-host>` · `--local` · `--force` · `--dry-run` · `--no-verify`.

## 3. zolai-core (manual equivalent)

```bash
ssh pcore-server
cd /home/ubuntu/zolai-core

# backup point before replacing anything
git update-ref refs/backup/native-deploy/$(date +%Y%m%d-%H%M%S) HEAD

git fetch --prune origin
git merge --no-edit origin/main

sudo systemctl restart zolai-core-dev

# POLL — the core needs ~13 s to answer; a bare sleep reports a false outage
for i in $(seq 1 60); do
  curl -fsS -o /dev/null http://127.0.0.1:8001/health && break
  sleep 1
done
curl -sS http://127.0.0.1:8001/health
curl -sS http://127.0.0.1:8001/api/v1/health
systemctl is-active zolai-core-dev
```

If the merge conflicts, it stops mid-merge:

```bash
git -C /home/ubuntu/zolai-core merge --abort
git -C /home/ubuntu/zolai-core reset --hard <PRE_SHA>     # the SHA native-deploy.sh printed
sudo systemctl restart zolai-core-dev
```

## 4. Studio (manual equivalent)

```bash
cd /home/peter/Documents/Projects/zolai-ai/zolai-explorer
bun run build

ssh pcore-server 'sudo cp -a /var/www/zolai-studio /var/www/zolai-studio.bak-$(date +%Y%m%d-%H%M%S)'
rsync -a --delete -e ssh --rsync-path="sudo rsync" dist/ pcore-server:/var/www/zolai-studio/

# prove the new bundle is the one being served
grep -o 'assets/[^"]*\.js' dist/index.html | head -1
curl -fsS https://studio.zolai.space/ | grep -o 'assets/[^"]*\.js' | head -1
```

The public Studio is the **built bundle** in `/var/www/zolai-studio`. The dev unit
(`zolai-studio-dev`, port 5173) is not the public site. Nginx reload is only needed
for a **vhost change**: `sudo nginx -t && sudo systemctl reload nginx`.

## 5. MCP landing page

```bash
scripts/native-deploy.sh mcp-landing
```

- Requires `/home/ubuntu/zolai-core/.venv-dev/bin/zolai` with an `mcp landing`
  subcommand. **It does not exist today** (verified 2026-10-18), so this fails
  loudly and writes nothing. Do **not** hand-write `/var/www/zolai-mcp/index.html`.
- Manual equivalent, once the generator exists:

```bash
ssh pcore-server
TMP=$(mktemp /tmp/zolai-mcp-landing.XXXXXX.html)
/home/ubuntu/zolai-core/.venv-dev/bin/zolai mcp landing --out "$TMP"
grep -qi '<html' "$TMP"                       # must be real HTML
sudo cp -a /var/www/zolai-mcp/index.html /var/www/zolai-mcp/index.html.bak-$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
sudo install -m 0644 "$TMP" /var/www/zolai-mcp/index.html
```

## 6. Verify

```bash
# origin (on pcore-server)
ssh pcore-server '
  systemctl is-active zolai-core-dev zolai-studio-dev
  curl -sS http://127.0.0.1:8001/health
  curl -sS http://127.0.0.1:8001/api/v1/health'

# public (from anywhere) — measured 2026-10-18: all 200
curl -sS https://api.zolai.space/health
curl -sS https://api.zolai.space/api/v1/health
curl -sS -o /dev/null -w '%{http_code}\n' https://studio.zolai.space/
curl -sS -o /dev/null -w '%{http_code}\n' https://mcp.zolai.space/health

# public reads (anonymous, by design)
curl -sS -X POST https://api.zolai.space/api/v1/search \
  -H 'Content-Type: application/json' -d '{"query":"pasian","limit":10}'
curl -sS -X POST https://api.zolai.space/api/v1/assistant/chat \
  -H 'Content-Type: application/json' -d '{"message":"hello"}'

# MCP: still the Cloudflare Worker as of 2026-10-18 (cutover pending)
curl -sS -X POST https://mcp.zolai.space/mcp -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"server/discover","params":{}}'
#   -> {"error":{"code":-32601,"message":"Method not found: server/discover"}}  = Worker, not the native core
```

Standing verify matrix (roles, admin keys, 404s, Studio gating): see
[`DEPLOY_RUNBOOK.md`](DEPLOY_RUNBOOK.md#verify-matrix). Rows not re-run on
2026-10-18 are marked there.

## 7. Rollback

```bash
# zolai-core — one reset + restart, then poll
ssh pcore-server 'cd /home/ubuntu/zolai-core && git reset --hard <PRE_SHA> && sudo systemctl restart zolai-core-dev'
# list the automatic backup refs:
git -C /home/ubuntu/zolai-core for-each-ref refs/backup/native-deploy

# Studio — restore the bundle backup directory
ssh pcore-server 'sudo rsync -a --delete /var/www/zolai-studio.bak-<ts>/ /var/www/zolai-studio/'

# MCP landing
ssh pcore-server 'sudo cp -a /var/www/zolai-mcp/index.html.bak-<ts> /var/www/zolai-mcp/index.html'

# Consumer key (preferred rollback for an enforcement problem)
ssh pcore-server 'cd /home/ubuntu/zolai-core && .venv-dev/bin/zolai apikey revoke <id>'
```

## 8. Post-deploy

- Record the result in `context/progress-tracker.md` (and `docs/OPEN-ISSUES.md` if something was wrong).
- Nightly backup timer is **still not installed** (needs-founder) — verify before assuming a backup exists.
- Founder-gated, unchanged: `ZOLAI_API_AUTH=enforce` flip, PG cutover, archive (KR2.4), permission letters, speaker recruitment.

## 9. Do not use

- **`zolai-core/scripts/sync-and-deploy.sh`** — Docker-based **and** `rsync --delete`
  over `/home/ubuntu/zolai-core/zolai/`: it would erase the server-only commits
  (the checkout is 12 ahead of `origin/main`). Unsafe until rewritten.
- `zolai-core/scripts/deploy.sh` — Compose-based.
- `Dockerfile.prod`, `docker-compose.prod.yml` — not the runtime.
- Any `docker exec` recipe from an older doc, including
  `.pcore/specs/client-setup-and-deploy.md` (untracked working notes, not updated here).
