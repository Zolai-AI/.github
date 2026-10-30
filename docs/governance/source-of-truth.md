---
title: "Zolai AI — Source of Truth Matrix"
description: "Canonical document owners by domain; resolve conflicts by authority, not overwrite"
created: 2026-09-18
last_updated: 2026-10-28
status: CONFIRMED
---

# Source of Truth Matrix

> Evidence first → Canonical source → Documentation → Decision → Execution

When documents conflict, prefer the **canonical** path below. Older files become historical / cross-referenced, not silently deleted.

## Organizational & strategy

| Domain | Canonical source | Legacy / detail |
|--------|------------------|-----------------|
| Mission / Vision | [`docs/strategy/mission-vision.md`](../strategy/mission-vision.md) | `docs/strategy/04-okr-system.md` (embedded), root `README.md` |
| Strategic pillars | [`docs/strategy/mission-vision.md`](../strategy/mission-vision.md) | `04-okr-system.md` |
| OKR (annual + quarterly) | [`docs/strategy/okr.md`](../strategy/okr.md) | `04-okr-system.md`, `05-90-day-okr.md`, `06-founder-okr.md` |
| Theory of change | [`docs/strategy/theory-of-change.md`](../strategy/theory-of-change.md) | — |
| Roadmap | [`docs/ROADMAP.md`](../ROADMAP.md) | `02-strategic-roadmap.md`, `15-execution-plan.md` |
| Gap register | [`docs/strategy/gap-register.md`](../strategy/gap-register.md) | `01-strategic-audit.md`, audits/ |
| Advisors / mentors | [`docs/strategy/advisors-and-mentors.md`](../strategy/advisors-and-mentors.md) | `07-weekly-mentoring.md` |
| Advisor meeting log | [`docs/strategy/advisor-log.md`](../strategy/advisor-log.md) | — |
| Decisions | [`docs/strategy/decisions.md`](../strategy/decisions.md) | `14-master-dashboard.md` |
| Agent / AI context | [`docs/context/project-context.md`](../context/project-context.md) | `context/project-overview.md`, `AGENTS.md` |

## Research, grants, community, business

| Domain | Canonical source | Legacy / detail |
|--------|------------------|-----------------|
| Research | [`docs/research/`](../research/) | `context/RESEARCH_SYNTHESIS.md`, `UPDATED_RESEARCH_SYNTHESIS.md` |
| White paper | [`docs/whitepaper/`](../whitepaper/) | `docs/strategy/whitepaper.md` |
| Grants | [`docs/grants/`](../grants/) | `03-grant-readiness.md`, `11-grant-alignment.md` |
| Community / literacy | [`docs/community/`](../community/) | `13-community-impact.md` |
| Business | [`docs/business/`](../business/) | `12-business-alignment.md` |

## Governance & technical

| Domain | Canonical source | Legacy / detail |
|--------|------------------|-----------------|
| Governance index | [`docs/governance/`](./) | — |
| Contributors / roles | [`docs/governance/contributors.md`](contributors.md) | — |
| Data governance | [`docs/governance/data-governance.md`](data-governance.md) | `context/DATA_GOVERNANCE.md` |
| Public vs private | [`docs/governance/public-vs-private.md`](public-vs-private.md) | — |
| Architecture | [`docs/architecture/status.md`](../architecture/status.md) · [`01-architecture-overview.md`](../architecture/01-architecture-overview.md) | per-repo `AGENTS.md` / `context/` |
| Database | [`docs/database/README.md`](../database/README.md) + [`tables.md`](../database/tables.md) + live `data/zolai.db` (**single source of truth**) | `docs/audits/`, `docs/reports/DATABASE_INTEGRITY_REPORT.md`, `docs/reports/SOURCE_OF_TRUTH_MATRIX.md` |
| Org profile (GitHub) | [`profile/README.md`](../../profile/README.md) | — |
| Nested repos | Each repo’s `AGENTS.md` + README | Do not glob `**/` from monorepo root |

## Single database (single source of truth)

There is **one** canonical data DB: `data/zolai.db` (SQLite WAL, 2.80 GB,
**126 user tables** / 3,266,049 rows as of 2026-10-30; the prior 150-table figure
predates the archival of the 26 `*_import` staging tables and the 125-table figure
predates `corpus_learning_layers`). Every engine resolves to it through
`zolai/config.py` `db` (env `ZOLAI_DB_PATH`, default `$ZOLAI_DATA_ROOT/zolai.db`);
`zolai_db` is an alias, not a second path. Duplicate/dev DBs were archived to
`data/archive/duplicate-dbs/2026-10-27/` (reversible). Evaluation data — the
ZolaiBench metric sets **and** the gold annotation lanes — lives in the
`eval_sets` / `eval_cases` tables of that same database; `eval_cases.kind` carries
the lane. PostgreSQL in `zolai-web` is a separate application store, not a data
source of truth for the toolkit. Counts and the full catalog live in
[`../database/tables.md`](../database/tables.md).

`data/zolai_eval.db` is **retired** (DEPRECATED, 2026-10-27). Nothing in
`zolai/eval/` reads or writes it; JSONL under `data/eval/` is interchange format
only, not a store. Its 848 gold items were moved into `data/zolai.db` on 2026-10-27
by the one-shot, idempotent, preflight-backed
`zolai-core/scripts/migrate_eval_store.py` (dump: `data/backups/eval_store_preflight.json`;
re-`--dry-run` reports no writes). The file stays on disk only as that
pre-migration snapshot — archive it, do not delete it, and never re-run the
migration against a `data/zolai.db` whose `eval_cases` count you have not read.

The database also records its own state in `knowledge_versions`, and that record
is checkable — a counts-only manifest cannot tell two same-sized databases apart,
so snapshots hash table content:

```bash
zolai knowledge version v2026.10.27 --pipeline-version phase5
zolai knowledge verify-version v2026.10.27   # exit 1 on drift
```

## Timestamp format (single source of truth)

Every timestamp — Python-side write, SQL DEFAULT, or stored value — has one
serialisation and one owner: **ISO-8601 UTC with an explicit `+00:00` offset**,
chosen only in `zolai-core/zolai/shared/clock.py` (`stamp()`, `now()`, `parse()`,
`SQL_NOW`).

| Domain | Canonical source | Enforcement |
|--------|------------------|-------------|
| Timestamp serialisation | `zolai/shared/clock.py` | `zolai-core/tests/test_timestamp_clock.py` |
| Timestamp rule (prose) | [`../database/README.md`](../database/README.md) §Timestamp rule | — |
| Data-domain read of it | [`../reports/SOURCE_OF_TRUTH_MATRIX.md`](../reports/SOURCE_OF_TRUTH_MATRIX.md) §Timestamp lane | — |

Forbidden: a local `_now()` / `_utc_now()` / `_stamp()`, an inline
`strftime("%Y-%m-%d %H:%M:%S")`, `datetime.utcnow()`, `datetime('now')`,
`CURRENT_TIMESTAMP` in a DEFAULT or UPDATE. Exempt (must change writer + rows
atomically, tracked separately): `zolai/auth/oauth.py`,
`zolai/api/session_auth.py`, `zolai/api/auth.py` — they compare stored session
and API-key expiry values as TEXT.

## Status labels (required on important claims)

| Label | Meaning |
|-------|---------|
| CONFIRMED | Verified against repo / evidence |
| PROPOSED | Suggested; not adopted |
| UNDER REVIEW | Draft pending human review |
| EXPERIMENTAL | In progress / lab only |
| PLANNED | Accepted intent; not built |
| DEPRECATED | Superseded; keep for history |
| UNKNOWN | Insufficient evidence |

## Conflict rule

1. Identify both claims and their dates/sources.
2. Prefer the domain’s canonical path.
3. If evidence is insufficient, mark **UNKNOWN** and open a decision in `docs/strategy/decisions.md`.
4. Archive or mark **DEPRECATED**; do not delete useful history.
