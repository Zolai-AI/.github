---
title: "Reading notes — OPUS parallel corpora (LREC 2012)"
status: ANNOTATED
date: 2026-09-28
last_updated: 2026-09-28
---

# OPUS — Parallel Data, Tools and Interfaces (verified + annotated)

- **Paper:** Jörg Tiedemann, *Parallel Data, Tools and Interfaces in OPUS*, Proceedings of the Eighth International Conference on Language Resources and Evaluation (LREC'12), Istanbul, Turkey, pp. 2214–2218, ELRA — https://aclanthology.org/L12-1246/
- **External PDF:** http://www.lrec-conf.org/proceedings/lrec2012/pdf/463_Paper.pdf · **Service:** https://opus.nlpl.eu/
- **Author:** Jörg Tiedemann (Uppsala University)
- **Verification:** CONFIRMED via ACL Anthology landing page (title, pages, venue, abstract) + OPUS project site 2026-09-28
- **Trust level:** **VERIFIED** — https://aclanthology.org/L12-1246/

## Abstract (condensed)

OPUS is a growing collection of parallel corpora built from free online data: the project converts and aligns those sources, adds linguistic annotation, and republishes them as a single openly downloadable resource. This paper reports the state of the collection at LREC 2012 — new data sets and their features — together with the annotation tools and models served from the website and the interfaces and online services that let researchers pull subsets in the formats they need. The stated purpose is broad: the resource is meant to support applications in computational linguistics, translation studies and cross-linguistic corpus studies, not just MT system building. It has since become the default distribution infrastructure for open parallel data (OPUS corpus pages, e.g. Europarl, instruct users to cite this paper when using any part of a corpus), and the collection continues to host religious-text corpora, including Bible data (`bible-uedin`) alongside web-mined sets such as ParaCrawl, CCAligned and HPLT.

## Takeaways for Zolai (PROPOSED adaptations)

| OPUS idea | Zolai application | Priority |
|-----------|-------------------|----------|
| Align + annotate + republish as one indexed collection | Our `data/zolai.db` is the analogue: sources are transformed into one canonical, queryable store | High |
| Every corpus carries provenance and a required citation | `data/CREDITS.md` is our OPUS-style attribution layer — keep it enforced on every table | High |
| Interfaces/services, not just bulk files | OPUS's API pattern is precedent for our MCP server + zolai-core API as the access path to Zolai data | Medium |
| Open download of the derived resource | Release derived Zolai parallel slices openly where licenses allow (Bible/dictionary) | Medium |
| Cite the infrastructure paper when using the data | When we release Zolai parallel data, publish the citation we want others to use | Low |

**Non-goals:** Not a Bible-translation or low-resource paper, and not an evaluation paper — cite it for **corpus infrastructure, provenance and access**, not for linguistic findings.

## How it applies to our project

- **Bible-as-parallel-corpus:** OPUS is the established precedent that religious texts are distributed as ordinary parallel corpora with provenance — supports our framing of the Tedim Bible as a language corpus, provided CREDITS stays explicit.
- **Data cleaning:** the OPUS model (convert → align → annotate → publish) mirrors our JSONL-pipeline → `*_import` → canonical-table flow; it is the citation for describing that pipeline in grants.
- **RAG-first:** a corpus that exists only as files is hard to retrieve from; OPUS's interfaces argument is why we expose the DB through API/MCP rather than shipping raw dumps.
- **KR1.5 annotated bibliography (20+):** fulfils the "corpus/OPUS" citation slot with a verified primary source.

## Gaps vs Tedim

- A systems/resource paper from 2012; says nothing about low-resource methodology, ZVS 2018, or evaluation — it is infrastructure context only.
- OPUS aggregates corpora contributed by others; it does not resolve licensing or community-consent questions for us (see Building Better and CARE framing).

## Citation ready?

Yes for data-pipeline, provenance and corpus-release sections of whitepaper, grant data-management plans, and CREDITS methodology. Full PDF deep-read optional.
