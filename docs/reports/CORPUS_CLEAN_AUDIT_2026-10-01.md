# Corpus Clean Audit — 2026-10-01

- **Status:** PRE-APPLY (read-only defect matrix — committed as evidence before `--apply`)
- **DB:** `/home/peter/Documents/Projects/zolai-ai/data/zolai.db`
- **Generated:** 2026-10-01 16:15:09 UTC · scan 227.64s
- **Spec:** `docs/planning/C1_CORPUS_CLEAN_PLAN.md` · module `zolai/data/corpus_clean.py`
- **Tables scanned:** 15

## Summary

- cells scanned: **1499337** · changed-candidate cells: 53543 · would-write: 5775
- defects: html 0 · whitespace 2669 · ZVS 50908 cells (123084 hits) · suah 3259 · uppercase 48 · word-sanity 122678 · json-unparseable 0
- review-needs: **suah 2928** · **word-sanity 137** · **json 0** · **unique 29** (total 3094)
- exact-duplicate groups: **29557** (detect + count only — no deletes)

> `suah` is never rewritten; `zo_hcl06`/`zo_fcl` are audit-only; EN/MY/label/staging columns are never selected. Row counts below are the pre-apply baseline — after apply they must be identical (NO-drops proof).

## Defect matrix

| table | column | kind | ctx | cells | html | ws | zvs cells (hits) | suah | upper | sanity | blocked | changed | would-write |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| dictionary | `zolai` | word | modern | 84490 | 0 | 0 | 9 (9) | 11 | 0 | 152 | 0 | 9 | 1 |
| dictionary_en_zo | `translations` | json | modern | 64025 | 0 | 0 | 141 (192) | 286 | 0 | 0 | 0 | 141 | 141 |
| dictionary_en_zo | `translations_clean` | word | modern | 25203 | 0 | 0 | 6 (6) | 4 | 0 | 3 | 0 | 6 | 6 |
| bible_verses | `zo_tdb77` | sentence | scripture | 31043 | 0 | 1 | 177 (186) | 370 | 0 | 0 | 0 | 178 | 178 |
| bible_verses | `zo_tedim2010` | sentence | scripture | 31260 | 0 | 0 | 377 (390) | 196 | 0 | 0 | 0 | 377 | 377 |
| bible_verses | `zo_tedim1932` | sentence | scripture | 30788 | 0 | 0 | 371 (384) | 194 | 0 | 0 | 0 | 371 | 371 |
| bible_verses | `zo_hcl06` | sentence | scripture | 28201 | 0 | 0 | 24062 (66939) | 2 | 0 | 0 | 0 | 24062 | — (audit-only) |
| bible_verses | `zo_fcl` | sentence | scripture | 29661 | 0 | 0 | 23540 (52680) | 329 | 0 | 0 | 0 | 23540 | — (audit-only) |
| phrases | `zolai` | word | modern | 10722 | 0 | 0 | 13 (13) | 3 | 0 | 10719 | 10 | 13 | 3 |
| phrases | `examples` | json | modern | 10722 | 0 | 1721 | 66 (66) | 20 | 0 | 0 | 0 | 1764 | 1764 |
| translations | `target` | sentence | modern | 27473 | 0 | 0 | 323 (332) | 185 | 0 | 0 | 0 | 323 | 323 |
| translations | `source` | sentence | modern | 29185 | 0 | 0 | 339 (348) | 188 | 0 | 0 | 0 | 339 | 339 |
| vocabulary | `headword` | word | modern | 104905 | 0 | 91 | 33 (33) | 78 | 0 | 42128 | 119 | 124 | 2 |
| vocabulary | `examples` | json | modern | 104906 | 0 | 848 | 19 (21) | 45 | 0 | 0 | 0 | 856 | 856 |
| word_usage | `word` | word | modern | 269903 | 0 | 0 | 16 (16) | 100 | 0 | 46544 | 1 | 16 | 1 |
| word_usage | `co_occurring_words` | json | modern | 269903 | 0 | 0 | 6 (6) | 131 | 0 | 0 | 0 | 6 | 6 |
| training_exercises | `zolai` | sentence | modern | 82159 | 0 | 0 | 979 (1000) | 532 | 0 | 0 | 0 | 979 | 979 |
| proverbs | `zolai` | sentence | modern | 8203 | 0 | 1 | 72 (78) | 68 | 0 | 0 | 0 | 73 | 73 |
| word_collocations | `word1` | word | modern | 5000 | 0 | 0 | 0 (0) | 3 | 0 | 215 | 0 | 0 | 0 |
| word_collocations | `word2` | word | modern | 5000 | 0 | 0 | 0 (0) | 2 | 0 | 169 | 0 | 0 | 0 |
| zolai_vocabulary | `zolai` | word | modern | 112279 | 0 | 0 | 14 (14) | 32 | 48 | 22748 | 7 | 14 | 3 |
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
- **unique** — a cleaned value that would collide with another row in a UNIQUE index (shared headword/zolai key) → merging rows is a destructive dedupe C1 refuses to decide; cell left untouched, counted only.

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

- id `28216`: `hakna` → `hahna`
- id `29862`: `hi leh` → `hihleh`

### vocabulary.examples

- id `1491`: `[{"ref": "DEU 32:49", "zo": "Jerikho gal lam, Moab sungah a om Nebo Mual, hih Abarim mual tungah kahto in; a ", "en": "G…` → `[{"ref": "DEU 32:49", "zo": "Jerikho gal lam, Moab sungah a om Nebo Mual, hih Abarim mual tungah kahto in; a", "en": "Ge…`
- id `1630`: `[{"ref": "1CH 7:18", "zo": "Tua ciangin Gilead’ sanggamnu Hammolekheth in Ishhod, Abiezer, leh Mahlah nei hi", "en": "An…` → `[{"ref": "1CH 7:18", "zo": "Tua ciangin Gilead’ sanggamnu Hammolekheth in Ishhod, Abiezer, leh Mahlah nei hi", "en": "An…`
- id `1659`: `[{"ref": "1KI 1:3", "zo": "Tua ahih ciangin amaute in Israel gamsung khempeuh ah nungak mel hoih khat zong ", "en": "So …` → `[{"ref": "1KI 1:3", "zo": "Tua ahih ciangin amaute in Israel gamsung khempeuh ah nungak mel hoih khat zong", "en": "So t…`

### word_usage.word

- id `12844`: `ram` → `gam`

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

- id `25732`: `hakna` → `hahna`
- id `27219`: `hi leh` → `hihleh`
- id `92479`: `hakna` → `hahna`

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
3. **Unique-index collisions** — a cleaned value that already exists in another row of the same table (e.g. `dictionary.zolai` has a UNIQUE index) would merge two rows. C1 refuses the write and counts the cell as a review-need (`unique`); row counts never change.
4. **Junk / word-sanity headwords** — word fields whose cleaned value fails `^[a-z][a-z-]*$` are left untouched (changing them could alter headword identity); they are counted as review-needs.
5. **Fate of `zo_hcl06` / `zo_fcl`** — audit quantifies their historical-form counts; C1 never writes them.
6. **Mixed EN/ZO JSON content** — `dictionary_en_zo.translations` and `word_usage.co_occurring_words` contain English glosses alongside ZO; plan §3 treats JSON string values as ZO, so a small number of ZVS rewrites touch EN-looking cells (reversible via `data_audit_log`).

## Note

**Cleaned ≠ zero defects.** Only deterministic ZVS/whitespace/HTML fixes are applied; everything else stays as review-needs triage (`suah`, word-sanity, json, unique-collision, duplicates). After `--apply` an `## Apply results` section is appended with before/after row counts, audit-row totals and the idempotency proof.

## Apply results

- **Applied:** 2026-10-01 15:43 UTC · db `/home/peter/Documents/Projects/zolai-ai/data/zolai.db` · batch 5000
- **Fresh backup before apply:** `data/backups/zolai-2026-10-01_2113.db.gz` (563M · sha256 in `data/backups/backup.log`)
- **Cells changed:** 5775 · **`data_audit_log` rows added:** 5775 (one per changed cell, `reason="corpus_clean_v1 by cli"`) · log total now 36520
- **Defect classes among written cells:** html 0 · whitespace 9 · ZVS 2999 · JSON 2767

### Row counts before == after (NO-drops proof)

| table | rows before | rows after | cells changed | audit rows |
|---|---:|---:|---:|---:|
| dictionary | 84490 | 84490 | 1 | 1 |
| dictionary_en_zo | 64025 | 64025 | 147 | 147 |
| bible_verses | 31649 | 31649 | 926 | 926 |
| phrases | 10722 | 10722 | 1767 | 1767 |
| translations | 207623 | 207623 | 662 | 662 |
| vocabulary | 104906 | 104906 | 858 | 858 |
| word_usage | 269903 | 269903 | 7 | 7 |
| training_exercises | 82159 | 82159 | 979 | 979 |
| proverbs | 8203 | 8203 | 73 | 73 |
| word_collocations | 5000 | 5000 | 0 | 0 |
| zolai_vocabulary | 112279 | 112279 | 3 | 3 |
| zolai_bible_analysis | 30758 | 30758 | 181 | 181 |
| zolai_word_usage | 85045 | 85045 | 7 | 7 |
| zolai_grammar_patterns | 13519 | 13519 | 110 | 110 |
| zolai_proverbs_idioms | 4984 | 4984 | 54 | 54 |

Totals: 1115265 == 1115265 — **identical** ✅

### Cells changed per table

| table | html | whitespace | zvs | json |
|---|---:|---:|---:|---:|
| dictionary | 0 | 0 | 1 | 0 |
| dictionary_en_zo | 0 | 0 | 6 | 141 |
| bible_verses | 0 | 1 | 925 | 0 |
| phrases | 0 | 0 | 3 | 1764 |
| translations | 0 | 0 | 662 | 0 |
| vocabulary | 0 | 0 | 2 | 856 |
| word_usage | 0 | 0 | 1 | 6 |
| training_exercises | 0 | 0 | 979 | 0 |
| proverbs | 0 | 1 | 72 | 0 |
| word_collocations | 0 | 0 | 0 | 0 |
| zolai_vocabulary | 0 | 0 | 3 | 0 |
| zolai_bible_analysis | 0 | 7 | 174 | 0 |
| zolai_word_usage | 0 | 0 | 7 | 0 |
| zolai_grammar_patterns | 0 | 0 | 110 | 0 |
| zolai_proverbs_idioms | 0 | 0 | 54 | 0 |

### Re-audit after apply (remaining defects = triage)

- review-needs: suah **2928** · word-sanity **137** · json **0** · unique **29** (total 3094)
- would-write cells remaining: **0**
- duplicate groups: **29558** (count-only — no deletes)
- html remaining: 0 · whitespace remaining: 91 · ZVS cells remaining: 47677

### Idempotency (second `--apply`)

- cells changed: **0** · audit rows added: **0** ✅ (0 new audit rows — clean is idempotent)

### needs-founder

1. **`suah` target** — rules_data says `chuak`, AGENTS/ZVS says `suahtakna` (context-dependent). C1 never rewrites `suah`; every hit is counted as a review-need for a founder decision.
2. **Dedupe DELETEs** — duplicate groups are counted only (destructive removal needs an explicit founder decision; row counts are unchanged).
3. **Unique-index collisions** — a cleaned value that already exists in another row of the same table (e.g. `dictionary.zolai` has a UNIQUE index) would merge two rows. C1 refuses the write and counts the cell as a review-need (`unique`); row counts never change.
4. **Junk / word-sanity headwords** — word fields whose cleaned value fails `^[a-z][a-z-]*$` are left untouched (changing them could alter headword identity); they are counted as review-needs.
5. **Fate of `zo_hcl06` / `zo_fcl`** — audit quantifies their historical-form counts; C1 never writes them.
6. **Mixed EN/ZO JSON content** — `dictionary_en_zo.translations` and `word_usage.co_occurring_words` contain English glosses alongside ZO; plan §3 treats JSON string values as ZO, so a small number of ZVS rewrites touch EN-looking cells (reversible via `data_audit_log`).

### Report notes

- Pre-apply section regenerated from backup `zolai-2026-10-01_2113.db.gz` after the JSON suah-counter fix (`7f1df75`): the original committed audit (`57c145d`) undercounted suah in JSON cells that had no other pending change (suah cells 3214→3259, review-needs suah 2883→2928 / total 3049→3094, +45 cells). All other pre-apply figures unchanged (html/whitespace/ZVS/uppercase/word-sanity/json, changed-candidates 53543, would-write 5775, duplicate groups 29557). Pre == post suah 2928 proves apply never touched `suah`.
- Duplicate groups 29557 → 29558 (net +1): ZVS normalization (`na ding` → `nading`) retexted one existing 2-row group in place (same rows, remove+add = net 0) and made one previously-distinct verse pair byte-identical (+1 group). Count-only — no deletes, row counts identical.
- Idempotency shown is the full re-scan run under final code (third `--apply`, state was terminal so cursors reset); the second apply (immediately after the first) was also 0/0. The suah-counter fix only propagates counters in the no-change path — write behavior (`changed`) is unchanged.
- Class sum: written cells 5775 = html 0 + whitespace 9 + ZVS 2999 + JSON 2767 (JSON cells are classed `json` regardless of the defect kinds they contained).

> `suah` / word-sanity / json / unique / duplicate counts above are the deliberate remainder — **cleaned ≠ zero defects**.

---

## C1.1 correction (2026-10-02)

The founder caught false positives in the `corpus_clean_v1` apply above: person-name
cells were gam-ified, EN glosses in `dictionary_en_zo` were rewritten, usage-table name
lists lost their onomastic token, and `zolai_grammar_patterns` teaching contrasts were
destroyed. This section records the revert + the guards that keep it from recurring.

### Detection (re-derived from `data_audit_log` + live-cell compare — never hard-coded ids)

Scanned all **5775** `reason="corpus_clean_v1 by cli"` rows; classification is
deterministic and re-runnable:

| # | Category | Cells | Definition |
|---|---|---:|---|
| A | `name_ram` | **70** | old matches the titlecase person-name pattern AND new contains gam/Gam — any table (bible_verses 22 · translations 16 · training_exercises 14 · phrases 6 · zolai_bible_analysis 6 · vocabulary 3 · proverbs 1 · zolai_grammar_patterns 1 · zolai_proverbs_idioms 1) |
| B | `en_headword` | **31** | `dictionary_en_zo` cell (25 JSON + 6 `translations_clean` strings) where a changed string leaf's **old** value is an exact EN headword of that table (23 × `ram` element, 2 × `samna`) |
| C | `usage_ram` | **8** | `word_usage` (5 × `co_occurring_words` JSON) / `zolai_word_usage` (3 × `word`) name-list cell with a lowercase earth/land token rewritten |
| D | `grammar_meta` | **46** | `zolai_grammar_patterns` cell (22 distinct old values) holding a ZVS violation inside a meta marker (`(not ` / `❌`) — documentation, not usage |
| — | out-of-scope | 5620 | legitimate corrections (COMPOUND fixes, titlecase God-name same-lexeme modernisation) — **deliberately untouched** |
| | **pending total** | **155** | |

### Prevention guards (committed with the revert)

1. **Titlecase person-name guard** (`_zvs_step`) — the earth/land DIALECT rewrite now
   fires only when the matched span is the exact lowercase token; the titlecase Bible
   person-name (1CH 2:9-11 genealogy, Job 32:2) is never rewritten. All other DIALECT
   entries (God-name, life/son, …) keep rewriting case-insensitively.
2. **EN-headword guard** (`_clean_string`/`_clean_json_node` via `_headword_guard`) —
   a `dictionary_en_zo` JSON element, or a whole `translations_clean` value, exactly
   equal to an EN headword of the same table is an English gloss: ZVS is skipped
   (whitespace/HTML fixes still apply).
3. **Meta-doc guard** — a `zolai_grammar_patterns` cell containing `(not ` or `❌`
   alongside a ZVS violation is teaching material; ZVS is skipped for the whole cell so
   contrasts like `Uses gam (not …)` survive.
4. Idempotency, NO-ALTER, no-drops and batched-transaction behavior are unchanged.

CLI: `zolai corpus revert-c1 [--apply] [--json] [--db PATH]` (dry-run by default).

### Live run evidence (2026-10-02)

- **Fresh backup first:** `data/backups/zolai-2026-10-02_0500.db.gz` (563M, dictionary
  rows 84490 verified by the backup script).
- **Dry-run:** 155 pending (A 70 / B 31 / C 8 / D 46), 0 written, audit log 36520.
- **Apply:** **155/155 reverted** · `data_audit_log` +155 rows
  (`reason="c1_1_name_revert by cli"`, old=corrupted → new=restored) · log total
  36520 → 36675 · **pending after run: 0** ✓
- **Spot-check:** `bible_verses` `1CH 2:9` live now reads
  `… Jerahme-el, Ram, leh Khelubai ahi uh hi.` (`zo_tdb77` + `zo_tedim2010`) ✓
- **B/C/D spot-checks:** `dictionary_en_zo` arrays restored (`["pieces", …, "ram"]`,
  `["samna", …]`); `word_usage.co_occurring_words` restored (`["ram"]`,
  `["tapate", "tacil", "ram", …]`); `zolai_word_usage.word` restored to `ram`
  (3 rows); grammar cells restored (`Uses `gam` (not `ram`)`) ✓
- **Detection re-run:** pending **0** · already **155** · conflict 0 · missing 0 ✓
- **Second `--apply` (live idempotency):** 0 cells, 0 audit rows ✓
- **Row counts unchanged:** bible_verses 31649 · translations 207623 ·
  dictionary_en_zo 64025 · word_usage 269903 · zolai_grammar_patterns 13519 ·
  training_exercises 82159 — all identical to the C1 apply table above ✓
- Original `corpus_clean_v1 by cli` audit rows were **never deleted** (full
  before/after chain preserved).

### Verification

- Full `zolai-core` pytest: **1584 passed · 0 failed · 8 skipped · 1 xfailed** (665s),
  including 6 new C1.1 tests (guards ×3, revert dry-run/apply+idempotency, CLI JSON).
- `ruff check zolai tests` clean; ZVS source-compliance gate (docstrings/comments across
  `zolai/`) **0 violations** — the report documents literal tokens, code cites descriptive
  glosses and points at `zvs/rules_data` for the literal map.
- Commits: zolai-core `b36b98c` (guards + revert + tests) · this docs commit (root).

### Residuals / needs-founder

1. **Validator-level titlecase behavior** — `zolai.zvs.validate()` still matches the
  titlecase person-name case-insensitively (rule application uses `re.IGNORECASE`,
  `rules.py` `_apply_rule`); the corpus guard sits at the corpus_clean layer only, so
  other `validate()` consumers will still flag it. Changing rule semantics is a
  founder/linguist decision.
2. **C-class and bare listing cells remain re-exposure risks** — prevention rules 1-3
  protect person-names, EN glosses and meta-docs only; a future clean run would again
  rewrite lowercase name-list tokens and bare `` `ram` `` listing cells in
  `zolai_grammar_patterns` (37 cells were deliberately kept this round as genuine
  table-content rewrites). Extend the guards if corpus_clean is ever re-run.
3. **Out-of-scope 5620 cells** stand as legitimate C1 corrections — no action needed.
