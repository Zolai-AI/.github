# `.github` — Zolai-AI org profile & community

GitHub special-cases a repo named **`.github`**: its `profile/README.md`
renders on the [Zolai AI](https://github.com/Zolai-AI) org Overview page.

## Contents

| Path | Purpose |
|------|---------|
| `profile/README.md` | Org profile (shown on org Overview) |
| `logo.png` / `og.png` | Brand assets (original website logo) |
| `CONTRIBUTING.md` | How to contribute |
| `SECURITY.md` | Security policy |
| `.github/workflows/lint.yml` | Org-level ruff lint |
| `docs/` | Ecosystem documentation |

## Part of the Zolai-AI org

This repo is the **profile repository** for the **[Zolai-AI](https://github.com/Zolai-AI)** organization.
It is not a code repo — no API, no tests, no package.

Other repos in the org:

`zolai-core` · `zolai-web` · `zolai-tauri` · `zolai-datasets` · `zolai-training` · `zolai-wiki` · `zolai-ai.github.io` · `zolai-mcp-server` · `zolai-landing`

## Data Sources & Attribution

We use the following data sources to build the Zolai language learning system.
**Full credits:** See [`data/CREDITS.md`](https://github.com/Zolai-AI/zolai-datasets/blob/main/data/CREDITS.md)

### Bible (Primary Training Corpus)

The Bible is our **only complete, trusted, EN/ZO parallel corpus** for Tedim Zolai:
- **31,102 parallel verses** (EN↔ZO)
- **Multiple versions** — TDB77, Tedim2010, Hakha, Falam, Paite
- **Source:** [dalsuum/bible-master](https://github.com/dalsuum/bible-master)

**Note:** We use the Bible as a *language learning corpus*, not for religious purposes.

### Dictionary Sources

| Source | Entries | Type |
|--------|---------|------|
| [ZomiLanguage/dictionary](https://github.com/ZomiLanguage/dictionary) | 93,931 | Zolai→English |
| [dalsuum/zolai-dictionary](https://github.com/dalsuum/zolai-dictionary) | 7,861 | Trilingual (ZO-EN-MY) |
| [paumkim/zomi-dataset](https://github.com/paumkim/zomi-dataset) | 130K+ | Multiple sources |
| TongDot dictionary | 5,004 | Zolai-English |
| Glosbe API | 21+ | Tedim-English examples |

### Corpus & Reference Materials

| Source | Size | Content |
|--------|------|---------|
| [paumkim/zomi-dataset](https://github.com/paumkim/zomi-dataset) | 208MB | Clean corpus (3M+ sentences) |
| Zolai Grammar Vol 1 (Taang Zomi, 2010) | 17K lines | Authoritative grammar |
| Zolai Sinna (ZAUS, 2010) | 6K lines | 34-lesson textbook |
| ZVS 2018 Standard Format | 2K lines | Orthography rules |

### Community Contributors

- **paumkim** — Comprehensive Zolai dataset + crawling scripts
- **dalsuum** — Bible JSON corpus + trilingual dictionary
- **Min Si Thu** — Tedim-English-Burmese Handbook + MyanmarGPT
- **Taang Zomi** — Authoritative Zolai Grammar Vol 1
- **ZAUS** — Zolai Sinna textbook
- **Zomi Virtual State** — ZVS 2018 orthography standard

## Why We Use the Bible

The Bible provides the most comprehensive, well-structured text in Tedim Zolai,
covering all grammar patterns, vocabulary, and registers of the language.
It is the only source with complete EN/ZO parallel translations across multiple Chin languages.

## Project Brain

Portable full-context overview for brainstorming: `docs/ZOLAI_AI_PROJECT_BRAIN.md`.
