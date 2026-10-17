# Deploy Runbook — zolai-core + Studio on pcore-server (NATIVE)

**Rewritten 2026-10-18 for the native runtime. Every command below is either
something run today or explicitly marked.** Sources of truth for this rewrite:

- **Measured on pcore-server 2026-10-18** (operator-measured, quoted as such):
  `docker ps -a` returns **nothing**; there is no container runtime in play.
- **Measured from a workstation 2026-10-18** (this session, read-only probes):
  the public hosts and the MCP surface probes in [§ Verify](#verify-matrix).
- **Read in the repo 2026-10-18**: `zolai-core/scripts/{deploy.sh,sync-and-deploy.sh}`,
  `zolai/cli/main.py` (no `mcp` / `landing` subcommand).

Anything not observed is marked **(not verified)** — do not treat it as fact.

> ### The one day-to-day command
>
> ```bash
> scripts/native-deploy.sh core          # feature/fix in zolai-core
> scripts/native-deploy.sh studio        # feature/fix in zolai-explorer (Studio)
> scripts/native-deploy.sh mcp-landing   # regenerate the mcp.zolai.space landing page
> scripts/native-deploy.sh status        # unit state + /health for all three hosts
> ```
>
> Run it from **this** root checkout; it reaches the server through the
> `pcore-server` ssh alias (override with `--host`), or pass `--local` if you are
> already on the box. `--dry-run` prints every mutating command without running it.

---

## Prerequisites

- SSH access to pcore-server (`ssh pcore-server true` must work **non-interactively**
  for the script's `BatchMode` checks).
- **No Docker required.** Docker is retired from the runtime (see
  [§ Retired](#retired--do-not-use)).
- A systemd service manager on the host (`systemctl`) — the runtime *is* units.
- `sudo` on the target for `/var/www` writes. The script preflights
  `sudo -n true` and fails clearly if it is not passwordless. **(not verified:
  whether the `ubuntu` user currently has a NOPASSWD rule)**
- For `studio`: `bun` on the machine that builds (`zolai-explorer/package.json`
  defines `build` = `tsc -b && vite build`).
- For `mcp-landing`: the core venv CLI at
  `/home/ubuntu/zolai-core/.venv-dev/bin/zolai` with an `mcp landing --out <file>`
  subcommand — **it is not on `main` today** (verified 2026-10-18 against the
  committed tree: `zolai/cli/main.py` as tracked in git has no `mcp` subcommand).
  The subcommand fails loudly rather than writing a hand-made page.
  *(Working-tree note: an uncommitted, not-on-`main` implementation does exist in a
  developer checkout — `zolai/cli/mcp.py`, `zolai/mcp/landing.py`, wired in
  `zolai/cli/main.py`. Its `--out` interface matches what this script calls, but it
  is another session's WIP and must not be relied on until it lands. It is
  **not verified** that a deploy from the current server checkout would have it.)*

## Runtime layout (native, operator-measured 2026-10-18)

| Unit | ExecStart | Listens | Public host |
|------|-----------|---------|-------------|
| `zolai-core-dev.service` | `/home/ubuntu/zolai-core/.venv-dev/bin/uvicorn zolai.api.server:app --host 127.0.0.1 --port 8001` | `127.0.0.1:8001` | `api.zolai.space` → `127.0.0.1:8001` |
| `zolai-studio-dev.service` | `bun run dev --host 127.0.0.1 --port 5173` | `127.0.0.1:5173` | — (dev only) |
| *nginx static bundle* | — | `/var/www/zolai-studio` | `studio.zolai.space` → `/var/www/zolai-studio` |
| *nginx vhost* | — | `127.0.0.1:8021` | `mcp.zolai.space` (landing + `/mcp`, `/health`) |

- Core `WorkingDirectory=/home/ubuntu/zolai-core`, `EnvironmentFile=/home/ubuntu/zolai-core/.env.dev`, `User=ubuntu`.
- The **public Studio is the built bundle**, not `5173`. A Studio change needs a
  build + install of `dist/` (`native-deploy.sh studio`), never a restart of the
  dev unit.
- **The core needs ~13 s to answer after a restart** (measured: start `18:01:02`
  → "Application startup complete" `18:01:15`). Every readiness check must
  **poll** `/health` with a budget. A bare `sleep` produces a false outage and
  caused exactly that false alarm on 2026-10-18.

## Environment variables (server-side)

The core reads `/home/ubuntu/zolai-core/.env.dev` (its `EnvironmentFile`). That
file lives **only on the server**, is **never** in git, and **must never be
copied over** by a deploy script.

Read the values in force without printing secrets:

```bash
# on pcore-server
systemctl show zolai-core-dev -p EnvironmentFiles -p WorkingDirectory -p ExecStart
sudo systemctl cat zolai-core-dev            # unit file, incl. EnvironmentFile path
# names only, never values:
grep -o '^[A-Z_]*=' /home/ubuntu/zolai-core/.env.dev | tr -d '='
```

Variables that matter for a deploy (names only; values are server-side):

| Variable | Meaning | Provenance |
|---|---|---|
| `ZOLAI_API_AUTH` | `warn` \| `enforce` \| `off` | `.env.production.template` (repo) |
| `ZOLAI_AUTH_SESSIONS`, `ZOLAI_SESSION_TTL_HOURS` | username/password sessions | template |
| `ZOLAI_ENGINE_MODE` | `rule` \| `hybrid` \| `ai` — live `/health` reports `hybrid` today | **verified live** |
| `AI_BRAIN_URL`, `AI_BRAIN_API_KEY` | P-Core Brain provider | template |
| `ZOLAI_DATA_ROOT` / `ZOLAI_DB_PATH` | where the canonical SQLite DB lives | **template only — the native unit's actual value is (not verified)** |
| `ZOLAI_CB_*`, `SMTP_*`, `ADMIN_EMAILS`, `ZOLAI_NOTIFICATIONS_ENABLED` | circuit breaker + notifications | template |

The repo template is `.env.production.template` (root). It still describes the
retired container path (`ZOLAI_DB_PATH=/data/zolai.db`) — **treat that line as
stale** until the template is re-cut for the native layout.

## Deploy zolai-core

The server checkout (`/home/ubuntu/zolai-core`) is a **git clone**, not an rsync
target. Deploy = fetch + merge `origin/main` + restart + poll.

### The scripted path (preferred)

```bash
scripts/native-deploy.sh core
```

What it does, in order:

1. Preflight: target reachable, `zolai-core-dev.service` exists, tree is a git checkout.
2. Prints `HEAD`, branch and any uncommitted paths (**they are not deployed by a merge**).
3. **Backup before replacing**: `git update-ref refs/backup/native-deploy/<ts> HEAD`.
4. `git -C /home/ubuntu/zolai-core fetch --prune origin`.
5. `git -C /home/ubuntu/zolai-core merge --no-edit origin/main`
   (on conflict it stops, tells you the `merge --abort` + `reset --hard` commands, and exits 1).
6. If `HEAD` did not move **and** the origin is already healthy → no-op
   (idempotent). Add `--force` to restart anyway.
7. `sudo systemctl restart zolai-core-dev`.
8. **Polls** `http://127.0.0.1:8001/health` then `/api/v1/health` for up to 60 s
   (≥20 s budget mandated; startup is ~13 s). On timeout it prints
   `systemctl status` + the last 30 journal lines and the rollback command.
9. Verifies `https://api.zolai.space/health` (edge). A non-200 there is a
   **warning**, because the origin was already proven healthy.

### The manual equivalent

```bash
ssh pcore-server
cd /home/ubuntu/zolai-core
git update-ref refs/backup/native-deploy/$(date +%Y%m%d-%H%M%S) HEAD   # backup point
git fetch --prune origin
git merge --no-edit origin/main
sudo systemctl restart zolai-core-dev
# POLL — do not sleep blindly:
for i in $(seq 1 60); do
  curl -fsS -o /dev/null http://127.0.0.1:8001/health && break
  sleep 1
done
curl -sS http://127.0.0.1:8001/api/v1/health
```

## Deploy zolai-explorer (Studio)

The Studio is a static bundle. `zolai-studio-dev.service` (5173) is **not** the
public site.

```bash
scripts/native-deploy.sh studio
```

1. `bun run build` in `zolai-explorer/` (`tsc -b && vite build`) — locally, or in
   `/home/ubuntu/zolai-explorer` when run with `--local`.
2. Refuses to continue if the build produced no `dist/index.html`.
3. Backs up `/var/www/zolai-studio` → `/var/www/zolai-studio.bak-<ts>` (backups are
   never pruned automatically; remove them yourself when satisfied).
4. `rsync -a --delete` of `dist/` into `/var/www/zolai-studio` (via
   `--rsync-path="sudo rsync"` when deploying from a workstation).
5. **Verifies over HTTPS**: the hashed `assets/*.js` in the live
   `https://studio.zolai.space/` must equal the one the build just produced
   (5 attempts). Mismatch fails the deploy rather than reporting a silent no-op.

Manual equivalent:

```bash
cd zolai-explorer && bun run build
ssh pcore-server 'sudo cp -a /var/www/zolai-studio /var/www/zolai-studio.bak-$(date +%Y%m%d-%H%M%S)'
rsync -a --delete -e ssh --rsync-path="sudo rsync" zolai-explorer/dist/ pcore-server:/var/www/zolai-studio/
curl -fsS https://studio.zolai.space/ | grep -o 'assets/[^"]*\.js'   # must match dist/index.html
```

Nginx needs no reload for a content swap. It does need one for a **config**
change: `sudo nginx -t && sudo systemctl reload nginx`. The vhost itself is
described in the retired section of git history and in `docs/mcp-surface.md`;
**(not verified: the current on-disk vhost contents — read them on the host)**.

## Deploy the MCP landing page

```bash
scripts/native-deploy.sh mcp-landing
```

1. Requires `/home/ubuntu/zolai-core/.venv-dev/bin/zolai` (fails clearly if absent).
2. `zolai mcp landing --out <tmp>` **on the server** — the page is generated by the
   application, never hand-written.
3. **Today this fails on purpose**: the subcommand does not exist (verified
   2026-10-18 — no `mcp` subcommand in `zolai/cli/main.py`, no "landing" anywhere
   in `zolai-core`). Exit is non-zero and **nothing is written**. Land the
   generator first; see `docs/mcp-surface.md` (step 5).
4. When it does exist: validates the output is non-empty HTML, backs up
   `/var/www/zolai-mcp/index.html` to `index.html.bak-<ts>`, installs it `0644`.
5. Verification discriminates by **behaviour, not content-type**: a `POST
   /mcp` `server/discover` that answers `-32601 Method not found` means the
   hostname is still the Cloudflare Worker (DNS cutover pending). The Worker's own
   landing is *also* HTML (verified 2026-10-18), so content-type alone proves nothing.

## Verify matrix

Rows marked **✅ live** were probed from a workstation on 2026-10-18; the rest are
the standing matrix and were **not** re-run this session.

| # | Test | Expected | Status |
|---|------|----------|--------|
| 1 | `curl -sS https://api.zolai.space/health` | 200 `{"status":"ok",...}` | ✅ live — `{"status":"ok","version":"1.0.0","uptime_s":1411.258,"engine_mode":"hybrid","llm_allowed":true}` |
| 2 | `curl -sS https://api.zolai.space/api/v1/health` | 200 | ✅ live |
| 3 | `curl -sS https://studio.zolai.space/` | 200, HTML shell | ✅ live |
| 4 | `curl -sS https://mcp.zolai.space/health` | 200 | ✅ live |
| 5 | `POST /api/v1/search` for core terms (e.g. `pasian`) | ≥5 relevant hits, exact first | not re-run |
| 6 | `POST /api/v1/assistant/chat` anonymous | 200, answer + citations or honest `retrieval_only` | not re-run |
| 7 | Enforce-mode roles: public 200 no key; `/agent/runs` 401 anon; admin chat 403 member | as stated | not re-run |
| 8 | Unknown path → 404 | 404 | not re-run |
| 9 | Studio: public chat works signed out; Settings/Agent hidden; admin key reveals all | as stated | not re-run |
| 10 | `POST /mcp` `initialize` | 200 | ✅ live — **still the Worker**: `serverInfo zolai-mcp 1.2.0` |
| 11 | `POST /mcp` `server/discover` | new-era answer | ✅ live — **`-32601 Method not found`** (Worker; cutover PENDING) |

Quick origin-side check after any core deploy:

```bash
ssh pcore-server
curl -sS http://127.0.0.1:8001/health
curl -sS http://127.0.0.1:8001/api/v1/health
systemctl is-active zolai-core-dev zolai-studio-dev
```

## Rollback

### zolai-core

```bash
# the script prints the exact SHA to keep; rollback is one reset + restart:
ssh pcore-server
cd /home/ubuntu/zolai-core
git log --oneline -3                      # confirm the target
git reset --hard <PRE_SHA>                # the value native-deploy.sh printed
sudo systemctl restart zolai-core-dev
# then POLL /health (never sleep):
for i in $(seq 1 60); do curl -fsS -o /dev/null http://127.0.0.1:8001/health && break; sleep 1; done
```

The pre-deploy ref is kept as `refs/backup/native-deploy/<timestamp>`; list them with
`git -C /home/ubuntu/zolai-core for-each-ref refs/backup/native-deploy`.

### Studio

```bash
ssh pcore-server
sudo rsync -a --delete /var/www/zolai-studio.bak-<ts>/ /var/www/zolai-studio/
curl -fsS https://studio.zolai.space/ | grep -o 'assets/[^"]*\.js'
```

### MCP landing

```bash
sudo cp -a /var/www/zolai-mcp/index.html.bak-<ts> /var/www/zolai-mcp/index.html
```

## Consumer API keys (Gate 3)

Inventory and prefixes were recorded on 2026-10-11. **The mint/revoke commands
changed** with the runtime: they now run in the core venv, not through `docker exec`.

```bash
# on pcore-server
cd /home/ubuntu/zolai-core
.venv-dev/bin/zolai apikey list                      # inventory (prefixes only)
.venv-dev/bin/zolai apikey revoke <id>               # preferred rollback: revoke
grep -c '^zolai_sk_' /home/ubuntu/.zolai/consumer-keys.txt   # 600-mode plaintext store, server-only
```

| ID | Name | Prefix | State |
|----|------|--------|-------|
| 1 | `peter-local` | `zolai_sk_5f0C-Cx` | kept (`last_used_at` 2026-10-05) |
| 15 | `zolai-mcp-server` | `zolai_sk_SddqOwL` | active |
| 16 | `zolai-tauri` | `zolai_sk_6qISRMt` | active |
| 17 | `zolai-scripts` | `zolai_sk_2pOsd1T` | active |
| 2–14 | `test-key-*`, `verify*`, `final-*`, `prod-*` | — | revoked 2026-10-11 |

Enforcement checks (origin, no Docker):

```bash
B=http://127.0.0.1:8001
K=$(grep -o 'zolai_sk_[A-Za-z0-9_-]\{8,\}' /home/ubuntu/.zolai/consumer-keys.txt | head -1)

curl -s -o /dev/null -w '%{http_code}\n' "$B/api/v1/records?table=dictionary"                  # 401
curl -s -o /dev/null -w '%{http_code}\n' -H "X-API-Key: $K" "$B/api/v1/records?table=dictionary" # 200
for p in /health /api/v1/health /api/v1/providers "/api/v1/lexicon/search?q=hello"; do
  curl -s -o /dev/null -w "$p -> %{http_code}\n" "$B$p"                                        # 200 each
done
```

Rollback: revoke the key (takes effect on the next request). The emergency mode
flip is **env-only**: set `ZOLAI_API_AUTH=warn` in `/home/ubuntu/zolai-core/.env.dev`
and `sudo systemctl restart zolai-core-dev`. Prefer revoke.

## Database sync (bidirectional)

One direction per update — the side that changed is the source, never a merge.
Without containers, "stop the API" means **stop the unit**.

> **DB path: (not verified).** Resolve it first — do not assume `/data/zolai.db`
> (that was the container path). `ZOLAI_DATA_ROOT`/`ZOLAI_DB_PATH` in
> `.env.dev` decide it; `sqlite3 "$DB" "PRAGMA database_list;"` confirms.

### Server → local (after server-side writes)

```bash
ssh pcore-server 'sqlite3 <SERVER_DB> ".backup /tmp/zolai-server.db"'
scp pcore-server:/tmp/zolai-server.db /tmp/zolai-server.db
sqlite3 /tmp/zolai-server.db 'PRAGMA integrity_check'          # expect: ok
# then: back up the local DB, replace it atomically, drop stale -wal/-shm
```

### Local → server (after local data work)

```bash
sqlite3 <LOCAL_DB> ".backup /tmp/zolai-local.db"
scp /tmp/zolai-local.db pcore-server:/tmp/zolai-local.db
ssh pcore-server '
  set -e
  sudo systemctl stop zolai-core-dev                                    # release the writer
  sqlite3 <SERVER_DB> ".backup <SERVER_DB>.bak-$(date +%Y%m%d-%H%M%S)"  # backup first
  cp /tmp/zolai-local.db <SERVER_DB>
  rm -f <SERVER_DB>-wal <SERVER_DB>-shm                                 # stale WAL must not survive
  sqlite3 <SERVER_DB> "PRAGMA integrity_check"
  sudo systemctl start zolai-core-dev'
# then POLL the health endpoint (13 s startup)
```

The old container-era helpers (`sync-db-from-server.sh`, `sync-db-to-server.sh`)
still call `docker`; **do not use them** until they are re-cut for systemd.

## Troubleshooting

| Symptom | First check |
|---|---|
| `core` deploy fails during merge | `git -C /home/ubuntu/zolai-core status`; `merge --abort` then `reset --hard <PRE_SHA>` |
| `/health` never returns 200 | `journalctl -u zolai-core-dev -n 50`; remember the **~13 s** startup before calling it an outage |
| `systemctl restart` fails | `systemctl status zolai-core-dev`; port 8001 already held (`ss -ltnp \| grep 8001`) |
| `api.zolai.space` 502/404 but origin 200 | nginx vhost + tunnel: `sudo nginx -t`, `systemctl status cloudflared` |
| Studio shows an old bundle | the build did not install, or the edge cached `index.html`; compare `assets/*.js` against `dist/index.html` |
| Studio blank page | wrong `VITE_API_BASE` at build time; browser console |
| `mcp.zolai.space` answers JSON-RPC as `zolai-mcp 1.2.0` | that is the **Worker** — the cutover is pending (`docs/mcp-surface.md`) |
| Notifications silent | `SMTP_*` in `.env.dev`, `journalctl -u zolai-core-dev`, circuit-breaker state |
| `zolai` CLI not found | `/home/ubuntu/zolai-core/.venv-dev/bin/zolai` (the venv is the entry point, there is no container PATH) |

## Post-deploy checklist

- [ ] `systemctl is-active zolai-core-dev zolai-studio-dev`
- [ ] `http://127.0.0.1:8001/health` and `/api/v1/health` → 200 (polled, not slept)
- [ ] `https://api.zolai.space/health` → 200
- [ ] `https://studio.zolai.space/` serves the freshly built `assets/*.js`
- [ ] `https://mcp.zolai.space/health` → 200
- [ ] No new failures: `journalctl -u zolai-core-dev --since '10 min ago' -p err`
- [ ] Result recorded in `context/progress-tracker.md`

## Retired — do not use

| Artifact | State |
|---|---|
| `Dockerfile`, `Dockerfile.prod`, `docker-compose*.yml` | **Not the runtime.** `docker ps -a` is empty on pcore-server. Kept for history only. |
| **`zolai-core/scripts/sync-and-deploy.sh`** | **DANGEROUS.** It is Docker-based **and** `rsync --delete`s a committed tree over `/home/ubuntu/zolai-core/zolai/`, which would **erase the server-only commits** on that branch. Do not run it until it is rewritten for the git+native flow. |
| `zolai-core/scripts/deploy.sh` | Docker/Compose-based (`COMPOSE_FILE=docker-compose.prod.yml`). Retired by the same fact. |
| `sync-db-from-server.sh` / `sync-db-to-server.sh` | Call `docker`; re-cut before use. |
| `docs/planning/BACKEND_CORE_V1_PLAN.md` §D1 ("Deployment = pcore-server + Docker") | Superseded — see the revision note in that file. |

## Known drift (owner action, not a deploy step)

The server checkout is on branch `preserve/server-working-tree-20261014` and is
**12 commits ahead of `origin/main`** (operator-measured 2026-10-18), holding
server-only fixes (RAG grounding `5454062`, notification honesty `702089b`, a
deploy guard `a07492e`). `native-deploy.sh core` merges `origin/main` **into** that
branch, so the drift persists and grows.

Reconciliation is a one-time owner action: push the server-only commits to GitHub,
then reset the server checkout to `origin/main`. `scripts/native-deploy.sh status`
prints the current `ahead-of-origin/main` count and any uncommitted paths, and
warns while the drift exists.
