---
title: "Zolai AI — Strategic Roadmap"
description: "Prioritized action plan with NOW/NEXT/LATER/DEFER/DO NOT DO classification"
author: "OpenCode orchestra conductor"
created: 2026-09-18
last_updated: 2026-09-18
status: current
source: "01-strategic-audit.md"
---

# Zolai AI — Strategic Roadmap

**Created:** 2026-09-18
**Source:** Full strategic audit (`docs/ZOLAI_AI_STRATEGIC_AUDIT.md`)

---

## Prioritization Framework

Every action classified by: **Impact × Urgency × Strategic Importance × Effort**

| Priority | Definition | Action |
|----------|-----------|--------|
| **NOW** | Do immediately (Week 1-4) | High impact, low effort, unblocks others |
| **NEXT** | Do soon (Month 2-3) | High impact, medium effort |
| **LATER** | Do when ready (Month 4-12) | Medium impact, high effort |
| **DEFER** | Do when conditions change | Low impact or blocked |
| **DO NOT DO** | Remove from plan | Low value, high cost, wrong timing |

---

## NOW (Week 1-4) — Critical Foundation

### Fix Broken Tests
- **What:** Fix test_prediction_api.py (FastAPI compat) and test_word_attestation (data loading)
- **Why:** Blocks CI, signals quality, enables confident development
- **Effort:** 8 hours
- **Done when:** `pytest tests/` passes with 0 failures
- **Owner:** Founder

### Set Up Automated Backup
- **What:** Automated daily backup of data/ to cloud storage
- **Why:** Data loss risk, grant requirement, operational hygiene
- **Effort:** 8 hours
- **Done when:** Backups running daily, tested restore
- **Owner:** Founder

### License Audit
- **What:** Document license for every data source (Bible, dictionaries, corpus)
- **Why:** Legal risk, grant requirement, publication blocker
- **Effort:** 16 hours
- **Done when:** Every source has documented license in data/CREDITS.md
- **Owner:** Founder

### Create Evaluation Data
- **What:** Build 100+ evaluation test cases covering translation, grammar, syllable
- **Why:** Can't improve what you can't measure, grant requirement
- **Effort:** 24 hours
- **Done when:** Evaluation dataset exists, results documented
- **Owner:** Founder

### Archive Duplicates
- **What:** Archive grammar_patterns_v1, old menus, Glosbe errors, stale docs
- **Why:** Reduce confusion, improve maintainability
- **Effort:** 16 hours
- **Done when:** 99 tables → 55-60, clear canonical set
- **Owner:** Founder

---

## NEXT (Month 2-3) — Governance & Community

### Create Governance Document
- **What:** Define decision-making, roles, contribution process
- **Why:** Grant requirement, contributor onboarding, sustainability
- **Effort:** 8 hours
- **Done when:** GOVERNANCE.md published
- **Owner:** Founder

### Identify Advisory Board
- **What:** Recruit 3-5 advisors (linguist, NLP researcher, community leader)
- **Why:** Grant requirement, credibility, expertise
- **Effort:** 16 hours (outreach)
- **Done when:** 3+ advisors committed
- **Owner:** Founder

### Join Masakhane Community
- **What:** Join Slack, attend meetings, introduce Zolai project
- **Why:** Network, visibility, collaboration, learning
- **Effort:** 8 hours
- **Done when:** Active member, first collaboration discussed
- **Owner:** Founder

### Interview Zomi Speakers
- **What:** Conduct 5-10 user interviews about needs and preferences
- **Why:** Validate assumptions, build trust, inform product
- **Effort:** 16 hours
- **Done when:** 5+ interviews completed, insights documented
- **Owner:** Founder

### Design Evaluation Benchmark
- **What:** Design Zolai NLP benchmark methodology
- **Why:** Research credibility, comparison, improvement
- **Effort:** 24 hours
- **Done when:** Benchmark plan published
- **Owner:** Founder

---

## LATER (Month 4-12) — Research & Applications

### Write Workshop Paper
- **What:** Write AmericasNLP/LowResNLP workshop paper
- **Why:** Academic credibility, visibility, citations
- **Effort:** 40 hours
- **Done when:** Paper submitted
- **Owner:** Founder + collaborator

### Launch Learning App v1
- **What:** Deploy vocabulary learning app with spaced repetition
- **Why:** Direct community benefit, adoption data
- **Effort:** 60 hours
- **Done when:** App live, 50+ users
- **Owner:** Founder

### Create A1-A2 Curriculum
- **What:** 50 lessons, 500 vocabulary, 100 exercises
- **Why:** Education foundation, user value
- **Effort:** 80 hours
- **Done when:** Curriculum complete, tested with learners
- **Owner:** Founder + curriculum specialist

### Submit Grant Applications
- **What:** Apply to 2-3 grant programs
- **Why:** Sustainability, funding
- **Effort:** 40 hours per application
- **Done when:** 2+ applications submitted
- **Owner:** Founder

### Desktop App v1
- **What:** Deploy Tauri desktop app with offline support
- **Why:** Offline access, field use
- **Effort:** 60 hours
- **Done when:** App downloadable, basic functionality
- **Owner:** Founder

---

## DEFER — Blocked or Low Priority

| Activity | Blocked By | Revisit When |
|----------|-----------|--------------|
| Mobile app | Web + desktop not complete | Month 12+ |
| Speech technology (ASR/TTS) | Text pipeline not proven | Year 2+ |
| Custom LLM training | Data foundation not solid, no evaluation | Year 2+ |
| n8n automation | No running instance, unclear value | Month 12+ |
| Knowledge graph | Canonical database not stable | Month 12+ |
| Custom tokenizer | SentencePiece works, unclear benefit | After evaluation |
| Chin language expansion | Zolai model not validated | Year 2+ |
| Revenue generation | No users, no validation | Month 12+ |

---

## DO NOT DO — Remove from Plan

| Activity | Why Not |
|----------|---------|
| Premature model training | Data foundation not solid, no evaluation |
| Expanding repos beyond 10 | Already too many, consolidate first |
| Building for imagined users | Validate with real users first |
| Ignoring evaluation | Can't improve what you can't measure |
| Multiple menu systems | Confusing, use v2 only |
| Glosbe downloads | All error pages, remove |
| Excessive architecture | 43 submodules, many stubs — complete before adding |

---

## Monthly Milestones

| Month | Research | Engineering | Data | Community | Grant |
|:-----:|----------|-------------|------|-----------|-------|
| 1 | Read 5 papers | Fix tests, backup | License audit | — | Research |
| 2 | Join Masakhane | CI for all repos | Archive duplicates | Governance doc | — |
| 3 | Design benchmark | Schema validation | 100+ eval cases | Advisory board | Draft application |
| 4 | Analyze results | Data quality dashboard | Community corrections | First feedback session | Submit application |
| 5 | Write paper outline | Fix integration issues | Validate with speakers | 2+ contributors | Second application |
| 6 | — | Deploy validation pipeline | 50+ corrections | Discord active | Third application |
| 7 | Write workshop paper | Launch learning app v1 | — | 5+ contributors | — |
| 8 | — | End-to-end RAG validation | — | — | — |
| 9 | Submit paper | Desktop app v1 | Benchmarks published | 10+ contributors | Year 2 strategy |
| 10 | — | Performance optimization | — | — | — |
| 11 | Present at conference | Scale infrastructure | 200+ corrections | Active community | — |
| 12 | Plan Year 2 | — | — | — | Year 2 grants |

---

*This roadmap is a living document. Update monthly based on progress and changing conditions.*
