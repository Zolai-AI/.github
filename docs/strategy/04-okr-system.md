---
title: "Zolai AI — Master OKR System"
description: "Strategic hierarchy, annual OKRs, quarterly OKRs, scoring system, and prioritization framework"
author: "OpenCode orchestra conductor"
created: 2026-09-18
last_updated: 2026-09-18
status: current
source: "01-strategic-audit.md + all context files"
---

# Zolai AI — Master OKR System

**Created:** 2026-09-18
**Source:** Comprehensive analysis of all project documentation (20+ files)

---

## Strategic Hierarchy

```
MISSION (why we exist)
  └→ VISION (where we're going)
      └→ STRATEGIC PILLARS (major areas of work)
          └→ ANNUAL OKRs (this year's goals)
              └→ QUARTERLY OKRs (90-day cycles)
                  └→ KEY RESULTS (measurable outcomes)
                      └→ INITIATIVES (specific projects)
```

---

## Mission

**Preserve & teach Tedim Zolai (ZVS 2018) with a RAG-first bilingual AI toolkit for the Zomi people.**

## Vision

**Empower the Zomi people with community-owned, culturally grounded AI tools that preserve and revitalize Tedim Zolai through ethical data practices, indigenous knowledge systems, and accessible technology.**

---

## 7 Strategic Pillars

| # | Pillar | Description | Why It Matters |
|---|--------|-------------|----------------|
| P1 | **Data & Language Infrastructure** | Canonical database, data quality, syllable engine, dictionary cleaning | Foundation for everything — no quality data = no quality tools |
| P2 | **NLP & AI Pipeline** | RAG, translation, grammar checking, morphology, phonology | Core intelligence that powers all user-facing features |
| P3 | **Evaluation & Quality** | Benchmarks, metrics, regression testing, quality assurance | Can't improve what you can't measure |
| P4 | **Community & Literacy** | Speaker engagement, validation, curriculum, cultural grounding | Without community, tools are technically correct but culturally hollow |
| P5 | **Research & Publications** | Academic papers, benchmarks, methodology, conferences | Credibility, visibility, grant eligibility |
| P6 | **Product & Deployment** | Web platform, desktop app, MCP server, user experience | Delivery mechanism to reach actual users |
| P7 | **Sustainability & Governance** | Funding, partnerships, legal structure, advisory board | Survival beyond solo founder capacity |

---

## Annual OKRs (2026-2027)

### Objective 1: Establish Zolai AI as a Credible Language Technology Project
**Strategic Pillar:** Research & Publications + Evaluation & Quality

| KR | Baseline | Target | Deadline | Evidence |
|----|----------|--------|----------|----------|
| KR1.1: Create 100+ evaluation test cases covering translation, grammar, syllable | 33 smoke tests | 100+ evaluation cases | Month 3 | Evaluation dataset in data/eval/ |
| KR1.2: Achieve 90%+ accuracy on Zolai NLP benchmark (syllable, grammar, translation) | No benchmark | 90%+ on 5 tasks | Month 6 | Published benchmark results |
| KR1.3: Submit 1 workshop paper (AmericasNLP/LowResNLP) | 0 papers | 1 submission | Month 9 | Submission confirmation |
| KR1.4: Join Masakhane + 1 other NLP community | 0 communities | 2 communities | Month 2 | Active membership evidence |
| KR1.5: Establish advisory board (3+ members) | 0 advisors | 3+ advisors | Month 3 | Signed advisory agreements |

### Objective 2: Build Community Trust and Engagement
**Strategic Pillar:** Community & Literacy + Sustainability & Governance

| KR | Baseline | Target | Deadline | Evidence |
|----|----------|--------|----------|----------|
| KR2.1: Complete 5+ user interviews with Zomi speakers | 0 interviews | 5+ interviews | Month 2 | Interview transcripts + insights |
| KR2.2: Deploy community annotation platform (Argilla or similar) | Not deployed | Platform live | Month 3 | Working platform URL |
| KR2.3: Achieve 50+ community corrections/annotations | 0 corrections | 50+ corrections | Month 6 | Correction database entries |
| KR2.4: Create GOVERNANCE.md + community guidelines | Not created | Published | Month 2 | Published document |
| KR2.5: Establish ZVS 2018 compliance rate at 99%+ across all data | ~95% | 99%+ | Month 3 | Compliance audit report |

### Objective 3: Secure First Funding
**Strategic Pillar:** Sustainability & Governance

| KR | Baseline | Target | Deadline | Evidence |
|----|----------|--------|----------|----------|
| KR3.1: Complete budget justification with line-item costs | $0 budget | Full budget template | Month 3 | Budget document |
| KR3.2: Submit 2+ grant applications | 0 applications | 2+ submissions | Month 6 | Submission confirmations |
| KR3.3: Establish organizational entity (nonprofit or fiscal sponsor) | Personal project | Legal entity | Month 4 | Registration documents |
| KR3.4: Secure 1+ partnership (academic or community organization) | 0 partners | 1+ partner | Month 3 | Partnership agreement/letter |
| KR3.5: Create sustainability plan (post-grant funding strategy) | Not created | Published plan | Month 3 | Document |

### Objective 4: Complete Core Data Infrastructure
**Strategic Pillar:** Data & Language Infrastructure

| KR | Baseline | Target | Deadline | Evidence |
|----|----------|--------|----------|----------|
| KR4.1: Fix all broken tests (test_prediction_api, test_word_attestation) | 2 broken tests | 0 broken tests | Month 1 | pytest passes clean |
| KR4.2: Set up automated daily backup of data/ | No backup | Daily backups running | Month 1 | Backup verification log |
| KR4.3: Complete license audit for all data sources | Partial | 100% documented | Month 1 | data/CREDITS.md complete |
| KR4.4: Archive duplicate/stale data (99→60 tables) | 99 tables | 60 canonical tables | Month 2 | Archive log |
| KR4.5: Achieve end-to-end RAG validation (dictionary→Bible→response) | Untested | E2E test passing | Month 2 | Integration test results |

### Objective 5: Build Zolai NLP Benchmark
**Strategic Pillar:** Evaluation & Quality + Research & Publications

| KR | Baseline | Target | Deadline | Evidence |
|----|----------|--------|----------|----------|
| KR5.1: Design benchmark methodology (5 tasks: syllable, grammar, translation, ZVS, tone) | No methodology | Published plan | Month 2 | Benchmark design document |
| KR5.2: Create gold standard datasets for each benchmark task | 0 gold sets | 5 gold datasets | Month 4 | datasets in data/eval/ |
| KR5.3: Run baseline evaluations on all benchmark tasks | No baselines | 5 baseline results | Month 5 | Results document |
| KR5.4: Achieve state-of-the-art on at least 1 Zolai NLP task | No SOTA | 1 SOTA result | Month 6 | Comparison table |
| KR5.5: Publish benchmark as open dataset on HuggingFace | Not published | 1 dataset published | Month 6 | HuggingFace dataset page |

---

## Quarterly OKRs

### Q1 (Months 1-3): Foundation

**Objective Q1.1: Fix Critical Infrastructure**
- KR: 0 broken tests → `pytest tests/` passes clean
- KR: Daily automated backup running for data/
- KR: 100% license documentation for all data sources
- KR: End-to-end RAG validation test passing
- Initiative: Infrastructure hardening sprint

**Objective Q1.2: Establish Evaluation Framework**
- KR: 100+ evaluation test cases created
- KR: Benchmark methodology designed (5 tasks)
- KR: Baseline measurements for all tasks
- KR: Quality regression CI gate active
- Initiative: Evaluation sprint

**Objective Q1.3: Begin Community Engagement**
- KR: 5+ Zomi speaker interviews completed
- KR: GOVERNANCE.md published
- KR: Advisory board: 3+ members committed
- KR: Masakhane membership active
- Initiative: Community outreach

### Q2 (Months 4-6): Validation

**Objective Q2.1: Validate with Community**
- KR: Annotation platform deployed and active
- KR: 50+ community corrections collected
- KR: ZVS compliance at 99%+
- KR: First feedback session with speakers
- Initiative: Community validation cycle

**Objective Q2.2: Submit Grants**
- KR: 2+ grant applications submitted
- KR: Organizational entity established
- KR: 1+ partnership formalized
- KR: Budget template finalized
- Initiative: Grant preparation

**Objective Q2.3: Build Research Track Record**
- KR: Workshop paper outline complete
- KR: Benchmark results documented
- KR: 1+ conference talk submitted
- KR: Research methodology published
- Initiative: Research sprint

### Q3 (Months 7-9): Deployment

**Objective Q3.1: Launch Learning App v1**
- KR: Web app deployed with vocabulary learning
- KR: 50+ active users
- KR: User satisfaction > 4/5
- KR: Spaced repetition engine working
- Initiative: Product launch

**Objective Q3.2: Publish & Disseminate**
- KR: Workshop paper submitted
- KR: Benchmark dataset on HuggingFace
- KR: 2+ conference presentations
- KR: Media coverage or blog posts
- Initiative: Dissemination

### Q4 (Months 10-12): Scale

**Objective Q4.1: Scale Community**
- KR: 10+ active contributors
- KR: 200+ community corrections
- KR: Discord/community channel active
- KR: Monthly community calls running
- Initiative: Community scaling

**Objective Q4.2: Plan Year 2**
- KR: Year 2 strategy document
- KR: Year 2 budget proposal
- KR: 3+ grant applications (Year 2)
- KR: Research agenda for Year 2
- Initiative: Strategic planning

---

## OKR Scoring System

### Scoring Scale
| Score | Meaning | Description |
|-------|---------|-------------|
| 1.0 | Complete | Fully achieved — all evidence met |
| 0.7 | On Track | Significant progress — most evidence met |
| 0.5 | Partial | Halfway there — some evidence |
| 0.3 | Behind | Minimal progress — few evidence |
| 0.0 | Not Started | No progress — no evidence |

### Scoring Rules
- **Score 0.7 = good** — ambitious OKRs should not always hit 1.0
- **Score 0.3 = need intervention** — course correction required
- **Score 0.0 for 2 consecutive quarters = reconsider the OKR**
- **Every KR must have evidence** — no subjective scoring
- **Score monthly** — don't wait until quarter end

### SMART Check
Every KR must pass:
- **S**pecific — What exactly will be achieved?
- **M**easurable — How will we know it's done? (evidence)
- **A**chievable — Is this realistic given founder capacity?
- **R**elevant — Does this advance a strategic pillar?
- **T**ime-bound — When will this be done? (deadline)

---

## Prioritization Framework

### Priority Levels
| Priority | Definition | Action |
|----------|-----------|--------|
| **P0** | Critical — blocks everything | Do immediately |
| **P1** | Important — high impact, enables future work | Do this month |
| **P2** | Valuable — medium impact, can wait | Do this quarter |
| **P3** | Nice to have — low impact, defer | Do when ready |
| **STOP** | Actively harmful or premature | Remove from plan |

### Time Horizon
| Horizon | Timeframe | Focus |
|---------|-----------|-------|
| **NOW** | This week | P0 items, blockers |
| **NEXT** | This month | P1 items, enablers |
| **LATER** | This quarter | P2 items, growth |
| **DEFER** | When conditions change | Blocked items |
| **STOP** | Never (for now) | Premature/wrong |

---

## Conflicts & Resolutions

| Conflict | Resolution |
|----------|------------|
| "Mobile app" mentioned in some docs vs "web+desktop first" in audit | **RESOLVED:** Mobile deferred to Year 2. Web → Desktop → Mobile |
| "Model training" in KAGGLE_SETUP vs "no raw fine-tuning" in architecture | **RESOLVED:** Fine-tuning deferred. RAG-first approach maintained. |
| "10 repos" vs "consolidate to 4-5" in audit | **RESOLVED:** Keep 10 repos but focus active work on 4-5 core repos |
| "PostgreSQL migration" in progress-tracker vs SQLite canonical | **RESOLVED:** SQLite remains canonical. PostgreSQL deferred until scale requires it |
| "25% arrangement" mentioned in user prompt | **FLAGGED:** Requires formal documentation (see 08-25-percent-arrangement.md) |

---

*This OKR system is reviewed monthly and updated quarterly.*
