---
title: "L1.1 — POS Implementation Audit"
description: "Audit of existing POS tagging, DB POS columns, and grammar patterns before designing the Zomi POS tagset"
created: 2026-09-29
last_updated: 2026-09-29
status: CONFIRMED
---

# L1.1 — POS Implementation Audit

> **Wave L1.1** of the 60-day Linguistic Core plan. Evidence-based audit
> (documentation ↔ schema ↔ code ↔ actual data) per Master Prompt §3.
> No schema/code changes made — audit only.

## 1. Current Architecture (POS-related components)

| Component | Purpose | Status |
|-----------|---------|--------|
| `zolai/pos_tagger/__init__.py` | Rule-based tagger (dictionary + closed-class lists) | EXISTS — 13 base tags + subtags |
| `zolai/foundation/analysis.py` | `FoundationAnalyzer` — uses tagger for word/sentence analysis | EXISTS — SOV/ergative/negation/ZVS checks |
| `zolai/foundation/morphology.py` | Agglutinative decomposer feeding POS hints | EXISTS (Wave L2 target) |
| `grammar_patterns` table | 5,560 syntactic pattern rows, 52 functions | EXISTS — no POS column; syntactic only |
| `dictionary` / `vocabulary` POS columns | Per-entry POS field | EXISTS — 2.6% / 2.1% populated |
| `zolai_vocabulary.pos` | Master vocab POS field | EXISTS — 22.1% populated, 132 variants (unusable) |
| POS gold evaluation set | Human-annotated sentences | **MISSING** |
| POS annotation format/guide | JSONL spec for annotators | **MISSING** |
| Statistical/ML tagger (CRF) | Baseline trainable tagger | **MISSING** (sklearn-crfsuite installed) |

### Existing tagset (from `pos_tagger/__init__.py` docstring)

13 base: `NOUN, VERB, ADJ, ADV, PRON, DET, POST, CONJ, PART, NUM, INTJ, PUNCT, X`

Subtags:
- NOUN: `N.PROPER, N.COMMON, N.COMPOUND`
- VERB: `V.INTRANS, V.TRANS, V.DITRANS, V.AUX, V.COP`
- ADJ: `ADJ.QUAL, ADJ.QUANT`
- PART: `PART.NEG, PART.QUESTION, PART.FOCUS, PART.TOPIC, PART.ERG`
- POST: `POST.LOC, POST.DAT, POST.GEN, POST.INS`

Closed classes hard-coded in module: 13 pronouns, 24 particles (incl. `kei/lo` NEG, `hiam/diam` QUESTION, `in` ERG), postpositions.

**Assessment:** Typologically sensible for Sino-Tibetan; `PART.ERG` for `in` and
`POST.*` are Zomi-appropriate. Not UD-aligned (no UPOS/XPOS mapping defined).

## 2. Current Data Inventory (POS columns in DB)

Canonical DB = `data/zolai.db` (2.3GB, 101 tables).

| Table | Rows | With POS | % | Distinct POS values | Quality |
|-------|------|----------|---|---------------------|---------|
| `dictionary` (ZO→EN) | 84,490 | 2,207 | 2.6% | 22 | Mixed free text: `noun`, `transitive verb`, `V, adjective`, `vs`, `poss` |
| `vocabulary` | 104,906 | 2,199 | 2.1% | 22 | Same 22 values as dictionary |
| `zolai_vocabulary` | 112,279 | 24,833 | 22.1% | **132** | Highly inconsistent: `n`, `Noun`, `NOUN`, `n & a`, `adv & prep`, `pt par`… |
| `grammar_patterns` | 5,560 | — | — | 52 `function` values | Syntactic functions, no POS column |

### Distinct POS values — `dictionary` (22)

```
Negative imperative verbal suffix · V, adjective · adjective · adverb ·
conjunction · exclamation · interjection · intj · intransitive verb ·
nominal prefix or verbal prefix · noun · particle · phrasal verb · poss ·
prefix · preposition · pronoun · suffix · transitive verb · unknown ·
verb · vs
```

### `zolai_vocabulary` POS (132 variants — sample)

```
n, v, a, adv, adj, prep, pro, pron, pro. n, prefix, pref,
n & a, v & n, a & n, adv & prep, adv & conj, pt par,
pas. part., a past. par, Noun, por, ...
```

**Assessment:** ~97% of dictionary/vocabulary rows have **no POS at all**.
Existing values are free-text, multi-valued, and non-canonical. Cannot be
used as-is for training or evaluation without normalization.

## 3. Grammar Patterns Analysis

- 5,560 rows, columns: `pattern_id, pattern, description, function, examples, frequency, myanmar, ...`
- 52 distinct `function` labels — syntactic/semantic, e.g.:
  - `ergative SOV declarative`, `yes/no question`, `general negation`
  - `subject agreement (I)`, `past perfective`, `future/intentional`
  - `ability negation: cannot`, `content question (why/how)`
  - `sentence_pattern`, `corpus_discovered` (generic buckets)
- 1 row has empty `function`
- **No POS tags** — but `pattern` strings are candidate material for Wave L3 sentence-pattern mining and Wave L4 rule layer.

## 4. Code Evidence

- `FoundationAnalyzer.analyze_word/sentence` calls `pos_tagger.tag_with_confidence()`,
  then checks: SOV validity, ergative (`PART.ERG`) presence, negation type,
  question type, tense, ZVS compliance.
- Tests (`test_foundation_analysis.py`) assert `PART.NEG`, `PART.QUESTION`, `N.PROPER`.
- **No POS accuracy evaluation exists** — no gold sentences, no precision/recall.

## 5. Gaps vs Master Prompt §10

| Requirement | Current state | Gap |
|-------------|---------------|-----|
| Zomi POS tagset (compare UD + Chin research + corpus) | 13-tag rule-based set, not UD-mapped, no source citations | **Full tagset design (L1.2)** |
| Tag definition table (tag, name, description, examples, usage, ambiguity, source) | Docstring only | Write `POS_SPEC.md` |
| Canonical lexicon fields (POS, morph_features, provenance) | `pos` column sparse + noisy; no morph_features/provenance | Schema migration (L1.3) |
| Zolai-POS Dataset (token-level JSONL annotation) | None | Format + guide (L1.4) + tool (L1.5) |
| 500-sentence gold set | None | Human annotation (L1.6) — needs speakers |
| Ambiguity first-class (§15: possible POS + confidence) | Tagger returns confidence but stores single tag | Support multi-hypothesis in schema |

## 6. Recommendations for L1.2 (POS_SPEC v0.1)

1. **Adopt UD-inspired UPOS backbone** (NOUN, VERB, ADJ, ADV, PRON, DET, ADP,
   PART, CONJ, NUM, INTJ, PUNCT, PROPN, AUX, X) + Zomi-specific XPOS/feats:
   - `PART.ERG` → UPOS `PART`, feat `Case=Erg`
   - directional prefixes, aspect suffixes → morphological features (Wave L2)
2. **Keep provenance per tag decision**: documented / corpus-observed /
   expert-validated / inferred / experimental (Master Prompt §8 rule).
3. **Normalize DB POS in a new column** (e.g. `pos_canonical`) — never
   overwrite the original `pos` (preserve before modifying, §2).
   Map the 22 dictionary values → canonical; leave blank rather than guess.
4. **`zolai_vocabulary.pos` (132 variants)**: treat as `status=unknown`
   legacy; normalize into `pos_canonical` where unambiguous, archive rest.
5. **Ambiguity**: schema supports `pos_candidates JSON` + `pos_confidence`.
6. **Annotation format**: JSONL `{sentence_id, source, tokens: [{id, text,
   lemma, upos, xpos, feats, ...}]}` + `ANNOTATION_GUIDE_POS.md`.

## 7. Next Steps

| # | Task | Wave |
|---|------|------|
| 1 | Design Zomi POS tagset (UD + Chin literature + corpus evidence) → `POS_SPEC.md` v0.1 | L1.2 |
| 2 | Schema migration: `pos_canonical`, `pos_candidates`, `morph_features`, provenance columns | L1.3 |
| 3 | Annotation format + guide | L1.4 |
| 4 | Annotation tool (CLI + review) | L1.5 |
| 5 | 500-sentence gold set (speaker-dependent) | L1.6 |
| 6 | CRF baseline + eval | L1.7 |

## Risks / uncertainties

- No human-annotated gold data yet — L1.6 blocked on speaker recruitment.
- Dictionary POS coverage (2.6%) too low for supervised training from lexicon alone — corpus + annotation required.
- Grammar-pattern `function` labels not validated against linguistic sources.

---

**Audit status:** COMPLETE · Evidence: DB queries run 2026-09-29 against `data/zolai.db`
· Code read: `zolai/pos_tagger/__init__.py`, `zolai/foundation/analysis.py`
