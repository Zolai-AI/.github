---
title: "Peer language communities — how others face low-resource NLP"
status: UNDER REVIEW
created: 2026-09-18
last_updated: 2026-09-18
evidence: CONFIRMED links + PARTIAL practice mapping
---

# Peer Language Communities (active references)

How communities **like ours** (low-resource, community-rooted, literacy/revitalization-adjacent) try, face blockers, and handle data, evaluation, and governance — mapped to Zolai AI.

**Evidence rule:** Official org pages and primary docs first. Practice lessons below are **PROPOSED adaptations**, not claims that Zolai already matches them.

## Snapshot comparison

| Community / program | What they try | What they face | How they handle it | Active refs | Relevance to Zolai |
|---------------------|---------------|----------------|--------------------|-------------|--------------------|
| **Masakhane** | Grassroots African NLP; open datasets; community annotation; MT & speech | Extractive “parachute” research; uneven compute; LID/quality for many languages | Community guidelines for dataset creation; hubs (e.g. LINGUA Africa partner); open science + local leadership | https://www.masakhane.io/ · [dataset guidelines](https://github.com/masakhane-io/masakhane-community/blob/master/dataset-creation-guidelines.md) · BoF PDF https://seyyaw.github.io/files/AfricaNLP_BoF.pdf | **KR1.4** join + community validation playbook; do **not** cite a single “Open Data Collection Playbook” title until found as one formal pub (**PARTIAL**) |
| **AmericasNLP** | Workshop + shared tasks for Indigenous languages of the Americas; ethics + revitalization tracks | Geographic focus (Americas); need rigorous eval with tiny data; sovereignty expectations | ACL co-located workshop; shared-task methodology; papers cite CARE / community control | https://americasnlp.org/ · 2026: https://americasnlp.org/2026_workshop.html (ACL 2026, San Diego; submissions ~Apr 2026) | Adapt **evaluation / shared-task discipline** (KR3.*); workshop paper target if methods transfer (not Americas language required if contribution clear — confirm CFP) |
| **Te Hiku Media / Papa Reo** | Māori speech/NLP owned by community; capability inside the iwi | Open-data norms clash with mana / digital colonization risk | **Kaitiakitanga License** — guardianship not ownership; benefits return to source; restrictions on mining corpora for NLP without permission | https://papareo.nz/ · [Kaitiakitanga License](https://github.com/TeHikuMedia/Kaitiakitanga-License) · https://kaituhi.nz/kaitiakitanga | Model for **data sovereignty** language in `DATA_GOVERNANCE`; Zolai must not assume “public scrape = free reuse” |
| **CARE Principles (GIDA)** | People/purpose overlay on FAIR for Indigenous data | FAIR-only policies ignore Authority to Control | Collective Benefit, Authority to Control, Responsibility, Ethics | https://www.gida-global.org/careprinciples · Carroll et al. 2020 *Data Science Journal* | Frame consent + redistribution policy; cite in grants/positionality |
| **Microsoft LINGUA** | Fund open speech/text datasets for underrepresented languages | **Geography-locked** open calls | **LINGUA Europe** (European languages); **LINGUA Africa** (African languages; Masakhane hub + Gates + Google.org) | Europe: https://www.microsoft.com/en-us/research/academic-program/lingua-expanding-europes-voices-in-ai/ · Africa: https://www.microsoft.com/en-us/research/academic-program/lingua-africa-open-call-for-inclusive-ai-language-projects/ · umbrella: https://www.microsoft.com/en-us/research/project/ai-for-low-resource-languages/ | **Chin / Tedim Zolai not in-scope** for current LINGUA Europe/Africa geography — treat as **method reference**, not near-term applicant track |
| **NSF/NEH DLI-DEL** | Document + infrastructure for endangered languages | U.S. institutional applicant rules | Solicitation NSF 22-615; archive + DMP requirements | https://www.nsf.gov/funding/opportunities/dli-del-nsf-dynamic-language-infrastructure-neh-documenting/nsf22-615/solicitation | Eligible only **with U.S. partner** — see grants tracker |
| **NatGeo Enduring Voices** | Historical hotspot documentation (Living Tongues partnership) | **Not a current open RFP** | Archival project pages / travel article | https://www.nationalgeographic.com/travel/article/about-enduring-voices | **Do not** list as active grant in strategy docs |
| **NatGeo Society grants** | Time-bound RFPs (science, culture, storytelling…) | RFP-specific geography & themes; no general open call | Portal: https://www.nationalgeographic.org/society/grants-and-investments/ | Official grants hub (live RFPs change) | Monitor RFPs; “Preserving Traditional Arts” (secondary reports: spoken arts, destination-prioritized) is **weak fit** for Chin/Myanmar NLP unless destination + artisan scope align — verify on portal before applying |

## Patterns Zolai should steal (and what we already do)

| Pattern from peers | Peer source | Zolai status | Recommended next action |
|--------------------|-------------|--------------|-------------------------|
| Community annotation guidelines before scale | Masakhane guidelines | OPEN gap | Draft ZO/EN annotation brief + quality rubric (KR5.*) |
| Shared-task style eval (tiny gold, human prefs) | AmericasNLP | OPEN | Define Tedim gold slices in `benchmarks.md` (KR3.2) |
| Guardianship / restricted commercial reuse | Te Hiku Kaitiakitanga | MITIGATING (governance UNDER REVIEW) | Finish license inventory rows; Bible editions **restricted until clear** |
| CARE over FAIR-only | GIDA CARE | Partial (positionality exists) | Explicit CARE mapping in data-governance |
| RAG / retrieval + community knowledge before raw FT | Aligns with our RAG-first strategy | CONFIRMED strategy | Keep FineWeb2/HPLT as **cleaning pipeline** refs, not FT-first justification |
| Orthography ground truth | Community standards (local) | CONFIRMED ZVS 2018 | Treat ZVS as non-negotiable in eval |

## Challenges peers repeatedly report (apply to us)

1. **License fog** — scraped dictionaries/Bibles lack clear redistribution rights (our KR2.3).
2. **LID / dialect mix** — Hakha/Falam/Paite intrusion into Tedim (our cleaning work).
3. **Eval vanity metrics** — BLEU on Bible alone ≠ literacy product quality.
4. **Extractive research** — outsiders publish; community gets little tooling benefit → prefer open tools + local capability (Te Hiku / Masakhane).
5. **Geographic grant mismatch** — LINGUA Europe/Africa and many NatGeo RFPs exclude Myanmar Chin by design.

## Recommended actions (ordered)

1. Publish this page in research README index (**done this pass**).
2. Complete CREDITS → license inventory rows ([`../governance/credits-license-inventory.md`](../governance/credits-license-inventory.md)).
3. Join Masakhane with intro post (KR1.4) — track membership evidence.
4. Watch AmericasNLP 2026 CFP for method paper (RAG + ZVS orthography compliance).
5. Do **not** apply LINGUA as Chin-language project under current geography.
6. Re-check NatGeo portal quarterly; do not cite Enduring Voices as funding.

## Related audited docs

- Gaps: [`gaps.md`](gaps.md)
- Literature: [`literature-review.md`](literature-review.md)
- Grants: [`../grants/opportunities.md`](../grants/opportunities.md)
- FineWeb2 / HPLT notes: [`papers/fineweb2.md`](papers/fineweb2.md), [`papers/hplt-v2.md`](papers/hplt-v2.md)
