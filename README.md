---
title: "Zolai-AI Organization"
description: "Open-source language technology for Tedim Zolai (ZVS 2018)"
created: 2026-09-04
last_updated: 2026-09-18
maintainer: "Peter Pau Sian Lian (@peterlianpi)"
license: MIT
---

# Zolai-AI

**Tedim Zolai language technology & AI research**

Zolai AI builds trustworthy language data, knowledge infrastructure, NLP tools, literacy
resources, and community-oriented applications for Tedim Zolai (ZVS 2018). Specialized model
training is later-stage when the foundation is reliable.

## Mission

Create practical, evidence-based language technology and knowledge infrastructure
that help Tedim Zolai (ZVS 2018) speakers and learners access information, learn
language, and participate digitally — grounded in verified data and responsible use.

## Vision

A durable Zomi language-technology ecosystem: community-informed tools, open research,
measurable literacy impact, and sustainable operations.

> Data, evaluation, research, and community impact first; specialized model training
> follows when the foundation is reliable.

## Repositories

| Repo | Purpose | Status | Stars |
|------|---------|:------:|:-----:|
| [`zolai-core`](https://github.com/Zolai-AI/zolai-core) | Python toolkit + RAG Knowledge Brain | ✅ Active | — |
| [`zolai-web`](https://github.com/Zolai-AI/zolai-web) | Learner platform (Next.js + Hono + Prisma) | ✅ Active | — |
| [`zolai-tauri`](https://github.com/Zolai-AI/zolai-tauri) | Offline desktop app (Tauri 2) | 🔄 Early | — |
| [`zolai-datasets`](https://github.com/Zolai-AI/zolai-datasets) | Bilingual corpora & datasets (HF/Kaggle) | ✅ Active | — |
| [`zolai-training`](https://github.com/Zolai-AI/zolai-training) | LoRA/QLoRA fine-tuning + GGUF export | 🔄 Early | — |
| [`zolai-wiki`](https://github.com/Zolai-AI/zolai-wiki) | Knowledge base (grammar, vocab, curriculum) | ✅ Active | — |
| [`zolai-mcp-server`](https://github.com/Zolai-AI/zolai-mcp-server) | MCP server for ChatGPT/Gemini/Claude | ✅ Live | — |
| [`zolai-landing`](https://github.com/Zolai-AI/zolai-landing) | Org landing page for zolai.space | ✅ Live | — |
| [`zolai-ai.github.io`](https://github.com/Zolai-AI/zolai-ai.github.io) | GitHub Pages org landing | ✅ Live | — |
| [`.github`](https://github.com/Zolai-AI/.github) | Org profile + community + workflows | ✅ Complete | — |

## Live URLs

| Service | URL | Status |
|---------|-----|:------:|
| Landing page | https://zolai.space/ | ✅ LIVE |
| MCP server | https://mcp.zolai.space/mcp | ✅ LIVE |

## Ecosystem Architecture

```
zolai-wiki (knowledge) → zolai-core (RAG retrieval + n-gram prediction)
                              ↓
                    zolai-web (online) + zolai-tauri (offline)

/data (4GB shared) → zolai-datasets (build/publish) → zolai-training (LoRA/QLoRA)

zolai-mcp-server → Cloudflare Workers → ChatGPT, Gemini, Claude (MCP protocol)
zolai-landing → Cloudflare Pages → zolai.space (org landing page)
```

## Data

All data lives in `data/zolai.db` (SQLite WAL, ~2.3GB, 99 tables, ~3.3M rows).

| Table | Rows | Purpose |
|-------|------|---------|
| `dictionary` (ZO→EN) | 84,490 | Zolai→English (master, cleaned) |
| `dictionary_en_zo` (EN→ZO) | 64,025 | English→Zolai + Burmese |
| `bible_verses` | 31,649 | Parallel EN/ZO/MY verses |
| `translations` | 207,623 | EN↔ZO + EN→MY sentence pairs |
| `syllable_data` | 189,563 | Syllable segmentation |
| `vocabulary` | 104,906 | Vocabulary index with frequency |
| `training_exercises` | 82,159 | 5 exercise types |
| `word_alignments` | 385,120 | Word-level ZO↔EN alignment |

See [`zolai-datasets/data/CREDITS.md`](https://github.com/Zolai-AI/zolai-datasets/blob/main/data/CREDITS.md) for full attribution.

## Documentation

| Document | Location | Description |
|----------|----------|-------------|
| Project context | [`docs/context/project-context.md`](docs/context/project-context.md) | Canonical context for agents & contributors |
| Mission & Vision | [`docs/strategy/mission-vision.md`](docs/strategy/mission-vision.md) | Identity and strategic pillars |
| Source of Truth | [`docs/governance/source-of-truth.md`](docs/governance/source-of-truth.md) | Canonical doc owners by domain |
| Architecture status | [`docs/architecture/status.md`](docs/architecture/status.md) | Implemented / Experimental / Planned |
| Research | [`docs/research/`](docs/research/) | Agenda, gaps, literature (verify citations) |
| Grants | [`docs/grants/`](docs/grants/) | Strategy + opportunity tracker (`researching`) |
| Strategic Audit | [`docs/strategy/01-strategic-audit.md`](docs/strategy/01-strategic-audit.md) | Full ecosystem audit |
| OKRs | [`docs/strategy/okr.md`](docs/strategy/okr.md) | Annual + 90-day OKR entry |
| Advisors | [`docs/strategy/advisors-and-mentors.md`](docs/strategy/advisors-and-mentors.md) | Advisor roles (non-ownership) |
| Documentation Index | [`docs/README.md`](docs/README.md) | Master documentation index |
| AI Tools & Attribution | [`docs/AI_TOOLS_AND_ATTRIBUTION.md`](docs/AI_TOOLS_AND_ATTRIBUTION.md) | AI toolchain documentation |

## AI-Assisted Development

This project uses AI tools to accelerate development. All work is human-directed
and AI-assisted. See [AI Tools & Attribution](docs/AI_TOOLS_AND_ATTRIBUTION.md) for details.

| Tool | Role | Model |
|------|------|-------|
| Cursor | IDE Agent / Task / Auto | Cursor Models pool (Composer, Grok, Auto) |
| OpenCode | CLI / desktop coding assistant | Free models only |
| P-Core Orchestra | Multi-agent orchestration | Runs on Cursor or OpenCode |

**Author:** Peter Pau Sian Lian ([@peterlianpi](https://github.com/peterlianpi))

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

We especially need:
- **Zomi speakers** — Validate translations and cultural knowledge
- **Linguists** — Grammar analysis and documentation
- **ML Engineers** — NLP pipelines and evaluation
- **Developers** — Web, desktop, and mobile applications

## License

MIT License — See [LICENSE](LICENSE) for details.

---

**Lungdam!** (Thank you!) 🙏

*Built with ❤️ for the Zomi people*
