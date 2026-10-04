---
title: "Backup strategy (KR2.2)"
description: "Automated daily backup plan for data/zolai.db and critical assets"
status: IMPLEMENTED
created: 2026-09-19
last_updated: 2026-10-04
---

# Backup Strategy (KR2.2)

**Status:** IMPLEMENTED (local leg) — script written + tested; cloud target + cron install pending founder.
**OKR:** O2 KR2.2 — "Set up automated daily backup" (baseline: no backup → daily backup to cloud)

## Scope

| Asset | Size | Priority | RPO target |
|-------|------|----------|------------|
| `data/zolai.db` | ~2.3 GB | CRITICAL | 24h |
| `data/` (JSONL, CREDITS, eval) | ~4 GB | HIGH | 24h |
| Git repos (all 10) | Small | HIGH | On push |
| `docs/` | Small | MEDIUM | On commit |
| `.env` / secrets | Tiny | CRITICAL | Manual, encrypted |

## Architecture

```
Local (data/zolai.db)                          ✅ implemented (scripts/backup-zolai.sh)
  → nightly cron: sqlite3 .backup → gz         ⏳ cron line provided, install pending founder
  → upload to encrypted cloud bucket (TBD: Backblaze B2 / Cloudflare R2 / S3)   ⏳ pending founder
  → keep 7 daily + 4 weekly + 12 monthly (3-2-1 rule)   ✅ daily+weekly rotation; monthly pending
```

## 3-2-1 rule

- **3** copies (local + cloud + weekly offsite manual)
- **2** media types (SSD + cloud object storage)
- **1** offsite (cloud bucket in different region)

## Implementation checklist (KR2.2)

- [x] Choose cloud provider → **deferred** (local first; cloud TBD by founder: B2 / R2 / S3)
- [x] Write backup script (`scripts/backup-zolai.sh`) — WAL-safe `sqlite3 .backup` + gzip + 7d/4w rotation
- [ ] Add cron/systemd timer → **command provided below, not installed** (founder decides; no crontab touched)
- [x] Log each run to `data/backups/backup.log`
- [x] Add `data/backups/` to `.gitignore` — verified: covered by the existing `data/` rule (`git check-ignore data/backups/backup.log` → `.gitignore:20:data/`)
- [x] Verify restore → `--verify` restore drill ran OK (2026-09-28), row counts match canonical table

### What the script does

```bash
scripts/backup-zolai.sh [--verify]
```

1. `sqlite3 "$DB" ".backup '$DEST'"` — WAL-safe online backup (safe while DB is in use; never `cp` the live file)
2. Row-count sanity check on `dictionary` before compressing
3. `gzip -f` → `data/backups/zolai-YYYY-MM-DD_HHMM.db.gz`
4. Rotation: keep newest **7 daily**; any daily older than that is promoted to `weekly-*` if its mtime is a Saturday, then deleted; keep newest **4 weekly**
5. `--verify` — gunzip latest backup to `/tmp`, count `dictionary`, `bible_verses`, `vocabulary`, `translations`, then delete the temp file

## Restore drill (monthly)

```bash
# via the script
scripts/backup-zolai.sh --verify

# or manually
sqlite3 /tmp/restore-test.db ".restore data/backups/zolai-YYYY-MM-DD.db"
sqlite3 /tmp/restore-test.db "SELECT count(*) FROM dictionary;"  # expect 84,490
```

## Verification log

| Date | Backup run | Size | Verified | Restored | Notes |
|------|-----------|------|----------|----------|-------|
| 2026-09-28 | ✅ | 562M (`zolai-2026-09-28_2050.db.gz`) | no | no | first test run (plain, no drill); exit 0, `dictionary rows: 84490` logged |
| 2026-09-28 | ✅ | 562M (`zolai-2026-09-28_2059.db.gz`) | yes | yes | `--verify` drill — restored to `/tmp`, counts matched, temp removed |

**Timing (measured, 2.4 GB WAL DB):** sqlite3 `.backup` ≈ 68–71 s; gzip dominates the rest — **total wall time ≈ 6–8.5 min per run**. Well within a nightly 02:00 window; if it ever collides with heavy work, switch compression to `gzip -1` or `pigz`.

**Log:** `data/backups/backup.log` (gitignored along with all of `data/`).

## Cron installation (pending founder)

The script does **NOT** auto-install a crontab — that is a system change the founder runs:

```bash
crontab -e
# add:
0 2 * * * /home/peter/Documents/Projects/zolai-ai/scripts/backup-zolai.sh >> /home/peter/Documents/Projects/zolai-ai/data/backups/backup.log 2>&1
```

Expected run: nightly 02:00, ~562 MB `.gz` per night → ≈ 3.9 GB/week before rotation; steady-state with 7 daily + 4 weekly ≈ **7–8 GB**. Disk budget at implementation: 32 GB free — sufficient, but re-check after any big data import.

## Sync server ↔ local (one direction per update)

**Rule: every update moves the DB exactly one way — the side that changed is the source.**
Never merge automatically; pick the direction for that update:

| Update kind | Command | Direction |
|---|---|---|
| Server deploy / migration / provider seed / server-side review or learn write | `sync-db-from-server.sh` | server → local |
| Local data work finished (clean, import, annotation, review) | `sync-db-to-server.sh` | local → server |

### Pull to local (server → workspace)

The nightly backup covers the **local** leg. When the server has the newer DB (after a
pcore-server deploy, migration, provider seed, observation build, or any review/learn
write), pull it back so the workspace copy stays authoritative for local work:

```bash
zolai-core/scripts/sync-db-from-server.sh --dry-run   # preview (no changes)
zolai-core/scripts/sync-db-from-server.sh             # pull
```

| Step | What happens |
|------|--------------|
| 1 | `ssh pcore-server "sqlite3 …/data/zolai.db '.backup /tmp/zolai-sync.db'"` — **WAL-safe snapshot** (a live WAL file is never raw-copied) |
| 2 | `rsync` the snapshot to `data/zolai.db.incoming` (same filesystem) |
| 3 | `PRAGMA integrity_check` on the pulled file — abort unless `ok` |
| 4 | Back up the existing local DB first via `scripts/backup-zolai.sh` (fallback: `data/backups/zolai-<ts>.db.gz`) |
| 5 | `mv` into place and drop the stale `-wal`/`-shm` of the replaced file |
| 6 | Remove the remote snapshot; echo sizes at every step (`set -euo pipefail`) |

- **Cadence:** after **every** server deploy / DB-affecting update (see
  `docs/planning/AI_AGENTS_RBAC_PLAN.md` §F Deployment). Not a substitute for the nightly
  backup — it *overwrites* local, so step 4 is the safety net.
- **Overrides:** `ZOLAI_SYNC_HOST`, `ZOLAI_SYNC_SERVER_DB`, `ZOLAI_SYNC_SSH_KEY`,
  `ZOLAI_DATA_ROOT`, `--target PATH`.
- Default target: `<workspace>/data/zolai.db` (the same file `scripts/backup-zolai.sh`
  backs up).

### Push to server (workspace → server)

When the **local** DB is the one that changed, push it up:

```bash
zolai-core/scripts/sync-db-to-server.sh --dry-run   # preview (no changes)
zolai-core/scripts/sync-db-to-server.sh             # push
```

| Step | What happens |
|------|--------------|
| 1 | Local `sqlite3 .backup` snapshot + `PRAGMA integrity_check` (WAL-safe, never raw-copy) |
| 2 | `rsync` the snapshot to `<db-dir>/.zolai-push.db` on the server |
| 3 | **Stop the api container** — the server DB is hot; never swap a file the process holds open |
| 4 | Back up the server DB first → `data/backups/zolai-<ts>.db.gz` |
| 5 | `PRAGMA integrity_check` **on the server** on the pushed file — abort (and restart api) unless `ok` |
| 6 | `mv` into place, drop stale `-wal`/`-shm`, start the api container |
| 7 | `/health` 200 gate (30s) — the update is not "done" until the API answers |

- **Cadence:** after **every** local DB-affecting change that must reach production; the
  paired pull runs after every server-side change. One direction per update.
- **Overrides:** `ZOLAI_SYNC_HOST`, `ZOLAI_SYNC_SERVER_DB`, `ZOLAI_SYNC_SSH_KEY`,
  `ZOLAI_SYNC_COMPOSE`, `ZOLAI_DATA_ROOT`, `--target PATH`, `--no-restart-health`.

## Open items

| Item | Owner | Status |
|------|-------|--------|
| Install cron line above | founder | PENDING |
| Choose cloud provider + offsite upload (B2 / R2 / S3) | founder | PENDING — local leg only for now |
| Monthly restore drill cadence | founder | PENDING (script supports `--verify`) |

## Risks

| Risk | Mitigation |
|------|-----------|
| Cloud provider outage | Two providers or weekly offsite file |
| Backup corruption | Monthly restore drill mandatory |
| DB hot-write during backup | Use sqlite3 `.backup` (WAL-safe), not `cp` |
| Secrets leaked to cloud | `.env` never in backup; use encrypted separate store |

## Related

- [`data-governance.md`](data-governance.md) — data governance policy
- [`../planning/COMPLETION_PLAN.md`](../planning/COMPLETION_PLAN.md) — Wave 3.5 (KR2.2)
