<p align="center"><img src="https://avatars.githubusercontent.com/u/271958086" alt="Zolai-AI" width="120"></p>

# Zolai-AI

**Building language technology for the Zomi people.**

Zolai AI is an open-source initiative to preserve and teach Tedim Zolai (ZVS 2018)
through community-owned, culturally grounded AI tools.

---

## What We Build

| Category | Tools | Status |
|----------|-------|:------:|
| **Language Data** | Dictionary (84K+ ZO→EN, 64K+ EN→ZO), Bible corpus (31K verses), Grammar (5.5K patterns) | ✅ |
| **NLP Pipeline** | Syllable segmentation (98.49%), POS tagging, morphology, translation | ✅ |
| **Applications** | Web learner platform, Desktop app, MCP server for AI assistants | 🔄 |
| **Education** | Vocabulary learning, progressive curriculum, proficiency testing | 🔄 |
| **Research** | Low-resource NLP, evaluation benchmarks, community validation | 🔄 |

## Data

We credit the **source materials** used to build the Zolai learning system. Source corpora
(Bible translations, TongDot/TongSan dictionaries, web-scraped Zolai corpus) are processed
into our own cleaned, ZVS-2018-aligned relational database (`data/zolai.db`, SQLite WAL,
99 tables / ~2.3GB / ~3.3M rows). See `zolai-datasets/data/CREDITS.md` for attribution.

### Key Resources

| Resource | Entries | Purpose |
|----------|---------|---------|
| `dictionary` (ZO→EN) | 84,490 | Cleaned master Zolai→English |
| `dictionary_en_zo` (EN→ZO) | 64,025 | English→Zolai + Burmese monolingual |
| `bible_verses` | 31,649 | Parallel EN/ZO/MY verses |
| `translations` | 207,623 | EN↔ZO + EN→MY sentence pairs |
| `syllable_data` | 189,563 | Syllable segmentation |
| `training_exercises` | 82,159 | 5 exercise types |

## Live URLs

| Service | URL |
|---------|-----|
| Landing | https://zolai.space/ |
| MCP Server | https://mcp.zolai.space/mcp |
| Documentation | https://github.com/Zolai-AI/.github/tree/main/docs |

## Repos

| Repo | Purpose | Status |
|------|---------|:------:|
| `zolai-core` | Python toolkit + RAG Knowledge Brain | ✅ Active |
| `zolai-web` | Learner platform (Next.js + Hono + Prisma) | ✅ Active |
| `zolai-tauri` | Offline desktop app (Tauri 2) | 🔄 Early |
| `zolai-datasets` | Bilingual corpora & datasets (HF/Kaggle) | ✅ Active |
| `zolai-training` | LoRA/QLoRA fine-tuning + GGUF export | 🔄 Early |
| `zolai-wiki` | Knowledge base (grammar, vocab, curriculum) | ✅ Active |
| `zolai-mcp-server` | MCP server for ChatGPT/Gemini/Claude | ✅ Live |
| `zolai-landing` | Org landing page for zolai.space | ✅ Live |

## Bible as Primary Corpus

The Bible is our **primary training corpus** — the only complete, trusted EN/ZO parallel
corpus for Tedim Zolai (31,649 parallel verses across TDB77, Tedim2010, Hakha, Falam, Paite).
We use it as a *language learning corpus*, not for religious purposes.

## Research & Documentation

| Document | Description |
|----------|-------------|
| [Strategic Audit](https://github.com/Zolai-AI/.github/blob/main/docs/strategy/01-strategic-audit.md) | Full 32-section ecosystem audit |
| [Strategic Roadmap](https://github.com/Zolai-AI/.github/blob/main/docs/strategy/02-strategic-roadmap.md) | Prioritized action plan |
| [Grant Readiness](https://github.com/Zolai-AI/.github/blob/main/docs/strategy/03-grant-readiness.md) | Grant gap analysis |
| [AI Tools & Attribution](https://github.com/Zolai-AI/.github/blob/main/docs/AI_TOOLS_AND_ATTRIBUTION.md) | AI toolchain documentation |

## How We Work

### Open Source
All code is MIT-licensed. All data is credited. Contributions welcome.

### Community-Driven
We center Zomi speakers as stakeholders, not just data sources.

### AI-Assisted Development
We use AI tools (OpenCode, P-Core Orchestra) to accelerate development.
See [AI Tools & Attribution](https://github.com/Zolai-AI/.github/blob/main/docs/AI_TOOLS_AND_ATTRIBUTION.md) for details.

### ZVS 2018 Compliant
All Zolai text follows ZVS 2018 orthography standards.

## Get Involved

| Role | How to Help |
|------|-------------|
| **Zomi Speaker** | Validate translations, test tools, contribute cultural knowledge |
| **Linguist** | Grammar analysis, dialect documentation, morphological study |
| **ML Engineer** | NLP pipelines, evaluation benchmarks, model training |
| **Developer** | Web/desktop/mobile apps, API development, infrastructure |
| **Educator** | Curriculum development, exercise creation, pedagogical grammar |

See [CONTRIBUTING.md](https://github.com/Zolai-AI/.github/blob/main/CONTRIBUTING.md) for details.

## Contact

- **GitHub Issues** — Bug reports, feature requests
- **GitHub Discussions** — Questions, ideas, community chat
- **Email** — peterpausianlian2020@gmail.com

---

**Lungdam!** (Thank you!) 🙏

---

<p align="center">
  <i>Built with ❤️ for the Zomi people</i><br>
  <sub>AI-assisted development by Peter Pau Sian Lian (@peterlianpi) using OpenCode free models
</p>
