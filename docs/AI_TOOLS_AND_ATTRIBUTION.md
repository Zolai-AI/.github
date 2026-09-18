---
title: "AI Tools & Attribution"
description: "Documents AI tools, models, and methods used in building Zolai AI"
created: 2026-09-18
last_updated: 2026-09-18
status: current
category: governance
---

# AI Tools & Attribution

> Transparency about AI tools used in building the Zolai AI ecosystem.

---

## Purpose

This document records which AI tools were used, how they were used, and who directed
the work. Transparency about AI assistance is important for:

- **Academic integrity** — Required for papers and publications
- **Community trust** — Being honest about how work was produced
- **Reproducibility** — Others should know what tools were used
- **Historical record** — Future contributors should understand the codebase origins

---

## Authorship Convention

All work in Zolai AI is **human-directed and AI-assisted**:

```
Primary Author: Peter Pau Sian Lian (@peterlianpi)
AI Assistance: Cursor + OpenCode + P-Core Orchestra
Reviewed by: Peter Pau Sian Lian (human review and approval)
```

**The human (Peter Pau Sian Lian) is the author, maintainer, and decision-maker.**
AI tools assist with implementation, research, and documentation under human direction.

---

## AI Toolchain

### Primary Tools

| Tool | Role | Usage |
|------|------|-------|
| **Cursor** | IDE agent (Agent / Task / Auto) | Coding, docs, QC; Cursor Models pool (Composer, Grok, Auto fallback) |
| **OpenCode** | CLI / desktop AI coding assistant | Code generation, debugging, refactoring, documentation |
| **P-Core Orchestra** | Multi-agent orchestration | Plan → Implement → Verify → Review (works in both Cursor and OpenCode) |
| **OpenCode free models** | LLM inference (OpenCode path) | Prefer free-tier models only for OpenCode sessions |

Name **both Cursor and OpenCode** when attributing work: they are parallel environments, not duplicates of one product.

### Models

**OpenCode:** free models only (e.g. `mimo-v2.5-free` and configured free fallbacks). See org `AGENTS.md`.

**Cursor:** included Cursor Models pool per [`docs/context/model-routing.md`](context/model-routing.md) — preferred model → **Auto** on limits → task-fit alternate. Avoid burning “Other Models” (Claude/GPT) as a daily default.

| Path | Provider | Notes |
|------|----------|-------|
| OpenCode free tier | OpenCode / Zen catalog | Primary for OpenCode sessions |
| Cursor Models (Composer, Grok, Auto) | Cursor | Primary for Cursor Agent sessions |

**Note:** Exact model IDs change often — record the path (Cursor vs OpenCode) in session notes when it matters for reproducibility.

### Orchestration System

The P-Core Orchestra is a multi-agent system that coordinates AI work:

| Agent | Role | Phase |
|-------|------|-------|
| `orchestra-planner` | Research and plan implementation | Phase 1 |
| `orchestra-implementer` | Write code and create files | Phase 2 |
| `orchestra-verifier` | Run tests, lint, verify | Phase 3 |
| `orchestra-reviewer` | Final review and quality check | Phase 4 |

### Other AI Services

| Service | Usage | Notes |
|---------|-------|-------|
| **Gemini** | Translation ensemble | Used in batch Myanmar translation (when API available) |
| **HuggingFace** | Model/dataset hosting | Published datasets and adapters |

---

## How AI Was Used

### Code Generation
- NLP pipeline modules (syllable, morphology, phonology, corpus analysis)
- API endpoints and data schemas
- Test suites (466+ tests)
- Database migrations and repository patterns

### Documentation
- Strategic audit (32 sections)
- Technical documentation
- API contracts
- README files

### Research
- Literature review (low-resource NLP, comparable projects)
- Grant opportunity research
- SWOT analysis
- Competitive analysis

### Data Processing
- Dictionary cleaning and normalization
- Bible verse alignment
- Syllable data generation
- Training exercise generation

---

## What AI Did NOT Do

- **Human made all strategic decisions** — Mission, vision, priorities, direction
- **Human reviewed all output** — Every AI-generated file was reviewed and approved
- **Human validated language data** — ZVS 2018 compliance checked by human
- **Human directed research** — AI assisted, human decided what to research
- **Human approved commits** — All git commits are human-approved

---

## For Papers and Publications

When citing work from Zolai AI in academic papers, use this acknowledgment:

### Acknowledgment Template

> The authors acknowledge the use of AI coding assistants (OpenCode with free
> tier models) for code generation, documentation, and research assistance.
> All AI-assisted work was reviewed and approved by the human authors. The
> P-Core Orchestra multi-agent system was used for coordinated development
> workflows.

### Citation

If citing the Zolai AI project:

```
Zolai-AI. (2026). Zolai AI: Language technology for Tedim Zolai.
https://github.com/Zolai-AI
```

---

## Policy

### For Contributors

- Contributors may use AI tools for their contributions
- AI usage should be disclosed in PR descriptions
- Human review is required for all AI-assisted contributions
- AI-generated code must pass the same tests as human-written code

### For Publications

- AI assistance must be acknowledged in papers
- AI cannot be listed as an author (per most journal/conference policies)
- Human authors are responsible for all content, including AI-assisted content
- Methods sections should describe AI usage where relevant

### For Data

- AI-generated data must be clearly labeled
- Human validation is required for language data
- Provenance tracking includes AI assistance metadata

---

*This document is a living standard. Update as tools and practices evolve.*

*Last updated: 2026-09-18*
