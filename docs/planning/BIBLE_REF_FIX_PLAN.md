# Bible Verse Ref Fix Plan (C2-style data correction)

Status: PLANNED · 2026-10-03 · Repo: zolai-core + zolai-datasets · Source: orchestra-planner PLAN_READY
Founder decisions: **Archive + remove** (bible_verses → 31,102) · GEN 1:2 wrong-ref sighting was **in a test** (trace test fixtures).

## Goal
Audit and correct impossible Bible `ref`s in `bible_verses` (+ downstream copies) so every
row carries a real 66-book verse reference — no invented text, no ZO rewrites.

## Diagnosis (read-only evidence, planner session)
Schema: 18 cols — ref, book, chapter, verse, zo_tdb77, zo_tedim2010, **en_kJV**, myanmar,
zo_tedim1932, zo_hcl06, zo_fcl, myanmar_judson, book_name, version, …
Ground truth: public-domain KJV JSON (66 books, 31,102 verses), thiagobodruk/bible.

| Finding | Count |
|---|---|
| Rows / duplicate (book,chapter,verse) / ref-formula mismatches | 31,649 / 0 / 0 |
| KJV refs missing from bible_verses (JOL↔JOE mapped) | 0 |
| **Impossible refs** (e.g. GEN 2:31, 1CO 16:58, 1CH 3:55) | **547** |
| EN matches own-ref KJV (exact + normalized + fuzzy) | 31,015 |
| Fuzzy says EN belongs to another ref | 437 → 431 impossible + 6 valid FP (parallel passages) |
| Impossible rows resolving to (book, chapter-1, verse) w/ target present | 545 / 547 (2 unresolved) |
| Pair quality: both OK 279 · dup-only OK 89 · target-only OK 133 · neither OK 44 | 545 |
| Target row lacks any cell the dup row has | 0 (archive loses nothing) |
| EN-quality at valid refs: 81 variants + 19 NULL en_kJV | 100 → needs-founder |
| data_audit_log bible_verses: C1 926, c1_1 22, Phase2-dedup 533, integrate 5 | no prior ref cycle |
| Downstream bad refs | word_alignments.ref 528, translations.reference 529 |
| Root cause | data/bible/parallel_corpus_v1.jsonl (545 invalid refs) ← bible_knowledge_builder.py::build_from_markdown emits md markers verbatim |
| Founder GEN 1:2 example | correct in DB all columns; "Gam a lak" absent from workspace → sighting was **in a test** |

**Classes:** (a) 547 impossible refs = chapter-final verse re-labeled → dup rows (auto-fix);
(b) 89 target rows w/ defective EN repairable by copying dup's KJV-matching EN;
(c) 100 EN-quality rows (valid ref) → founder; (d) 6 FP → no action; (e) downstream 528/529.

## Approach
1. **Phase 0 (read-only):** md root cause line; grep consumers/tests citing 31,649; locate the
   test fixture the founder saw (search for GEN 1:2 + suspicious text in tests) → report.
2. **Ground truth:** `data/reference/kjv_en.json` (gitignored, fetched once, provenance in
   report) + committed 66-book verse-count table `zolai/data/verse_counts.py` (offline
   structural validity; text-repair degrades to audit-only when JSON absent).
3. **`zolai bible-ref audit [--report|--json]`** (read-only): classify every row
   `ok | impossible_ref | en_needs_review | null_en`.
4. **`zolai bible-ref fix [--apply]`** (dry-run default), per impossible ref:
   (i) resolve target (chapter-1, verse); (ii) if dup EN matches KJV@target and target EN
   doesn't → copy EN to target (`reason=bible_ref_fix_v1: kjv_verified_en_restore`);
   (iii) full-row **copy into `bible_verses_archive`** (additive DDL: 18 cols +
   source_row_id, archive_reason, archived_at), audit row (field=ref,
   old→`ARCHIVED:<ref>`), then DELETE from canonical — lossless/revertible;
   (iv) refuse any write creating duplicate ref. **No ZO/label writes anywhere.**
5. **Phase 2 (separate commit):** remap word_alignments.ref + translations.reference
   archived→target (audit-logged); only after Phase 1 verify passes.
6. **needs-founder (report only, never auto):** 44 neither-EN-matches pairs; 2 unresolvable;
   81 valid-ref EN variants; 19 NULL en_kJV (off-by-default `--fill-null-en`); 6 parallel-passage
   rows; GEN 1:2 test-fixture trace result.
7. **`zolai bible-ref revert [--apply]`:** reinsert archived rows by source_row_id, reverse
   EN restores, audit `bible_ref_fix_revert by cli` (mirrors revert-c1).
8. **Pipeline guard:** bible_knowledge_builder validates refs against verse_counts; fails
   build on impossible refs (test).

## Files to touch
- `zolai-core/zolai/data/bible_ref_fix.py`* — audit/fix/revert engine (mirrors corpus_clean.py)
- `zolai-core/zolai/data/verse_counts.py`* — committed KJV structural table
- `zolai-core/zolai/cli/main.py` — `zolai bible-ref audit|fix|revert`
- `zolai-core/tests/test_bible_ref_fix.py`* — dry-run/apply/idempotency/archive/revert/guards
- `zolai-datasets/scripts/bible/bible_knowledge_builder.py` — ref validation guard
- `data/reference/kjv_en.json`* (gitignored) · fresh pre-apply backup
- root: this plan, `docs/reports/BIBLE_REF_FIX_AUDIT_2026-10-03.md`*, tracker

## Commits
1. root: `docs(plan): bible ref fix plan`
2. zolai-core: `feat(data): bible ref audit/fix/revert engine + CLI` (code+tests atomic)
3. zolai-datasets: `fix(bible): reject impossible verse refs at build time`
4. Phase 2 downstream remap = own commit after Phase 1 verify
5. root: report + tracker
- `--apply` runs only after report delivered; fresh backup first.

## Risks
- Row count 31,649 → 31,102: grep docs/tests/eval citing 31,649 and update (Phase 0).
- KJV edition diffs explain 81 mismatches — text never rewritten to "match" KJV.
- DELETE breaks no-DELETE precedent → mitigated by lossless archive + revert; mark-only
  alternative rejected by founder (archive+remove chosen).
- Confirm no FKs reference bible_verses before apply.

## Done-when
1. audit after fix --apply: 0 impossible, 0 duplicate, all refs ∈ verse table, count 31,102.
2. Every write audited (reason `bible_ref_fix_v1 by cli`); archive count == archived rows;
   fix twice → 0 new audit rows (idempotent).
3. revert --apply restores ids/text byte-identically (test-asserted).
4. Tests green (new suite + full ≥1716), ruff clean; builder refuses impossible ref (test).
5. Report + needs-founder list delivered; Phase 2 shipped or explicitly deferred.
