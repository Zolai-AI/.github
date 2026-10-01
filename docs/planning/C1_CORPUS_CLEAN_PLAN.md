# C1 Corpus Clean — PLAN_READY (2026-10-01)

## Goal
Audit every canonical table with ZO text, then in-place ZVS-2018 normalize + whitespace/HTML-entity fix with `data_audit_log` old→new rows (no drops), plus committed before/after report.

## Context alignment
- Follows R1-D3 C1 in `docs/planning/BACKEND_CORE_V1_PLAN.md`; Phase-0 baseline verified present (`data/backups/baseline-2026-09-30.json` sha256 + `zolai-2026-10-01_0002.db.gz`) — apply gate satisfied.
- Invariants: canonical `data/zolai.db` only (no `*_import` staging), additive writes (UPDATE + audit row, NO deletes), secrets untouched, Conventional Commits, ruff clean.
- Single ZVS source: import `zolai/zvs/rules_data.py` + `zolai.zvs.validate()` — no forked forbidden-form table.

## 1. Audit first (read-only)
`zolai corpus audit [--report PATH]` scans the column registry; per table×column defect counts: forbidden forms (modern tables empty registry; Bible Tedim cols `context="scripture"` so historical/phrases suppress), `suah` conflict hits, HTML entities/tags, whitespace, uppercase in word fields, word-field `[a-z-]+` sanity violations, JSON parse failures, exact-dup groups (GROUP BY ZO+EN HAVING>1). Writes `docs/reports/CORPUS_CLEAN_AUDIT_2026-10-01.md` with samples. Only tables with defects>0 enter apply.

## 2. Column inventory (verified via live PRAGMA + row probes)
| table | ZO columns (kind) |
|---|---|
| dictionary | `zolai` (word) |
| dictionary_en_zo | `translations`, `translations_clean` (JSON list) |
| bible_verses | `zo_tdb77`, `zo_tedim2010`, `zo_tedim1932` (sentence, scripture ctx); **`zo_hcl06`, `zo_fcl` = audit-only, NEVER written** |
| phrases | `zolai` (word), `examples` (JSON list, clean `"zo"` values only) |
| translations | direction-aware: `en_to_zo`→`target`, `zo_to_en`→`source` (sentence); `en→my` rows skipped |
| vocabulary | `headword` (word), `examples` (JSON) |
| word_usage | `word` (word), `co_occurring_words` (JSON) |
| training_exercises | `zolai` (sentence) |
| proverbs | `zolai` (sentence) |
| word_collocations | `word1`, `word2` (word) |
| zolai_vocabulary | `zolai` (word), `example_zo` (sentence) |
| zolai_bible_analysis | `zolai` (sentence) |
| zolai_word_usage | `word` (word), `contexts` (JSON) |
| zolai_grammar_patterns | `zolai_example` (sentence) — `pattern`/`structure`/`pattern_text` labels excluded |
| zolai_proverbs_idioms | `zolai` (sentence) |

Excluded (documented in report): `*_import` staging (26), EN cols, MY cols, `grammar_patterns` (no ZO prose col), `articles`/`wiki_lessons` (mixed-lang → "in doubt" left alone), label cols.

## 3. Cleaning rules (`clean_value(text, kind, bible_ctx)`), ordered, idempotent
- HTML tag strip `<[^>]+>` → space; `html.unescape` to fixed point (max 3 iters).
- Whitespace: word = collapse+strip; sentence = collapse non-newline whitespace (incl. nbsp)+strip edges. No lowercasing of sentences (sentence-initial caps are correct ZO style).
- ZVS: `zolai.zvs.validate()` violations → apply `preferred` right-to-left, non-overlapping, case-preserving ("Pathian"→"Pasian"). Modern tables = empty registry (pathian/fapa/bawipa/siangpahrang/cu/cun DO get normalized); Bible Tedim cols = default exceptions (source-faithful historical forms preserved).
- **`suah` = review-needs, NEVER rewritten** (rules_data says →chuak, AGENTS says →suahtakna context-dependent — two canonical docs disagree; needs-founder). `nunnak→nuntakna` auto (docs+rules_data agree).
- **Bible `zo_hcl06`/`zo_fcl` never written**: Hakha/Falam versions — converting to Tedim ZVS would falsify parallel versions (2026-09-13 precedent).
- Word-field sanity: after clean `^[a-z][a-z-]*$` else count as review-needs, no change (e.g. `100 cing` — stripping could change headword identity = needs-founder).
- JSON: parse → clean ZO string values (dicts: `zo` key only) → re-dump default separators; unparseable → review-needs.
- Dedupe = detect + count only (training_exercises 26,893 dup groups; bible_tdb77 624; dict/vocab 0) — DELETE is destructive → needs-founder. Row counts identical before/after (NO-drops proof).

## 4. Apply
`zolai corpus clean [--table T] [--apply]` (dry-run default). Per batch: `SELECT id > cursor ORDER BY id LIMIT 5000` → UPDATE changed cells + INSERT `data_audit_log` (`reason="corpus_clean_v1 by cli"` — actor in reason, mirroring record_review_router) in one transaction, commit, cursor → `data/.corpus_clean_state.json` for `--resume`. No `version`/`content_hash` bumps. Field-only UPDATE.

## 5. Report
Audit run → commit before apply; after apply re-run audit, append `## Apply results` (cells changed per table/defect class, audit-row count, row counts before==after, review_needs totals, dup groups, needs-founder list) → second commit.

## 6. Tests (`tests/test_corpus_clean.py`, tmp-DB fixture like `test_api_keys_migration.py`)
dry-run = 0 writes; apply = cells changed + audit rows exact; idempotent (2nd run → 0/0); EN/MY + staging byte-identical; entity/tag cases incl. `&amp;amp;` fixed-point; `nunnak` fixed / `suah` unchanged+counted; `zo_hcl06` untouched; direction-aware translations (en→my skipped); JSON stays parseable; word-sanity review-needs no-write; dedupe counts but row count unchanged; CLI smoke (typer.CliRunner: default dry-run, `--apply`).

## Files to touch
- `zolai-core/zolai/data/corpus_clean.py` — NEW (COLUMN_REGISTRY, clean_value, run_audit, clean_table batched/resume, report writer)
- `zolai-core/zolai/cli/main.py` — NEW `corpus_app` sub-app (`zolai corpus audit|clean`)
- `zolai-core/tests/test_corpus_clean.py` — NEW (~14 cases)
- `docs/reports/CORPUS_CLEAN_AUDIT_2026-10-01.md` — NEW (root): audit § + apply-results §

## Commits
1. `feat(data): corpus clean module + CLI (audit + dry-run/apply)` (zolai-core)
2. `test(data): corpus clean dry-run/apply/audit/idempotency` (zolai-core)
3. `docs(reports): corpus clean audit before (defect matrix)` (root, pre-apply evidence)
4. `docs(reports): corpus clean apply results + before/after counts` (root, post-apply)

## Risks / open questions
- Live apply mutates 2.3GB DB → gate = Phase-0 backup present (✅); recommend fresh `scripts/backup-zolai.sh` immediately before apply if writes landed since baseline.
- **needs-founder:** (a) suah target chuak vs suahtakna (no writes in C1); (b) dedupe DELETEs (counted only); (c) junk headwords; (d) fate of zo_hcl06/zo_fcl (audit quantifies). None block dry-run/audit/apply.
- ~2,800 suah cells + ~800 word-sanity cells stay untouched → report must say "cleaned ≠ zero defects, remainder is triage".

## Done when
- `zolai corpus audit` read-only + committed report with defect counts + samples + exclusions
- Live `--apply` → `data_audit_log` rows ≥ cells changed; per-table COUNT(*) identical before/after
- Second live `--apply` → 0 new audit rows (idempotent); same asserted in tests
- All 7 mandated test categories pass; full suite green; ruff clean; both report commits landed
- Complexity: M
