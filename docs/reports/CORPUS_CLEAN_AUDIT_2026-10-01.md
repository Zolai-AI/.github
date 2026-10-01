# Corpus Clean Audit — 2026-10-01

- **Status:** PRE-APPLY (read-only defect matrix — committed as evidence before `--apply`)
- **DB:** `/home/peter/Documents/Projects/zolai-ai/data/zolai.db`
- **Generated:** 2026-10-01 14:40:28 UTC · scan 297.4s
- **Spec:** `docs/planning/C1_CORPUS_CLEAN_PLAN.md` · module `zolai/data/corpus_clean.py`
- **Tables scanned:** 15

## Summary

- cells scanned: **1499337** · changed-candidate cells: 53543 · would-write: 5804
- defects: html 0 · whitespace 2669 · ZVS 50908 cells (123084 hits) · suah 3214 · uppercase 48 · word-sanity 122678 · json-unparseable 0
- review-needs: **suah 2883** · **word-sanity 137** · **json 0** (total 3020)
- exact-duplicate groups: **29557** (detect + count only — no deletes)

> `suah` is never rewritten; `zo_hcl06`/`zo_fcl` are audit-only; EN/MY/label/staging columns are never selected. Row counts below are the pre-apply baseline — after apply they must be identical (NO-drops proof).

## Defect matrix

| table | column | kind | ctx | cells | html | ws | zvs cells (hits) | suah | upper | sanity | blocked | changed | would-write |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| dictionary | `zolai` | word | modern | 84490 | 0 | 0 | 9 (9) | 11 | 0 | 152 | 0 | 9 | 9 |
| dictionary_en_zo | `translations` | json | modern | 64025 | 0 | 0 | 141 (192) | 286 | 0 | 0 | 0 | 141 | 141 |
| dictionary_en_zo | `translations_clean` | word | modern | 25203 | 0 | 0 | 6 (6) | 4 | 0 | 3 | 0 | 6 | 6 |
| bible_verses | `zo_tdb77` | sentence | scripture | 31043 | 0 | 1 | 177 (186) | 370 | 0 | 0 | 0 | 178 | 178 |
| bible_verses | `zo_tedim2010` | sentence | scripture | 31260 | 0 | 0 | 377 (390) | 196 | 0 | 0 | 0 | 377 | 377 |
| bible_verses | `zo_tedim1932` | sentence | scripture | 30788 | 0 | 0 | 371 (384) | 194 | 0 | 0 | 0 | 371 | 371 |
| bible_verses | `zo_hcl06` | sentence | scripture | 28201 | 0 | 0 | 24062 (66939) | 2 | 0 | 0 | 0 | 24062 | — (audit-only) |
| bible_verses | `zo_fcl` | sentence | scripture | 29661 | 0 | 0 | 23540 (52680) | 329 | 0 | 0 | 0 | 23540 | — (audit-only) |
| phrases | `zolai` | word | modern | 10722 | 0 | 0 | 13 (13) | 3 | 0 | 10719 | 10 | 13 | 3 |
| phrases | `examples` | json | modern | 10722 | 0 | 1721 | 66 (66) | 13 | 0 | 0 | 0 | 1764 | 1764 |
| translations | `target` | sentence | modern | 27473 | 0 | 0 | 323 (332) | 185 | 0 | 0 | 0 | 323 | 323 |
| translations | `source` | sentence | modern | 29185 | 0 | 0 | 339 (348) | 188 | 0 | 0 | 0 | 339 | 339 |
| vocabulary | `headword` | word | modern | 104905 | 0 | 91 | 33 (33) | 78 | 0 | 42128 | 119 | 124 | 5 |
| vocabulary | `examples` | json | modern | 104906 | 0 | 848 | 19 (21) | 7 | 0 | 0 | 0 | 856 | 856 |
| word_usage | `word` | word | modern | 269903 | 0 | 0 | 16 (16) | 100 | 0 | 46544 | 1 | 16 | 15 |
| word_usage | `co_occurring_words` | json | modern | 269903 | 0 | 0 | 6 (6) | 131 | 0 | 0 | 0 | 6 | 6 |
| training_exercises | `zolai` | sentence | modern | 82159 | 0 | 0 | 979 (1000) | 532 | 0 | 0 | 0 | 979 | 979 |
| proverbs | `zolai` | sentence | modern | 8203 | 0 | 1 | 72 (78) | 68 | 0 | 0 | 0 | 73 | 73 |
| word_collocations | `word1` | word | modern | 5000 | 0 | 0 | 0 (0) | 3 | 0 | 215 | 0 | 0 | 0 |
| word_collocations | `word2` | word | modern | 5000 | 0 | 0 | 0 (0) | 2 | 0 | 169 | 0 | 0 | 0 |
| zolai_vocabulary | `zolai` | word | modern | 112279 | 0 | 0 | 14 (14) | 32 | 48 | 22748 | 7 | 14 | 7 |
| zolai_vocabulary | `example_zo` | sentence | modern | 0 | 0 | 0 | 0 (0) | 0 | 0 | 0 | 0 | 0 | 0 |
| zolai_bible_analysis | `zolai` | sentence | modern | 30758 | 0 | 7 | 174 (183) | 366 | 0 | 0 | 0 | 181 | 181 |
| zolai_word_usage | `word` | word | modern | 85045 | 0 | 0 | 7 (7) | 50 | 0 | 0 | 0 | 7 | 7 |
| zolai_word_usage | `contexts` | json | modern | 0 | 0 | 0 | 0 (0) | 0 | 0 | 0 | 0 | 0 | 0 |
| zolai_grammar_patterns | `zolai_example` | sentence | modern | 13519 | 0 | 0 | 110 (124) | 7 | 0 | 0 | 0 | 110 | 110 |
| zolai_proverbs_idioms | `zolai` | sentence | modern | 4984 | 0 | 0 | 54 (57) | 57 | 0 | 0 | 0 | 54 | 54 |

### Column row counts (pre-apply baseline)

| table | rows |
|---|---:|
| dictionary | 84490 |
| dictionary_en_zo | 64025 |
| bible_verses | 31649 |
| phrases | 10722 |
| translations | 207623 |
| vocabulary | 104906 |
| word_usage | 269903 |
| training_exercises | 82159 |
| proverbs | 8203 |
| word_collocations | 5000 |
| zolai_vocabulary | 112279 |
| zolai_bible_analysis | 30758 |
| zolai_word_usage | 85045 |
| zolai_grammar_patterns | 13519 |
| zolai_proverbs_idioms | 4984 |

## Duplicate groups (detect + count only)

| table | key | groups |
|---|---|---:|
| dictionary | `zolai`, `english` | 0 |
| dictionary_en_zo | `translations_clean`, `headword` | 0 |
| bible_verses | `zo_tdb77` | 623 |
| phrases | `zolai`, `english` | 0 |
| translations | `source`, `target` | 0 |
| vocabulary | `headword`, `english` | 0 |
| training_exercises | `zolai`, `english` | 26893 |
| proverbs | `zolai`, `english` | 0 |
| word_collocations | `word1`, `word2` | 0 |
| zolai_vocabulary | `zolai`, `english` | 493 |
| zolai_bible_analysis | `zolai`, `english` | 601 |
| zolai_grammar_patterns | `zolai_example`, `english_translation` | 941 |
| zolai_proverbs_idioms | `zolai`, `english_translation` | 6 |

## Review-need definitions

- **suah** — cells containing standalone `suah` in a column C1 would write; two canonical docs disagree on the target → left untouched, counted only.
- **word-sanity** — word-kind cells whose *cleaned* value fails `^[a-z][a-z-]*$` while a change was pending → write refused (headword identity), counted only. (The full count of word cells failing the regex — including those needing no change — is the `sanity` column of the defect matrix.)
- **json** — JSON cells that fail to parse → left untouched, counted only.

## Exclusions

- `*_import` staging tables — never scanned, never written.
- EN columns (`english`, `english_clean`, `english_translation`, `en_kJV`, `ref`/`book`/`chapter` labels) — byte-identical after apply.
- MY columns (`myanmar`, `myanmar_judson`) — byte-identical after apply.
- `grammar_patterns` — no ZO prose column (pattern metadata only).
- `articles` / `wiki_lessons` — mixed-language prose, 'in doubt' → left alone.
- Label columns in `zolai_grammar_patterns` (`pattern`, `structure`, `pattern_text`) — structural labels, not prose.
- `bible_verses.zo_hcl06` / `bible_verses.zo_fcl` — audit-only (Hakha/Falam parallel versions; converting them would falsify the corpus).

## Samples (first cells that `--apply` would change)

### dictionary.zolai

- id `108091`: `bawipa` → `topa`
- id `180828`: `cun` → `tua`
- id `122451`: `hakna` → `hahna`

### dictionary_en_zo.translations

- id `3027`: `["archaelogy", "a omlai nate pansana nidang lai-a mite thu sinna", "nidang lai-a mite teenna khua, a vanzatte uh lei in …` → `["archaelogy", "a omlai nate pansana nidang lai-a mite thu sinna", "nidang lai-a mite teenna khua, a vanzatte uh lei in …`
- id `3129`: `["(n) kido khawlphotna dinga thukimna, ahun kiciangtan sung kido khawl phot na ding bawlna"]` → `["(n) kido khawlphotna dinga thukimna, ahun kiciangtan sung kido khawl phot nading bawlna"]`
- id `3173`: `["sum bat piak ding om lai sum a om lai na sep ding", "arrear", "arrears", "piak hun lai-a kipe kha lo a kikhawnung piak…` → `["sum bat piak ding om lai sum a om lai nasep ding", "arrear", "arrears", "piak hun lai-a kipe kha lo a kikhawnung piak …`

### dictionary_en_zo.translations_clean

- id `7945`: `samna` → `sapna`
- id `21407`: `ram` → `gam`
- id `22300`: `samna` → `sapna`

### bible_verses.zo_tdb77

- id `62`: `Ama sung panin a suak Hezron’ tapate in: Jerahme-el, Ram, leh Khelubai ahi uh hi.` → `Ama sung panin a suak Hezron’ tapate in: Jerahme-el, Gam, leh Khelubai ahi uh hi.`
- id `63`: `Ram in Amminadab’ pa hi a, Amminadab in Judah tapate sung pan ulian Nahshon’ pa ahi hi.` → `Gam in Amminadab’ pa hi a, Amminadab in Judah tapate sung pan ulian Nahshon’ pa ahi hi.`
- id `78`: `Hezron’ tacil Jerahme-el’ tapate in: A tacil Ram, Bunah, Oren, Ozem, leh Ahijah ahi uh hi.` → `Hezron’ tacil Jerahme-el’ tapate in: A tacil Gam, Bunah, Oren, Ozem, leh Ahijah ahi uh hi.`

### bible_verses.zo_tedim2010

- id `62`: `Ama sung panin a suak Hezron' tapate: Jerahmeel, Ram, leh Khelubai ahi uh hi.` → `Ama sung panin a suak Hezron' tapate: Jerahmeel, Gam, leh Khelubai ahi uh hi.`
- id `63`: `Ram pen Amminadab' pa hi a, Amminadab pen Judah' tapate' sung pan ulian Nahshon' pa ahi hi.` → `Gam pen Amminadab' pa hi a, Amminadab pen Judah' tapate' sung pan ulian Nahshon' pa ahi hi.`
- id `78`: `Hezron' tacil Jerahmeel' tapate: A tacil Ram, Bunah, Oren, leh Ahijah ahi uh hi.` → `Hezron' tacil Jerahmeel' tapate: A tacil Gam, Bunah, Oren, leh Ahijah ahi uh hi.`

### bible_verses.zo_tedim1932

- id `62`: `Ama sung panin a suak Hezron' tapate: Jerahmeel, Ram, leh Khelubai ahi uh hi.` → `Ama sung panin a suak Hezron' tapate: Jerahmeel, Gam, leh Khelubai ahi uh hi.`
- id `63`: `Ram pen Amminadab' pa hi a, Amminadab pen Judah' tapate' sung pan ulian Nahshon' pa ahi hi.` → `Gam pen Amminadab' pa hi a, Amminadab pen Judah' tapate' sung pan ulian Nahshon' pa ahi hi.`
- id `78`: `Hezron' tacil Jerahmeel' tapate: A tacil Ram, Bunah, Oren, leh Ahijah ahi uh hi.` → `Hezron' tacil Jerahmeel' tapate: A tacil Gam, Bunah, Oren, leh Ahijah ahi uh hi.`

### phrases.zolai

- id `428`: `hi leh` → `hihleh`
- id `5026`: `na ding` → `nading`
- id `5372`: `na sep` → `nasep`

### phrases.examples

- id `1`: `[{"ref": "1CH 1:4", "zo": "Lamek' ta Noah ahi hi. Noah in tapa thum nei a, tuate pen Shem, Ham, leh Jafeth ", "en": "Noa…` → `[{"ref": "1CH 1:4", "zo": "Lamek' ta Noah ahi hi. Noah in tapa thum nei a, tuate pen Shem, Ham, leh Jafeth", "en": "Noah…`
- id `3`: `[{"ref": "1CH 1:43", "zo": "Israel-te tungah kumpi khat peuhpeuh in a uk ma-in Edom gamsungah a uk kumpite: ", "en": "No…` → `[{"ref": "1CH 1:43", "zo": "Israel-te tungah kumpi khat peuhpeuh in a uk ma-in Edom gamsungah a uk kumpite:", "en": "Now…`
- id `7`: `[{"ref": "1CH 4:10", "zo": "Jabez in Israel Pasian tungah thu ngen a, “Kei thupha hong pia-in ka gamgi hong ", "en": "An…` → `[{"ref": "1CH 4:10", "zo": "Jabez in Israel Pasian tungah thu ngen a, “Kei thupha hong pia-in ka gamgi hong", "en": "And…`

### translations.target

- id `126`: `Ama sung panin a suak Hezron' tapate: Jerahmeel, Ram, leh Khelubai ahi uh hi.` → `Ama sung panin a suak Hezron' tapate: Jerahmeel, Gam, leh Khelubai ahi uh hi.`
- id `128`: `Ram pen Amminadab' pa hi a, Amminadab pen Judah' tapate' sung pan ulian Nahshon' pa ahi hi.` → `Gam pen Amminadab' pa hi a, Amminadab pen Judah' tapate' sung pan ulian Nahshon' pa ahi hi.`
- id `158`: `Hezron' tacil Jerahmeel' tapate: A tacil Ram, Bunah, Oren, leh Ahijah ahi uh hi.` → `Hezron' tacil Jerahmeel' tapate: A tacil Gam, Bunah, Oren, leh Ahijah ahi uh hi.`

### translations.source

- id `125`: `Ama sung panin a suak Hezron' tapate: Jerahmeel, Ram, leh Khelubai ahi uh hi.` → `Ama sung panin a suak Hezron' tapate: Jerahmeel, Gam, leh Khelubai ahi uh hi.`
- id `127`: `Ram pen Amminadab' pa hi a, Amminadab pen Judah' tapate' sung pan ulian Nahshon' pa ahi hi.` → `Gam pen Amminadab' pa hi a, Amminadab pen Judah' tapate' sung pan ulian Nahshon' pa ahi hi.`
- id `157`: `Hezron' tacil Jerahmeel' tapate: A tacil Ram, Bunah, Oren, leh Ahijah ahi uh hi.` → `Hezron' tacil Jerahmeel' tapate: A tacil Gam, Bunah, Oren, leh Ahijah ahi uh hi.`

### vocabulary.headword

- id `8623`: `bawipa` → `topa`
- id `28216`: `hakna` → `hahna`
- id `29862`: `hi leh` → `hihleh`

### vocabulary.examples

- id `1491`: `[{"ref": "DEU 32:49", "zo": "Jerikho gal lam, Moab sungah a om Nebo Mual, hih Abarim mual tungah kahto in; a ", "en": "G…` → `[{"ref": "DEU 32:49", "zo": "Jerikho gal lam, Moab sungah a om Nebo Mual, hih Abarim mual tungah kahto in; a", "en": "Ge…`
- id `1630`: `[{"ref": "1CH 7:18", "zo": "Tua ciangin Gilead’ sanggamnu Hammolekheth in Ishhod, Abiezer, leh Mahlah nei hi", "en": "An…` → `[{"ref": "1CH 7:18", "zo": "Tua ciangin Gilead’ sanggamnu Hammolekheth in Ishhod, Abiezer, leh Mahlah nei hi", "en": "An…`
- id `1659`: `[{"ref": "1KI 1:3", "zo": "Tua ahih ciangin amaute in Israel gamsung khempeuh ah nungak mel hoih khat zong ", "en": "So …` → `[{"ref": "1KI 1:3", "zo": "Tua ahih ciangin amaute in Israel gamsung khempeuh ah nungak mel hoih khat zong", "en": "So t…`

### word_usage.word

- id `5460`: `ram` → `gam`
- id `12844`: `ram` → `gam`
- id `67988`: `ram` → `gam`

### word_usage.co_occurring_words

- id `7830`: `["(n.) Khuachia bawipa"]` → `["(n.) Khuachia topa"]`
- id `10490`: `["ram"]` → `["gam"]`
- id `14292`: `["ram"]` → `["gam"]`

### training_exercises.zolai

- id `47`: `Ama sung panin a suak Hezron' tapate: Jerahmeel, Ram, leh Khelubai ahi uh hi.` → `Ama sung panin a suak Hezron' tapate: Jerahmeel, Gam, leh Khelubai ahi uh hi.`
- id `48`: `Ram pen Amminadab' pa hi a, Amminadab pen Judah' tapate' sung pan ulian Nahshon' pa ahi hi.` → `Gam pen Amminadab' pa hi a, Amminadab pen Judah' tapate' sung pan ulian Nahshon' pa ahi hi.`
- id `60`: `Hezron' tacil Jerahmeel' tapate: A tacil Ram, Bunah, Oren, leh Ahijah ahi uh hi.` → `Hezron' tacil Jerahmeel' tapate: A tacil Gam, Bunah, Oren, leh Ahijah ahi uh hi.`

### proverbs.zolai

- id `1797`: `A vanglian Topa, Israel mite’ Pasian in hih bangin hong ci hi. Na nuntakzia uh leh na gamtatnate uh kikhel un. Tua hi le…` → `A vanglian Topa, Israel mite’ Pasian in hih bangin hong ci hi. Na nuntakzia uh leh na gamtatnate uh kikhel un. Tua hihle…`
- id `2181`: `Ahih hangin amaute in ka lungsim tawng dong thei uh hi leh ka thu gente ka mite tungah a tangko ding uh a, a nuntakna ho…` → `Ahih hangin amaute in ka lungsim tawng dong thei uh hihleh ka thu gente ka mite tungah a tangko ding uh a, a nuntakna ho…`
- id `1817`: `Ahih hangin, ‘Ka thu hong mang un; tua hi leh note’ Pasian ka hi ding-a, note in ka hoih zawk nadingin na khempeuh-ah ko…` → `Ahih hangin, ‘Ka thu hong mang un; tua hihleh note’ Pasian ka hi ding-a, note in ka hoih zawk nadingin na khempeuh-ah ko…`

### zolai_vocabulary.zolai

- id `7488`: `bawipa` → `topa`
- id `25732`: `hakna` → `hahna`
- id `27219`: `hi leh` → `hihleh`

### zolai_bible_analysis.zolai

- id `62`: `Ama sung panin a suak Hezron’ tapate in: Jerahme-el, Ram, leh Khelubai ahi uh hi.` → `Ama sung panin a suak Hezron’ tapate in: Jerahme-el, Gam, leh Khelubai ahi uh hi.`
- id `63`: `Ram in Amminadab’ pa hi a, Amminadab in Judah tapate sung pan ulian Nahshon’ pa ahi hi.` → `Gam in Amminadab’ pa hi a, Amminadab in Judah tapate sung pan ulian Nahshon’ pa ahi hi.`
- id `78`: `Hezron’ tacil Jerahme-el’ tapate in: A tacil Ram, Bunah, Oren, Ozem, leh Ahijah ahi uh hi.` → `Hezron’ tacil Jerahme-el’ tapate in: A tacil Gam, Bunah, Oren, Ozem, leh Ahijah ahi uh hi.`

### zolai_word_usage.word

- id `309`: `ram` → `gam`
- id `4177`: `thatna` → `thahna`
- id `29899`: `hakna` → `hahna`

### zolai_grammar_patterns.zolai_example

- id `1070`: `Na maipha ka muh na ding` → `Na maipha ka muh nading`
- id `2054`: `lei tung` → `leitung`
- id `2108`: `lei tung` → `leitung`

### zolai_proverbs_idioms.zolai

- id `140`: `Mi khat bek hi leh zawh nop kisa a, nih pha leh kizo zo lo hi. Zang thum-a kiheek khauhual bawhsat hak hi.` → `Mi khat bek hihleh zawh nop kisa a, nih pha leh kizo zo lo hi. Zang thum-a kiheek khauhual bawhsat hak hi.`
- id `835`: `Leenggui lo tungah ka heh nawn kei hi. Lingte leh lingkungte om hi leh keimah kuan khia-in tuate ka haltum ding hi.` → `Leenggui lo tungah ka heh nawn kei hi. Lingte leh lingkungte om hihleh keimah kuan khia-in tuate ka haltum ding hi.`
- id `1023`: `Hezekiah' thu ngai kei un; bang hang hiam cih leh Assiria kumpipa in hih bangin ci hi: Kei tawh kilemna hong bawl un la …` → `Hezekiah' thu ngai kei un; bang hang hiam cih leh Assiria kumpipa in hih bangin ci hi: Kei tawh kilemna hong bawl un la …`

## needs-founder (none of these block audit/apply)

1. **`suah` target** — rules_data says `chuak`, AGENTS/ZVS says `suahtakna` (context-dependent). C1 never rewrites `suah`; every hit is counted as a review-need for a founder decision.
2. **Dedupe DELETEs** — duplicate groups are counted only (destructive removal needs an explicit founder decision; row counts are unchanged).
3. **Junk / word-sanity headwords** — word fields whose cleaned value fails `^[a-z][a-z-]*$` are left untouched (changing them could alter headword identity); they are counted as review-needs.
4. **Fate of `zo_hcl06` / `zo_fcl`** — audit quantifies their historical-form counts; C1 never writes them.
5. **Mixed EN/ZO JSON content** — `dictionary_en_zo.translations` and `word_usage.co_occurring_words` contain English glosses alongside ZO; plan §3 treats JSON string values as ZO, so a small number of ZVS rewrites touch EN-looking cells (reversible via `data_audit_log`).

## Note

**Cleaned ≠ zero defects.** Only deterministic ZVS/whitespace/HTML fixes are applied; everything else stays as review-needs triage (`suah`, word-sanity, json, duplicates). After `--apply` an `## Apply results` section is appended with before/after row counts, audit-row totals and the idempotency proof.
