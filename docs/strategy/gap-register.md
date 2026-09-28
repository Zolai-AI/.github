---
title: "Zolai AI — Gap Register"
description: "Prioritized gaps across technical, data, research, community, business, org, founder"
created: 2026-09-18
last_updated: 2026-09-28
status: CONFIRMED
---

# Gap Register

Prioritize by: **Impact × Urgency × Strategic Importance × Dependency**.

Statuses: OPEN · MITIGATING · CLOSED · UNKNOWN

## Technical

| Gap | Priority | Status | Notes / link |
|-----|----------|--------|--------------|
| Broken / flaky tests (zolai-core) | High | **CLOSED** | KR2.1 ✅ 1010 passed / 0 failed (2026-09-18) |
| Evaluation coverage thin | High | **MITIGATING** | KR3.1 ✅ eval_v1 (110 cases); gold sets still needed (KR3.3) |
| Security follow-ups | Medium | OPEN | `docs/audits/04-security-audit.md` |
| Observability / DevOps maturity | Medium | OPEN | Per-repo |
| Backup automation | High | **MITIGATING** | KR2.2 — script written + tested; cron install pending founder |

## Data

| Gap | Priority | Status | Notes / link |
|-----|----------|--------|--------------|
| Full license / provenance audit | High | IN PROGRESS | KR2.3 — 4-phase checklist; Phase 1 done |
| Duplicate / non-canonical tables | Medium | **MITIGATING** | KR2.4 — archive plan drafted (26 staging tables, 1.79M rows); execution pending founder approval → [`../database/archive-plan.md`](../database/archive-plan.md) |
| Correction / user-feedback tables missing | Medium | OPEN | Data SoT matrix |
| Bible & dictionary permission clarity | High | OPEN | Permission letters DRAFTED (3 letters, 6 targets) — founder review + send pending |

## Research

| Gap | Priority | Status | Notes / link |
|-----|----------|--------|--------------|
| Structured literature review | Medium | IN PROGRESS | 6→10 papers annotated; all 10 claimed-citation rows resolved (8 VERIFIED papers + 1 LREC tutorial + 1 PARTIAL playbook) 2026-09-28 |
| Published methodology / benchmarks | High | OPEN | KR1.4 DRAFT exists; KR3.2 PLANNED |
| Annotated bibliography (20+) | Medium | OPEN | 10 papers annotated (KR1.1 ✅); KR1.5 needs 20+ |
| Masakhane membership | Medium | OPEN | KR1.2 — not joined |

## Community

| Gap | Priority | Status | Notes / link |
|-----|----------|--------|--------------|
| Speaker interviews (5) | High | OPEN | KR5.1 — template ready in `../community/README.md` |
| Consent framework | Medium | DRAFTED | KR5.2 — templates in `../community/README.md` |
| Annotation pilot | Medium | OPEN | KR5.4 — brief drafted; needs speakers |
| Advisor position vacant | Medium | OPEN | Not confirmed; Shwe Yee = whitepaper ideas only |

## Business

| Gap | Priority | Status | Notes / link |
|-----|----------|--------|--------------|
| Customer discovery (10 interviews) | High | OPEN | KR6.1 — personas drafted in `../community/target-users.md` |
| Revenue model validation | Medium | OPEN | KR6.2 — 6 hypotheses, all UNVALIDATED |
| Paid pilot | Low | DEFERRED | Premature until discovery |

## Organization

| Gap | Priority | Status | Notes / link |
|-----|----------|--------|--------------|
| Legal entity / fiscal sponsor | High | OPEN | KR4.5 |
| Undefined commercial arrangement | High | OPEN | Private record; DEC-003 |
| Grant application draft | Medium | OPEN | KR4.4 — budget template exists in `03-grant-readiness.md` |
| Whitepaper review + finalization | Medium | DRAFTED | v0.1 (411 lines); needs founder review |

## Founder

| Gap | Priority | Status | Notes / link |
|-----|----------|--------|--------------|
| Research reading cadence | Medium | OPEN | `06-founder-okr.md` |
| Grant writing / business skills | Medium | OPEN | Mentoring segments |
| Consistency / communication | Medium | OPEN | Weekly log |

## Related

- Strategic audit: `01-strategic-audit.md`
- Grant readiness: `03-grant-readiness.md`
- Audits: `docs/audits/`

## Wave mapping

See [`../planning/COMPLETION_PLAN.md`](../planning/COMPLETION_PLAN.md) for wave-by-wave closure plan.

| Wave | Closes these gaps |
|------|-------------------|
| Wave 3 (Days 5–14) | Backup, license audit, interviews, Masakhane |
| Wave 4 (Days 14–30) | Evaluation coverage, methodology, benchmarks |
| Wave 5 (Days 30–45) | Whitepaper, grant draft, entity |
| Wave 6 (Days 30–60) | Discovery, revenue, annotation pilot |
| Wave 7 (Days 60–90) | Re-score + close |
