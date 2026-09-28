---
title: "Backup strategy (KR2.2)"
description: "Automated daily backup plan for data/zolai.db and critical assets"
status: DRAFT
created: 2026-09-19
last_updated: 2026-09-19
---

# Backup Strategy (KR2.2)

**Status:** DRAFT — needs implementation + founder confirmation of cloud target.
**OKR:** O2 KR2.2 — "Set up automated daily backup" (baseline: no backup → daily backup to cloud)

## Scope

| Asset | Size | Priority | RPO target |
|-------|------|----------|------------|
| `data/zolai.db` | ~2.3 GB | CRITICAL | 24h |
| `data/` (JSONL, CREDITS, eval) | ~4 GB | HIGH | 24h |
| Git repos (all 10) | Small | HIGH | On push |
| `docs/` | Small | MEDIUM | On commit |
| `.env` / secrets | Tiny | CRITICAL | Manual, encrypted |

## Proposed architecture

```
Local (data/zolai.db)
  → nightly cron: sqlite3 .backup → gz
  → upload to encrypted cloud bucket (TBD: Backblaze B2 / Cloudflare R2 / S3)
  → keep 7 daily + 4 weekly + 12 monthly (3-2-1 rule)
```

## 3-2-1 rule

- **3** copies (local + cloud + weekly offsite manual)
- **2** media types (SSD + cloud object storage)
- **1** offsite (cloud bucket in different region)

## Implementation checklist (KR2.2)

- [ ] Choose cloud provider (founder decision: B2 / R2 / S3)
- [ ] Write backup script (`scripts/backup.sh`) with sqlite3 `.backup` + gzip
- [ ] Add cron/systemd timer (daily 02:00)
- [ ] Verify restore (monthly drill: restore to temp DB + row count check)
- [ ] Log each run to `data/backups/manifest.log`
- [ ] Add `data/backups/` to `.gitignore`

## Restore drill (monthly)

```bash
sqlite3 /tmp/restore-test.db ".restore data/backups/zolai-YYYY-MM-DD.db"
sqlite3 /tmp/restore-test.db "SELECT count(*) FROM dictionary;"  # expect 84,490
```

## Verification log

| Date | Backup run | Size | Verified | Restored | Notes |
|------|-----------|------|----------|----------|-------|
| — | — | — | — | — | (not yet implemented) |

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
