---
title: "Zolai AI — Business Strategy"
description: "Target users, value propositions, revenue models, competitive landscape"
created: 2026-09-19
last_updated: 2026-09-19
status: UNDER REVIEW
source: "docs/community/target-users.md + docs/strategy/whitepaper.md §8 + docs/business/hypotheses.md + OKR Objective 6"
---

# Zolai AI — Business Strategy

> **Status: UNDER REVIEW.** All business hypotheses are UNVALIDATED until interview or pilot evidence exists. This document is a strategic scaffold, not a business plan.

---

## 1. Target Users

| Segment | Description | Hypothesis | Validation Status |
|---------|-------------|------------|-------------------|
| **Tedim Zolai learners (beginner–intermediate)** | New speakers, diaspora youth, community learners | Need dictionary, literacy pathways, practice | UNVALIDATED |
| **Bilingual speakers (ZO↔EN)** | Heritage speakers, translators, writers | Need translation / lookup / writing support | UNVALIDATED |
| **Teachers / community educators** | Language school teachers, church educators, curriculum developers | Need curriculum-aligned tools, lesson plans, exercises | UNVALIDATED |
| **Diaspora learners** | Zomi people outside Myanmar, second-generation speakers | Need remote access (web/MCP), offline mode | UNVALIDATED |
| **Researchers / developers** | NLP researchers, computational linguists, Chin language scholars | Need APIs, datasets, MCP, open data | PARTIAL (MCP live) |
| **Language preservation organizations** | Endangered language programs, UNESCO, SIL International | Need standardized data, evaluation, governance | UNVALIDATED |

**Source:** [`docs/community/target-users.md`](../community/target-users.md)

---

## 2. Customer Segments

| Segment | Primary Need | Willingness to Pay (HYPOTHESIS) | Validation |
|---------|-------------|--------------------------------|------------|
| Individual learners | Free literacy tool | Low (expect free) | UNVALIDATED |
| Teachers / schools | Curriculum tools, exercises | Medium (institutional budget) | UNVALIDATED |
| Diaspora communities | Remote/offline access | Low–Medium (personal use) | UNVALIDATED |
| Researchers | APIs, datasets, benchmarks | Low (expect open access) | UNVALIDATED |
| Preservation orgs | Standardized data, governance | Medium–High (grant-funded) | UNVALIDATED |
| AI/tech companies | MCP integration, language data | Medium (commercial value) | UNVALIDATED |

---

## 3. Value Propositions

> **All UNVALIDATED.** These are hypotheses until user interviews confirm.

| For... | Value Proposition | Status |
|--------|-------------------|--------|
| Learners | First free, accurate Zolai literacy tool with ZVS 2018 compliance | UNVALIDATED |
| Bilingual speakers | Context-aware translation that respects polysemy and tone | UNVALIDATED |
| Teachers | CEFR-aligned curriculum with auto-generated exercises | UNVALIDATED |
| Diaspora | Web + MCP access from anywhere; offline via desktop app | UNVALIDATED |
| Researchers | Largest open Zolai dataset (3.3M rows) + RAG-first architecture reference | PARTIAL (data exists) |
| Preservation orgs | Community-owned, CARE-compliant data governance model | UNVALIDATED |

---

## 4. Product Hypotheses

| ID | Hypothesis | Type | Status | Evidence Required |
|----|------------|------|--------|-------------------|
| BH1 | Learners will use a free web literacy tool regularly | Product | UNVALIDATED | 5+ speaker interviews, web analytics |
| BH2 | Institutions may pay for API / translation assist | Revenue | UNVALIDATED | 3+ institutional interviews |
| BH3 | Grants can fund research & data infrastructure for 12–24 months | Funding | UNVALIDATED | 1+ grant application submitted |
| BH4 | Consulting / research services could subsidize open tools | Service | UNVALIDATED | 1+ consulting engagement |
| BH5 | MCP integration creates developer adoption | Product | UNVALIDATED | MCP usage analytics, 5+ developer feedback |
| BH6 | Desktop app serves offline learners | Product | UNVALIDATED | Desktop app deployed, 10+ active users |

**Source:** [`docs/business/hypotheses.md`](hypotheses.md)

**Update only with interview or pilot evidence.**

---

## 5. Revenue Models (Exploring)

| Stream | Model | Status | Source |
|--------|-------|--------|--------|
| API access | Freemium (free tier + paid) | Exploring | Whitepaper §8 |
| Dataset licensing | Open data + premium curated sets | Exploring | Whitepaper §8 |
| Education platform | Premium features (offline, advanced) | Exploring | Whitepaper §8 |
| Grant funding | NSF, UNESCO, Microsoft | Planning | Whitepaper §8, OKR Obj 4 |
| Consulting/partnerships | Language technology partnerships | Exploring | Whitepaper §8 |

**Revenue projection:** $0 currently. No validated path to revenue. All models UNVALIDATED.

---

## 6. Competitive Landscape

| Project | Scope | Approach | Differentiator (Zolai AI) |
|---------|-------|----------|---------------------------|
| **Masakhane** | African languages (80+) | Shared-task NLP, community-driven | Zolai-specific; RAG-first; ZVS 2018 enforcement |
| **Te Hiku Media** | Māori language | Speaker-owned data sovereignty | Similar governance; different language/family |
| **AmericasNLP** | Indigenous American languages | Shared-task evaluation | Different language family; evaluation focus |
| **OPUS** | All languages | Parallel corpus collection | Zolai AI is a full toolkit, not just corpora |
| **Generic MT (Google, DeepL)** | Major languages | Neural MT at scale | Zolai not supported; ZVS 2018 not enforced |
| **SIL International** | 7,000+ languages | Language documentation tools | Zolai AI is RAG-first, community-owned, not institutional |

**Zolai AI's unique position:**
1. **ZVS 2018 enforcement** — no other tool enforces Tedim orthography
2. **RAG-first** — dictionary → Bible → corpus → AI (not fine-tune-first)
3. **Community-owned** — CARE Principles, open data, open source
4. **Largest Zolai dataset** — 3.3M rows, no comparable public resource

---

## 7. Sustainability

### 7.1 Current State

| Factor | Status | Risk |
|--------|--------|------|
| Founder | Solo (Peter Pau Sian Lian) | HIGH — single point of failure |
| Funding | $0 secured | HIGH — no operational budget |
| Community | Limited active contributors | HIGH — no community momentum |
| Revenue | $0 | HIGH — no validated path |
| Time | 20–25 hrs/week (working professional + CS student) | MEDIUM — bandwidth constrained |

### 7.2 Scaling Path (UNVALIDATED)

| Phase | Timeline | Goal | Dependencies |
|-------|----------|------|-------------|
| Foundation | Months 1–3 | Tests, backup, license, evaluation | Solo founder time |
| Validation | Months 4–6 | 5+ speaker interviews, benchmark v1 | Community outreach |
| Growth | Months 7–12 | Grant application, desktop app, curriculum | Funding or advisor support |
| Sustainability | Year 2+ | Revenue stream, advisory board, active community | Multiple validated hypotheses |

### 7.3 Key Risks

| Risk | Probability | Impact | Mitigation |
|------|:-----------:|:------:|------------|
| Solo founder burnout | High | Critical | Enforce 20–25 hr/week cap; seek co-builder |
| No funding secured | High | High | Grant pipeline (KR4.3–4.4); rolling applications |
| Community disengagement | High | High | Start with diaspora contacts; offer incentives |
| Advisor unavailability | Medium | Medium | Async communication; clear expectations |
| Undefined commercial arrangement | Low | High | Document early (private); get legal advice |

---

## 8. Non-Goals (Near Term)

- **Premature commercialization** — do not claim revenue models until validated
- **Unvalidated product claims** — do not state "serves X users" without evidence
- **Expanding beyond 10 repos** — focus, not sprawl
- **Building for imagined users** — validate first, build second
- **Fine-tune-first narrative** — RAG-first per DEC-001

---

## Related

- [`../strategy/mission-vision.md`](../strategy/mission-vision.md) — Identity and pillars
- [`../strategy/whitepaper.md`](../strategy/whitepaper.md) — §8 Sustainability
- [`../community/target-users.md`](../community/target-users.md) — User segments
- [`hypotheses.md`](hypotheses.md) — Product hypotheses
- [`../strategy/05-90-day-okr.md`](../strategy/05-90-day-okr.md) — OKR Objective 6 (Business Validation)
- [`../architecture/component-status.md`](../architecture/component-status.md) — Component status
- [`../ROADMAP.md`](../ROADMAP.md) — Strategic roadmap
