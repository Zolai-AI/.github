---
title: "Zolai-AI Roadmap"
description: "Strategic roadmap aligned with OKRs and ecosystem audit"
created: 2026-09-07
last_updated: 2026-09-19
maintainer: "Peter Pau Sian Lian (@peterlianpi)"
source: "docs/strategy/01-strategic-audit.md + docs/strategy/okr.md"
---

# Zolai-AI Roadmap

> Horizons: **Immediate 0–30d** · **Near-term 31–90d** · **Medium 3–12m** · **Long-term 1–3y**  
> Canonical OKRs: [`strategy/05-90-day-okr.md`](strategy/05-90-day-okr.md) · Execution: [`strategy/15-execution-plan.md`](strategy/15-execution-plan.md)  
> Full audit: [`strategy/01-strategic-audit.md`](strategy/01-strategic-audit.md)

Every major item links: OKR · Owner · Dependency · Evidence · Repository · Docs · Status.

---

## Current Assessment: 4.5/10

| Area | Score | Status |
|------|:-----:|--------|
| Data Assets | 8/10 | Strong — ~3.3M rows, ~99 tables (verify via audit/DB) |
| Code Quality | 7/10 | Good — 466+ tests, ruff linting |
| NLP Pipeline | 6/10 | Syllable strong; others Experimental / incomplete |
| Documentation | 6/10 | Architecture v2 canonical paths added 2026-09-18 |
| Community | 4/10 | Weak — limited active contributors |
| Evaluation | 3/10 | Minimal — expand per KR3.* |
| Business | 2/10 | Hypotheses only |
| Grants | 3/10 | Not ready — major gaps |
| Research | 4/10 | Nascent — scaffold in `docs/research/` |

---

## NOW (Week 1-4) — Critical Foundation · Immediate 0–30d

| # | Task | OKR | Owner | Dependency | Evidence | Repository | Docs link | Effort | Status |
|---|------|-----|-------|------------|----------|------------|-----------|:------:|:------:|
| 1 | Fix broken tests | KR2.1 | Peter | None | pytest output | zolai-core | [`05-90-day-okr.md`](strategy/05-90-day-okr.md) | 8h | ✅ KR2.1 CLOSED (1010 passed) |
| 2 | Automated backup for data/ | KR2.2 | Peter | None | Backup verification log | data/ | [`05-90-day-okr.md`](strategy/05-90-day-okr.md) | 8h | ⏳ |
| 3 | License audit all sources | KR2.3 | Peter | None | data/CREDITS.md complete | zolai-core | [`05-90-day-okr.md`](strategy/05-90-day-okr.md) | 16h | ⏳ |
| 4 | Create 100+ evaluation cases | KR3.1 | Peter | KR2.1 (tests passing) | Evaluation dataset | zolai-core | [`05-90-day-okr.md`](strategy/05-90-day-okr.md) | 24h | ⏳ |
| 5 | Archive duplicate/stale data (backup first) | KR2.4 | Peter | KR2.2 (backup running) | Archive log + DB size reduced | data/ | [`05-90-day-okr.md`](strategy/05-90-day-okr.md) | 16h | ⏳ |

## NEXT (Month 2-3) — Near-term 31–90d

| # | Task | OKR | Owner | Dependency | Evidence | Repository | Docs link | Effort | Status |
|---|------|-----|-------|------------|----------|------------|-----------|:------:|:------:|
| 6 | Governance + advisor clarity | KR5.2 / DEC-002 | Peter | None | Published GOVERNANCE.md | .github | [`decisions.md`](strategy/decisions.md) | 16h | 🔄 docs v2 started |
| 7 | Join Masakhane | KR1.2 | Peter | None | Slack/GitHub membership | — | [`peer-language-communities.md`](research/peer-language-communities.md) | 8h | ⏳ |
| 8 | Interview 5 Zomi speakers | KR5.1 | Peter | Community outreach | Interview summaries | — | [`target-users.md`](community/target-users.md) | 16h | ⏳ |
| 9 | Design evaluation benchmark | KR3.2 | Peter | KR3.1 (100+ cases) | Published benchmark plan | zolai-core | [`benchmarks.md`](research/benchmarks.md) | 24h | ⏳ |
| 10 | Unified documentation (Architecture v2) | — | Peter | None | Documentation Architecture v2.5 | docs/ | [`project-context.md`](context/project-context.md) | 16h | ✅ v2.5 complete |

## LATER (Month 4-12) — Research & Applications

| # | Task | OKR | Owner | Dependency | Evidence | Repository | Docs link | Effort | Status |
|---|------|-----|-------|------------|----------|------------|-----------|:------:|:------:|
| 11 | Write workshop paper (AmericasNLP/LowResNLP) | KR1.3 | Peter | KR1.1 (papers read), KR3.* (evaluation) | Submission confirmation | docs/research | [`research/`](research/) | 40h | ⏳ |
| 12 | Launch vocabulary learning app v1 | — | Peter | Web platform stable, 5+ speaker interviews | User metrics | zolai-web | [`component-status.md`](architecture/component-status.md) | 60h | ⏳ |
| 13 | Create A1-A2 curriculum | KR5.* | Peter | KR5.1 (speaker interviews), wiki content | Curriculum document | zolai-wiki | [`component-status.md`](architecture/component-status.md) | 80h | ⏳ |
| 14 | Submit 2-3 grant applications | KR4.3–4.4 | Peter | KR4.1 (white paper), KR4.2 (budget), legal entity | Application confirmations | docs/grants | [`03-grant-readiness.md`](strategy/03-grant-readiness.md) | 120h | ⏳ |
| 15 | Deploy desktop app v1 (Tauri) | — | Peter | Web platform stable, Tauri build green | Working AppImage | zolai-tauri | [`component-status.md`](architecture/component-status.md) | 60h | ⏳ |

## DEFER — Blocked or Low Priority

| Activity | Blocked By | Revisit When |
|----------|-----------|--------------|
| Mobile app | Web + desktop not complete | Month 12+ |
| Speech technology (ASR/TTS) | Text pipeline not proven | Year 2+ |
| Custom LLM training | Data foundation not solid | Year 2+ |
| n8n automation | No running instance | Month 12+ |
| Knowledge graph | Database not stable | Month 12+ |
| Chin language expansion | Zolai model not validated | Year 2+ |

## DO NOT DO

- Premature model training
- Expanding repos beyond 10
- Building for imagined users (validate first)
- Ignoring evaluation
- Excessive architecture (43 submodules, many stubs)

---

## Phase Timeline

### Phase 1: Foundation (Months 1-2)
- [x] Repository audit complete
- [x] Database audit complete
- [ ] Fix broken tests
- [ ] Backup strategy
- [ ] License audit
- [ ] Governance structure

### Phase 2: Data Quality (Months 2-4)
- [ ] Archive import/duplicate tables
- [ ] Data quality dashboard
- [ ] 100+ evaluation test cases
- [ ] Community validation pipeline

### Phase 3: NLP Foundation (Months 4-8)
- [ ] Evaluation benchmark suite
- [ ] POS tagging integration
- [ ] End-to-end RAG validation
- [ ] Community corrections flowing

### Phase 4: Applications (Months 8-14)
- [ ] Vocabulary learning app v1
- [ ] A1-A2 curriculum
- [ ] Desktop app v1
- [ ] Research paper submitted

### Phase 5: Research (Months 10-18)
- [ ] Workshop paper published
- [ ] Evaluation benchmarks published
- [ ] Research partnerships established
- [ ] Conference presentation

### Phase 6: Ecosystem (Months 18-36)
- [ ] Other Chin languages supported
- [ ] Active contributor community
- [ ] Sustainable funding
- [ ] Scaling education programs

---

## Success Metrics

### Data Quality
- Dictionary coverage: 84K → 150K+ entries
- Evaluation cases: 33 → 500+
- Verified entries: 0 → 50,000+

### Community
- Active contributors: 0 → 25+
- Community corrections: 0 → 500+
- Learning app users: 0 → 500+

### Research
- Published papers: 0 → 3+
- Evaluation benchmarks: 0 → 3
- Research partnerships: 0 → 2+

### Funding
- Grant applications: 0 → 3+
- Funding secured: $0 → $100K+
- Revenue: $0 → sustainable

---

## Documents

| Document | Description |
|----------|-------------|
| [OKR entry](strategy/okr.md) | Annual + 90-day OKRs |
| [Mission & vision](strategy/mission-vision.md) | Identity / pillars |
| [Gap register](strategy/gap-register.md) | Prioritized gaps |
| [Architecture status](architecture/status.md) | Feature status labels |
| [Database docs](database/README.md) | DB audit pointers |
| [Strategic Audit](strategy/01-strategic-audit.md) | Full audit |
| [Strategic Roadmap detail](strategy/02-strategic-roadmap.md) | Detailed action plan |
| [Grant Readiness](strategy/03-grant-readiness.md) | Grant gaps |
| [Project context](context/project-context.md) | Agent context |
| [Model routing](context/model-routing.md) | Best model per agent role |

---

**Last review:** 2026-09-18
**Next review:** 2026-10-18
**Feedback:** Open a GitHub Discussion or issue

---

**Lungdam!** (Thank you!) 🙏
