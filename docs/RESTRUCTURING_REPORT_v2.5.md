---
title: "Zolai AI — Restructuring Report v2.5"
description: "Final output report covering sections A–L per Master Prompt §33"
created: 2026-09-19
last_updated: 2026-09-19
status: CONFIRMED
version: "Documentation Architecture v2.5"
---

# Restructuring Report v2.5

> **Version:** Documentation Architecture v2.5  
> **Date:** 2026-09-19  
> **Scope:** Master Documentation & Context Restructuring Prompt continuation — fill remaining stubs  
> **Previous:** v2.4 (2026-09-18, OS close-out)

---

## A. Documentation Changes

### Created (this batch)

| File | Section | Purpose |
|------|---------|---------|
| `docs/architecture/component-status.md` | §15 | Full component status matrix (ecosystem, NLP, learning, API, infrastructure, deferred) |
| `docs/database/tables.md` | §16 | Complete DB table catalog (99 tables, row counts, relationships, consolidation candidates) |
| `docs/business/strategy.md` | §26 | Business strategy (target users, segments, value props, revenue models, competitive landscape, sustainability) |
| `docs/RESTRUCTURING_REPORT_v2.5.md` | §33 | This report (A–L sections) |

### Updated (this batch)

| File | Section | Changes |
|------|---------|---------|
| `docs/ROADMAP.md` | §25 | Added Dependency, Evidence, Repository, Docs link columns to all NOW/NEXT/LATER items; linked OKR KRs |
| `docs/context/project-context.md` | §22 | Added entries for component-status, tables, business-strategy; updated last_updated to 2026-09-19 |
| `docs/DOCUMENTATION_CHANGELOG.md` | §30 | New batch entry at top for v2.5 |

### Total files touched: 7 (4 created, 3 updated)

---

## B. Context Changes

| Area | Before | After |
|------|--------|-------|
| Component status | Stub in `architecture/status.md` (63 lines, partial) | Full matrix in `architecture/component-status.md` (6 sections, ~150 items) |
| Database catalog | `database/README.md` (audit pointers only) | Full table catalog in `database/tables.md` (99 tables, relationships, consolidation candidates) |
| Business strategy | `business/hypotheses.md` (4 rows) | Full strategy in `business/strategy.md` (8 sections, 6 segments, revenue models, competitive landscape) |
| Roadmap | NOW/NEXT/LATER with 6 columns | 9 columns (added Dependency, Evidence, Repository, Docs link) |
| Project context | 20 entries | 20 entries (updated links and last_updated) |

---

## C. Strategy Changes

| Area | Status | Notes |
|------|--------|-------|
| Mission | Unchanged | Preserve & teach Tedim Zolai with RAG-first bilingual AI toolkit |
| Vision | Unchanged | Language vitality through better data → better tools → better access |
| Pillars | Unchanged | Data, NLP/AI research, Literacy, Community, Research/open knowledge, Products/sustainability, Partnerships/grants/org |
| OKRs | Unchanged | 6 objectives with 30 KRs (KR1.1–KR6.5) |
| Roadmap | Updated | Enriched with dependency/evidence/repository/docs columns |
| Business strategy | NEW | Full strategy document with hypotheses, revenue models, competitive landscape |

---

## D. Governance Changes

| Area | Status | Notes |
|------|--------|-------|
| Founder | Peter Pau Sian Lian — unchanged | Solo founder |
| Advisor | Shwe Yee — Strategic Advisor & Business/Impact Mentor | Advisory only (DEC-002) |
| Contributors | Limited active | Solo founder risk (HIGH) |
| Commercial arrangement | Undefined, private (DEC-003) | Not resolved |
| Legal entity | Not established | Blocker for grants (KR4.5) |
| GOVERNANCE.md | Planned (KR5.2) | Not yet published |

---

## E. Research Changes

| Area | Status | Notes |
|------|--------|-------|
| Research agenda | Nascent | 10 papers read (KR1.1 in progress) |
| Gaps | Documented | `docs/research/gaps.md` |
| Papers | Quarantined | Unverified cites in `literature-review.md`; DEC-006 |
| Methodology | Planned | KR1.4 |
| Evaluation | Minimal | 33 smoke tests + 1,725-word syllable set; KR3.* targets 100+ |
| Peer communities | Documented | Masakhane, AmericasNLP, Te Hiku, NatGeo, LINGUA |
| FineWeb2 + HPLT | Annotated | arXiv abstracts read, notes in `docs/research/papers/` |

---

## F. White Paper Status

| Aspect | Status |
|--------|--------|
| Current version | v0.1 (2026-09-18) |
| Completed sections | Abstract, §1 Introduction, §2 Related Work (VERIFIED-only), §3 Data & Resources, §4 Methods, §5 Evaluation, §6 Community Impact, §7 Ethics, §8 Sustainability, §9 Roadmap, §10 References, Appendix A (DB Schema), Appendix B (Language Quick Reference) |
| Missing sections | None major; all sections have content |
| Evidence gaps | Syllable accuracy (self-consistency only), MT/QA/Summarizer (basic fallback only), no native speaker evaluation, no comparison with baselines (NLLB, mBART) |
| Status | **UNDER REVIEW** — accuracy figures and capability claims not re-verified in this pass |

---

## G. Grant Readiness

| Aspect | Status |
|--------|--------|
| Current readiness | **NOT READY** — major gaps |
| White paper draft | v0.1 exists; needs review |
| Budget justification | Not started (KR4.2) |
| Target programs | 3+ identified (NSF DLI-DEL, UNESCO IDIL, Microsoft AI for Good) but eligibility not confirmed |
| Missing evidence | Legal entity (KR4.5), budget (KR4.2), 5+ speaker interviews (KR5.1), 100+ evaluation cases (KR3.1) |
| Blocker | No legal entity; undefined commercial arrangement |

---

## H. Business Readiness

| Aspect | Status |
|--------|--------|
| Validated assumptions | **NONE** — all hypotheses UNVALIDATED |
| Hypotheses | BH1–BH6 documented; none validated |
| Customer discovery | 0 interviews (KR6.1 target: 10+) |
| Revenue models | 5 streams explored; none generating revenue |
| Financial projection | Not created (KR6.3 target) |
| Competitive analysis | Documented in `business/strategy.md` |
| Partner identification | Not started (KR6.5 target: 3+) |

---

## I. Technical Readiness

| Aspect | Status |
|--------|--------|
| Architecture | Implemented — wiki → core → web + tauri; MCP + landing live |
| Data gaps | Missing correction/feedback tables, evaluation tables, user interaction tables |
| Evaluation gaps | No gold-standard test sets; no native speaker evaluation; no baseline comparisons |
| Code quality | 1010 tests passing (zolai-core); ruff linting; CI green on 4/6 repos |
| Infrastructure | SQLite WAL + Cloudflare (MCP + landing) + GitHub Actions CI |
| Security | P0 resolved (git history cleaned) |
| Component gaps | Desktop (experimental), training (deferred), mobile (planned), speech (planned) |

---

## J. Top 10 Next Actions (Ranked)

| Rank | Action | Impact | Urgency | Dependency | Feasibility | OKR |
|------|--------|:------:|:-------:|------------|:-----------:|-----|
| 1 | Automated backup for data/ | HIGH | HIGH | None | HIGH | KR2.2 |
| 2 | License audit all sources | HIGH | HIGH | None | HIGH | KR2.3 |
| 3 | Create 100+ evaluation cases | HIGH | HIGH | KR2.1 ✅ | MEDIUM | KR3.1 |
| 4 | Complete 5 Zomi speaker interviews | HIGH | HIGH | Outreach | MEDIUM | KR5.1 |
| 5 | Design evaluation benchmark | HIGH | MEDIUM | KR3.1 | MEDIUM | KR3.2 |
| 6 | Publish GOVERNANCE.md | MEDIUM | MEDIUM | None | HIGH | KR5.2 |
| 7 | Write white paper draft | HIGH | MEDIUM | KR1.1, KR3.* | MEDIUM | KR4.1 |
| 8 | Archive duplicate/stale data | MEDIUM | MEDIUM | KR2.2 | HIGH | KR2.4 |
| 9 | Join Masakhane community | MEDIUM | MEDIUM | None | HIGH | KR1.2 |
| 10 | Draft 1 grant application | HIGH | LOW | KR4.1, KR4.2, legal entity | LOW | KR4.4 |

---

## K. Contradictions / Unresolved Questions

1. **Syllable accuracy:** 98.49% claimed but gold set is rule-generated (self-consistency only). No independent human-annotated test set exists. **Resolution:** KR3.3 targets gold datasets from native speakers.

2. **Database table overlap:** `vocabulary` (104K) vs `zolai_vocabulary` (112K); `grammar_patterns` (5.5K) vs `zolai_grammar_patterns` (13.5K); `word_usage` (269K) vs `zolai_word_usage` (85K). **Resolution:** Consolidation candidates documented in `database/tables.md`; deprecation requires downstream code audit.

3. **Business model:** All revenue hypotheses UNVALIDATED. No interviews, no pilots, no revenue. **Resolution:** OKR Objective 6 targets customer discovery.

4. **Legal entity:** Blocker for grants (KR4.5). Undefined commercial arrangement complicates governance. **Resolution:** Documented as open decision; requires legal advice.

5. **Advisor role:** Advisory only (DEC-002), but advisor mentioned in OKR evidence and mentoring sessions. **Resolution:** Public docs use advisor language only; no ownership claims.

6. **Claims audit:** Many items still `NOT_VERIFIED` or `PARTIALLY_VERIFIED`. **Resolution:** Ongoing verification per audit recommended next steps.

7. **NLP modules:** Many listed as "Experimental" with "partially verified" status. No end-to-end RAG pipeline validation. **Resolution:** KR3.* targets evaluation framework.

---

## L. Recommended Next Phase

### Immediate (Week 1-2)
1. **Run automated backup** for `data/` (KR2.2)
2. **Complete license audit** (KR2.3)
3. **Start 100+ evaluation cases** (KR3.1) — KR2.1 is now closed

### Short-term (Month 1-2)
1. **Outreach to 5 Zomi speakers** for interviews (KR5.1)
2. **Publish GOVERNANCE.md** (KR5.2)
3. **Design evaluation benchmark** (KR3.2)
4. **Start white paper draft** (KR4.1)

### Medium-term (Month 3-6)
1. **Run baseline evaluations** (KR3.4)
2. **Create gold datasets** (KR3.3) — needs native speaker validation
3. **Complete budget justification** (KR4.2)
4. **Draft 1 grant application** (KR4.4)

### Evidence Hygiene
- All accuracy claims labeled as self-consistency until independent validation
- All business hypotheses labeled UNVALIDATED until interview evidence
- All NLP module statuses based on claims audit (not marketing)
- Cross-references use relative links

---

*Documentation Architecture v2.5 — 2026-09-19*
*Previous: v2.4 (2026-09-18, OS close-out)*
*Source: Master Documentation & Context Restructuring Prompt §§15,16,22,25,26,30,33*
