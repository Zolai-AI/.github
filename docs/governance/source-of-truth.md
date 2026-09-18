---
title: "Zolai AI — Source of Truth Matrix"
description: "Canonical document owners by domain; resolve conflicts by authority, not overwrite"
created: 2026-09-18
last_updated: 2026-09-18
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
| Architecture | [`docs/architecture/`](../architecture/) · [`status.md`](../architecture/status.md) | per-repo `AGENTS.md` / `context/` |
| Database | [`docs/database/README.md`](../database/README.md) + live `data/zolai.db` | `docs/audits/`, `docs/reports/DATABASE_INTEGRITY_REPORT.md`, `docs/reports/SOURCE_OF_TRUTH_MATRIX.md` |
| Org profile (GitHub) | [`profile/README.md`](../../profile/README.md) | — |
| Nested repos | Each repo’s `AGENTS.md` + README | Do not glob `**/` from monorepo root |

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
