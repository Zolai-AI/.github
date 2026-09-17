---
title: "Zolai-AI Roadmap"
description: "Strategic roadmap aligned with comprehensive ecosystem audit"
created: 2026-09-07
last_updated: 2026-09-18
maintainer: "Peter Pau Sian Lian (@peterlianpi)"
source: "docs/strategy/01-strategic-audit.md"
---

# Zolai-AI Roadmap

> Prioritized action plan aligned with the comprehensive strategic audit.
> See [`docs/strategy/01-strategic-audit.md`](docs/strategy/01-strategic-audit.md) for full audit.

---

## Current Assessment: 4.5/10

| Area | Score | Status |
|------|:-----:|--------|
| Data Assets | 8/10 | Strong — 3.3M rows, 99 tables |
| Code Quality | 7/10 | Good — 466+ tests, ruff linting |
| NLP Pipeline | 6/10 | Basic — syllable excellent, others incomplete |
| Documentation | 5/10 | Scattered — rich context files, not integrated |
| Community | 4/10 | Weak — no active contributors |
| Evaluation | 3/10 | Minimal — 33 smoke tests only |
| Business | 2/10 | None — no revenue, no plan |
| Grants | 3/10 | Not ready — major gaps |
| Research | 4/10 | Nascent — questions articulated, no publications |

---

## NOW (Week 1-4) — Critical Foundation

| # | Task | Why | Effort | Status |
|---|------|-----|:------:|:------:|
| 1 | Fix broken tests (test_prediction_api, test_word_attestation) | Blocks CI, signals quality | 8h | ⏳ |
| 2 | Set up automated backup for data/ | Data loss risk | 8h | ⏳ |
| 3 | Audit and document licenses for all data sources | Legal risk, grant requirement | 16h | ⏳ |
| 4 | Create 100+ evaluation test cases | Can't improve what you can't measure | 24h | ⏳ |
| 5 | Archive duplicate/stale data | Reduce confusion | 16h | ⏳ |

## NEXT (Month 2-3) — Governance & Community

| # | Task | Why | Effort | Status |
|---|------|-----|:------:|:------:|
| 6 | Create governance document + identify 3-5 advisors | Grant requirement, credibility | 16h | ⏳ |
| 7 | Join Masakhane community | Network, collaboration | 8h | ⏳ |
| 8 | Interview 5 Zomi speakers | Validate assumptions | 16h | ⏳ |
| 9 | Design evaluation benchmark | Research credibility | 24h | ⏳ |
| 10 | Create unified documentation site | Discoverability | 16h | ⏳ |

## LATER (Month 4-12) — Research & Applications

| # | Task | Why | Effort | Status |
|---|------|-----|:------:|:------:|
| 11 | Write workshop paper (AmericasNLP/LowResNLP) | Academic credibility | 40h | ⏳ |
| 12 | Launch vocabulary learning app v1 | Community benefit | 60h | ⏳ |
| 13 | Create A1-A2 curriculum | Education foundation | 80h | ⏳ |
| 14 | Submit 2-3 grant applications | Sustainability | 120h | ⏳ |
| 15 | Deploy desktop app v1 (Tauri) | Offline access | 60h | ⏳ |

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
| [Strategic Audit](docs/strategy/01-strategic-audit.md) | Full 32-section audit |
| [Strategic Roadmap](docs/strategy/02-strategic-roadmap.md) | Detailed action plan |
| [Grant Readiness](docs/strategy/03-grant-readiness.md) | Grant gap analysis |
| [AI Tools & Attribution](docs/AI_TOOLS_AND_ATTRIBUTION.md) | AI toolchain docs |

---

**Last review:** 2026-09-18
**Next review:** 2026-10-18
**Feedback:** Open a GitHub Discussion or issue

---

**Lungdam!** (Thank you!) 🙏
