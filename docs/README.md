---
title: Zolai AI Documentation
description: Master documentation index for the Zolai AI project
last_updated: 2026-09-18
---

# Zolai AI — Documentation

> Master index for all project documentation. Organized by category.

---

## Quick Links (Architecture v2)

| Document | Purpose | Status |
|----------|---------|:------:|
| [Project context (agents)](context/project-context.md) | Canonical AI/contributor context | ✅ |
| [Mission & Vision](strategy/mission-vision.md) | Identity, pillars | ✅ |
| [Source of Truth](governance/source-of-truth.md) | Domain → canonical path | ✅ |
| [OKR entry](strategy/okr.md) | → master + 90-day OKRs | ✅ |
| [Decisions](strategy/decisions.md) | Decision register | ✅ |
| [Gap register](strategy/gap-register.md) | Cross-cutting gaps | ✅ |
| [Advisors](strategy/advisors-and-mentors.md) | Advisor roles | ✅ |
| [Roadmap](ROADMAP.md) | Top-level roadmap | ✅ |
| [Architecture status](architecture/status.md) | Implemented / Experimental / … labels | ✅ |
| [Database docs](database/README.md) | Audit pointers, consolidation rule | ✅ |
| [Model routing](context/model-routing.md) | Best Cursor model per agent role | ✅ |
| [Doc changelog](DOCUMENTATION_CHANGELOG.md) | Architecture v2 history | ✅ |

### Detailed strategy (preserved)

| Document | Purpose | Status |
|----------|---------|:------:|
| [Strategic Audit](strategy/01-strategic-audit.md) | Full audit | ✅ |
| [Master OKR](strategy/04-okr-system.md) | Annual + quarterly | ✅ |
| [90-Day OKR](strategy/05-90-day-okr.md) | Sep–Dec 2026 | ✅ |
| [Dashboard](strategy/14-master-dashboard.md) | Top KRs / risks | ✅ |

---

## Documentation Structure

```
docs/
├── README.md
├── DOCUMENTATION_CHANGELOG.md
├── ROADMAP.md
├── context/project-context.md     ← agents / contributors
├── governance/                    ← SoT, roles, data, public/private
├── strategy/                      ← canonical + numbered detail (01–15)
├── research/ · grants/ · community/ · business/ · whitepaper/
├── architecture/ · audits/ · guides/ · planning/ · reports/
├── prompts/                       ← master restructuring prompt
└── private/                       ← gitignored (sensitive)
```

---

## Strategy & Planning

| Document | Description | Size |
|----------|-------------|------|
| [Strategic Audit](strategy/01-strategic-audit.md) | Comprehensive 32-section audit covering architecture, data, NLP, research, SWOT, mission, vision, grants, business, risks | 73KB |
| [Strategic Roadmap](strategy/02-strategic-roadmap.md) | Prioritized actions with NOW/NEXT/LATER/DEFER/DO NOT DO classification | 7KB |
| [Grant Readiness](strategy/03-grant-readiness.md) | Grant gap analysis, budget template, application checklist, contact strategy | 11KB |
| [**Master OKR System**](strategy/04-okr-system.md) | 7 strategic pillars, annual OKRs, quarterly OKRs, scoring, prioritization framework | 12KB |
| [**90-Day OKR**](strategy/05-90-day-okr.md) | 6 immediate objectives with baselines, targets, owners, evidence, risks (Sep-Dec 2026) | 8KB |
| [**Founder OKR**](strategy/06-founder-okr.md) | 7 skill areas for Peter — research, writing, grants, business, product, communication, technical | 9KB |
| [**Weekly Mentoring**](strategy/07-weekly-mentoring.md) | Meeting structure with Shwe Yee — 6×10-min segments, role boundaries, decision framework | 7KB |
| [Commercial arrangement stub](strategy/08-25-percent-arrangement.md) | Public stub only — details private / pending clarification | stub |
| [**Review Templates**](strategy/09-review-templates.md) | Weekly, monthly, quarterly review templates | 8KB |
| [**White Paper Alignment**](strategy/10-whitepaper-alignment.md) | White paper sections mapped to OKRs with timeline | 4KB |
| [**Grant Alignment**](strategy/11-grant-alignment.md) | Grant requirements mapped to OKRs (NSF, UNESCO, NatGeo, Microsoft) | 4KB |
| [**Business Alignment**](strategy/12-business-alignment.md) | Business model canvas, revenue streams, mission alignment | 5KB |
| [**Community Impact**](strategy/13-community-impact.md) | CARE principles, 5 impact dimensions, monthly/quarterly reporting | 6KB |
| [**Master Dashboard**](strategy/14-master-dashboard.md) | Top 5 Objectives, Top 10 KRs, Top 10 Initiatives, Top 10 Risks, Top 10 Decisions | 6KB |
| [**Execution Plan**](strategy/15-execution-plan.md) | THIS WEEK/MONTH/QUARTER/YEAR + NOT NOW list | 6KB |
| [Roadmap](ROADMAP.md) | Top-level prioritized roadmap with current assessment | 5KB |

## Architecture

| Document | Description | Size |
|----------|-------------|------|
| [Architecture Overview](architecture/01-architecture-overview.md) | System architecture, data flow, technology stack | 3KB |
| [Project Brain](architecture/02-project-brain.md) | Central project knowledge base | 8KB |
| [Repo Split Blueprint](architecture/03-repo-split-blueprint.md) | Plan for splitting monorepo into separate repos | 7KB |

## Audits

| Document | Description | Size |
|----------|-------------|------|
| [Burmese Layer Audit](audits/01-burmese-layer-audit.md) | Myanmar translation layer assessment | 12KB |
| [Syllable Audit](audits/02-syllable-audit.md) | Syllable segmentation evaluation | 22KB |
| [Database Reconciliation](audits/03-database-reconciliation.md) | Database consistency check | 6KB |
| [Security Audit](audits/04-security-audit.md) | Security assessment | 3KB |
| [V2 Claims Audit](audits/05-v2-claims-audit.md) | V2 claims verification | 11KB |
| [V2 Final Report](audits/06-v2-final-report.md) | V2 audit final report | 6KB |

## Guides

| Document | Description | Size |
|----------|-------------|------|
| [Getting Started](guides/01-getting-started.md) | Onboarding guide | 4KB |
| [Annotation Guide](guides/02-annotation-guide.md) | Data annotation instructions | 3KB |
| [Resume Backlog](guides/03-resume-backlog.md) | Session resumption guide | 4KB |
| [Root Cleanup Policy](guides/04-root-cleanup-policy.md) | Cleanup procedures | 1KB |

## Planning

| Document | Description | Size |
|----------|-------------|------|
| [GitHub Org Plan](planning/01-github-org-plan.md) | Organization structure plan | 4KB |

## Reports

| Document | Description | Size |
|----------|-------------|------|
| [Ecosystem Audit V2](reports/ECOSYSTEM_AUDIT_V2.md) | Full ecosystem audit report | 40KB |
| [ChatGPT Integration Report](reports/CHATGPT_INTEGRATION_REPORT.md) | ChatGPT integration assessment | 7KB |
| [Database Integrity Report](reports/DATABASE_INTEGRITY_REPORT.md) | Database integrity check | 4KB |
| [Integration Matrix](reports/INTEGRATION_MATRIX.md) | Cross-repo integration map | 2KB |
| [Source of Truth Matrix](reports/SOURCE_OF_TRUTH_MATRIX.md) | Data source tracking | 3KB |

---

## Related Documentation

### In `context/` (Project Context)
- [architecture.md](../context/architecture.md) — Technical architecture details
- [project-overview.md](../context/project-overview.md) — Project scope and goals
- [code-standards.md](../context/code-standards.md) — Coding conventions
- [progress-tracker.md](../context/progress-tracker.md) — Active progress tracking
- [DATA_MANAGEMENT_PLAN.md](../context/DATA_MANAGEMENT_PLAN.md) — Data management
- [DATA_GOVERNANCE.md](../context/DATA_GOVERNANCE.md) — Data governance
- [MASTER_PLAN.md](../context/MASTER_PLAN.md) — Master project plan
- [MASTER_GRAMMAR_REFERENCE.md](../context/MASTER_GRAMMAR_REFERENCE.md) — Zolai grammar reference
- [NLP_TOOLS_GUIDE.md](../context/NLP_TOOLS_GUIDE.md) — NLP tools documentation
- [RESEARCH_SYNTHESIS.md](../context/RESEARCH_SYNTHESIS.md) — Research synthesis
- [UPDATED_RESEARCH_SYNTHESIS.md](../context/UPDATED_RESEARCH_SYNTHESIS.md) — Updated research
- [ZOLAI_KNOWLEDGE_BASE.md](../context/ZOLAI_KNOWLEDGE_BASE.md) — Knowledge base
- [zolai-knowledge-updated.md](../context/zolai-knowledge-updated.md) — Updated knowledge base
- [PROJECT_STATE.md](../context/PROJECT_STATE.md) — Current project state
- [ZOLAI_V2_CURRENT_STATE.md](../context/ZOLAI_V2_CURRENT_STATE.md) — V2 baseline state
- [WORKFLOW.md](../context/WORKFLOW.md) — Complete workflow & system guide

### In `data/` (Data Documentation)
- [CREDITS.md](../data/CREDITS.md) — Data source attribution
- [DATA_INDEX.md](../data/DATA_INDEX.md) — Data directory index
- [SOURCES.md](../data/SOURCES.md) — Data sources and policy

### Root Level
- [AGENTS.md](../AGENTS.md) — AI agent scoping rules
- [README.md](../README.md) — Org profile and overview

---

## Documentation Standards

All documents follow these conventions:

1. **Frontmatter:** YAML frontmatter with title, description, last_updated
2. **Naming:** `XX-descriptive-name.md` (numbered for sort order)
3. **Headers:** `# Title` → `## Major Section` → `### Subsection`
4. **Tables:** Pipe-delimited, aligned for readability
5. **Code blocks:** Fenced with language specified
6. **Links:** Relative paths within docs/
7. **Updates:** Include `last_updated` in frontmatter and changelog at bottom

---

*Last updated: 2026-09-18*
