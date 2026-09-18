---
title: "AmericasNLP 2026 — method paper outline (DRAFT)"
status: UNDER REVIEW
created: 2026-09-18
deadline_note: "Workshop ~3–4 Jul 2026 ACL San Diego; submissions ~15–20 Apr 2026 — confirm on https://americasnlp.org/2026_workshop.html"
---

# AmericasNLP 2026 — Method paper outline (DRAFT)

**Working title (PROPOSED):** *RAG-first literacy tooling for Tedim Zolai with orthography-grounded retrieval*

**Fit note:** AmericasNLP focuses on Indigenous languages of the Americas. Submissions that transfer methods without Americas languages may be acceptable if the CFP allows — **confirm** before writing. Alternate venues: LowResNLP / AfricaNLP / ComputEL if geo mismatch.

## Claim (1 sentence)

For ultra-low-resource Tibeto-Burman literacy, community-validated RAG with ZVS orthography constraints beats raw fine-tune-first pipelines on faithfulness and forbidden-form avoidance.

## Sections

1. **Positionality** — speaker-led project; CARE-aligned data limits  
2. **Data** — Bible parallel + dictionaries; license inventory honesty (RESTRICTED until cleared)  
3. **System** — zolai-core EvidencePack RAG; ZVS forbidden-form gate  
4. **Eval** — gold slices from annotation brief (forbidden forms, sense OK/false, RAG relevance)  
5. **Results** — retrieval precision @k; human preference; orthography violation rate  
6. **Limits** — Bible genre bias; Chin dialect intrusion; no Americas language claim  

## Evidence to gather before drafting

- [ ] Annotation brief gold v0 (≥200 forbidden pairs)  
- [ ] RAG benchmark numbers from `zolai-core`  
- [ ] Permission status for any published verse examples  
- [ ] CFP confirmation that method-transfer papers are welcome  

## Active refs

- Workshop: https://americasnlp.org/2026_workshop.html  
- Peers: [`../research/peer-language-communities.md`](../research/peer-language-communities.md)
