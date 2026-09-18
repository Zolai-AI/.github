---
title: "Reading notes — HPLT v2"
status: ANNOTATED
date: 2026-09-18
---

# HPLT v2 (verified + annotated)

- **Paper:** Burchell et al., *An Expanded Massive Multilingual Dataset for High-Performance Language Technologies (HPLT)*, arXiv:2503.10267v3 — https://arxiv.org/abs/2503.10267
- **ACL:** https://aclanthology.org/2025.acl-long.854/ (ACL 2025 Main — per arXiv comment)
- **Data:** https://hplt-project.org/datasets/v2.0
- **Verification:** CONFIRMED via arXiv Atom API 2026-09-18

## Abstract (condensed)

HPLT v2 expands prior HPLT work: **monolingual ~8T tokens / 193 languages**; **parallel ~380M sentence pairs / 51 languages**. Documents full pipeline + reproducible code; analyzes quality/characteristics; evaluates LMs and MT systems trained on the release.

## Takeaways for Zolai (PROPOSED adaptations)

| HPLT idea | Zolai application | Priority |
|-----------|-------------------|----------|
| Document entire data pipeline end-to-end | Mirror in `zolai-datasets` CREDITS + pipeline scripts | High |
| Separate monolingual vs parallel releases | Keep Bible parallel distinct from scraped monolingual | High |
| Quality analysis before claiming usefulness | Publish dedup/LID/forbidden-form metrics | High |
| Train small MT/LM for **evaluation**, not product-first | Optional smoke models; product stays RAG-first | Medium |
| Permissive release discussion | Contrast with our RESTRICTED Bible/dict rows | High (governance) |

**Non-goals:** Do not claim Tedim is in HPLT coverage without checking language inventory. Do not treat HPLT scale as a requirement for literacy tools.

## Gaps vs Tedim

- HPLT languages are still mostly higher-web-presence; Chin/Tedim may be absent or tiny.
- Parallel slice (51 langs) unlikely to replace our Bible-aligned EN↔ZO resource.
- License story for community corpora differs from large crawl aggregations — see Te Hiku / CARE in peer doc.

## Citation ready?

Yes for corpus-construction / release-practice related work.
