---
title: "Zomi POS Tagset Specification v0.1"
description: "UD-aligned Zomi/Tedim part-of-speech tagset with Zomi-specific features, evidence classes, and ambiguity policy"
created: 2026-09-29
last_updated: 2026-09-29
status: PROPOSED
version: 0.1
---

# Zomi POS Tagset Specification (POS_SPEC) v0.1

> **Status: PROPOSED — pending linguistics-advisor review** (Wave L1.2).
> Per Master Prompt §10: tagset must compare existing Zomi resources,
> Universal Dependencies, Chin-language research, and corpus evidence —
> not blindly copy English Penn Treebank tags.

## 1. Design principles

1. **UD backbone** — UPOS is a fixed list of 17 tags and cannot be extended
   (UD morphology guidelines). Zomi-specific distinctions go into **features**
   (XPOS/feats), never new UPOS tags.
2. **Evidence classification** for every tag/feature decision (Master Prompt §8):
   `documented` · `corpus-observed` · `expert-validated` · `inferred` · `experimental`.
3. **Ambiguity is first-class** (§15): tokens may carry multiple candidate tags
   with confidence; no forced single answer when evidence is weak.
4. **Preserve before modifying** (§2): existing `pos` columns stay untouched;
   canonical values go to new `pos_canonical` fields (L1.3).

## 2. Evidence base (this version)

| Source | Type | Used for |
|--------|------|----------|
| Universal Dependencies v2 guidelines (universaldependencies.org) | Standard, documented | UPOS definitions, feature conventions |
| **UD Zomi corpus** — Tun Tun Aung, Univ. of Strasbourg TCLoc (Oct 2025): 10,583 tokens, POS + morphological features (tense, aspect, case, evidentiality) + dependencies, custom Zomi annotation guidelines; baseline POS-tagging experiments | Prior art, documented | Confirms UD is applicable to Zomi; features: TAME + evidentiality |
| *A Descriptive Grammar of the Zo language* (2013 thesis) | Linguistic literature, documented | TAME system, stem alternation, agglutination, ergativity |
| *A Descriptive Grammar of Tedim Chin* (Zam Ngaih Cing, 2017) | Linguistic literature, documented | Tedim-specific grammar |
| Our corpus: `bible_verses` (31,102), `translations` (207,623), `word_usage` (269,903) | Corpus-observed | Frequency, attestation of tags/particles |
| `grammar_patterns` (5,560 rows / 52 syntactic functions) | Corpus-observed | Sentence-level function labels |
| Existing `zolai/pos_tagger` 13-tag set | In-house prior work | Legacy mapping (§6) |

**Uncertainty note:** The UD Zomi corpus (10.5K tokens) is not yet public
(thesis access via author contact). Until obtained, feature definitions below
are `inferred`/`experimental` where marked — do not treat as expert-validated.

## 3. UPOS tagset (adopted as-is from UD)

Open classes: `NOUN · PROPN · VERB · ADJ · ADV · INTJ`
Closed classes: `PRON · DET · ADP · PART · NUM · CCONJ · SCONJ · AUX`
Other: `PUNCT · SYM · X`

### 3.1 Tag definitions with Zomi decisions

| UPOS | Name | Description | Zomi examples | Zomi-specific usage | Ambiguity watch | Evidence |
|------|------|-------------|---------------|---------------------|-----------------|----------|
| NOUN | noun | Common nouns, includes relational nouns | `gam` (earth), `vantung` (heaven), `mi` (person) | Compounds (`vantung` = van+tung) stay NOUN; components are morphemes, not POS | `ni` day/two/fire (§5) | corpus-observed |
| PROPN | proper noun | Personal/place names | `Pasian`, `Zeisu` | Capitalized in ZVS 2018 orthography | Biblical common nouns used as names | corpus-observed |
| VERB | verb | Predicates incl. intransitive/transitive; includes full verb morphology (directional prefix + stem + aspect + particle — Wave L2) | `piangsak` (create), `mu` (see), `pai` (go) | Subtypes via features (Transitivity), not separate tags | Copula-like `hi` vs AUX (§5) | documented |
| ADJ | adjective | Stative predicates | `khem` (thin/weak), `mahmah` (big) | Kuki-Chin adjectives often predicate nominal — annotate by function, not lexeme | Stative VERB vs ADJ — requires corpus test (predicative vs attributive) | inferred |
| ADV | adverb | Manner/time/degree adverbs; incl. derived `V + na` manner adverbs | `a that` (thus), `hah` (very) | — | `nuntakna` (life) nominalized forms → NOUN not ADV | corpus-observed |
| INTJ | interjection | Independent exclamations | `aw`, `eh` | — | Discourse particles (`ci`, `lah`) → PART, not INTJ (UD: small closed list) | inferred |
| PRON | pronoun | Personal/demonstrative/interrogative pronouns (13-item closed class in `pos_tagger`) | `ka` (1sg), `na` (2sg), `a` (3sg), `ki` (3pl), `amah` (emphatic) | Bound pronominal clitics on verbs → PRON with `Clitic=Yes` (per UD Zomi corpus: "pronominal clitics attached as bound morphemes") | Free `a` (he/she) vs agreement prefix `a` before verb → see §5 | documented |
| DET | determiner | Articles, demonstrative determiners, quantifiers | — | **Research question:** Zomi may lack a true DET class; demonstratives (`khai`?) may be PRON or NOUN-modifier | UD v2: PRON/DET borderline is language-specific; decide after corpus check | experimental |
| ADP | adposition | Prepositions **and postpositions** (UD uses one tag) | `tawh`, `ah`, `kha` | Existing `POST.*` subtags map here; adposition type recorded in `AdpType=Pre/Post` | — | documented |
| PART | particle | Small closed-class grammatical markers | `hi` (declarative), `in` (ergative), `kei`/`lo` (neg), `hiam` (question), `pen` (focus) | Carries most Zomi grammar via features (§4): `Polarity`, `Case=Erg`, question/evidential | Multi-function particles: `hi` PART vs AUX (§5) | documented |
| NUM | numeral | Cardinals, ordinals | `ma` (one), `ni` (two), `pathum` (three) | `NumType=Card/Ord` | `ni` two vs day vs fire (§5) | corpus-observed |
| CCONJ | coordinating conjunction | Coordinators | `leh` (and) | — | `leh` also PART (discourse) in some corpora — function-based decision | corpus-observed |
| SCONJ | subordinating conjunction | Clause subordinators | `hileh` (if/then), `ci` (quotative/complementizer) | Clause chaining (per UD Zomi corpus) often uses verb-final chaining without SCONJ | `ci` in `pos_tagger` listed as PART — re-evaluate: quotative → SCONJ (UD standard) | inferred |
| AUX | auxiliary | TAM auxiliaries + copula (UD v2: copulas are AUX) | `hi` (copula/declarative), `ding` (future), `om` (existential) | TAME stack attaches to main verb; auxiliaries marked `VerbForm=Fin` | **Key ambiguity: `hi` PART vs AUX** — see §5 | inferred |
| PUNCT | punctuation | `. ? ! ,` | — | — | — | documented |
| SYM | symbol | Currency/symbols/emoji | — | — | — | documented |
| X | other | Foreign words, unanalyzable, uncertain | English loanwords pending analysis | Use only when no tag applies (UD: never empty; `_` not allowed) | Avoid overuse; prefer `pos_candidates` uncertainty flag | documented |

## 4. Morphological features (Zomi-specific, UD `feats` namespace)

Feature decisions come from the UD Zomi corpus (TAME + evidentiality),
our grammar tables, and ZVS 2018 grammar rules. Values follow UD where a
standard feature exists.

### 4.1 Nominal features

| Feature | Values | Applies to | Examples | Evidence |
|---------|--------|-----------|----------|----------|
| `Number` | `Sing`, `Plur` | NOUN, PRON | `ki` (3pl), `mi` + plural `te` | documented |
| `Person` | `1`, `2`, `3` | PRON | `ka`=1, `na`=2, `a`=3 | documented |
| `PronType` | `Prs`, `Dem`, `Int`, `Rel`, `Ind` | PRON, DET | interrogative pronouns | documented |
| `Number[psor]` / possessive | `Sing`, `Plur` | possessors | `ku`/`nu`/`u` possessive forms | inferred |

### 4.2 Case

| Feature | Values | Marker | Examples | Evidence |
|---------|--------|--------|----------|----------|
| `Case` | `Erg`, `Nom`/default, (candidate `Abl`, `Dat`, `Loc` — research) | ergative `in` | `Pasian **in** leitung a piangsak hi.` (God-ERG earth created) | documented (ergativity core to ZVS grammar rules) |

**Decision:** `in` → `PART` with `Case=Erg` (not a separate UPOS). Postpositions
may also bear `Case` on their phrase — Phase: L4 grammatical relations.

### 4.3 Verbal TAME (tense / aspect / mood / evidentiality)

Per architecture context + grammar_patterns (52 functions) + Zo grammar (TAME web):

| Feature | Value | Zomi marker | Example | Evidence |
|---------|-------|-------------|---------|----------|
| `Tense` | `Past` | `ta` | `A pai ta hi.` (he went) | documented |
| `Tense` | `Fut` | `ding` | `Ka pai ding hi.` (I will go) | documented |
| `Aspect` | `Perf` | `zo` | `A pai zo hi.` (he finished going) | documented |
| `Aspect` | `Prog` | `lai` | `A ne lai hi.` (he is eating) | documented |
| `Aspect` | `Exp` (experiential — UD `Aspect=Exper` research needed; fallback `Tense=Past` + note) | `khin` | `Ka mu khin hi.` (I have seen before) | inferred |
| `Polarity` | `Neg` | `kei` (all persons), `lo` (literary, standalone) | `Ka pai kei hi.` | documented |
| `Mood` | `Ind`, `Imp`, `Int` (yes/no `hiam`), content-Q (`bang hang`) | final particles | `Na pai hiam?` | documented |
| `Evid` (evidentiality) | research values — `Evid`/`Evident` TBD after UD-Zomi corpus access | `un`, `hen`, `vo` style markers | pending corpus attestation | experimental |

**Morphology caveat:** markers are **suffixes/clitics on verbs** (agglutinative
stacking: directional + stem + aspect + particle). In tokenization for POS
annotation: annotate whole verb forms as VERB with feats; morpheme-level
decomposition is Wave L2 (`MORPHOLOGY_SPEC`), not POS.

## 5. Known ambiguities (first-class)

| Token(s) | Candidates | Resolution rule (current hypothesis) | Evidence |
|----------|-----------|--------------------------------------|----------|
| `hi` | `PART` (declarative/final) vs `AUX` (copula) vs `VERB` (exist) | UD v2 issue 275: copula → AUX; sentence-final particle → PART. **Requires corpus test** (nominal predicate vs verbal predicate) | experimental |
| `a` | `PRON` (3sg free) vs agreement marker before verb | Before verb: bound form → `PRON` + `Clitic=Yes` (per UD Zomi pronominal-clitic finding); else PRON | inferred |
| `ni` | `NUM` (two) vs `NOUN` (day/sun) vs `NOUN` (fire) vs `PART` (discourse) | Context + dictionary sense; annotate lemma to disambiguate | corpus-observed (polysemy documented in `word_usage`) |
| `in` | `PART.Case=Erg` vs `VERB` (say/other verbs) | Corpus frequency check; ergative reading dominant pre-verbal | inferred |
| `lo` | `PART.Polarity=Neg` (literary standalone) vs other `lo` senses | Standing alone / final position → NEG; also ZVS rule: `lo` never takes `a` agreement | documented |
| `man` | `NOUN` (price) vs `ADJ`/`ADV` (true, as much as) | Function-based; multi-tag candidate list | corpus-observed |
| `ding` | `AUX` (future) vs other | Attached to verb complex → feature `Tense=Fut` on verb or AUX — decide in L4 | experimental |
| ADJ vs stative VERB | `khem`, `dam`… | Attributive position → ADJ; predicative → VERB (working hypothesis, corpus test needed) | inferred |

**Policy:** annotators record ALL plausible tags in `pos_candidates` with the
chosen tag in `pos` + `pos_confidence` (0–1) + `evidence` field.

## 6. Legacy tagset mapping (13-tag → UD)

| Legacy tag | → UPOS | Notes |
|------------|--------|-------|
| `N.COMMON` | NOUN | |
| `N.PROPER` | PROPN | |
| `N.COMPOUND` | NOUN | compoundness → morph, not POS |
| `V.INTRANS/TRANS/DITRANS/COP` | VERB / AUX | COP → AUX (re-evaluate) |
| `V.AUX` | AUX | |
| `ADJ.QUAL/QUANT` | ADJ | quantifier readings → DET/NUM (research) |
| `ADV` | ADV | |
| `PRON` | PRON | |
| `DET` | DET | verify existence in Zomi |
| `POST.LOC/DAT/GEN/INS` | ADP | subtypes → `AdpType` + `Case` feats |
| `CONJ` | CCONJ / SCONJ | functional split |
| `PART.NEG` | PART + `Polarity=Neg` | |
| `PART.QUESTION` | PART + `Mood=Int` | |
| `PART.ERG` | PART + `Case=Erg` | |
| `PART.FOCUS/TOPIC` | PART (+ `Focus`/`Top` feats — research) | |
| `NUM`, `INTJ`, `PUNCT`, `X` | same | |

## 7. Annotation format (for L1.4/L1.5)

JSONL, one sentence per line (UD-Zomi-corpus-compatible fields):

```json
{
  "sentence_id": "gen-001-006",
  "source": "bible_verses:TDB77",
  "text": "Pasian in vantung leh leitung a piangsak hi.",
  "tokens": [
    {"id": 1, "text": "Pasian", "lemma": "pasian", "upos": "PROPN",
     "xpos": null, "feats": {}, "pos_candidates": ["PROPN", "NOUN"],
     "pos_confidence": 0.95, "evidence": "corpus-observed"},
    {"id": 2, "text": "in", "lemma": "in", "upos": "PART",
     "feats": {"Case": "Erg"}, "pos_candidates": ["PART", "VERB"],
     "pos_confidence": 0.9, "evidence": "documented"},
    {"id": 3, "text": "vantung", "lemma": "vantung", "upos": "NOUN",
     "feats": {}, "pos_candidates": ["NOUN"], "pos_confidence": 0.95,
     "evidence": "corpus-observed"},
    {"id": 4, "text": "leh", "lemma": "leh", "upos": "CCONJ",
     "feats": {}, "pos_candidates": ["CCONJ", "PART"],
     "pos_confidence": 0.8, "evidence": "inferred"},
    {"id": 5, "text": "leitung", "lemma": "leitung", "upos": "NOUN",
     "feats": {}, "pos_candidates": ["NOUN"], "pos_confidence": 0.95,
     "evidence": "corpus-observed"},
    {"id": 6, "text": "a", "lemma": "a", "upos": "PRON",
     "feats": {"Person": "3", "Number": "Sing", "Clitic": "Yes"},
     "pos_candidates": ["PRON", "PART"], "pos_confidence": 0.85,
     "evidence": "inferred"},
    {"id": 7, "text": "piangsak", "lemma": "piang", "upos": "VERB",
     "feats": {"Aspect": "Perf", "Transitivity": "Trans"},
     "pos_candidates": ["VERB"], "pos_confidence": 0.95,
     "evidence": "documented"},
    {"id": 8, "text": "hi.", "lemma": "hi", "upos": "PART",
     "feats": {"Mood": "Ind"}, "pos_candidates": ["PART", "AUX"],
     "pos_confidence": 0.7, "evidence": "experimental"}
  ]
}
```

CoNLL-U export supported for interoperability (UD tooling: UD Annotatrix,
INCEpTION — same tools used by the UD Zomi corpus project).

## 8. Open research questions (before v1.0)

1. Does Zomi have a true DET class? (corpus distribution study)
2. ADJ vs stative VERB boundary — attestation protocol needed
3. `hi` PART vs AUX — nominal-predicate corpus test
4. Evidentiality feature inventory — requires UD-Zomi-corpus access
   (contact: Tun Tun Aung, TCLoc thesis)
5. Content-question (`bang hang`) annotation vs echo-question analysis
6. Degree/quantifier adjectives → DET or ADJ?

## 9. Versioning

- **v0.1** (2026-09-29): initial proposal — UD backbone + Zomi feats + ambiguity policy. Status PROPOSED.
- v0.2: after linguistics-advisor review + UD-Zomi-corpus acquisition.
- v1.0: after L1.6 gold-set annotation feedback round (500 sentences).

---

**Change policy (§29):** modifications to this spec require evidence citation +
review note appended to §9 version log. No silent edits.
