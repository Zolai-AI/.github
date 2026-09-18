---
title: "Zolai AI — Execution Plan"
description: "Immediate action plan with time horizons from this week to this year"
author: "OpenCode orchestra conductor"
created: 2026-09-18
last_updated: 2026-09-18
status: current
---

# Zolai AI — Execution Plan

**Created:** 2026-09-18
**Source:** OKR system, strategic audit, all context files

---

## THIS WEEK (Sep 18-24)

### Priority 1: Fix Critical Infrastructure
| Action | OKR | Hours | Owner | Done When |
|--------|-----|:-----:|-------|-----------|
| Fix test_prediction_api.py | O4: KR2.1 | 2h | Peter | `pytest tests/` passes |
| Fix test_word_attestation | O4: KR2.1 | 4h | Peter | All tests green |
| Verify all tests pass | O4: KR2.1 | 2h | Peter | 0 failures |

### Priority 2: Start Backup Setup
| Action | OKR | Hours | Owner | Done When |
|--------|-----|:-----:|-------|-----------|
| Research backup options (S3, B2, GCS) | O4: KR2.2 | 2h | Peter | Options compared |
| Set up automated backup script | O4: KR2.2 | 4h | Peter | Daily backup running |

### Priority 3: Begin License Audit
| Action | OKR | Hours | Owner | Done When |
|--------|-----|:-----:|-------|-----------|
| List all data sources | O4: KR2.3 | 2h | Peter | Complete inventory |
| Check license for each source | O4: KR2.3 | 4h | Peter | All sources documented |

### Priority 4: Start Research Reading
| Action | OKR | Hours | Owner | Done When |
|--------|-----|:-----:|-------|-----------|
| Read 2 NLP papers | O1: KR1.1 | 4h | Peter | Annotated notes |
| Set up Zotero/citation manager | O1: KR1.4 | 1h | Peter | Tool configured |

### Weekly Time Budget: ~25 hours
| Category | Hours |
|----------|:-----:|
| Infrastructure fixes | 14h |
| Backup setup | 6h |
| License audit | 6h |
| Research reading | 4h |
| Admin/planning | 2h |
| **Total** | **~32h** (reduce to 25h by spreading) |

---

## THIS MONTH (Sep 18 – Oct 18)

### Major Deliverables
| Deliverable | OKR | Hours | Status |
|-------------|-----|:-----:|:------:|
| All tests passing (0 failures) | O4: KR2.1 | 8h | 🔴 Not started |
| Automated daily backup running | O4: KR2.2 | 8h | 🔴 Not started |
| 100% license documentation | O4: KR2.3 | 16h | 🔴 Not started |
| 5 NLP papers read + annotated | O1: KR1.1 | 10h | 🔴 Not started |
| Masakhane membership active | O1: KR1.2 | 8h | 🔴 Not started |
| 3 advisor candidates identified | O1: KR1.5 | 8h | 🔴 Not started |
| 3 speaker interviews scheduled | O5: KR5.1 | 8h | 🔴 Not started |
| GOVERNANCE.md draft | O5: KR5.2 | 4h | 🔴 Not started |

### Month 1 Success Criteria
- [ ] `pytest tests/` passes with 0 failures
- [ ] Daily backup running and tested
- [ ] All data sources have documented licenses
- [ ] 5+ papers read with annotations
- [ ] Masakhane membership confirmed
- [ ] 3+ advisor candidates identified
- [ ] 3+ speaker interviews scheduled
- [ ] GOVERNANCE.md published

---

## THIS QUARTER (Sep 18 – Dec 18)

### Major Outcomes
| Outcome | OKR | Hours | Evidence |
|---------|-----|:-----:|----------|
| 100+ evaluation test cases | O3: KR3.1 | 24h | Evaluation dataset |
| Benchmark methodology published | O5: KR5.2 | 16h | Design document |
| 5 gold standard datasets created | O3: KR3.3 | 40h | Gold datasets |
| White paper draft complete | O4: KR4.1 | 62h | White paper |
| 5+ speaker interviews completed | O5: KR5.1 | 16h | Interview notes |
| 50+ community corrections | O5: KR5.3 | 20h | Correction database |
| Advisory board (3+ members) | O1: KR1.5 | 16h | Signed agreements |
| 1 grant application drafted | O4: KR4.4 | 40h | Application draft |
| Business model canvas | O6: KR6.2 | 8h | Canvas document |
| 12-month financial projection | O6: KR6.3 | 8h | Financial model |

### Quarter Success Criteria
- [ ] Evaluation framework operational
- [ ] Benchmark results documented
- [ ] White paper draft reviewed by Shwe Yee
- [ ] 5+ community members engaged
- [ ] Advisory board active
- [ ] 1+ grant application ready
- [ ] Business model validated
- [ ] Financial projections realistic

---

## THIS YEAR (Sep 2026 – Sep 2027)

### Strategic Outcomes
| Outcome | OKR | Timeline | Evidence |
|---------|-----|:--------:|----------|
| Published workshop paper | O1: KR1.3 | Month 9 | Submission |
| 50+ active learners | O6: KR6.2 | Month 12 | Analytics |
| 500+ community corrections | O5: KR5.3 | Month 12 | Database |
| 2+ grant applications submitted | O4: KR4.4 | Month 6 | Confirmations |
| Organizational entity established | O4: KR4.5 | Month 4 | Registration |
| 10+ active contributors | O5: KR5.3 | Month 12 | GitHub |
| Revenue stream validated | O6: KR6.2 | Month 12 | Revenue data |
| State-of-the-art on 1 Zolai NLP task | O3: KR3.4 | Month 6 | Comparison |

### Year 1 Success Criteria
- [ ] At least 1 paper published or accepted
- [ ] 50+ active learners using the platform
- [ ] 500+ community corrections collected
- [ ] 2+ grants submitted
- [ ] Organizational entity established
- [ ] 10+ active contributors
- [ ] At least 1 revenue stream generating income
- [ ] State-of-the-art on at least 1 NLP task

---

## NOT NOW (Deliberately Waiting)

| Activity | Why Waiting | Revisit When |
|----------|-------------|--------------|
| Mobile app | Web + desktop not complete | Month 12+ |
| Speech technology (ASR/TTS) | Text pipeline not proven | Year 2+ |
| Custom LLM training | Data foundation not solid, no evaluation | Year 2+ |
| n8n automation | No running instance, unclear value | Month 12+ |
| Knowledge graph | Canonical database not stable | Month 12+ |
| Custom tokenizer | SentencePiece works, unclear benefit | After evaluation |
| Chin language expansion | Zolai model not validated | Year 2+ |
| Revenue generation | No users, no validation | Month 12+ |
| PostgreSQL migration | SQLite works fine at current scale | When scale requires |
| Multiple menu systems | Confusing, use v2 only | Never |

---

## Weekly Rhythm

| Day | Focus | Time |
|-----|-------|------|
| Monday | Planning + OKR review | 1h |
| Tue-Thu | Deep work (rotating focus) | 3-4h/day |
| Friday | Progress update + evidence | 1h |
| Saturday | Research + learning | 2h |
| Sunday | Rest / light admin | 0-1h |

**Total:** 20-25 hours/week

---

*This execution plan is updated weekly. See 04-okr-system.md for the full OKR framework.*
