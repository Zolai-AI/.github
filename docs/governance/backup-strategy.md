---
title: "Backup strategy (KR2.2)"
description: "Automated daily backup plan for data/zolai.db and critical assets"
status: IMPLEMENTED
created: 2026-09-19
last_updated: 2026-09-28
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
