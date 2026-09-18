<p align="center"><img src="https://avatars.githubusercontent.com/u/324700055?s=400&u=d543083e81eb710dd047f69a6515d5314879ac9b&v=4" alt="Zolai-AI" width="120"></p>

# Zolai-AI

**Tedim Zolai language technology & AI research**

Zolai AI builds trustworthy language data, knowledge infrastructure, NLP tools, literacy
resources, and community-oriented applications for Tedim Zolai (ZVS 2018) — with specialized
model training as a later stage when the foundation is reliable.

---

## Mission

Create practical, evidence-based language technology and knowledge infrastructure that help
Tedim Zolai speakers and learners access information, learn language, and participate digitally.

## Vision

A durable Zomi language-technology ecosystem: community-informed tools, open research,
measurable literacy impact, and sustainable operations.

---

## What We Build

Status labels: **Implemented** · **Experimental** · **Planned** · **Live**

| Category | Focus | Status |
|----------|-------|:------:|
| **Language data** | Dictionary, Bible parallel corpus (where permitted), grammar, syllables | Implemented (ongoing quality) |
| **NLP** | Syllable segmentation strong; POS, morphology, MT, etc. | Mixed — see notes |
| **Applications** | Web learner, desktop (early), MCP for AI assistants | Live / Early |
| **Education** | Vocab, curriculum, exercises | Experimental → Planned |
| **Research** | Low-resource NLP, evaluation, community validation | Planned / in progress |

**NLP honesty note:** Syllable tooling has the strongest evidence. Broader NLP modules exist in
code but many claims remain only partially verified — see
[claims audit](https://github.com/Zolai-AI/.github/blob/main/docs/audits/05-v2-claims-audit.md).

## Data

We credit **source materials** used to build the Zolai learning system. Source corpora
(Bible translations, TongDot/TongSan dictionaries, and other corpora) are processed into a
cleaned, ZVS-2018-aligned database (`data/zolai.db`, SQLite WAL, ~99 tables / ~2.3GB / ~3.3M rows).
See `zolai-datasets` CREDITS for attribution. Public accessibility ≠ unrestricted reuse.

### Key resources

| Resource | Entries | Purpose |
|----------|---------|---------|
| `dictionary` (ZO→EN) | 84,490 | Cleaned master Zolai→English |
| `dictionary_en_zo` (EN→ZO) | 64,025 | English→Zolai (+ related fields) |
| `bible_verses` | 31,649 | Parallel EN/ZO/MY verses |
| `translations` | 207,623 | Sentence pairs |
| `syllable_data` | 189,563 | Syllable segmentation |
| `training_exercises` | 82,159 | Exercise types |

## Live URLs

| Service | URL |
|---------|-----|
| Landing | https://zolai.space/ |
| MCP Server | https://mcp.zolai.space/mcp |
| Documentation | https://github.com/Zolai-AI/.github/tree/main/docs |

## Repos

| Repo | Purpose | Status |
|------|---------|:------:|
| `zolai-core` | Python toolkit + RAG Knowledge Brain | Active |
| `zolai-web` | Learner platform (Next.js + Hono + Prisma) | Active |
| `zolai-tauri` | Offline desktop app (Tauri 2) | Early |
| `zolai-datasets` | Bilingual corpora & datasets | Active |
| `zolai-training` | LoRA/QLoRA + GGUF (later-stage focus) | Early |
| `zolai-wiki` | Knowledge base (grammar, vocab, curriculum) | Active |
| `zolai-mcp-server` | MCP for ChatGPT / Gemini / Claude | Live |
| `zolai-landing` | Org landing (zolai.space) | Live |

## Bible corpus

Parallel Bible text is a major EN/ZO resource used as a *language learning / research corpus*,
not for religious advocacy. License and permission status must be documented before redistribution
or commercial reuse.

## People

| Role | Name | Notes |
|------|------|-------|
| Founder & Technical Lead | Peter Lianpi (`@peterlianpi`) | Architecture, engineering, execution |
| Strategic Advisor & Business/Impact Mentor | Shwe Yee | Advisory only — no ownership; public listing subject to ongoing consent |

## Research & documentation

| Document | Description |
|----------|-------------|
| [Project context](https://github.com/Zolai-AI/.github/blob/main/docs/context/project-context.md) | Canonical context for agents & contributors |
| [Mission & vision](https://github.com/Zolai-AI/.github/blob/main/docs/strategy/mission-vision.md) | Identity and pillars |
| [Source of truth](https://github.com/Zolai-AI/.github/blob/main/docs/governance/source-of-truth.md) | Canonical doc owners |
| [OKRs](https://github.com/Zolai-AI/.github/blob/main/docs/strategy/okr.md) | Annual + 90-day objectives |
| [Strategic audit](https://github.com/Zolai-AI/.github/blob/main/docs/strategy/01-strategic-audit.md) | Full ecosystem audit |
| [Docs index](https://github.com/Zolai-AI/.github/blob/main/docs/README.md) | Master documentation index |

## How we work

- **Open source** — code MIT-licensed; data credited; contributions welcome
- **Evidence first** — data, evaluation, and community impact before model hype
- **Community-aware** — Zomi speakers as stakeholders, not only data sources
- **ZVS 2018** — orthography ground truth; SOV; ergative `in`
- **AI-assisted development** — human-directed; see [AI Tools & Attribution](https://github.com/Zolai-AI/.github/blob/main/docs/AI_TOOLS_AND_ATTRIBUTION.md)

## Get involved

| Role | How to help |
|------|-------------|
| **Zomi speaker** | Validate translations, test tools, contribute cultural knowledge |
| **Linguist** | Grammar, dialect documentation, morphology |
| **ML engineer** | NLP pipelines, evaluation, careful training experiments |
| **Developer** | Web / desktop / API / infrastructure |
| **Educator** | Curriculum, exercises, pedagogical grammar |

See [CONTRIBUTING.md](https://github.com/Zolai-AI/.github/blob/main/CONTRIBUTING.md).

## Contact

- **GitHub Issues** — bugs, features
- **GitHub Discussions** — questions, ideas
- **Email** — peterpausianlian2020@gmail.com

---

**Lungdam!** (Thank you!)

<p align="center">
  <i>Built for the Zomi people</i><br>
  <sub>Led by Peter Pau Sian Lian (@peterlianpi) · AI-assisted with OpenCode free models</sub>
</p>
