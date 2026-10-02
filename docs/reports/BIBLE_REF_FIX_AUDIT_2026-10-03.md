---
title: "Bible Verse Reference Fix — Audit & Execution Report"
description: "Pre-fix audit, live apply, downstream remap and verification evidence for the bible_verses 31,649 → 31,102 reference fix"
created: 2026-10-03
last_updated: 2026-10-03
status: CONFIRMED
---

# Bible Verse Reference Fix — Audit & Execution Report

**Date:** 2026-10-03 · **Plan:** [`docs/planning/BIBLE_REF_FIX_PLAN.md`](../planning/BIBLE_REF_FIX_PLAN.md)
**Canonical DB:** `data/zolai.db` · **Scope:** `bible_verses` + downstream ref columns only
**Engine:** `zolai-core/zolai/data/bible_ref_fix.py` · **CLI:** `zolai bible-ref audit|fix|remap|revert`

---

## 1. Outcome (headline)

| Metric | Before | After |
|---|---|---|
| `bible_verses` rows | 31,649 | **31,102** (canonical verse count, all `ok`) |
| Impossible refs in canonical table | 547 | **0** |
| Rows in `bible_verses_archive` | 0 | **547** (full-row copies, revertible) |
| `word_alignments` rows on archived refs | 7,150 | **0** |
| `translations` rows on archived refs | 1,028 | **0** |
| Distinct invalid refs downstream | wa 528 / tr 529 | wa **0** / tr **2** (pre-existing pseudo-refs, not Bible refs) |
| `en_kJV` cells written | — | **0** (EN restore not needed — see §4) |
| ZO / label / other fields written | — | **0** |
| `PRAGMA integrity_check` | ok | **ok** |
| Duplicate `(book,chapter,verse)` triples | 0 | **0** |
| `data_audit_log` rows (all `bible_ref_fix%`) | 0 | **8,725** (547 ref changes + 8,178 downstream remaps) |

**Verified gates (plan lines 4 & 85):** `bible_verses = 31,102` and `0` impossible refs — both TRUE.

---

## 2. Root cause (measured)

- `31,649 = 31,102 canonical verses + 547 impossible refs` (e.g. `GEN 2:31`, `EXO 41:13`,
  `1CH 19:20`, `3JN 1:15` — chapters/verses that do not exist in any of the 66 books).
- Source of the bad rows: the markdown chapter-header **flush bug** in the upstream md source
  (chapter headers parsed as verse bodies) that fed the JSONL → DB import. The DB is now fixed;
  **the md source and `data/bible/parallel_corpus_v1.jsonl` still contain the bug** (§14).
- Downstream copies of those refs live in `word_alignments.ref` (7,150 rows / 528 distinct) and
  `translations.reference` (1,028 rows / 529 distinct). The extra 2 distinct `translations` refs
  (`news:chuuhtetnaing/...`, `parallel:archx64/...`) are **source-key pseudo-refs, not Bible refs**
  — pre-existing, out of scope, still present after the fix.

---

## 3. Phase 0 — read-only pre-fix audit

Command: `zolai bible-ref audit --json` (read-only, no writes).
Evidence: `/tmp/opencode/bible_ref_audit_pre.json` (generated `2026-10-02T21:01:43Z`).

| Class | Count |
|---|---|
| `ok` | 31,102 |
| `impossible_ref` | 547 |
| `en_needs_review` | 0 |
| `null_en` | 0 (all 19 NULL `en_kJV` rows sit **at impossible refs**, not at valid ones) |
| duplicate triples / ref-formula mismatches | 0 / 0 |
| target row count | 31,102 |

**Pair quality** (impossible row ↔ resolved canonical target, 545 resolvable pairs):

| Pair class | Count | Meaning |
|---|---|---|
| `both_ok` | 431 | doomed row EN and target EN both match KJV — nothing to fix |
| `target_only_ok` | 114 | **target** EN matches KJV; the defective EN (97 truncated + 17 NULL) sits on the **doomed row** and is archived with it |

**Needs-founder (pre-fix):** `unresolvable 2`, everything else 0
(`neither_ok_pairs`, `en_variants`, `null_en`, `parallel_candidates`, `restore_blocked_null_target`).

---

## 4. Plan-vs-measured deltas (calibration results)

| Plan predicted | Measured | Explanation |
|---|---|---|
| EN variants needing restore: **81** | **0** | The calibrated matcher tiers absorb verse+marginal-note editions (`extended`: KJV chars present in order, `≥0.90` coverage, longer-or-equal length; `fuzzy`: ratio `≥0.80`, both with `difflib.autojunk=False`). No valid-ref row needs an EN correction. |
| EN restores: **89** | **0** | All 545 resolvable targets already carry KJV-matching EN (431 `both_ok` + 114 `target_only_ok`). The broken ENs were on the doomed rows themselves → archived. `--fill-null-en` stayed OFF (founder gate). |
| NULL `en_kJV` at valid refs: (assumed ~19) | **0** | All 19 NULL EN rows are at impossible refs → archived, no fill needed. |
| Parallel candidates: **6** | **0** | No action either way; reported for honesty. |
| Downstream bad refs: **528 / 529** | **528 / 529** | **Exact match** to plan figures. |

**Matcher distribution on live data (valid-ref rows):** exact 17,702 · normalized 7,010 ·
extended 6,245 · fuzzy 145 = **31,102** (non-match **0**).

---

## 5. Archive content integrity — nothing unique was lost

Verified across **all 547 archived rows** (every ZO variant column checked against the canonical
table):

| Check | Result |
|---|---|
| rows with `zo_tdb77` byte-identical to their (chapter−1, verse) target | **532** |
| rows with empty `zo_tdb77` (content lives in other variant columns) | **12** — 0 rows are empty across *all* ZO columns |
| rows whose `zo_tdb77` matches a different canonical ref | **1** — `REV 12:18` (duplicates `REV 12:17`) |
| rows with no resolvable target | **2** — `3JN 1:15`, `1CH 19:20` |
| unique content in `zo_tedim2010` / `zo_tedim1932` / `myanmar` / `myanmar_judson` | **0** |
| unique content in `zo_hcl06` / `zo_fcl` | 2 / 3 — confined to the **3 rows below** |

**Downstream spot check (transcript-level):** 6/6 sampled `translations` remaps have EN-side
overlap 1.0 with the new target verse; sampled `word_alignments` rows land on valid refs with
their ZO token present in the target verse (gloss-style `english_word` values such as
`"be, is, was"` are dictionary glosses, not verse text — expected).

### The 3 rows that carry content only in the archive (needs-founder review)

| Row | Ref | Why the ref is impossible | What is only in the archive |
|---|---|---|---|
| 97 | `3JN 1:15` | 3 John has **14 verses** in the KJV/Textus Receptus (web-verified 2026-10-03; SBL critical text has 15) — our ground truth (`kjv_en.json`, `VERSE_COUNTS`) is 14 | TDB77 closing doxology *"Nangma tungah nopna om ta hen…"* + its `zo_hcl06` / `zo_fcl` counterparts. Canonical `3JN 1:14` carries only the first sentence (EN + ZO) |
| 546 | `1CH 19:20` | 1 Chronicles 19 has **19 verses** | `zo_fcl` only (`zo_tdb77`/`zo_tedim2010`/… empty); its TDB77 cell was already empty pre-fix |
| 547 | `REV 12:18` | our ground truth numbers Revelation 12 with **17 verses** — the KJV's 12:18 text (*"And he stood upon the sand of the sea"*) is folded into `REV 13:1` (*"And I stood upon the sand of the sea, and saw a beast rise up…"*) | `zo_hcl06` + `zo_fcl` only; its `zo_tdb77` is a duplicate of canonical `REV 12:17` |

All three are **preserved verbatim** in `bible_verses_archive` with `source_row_id`, so a founder
decision (re-attach under a corrected ref, merge into the neighbouring verse, or keep archived) is
a data-only operation — the engine will not do it automatically (hard rule: no ZO/label writes).

Ground-truth sanity: our KJV JSON totals **OT 23,145 + NT 7,957 = 31,102** (both exactly standard)
and Revelation = 404 verses — the per-chapter numbering nuance above is the only observed
divergence.

**Downstream impact of these rows:** **0** — `run_remap` reported
`unmapped_refs = ['1CH 19:20', '3JN 1:15']` with `unmapped: 0` in both downstream tables (nothing
referenced them), and `REV 12:18` rows were remapped to their resolved target.

---

## 6. Backup (before live apply)

`./scripts/backup-zolai.sh --verify` → `data/backups/zolai-2026-10-03_0349.db.gz` (**563 MB**),
restore-verified: `bible_verses = 31649`, `dictionary = 84490`, `vocabulary = 104906`,
`translations = 207623` → `OK` (see `data/backups/backup.log`).

---

## 7. Phase 1 — live apply

```
DRY-RUN  · actions 547/547 · would archive 547 · EN restores 0 · unresolvable 2 · exit 0
APPLY    · rows 31649 → 31102 · archived 547 · audit rows 547 · EN restored 0 · exit 0 (~46 s)
```

Post-apply verification (`zolai bible-ref audit --json`, evidence
`/tmp/opencode/bible_ref_audit_post2.json`):

- `db_rows 31102`, classes `ok 31102 / impossible 0 / en_needs_review 0 / null_en 0`
- `duplicate_ref_triples 0`, `ref_formula_mismatches 0`, distinct refs 31,102, `PRAGMA integrity_check = ok`
- `audit_reasons {'bible_ref_fix_v1 by cli': 547}` — **fields written: `ref` only** (0 × `en_kJV`, 0 × ZO)
- archive present with 547 rows

---

## 8. Phase 2 — downstream remap

```
DRY-RUN  · mapping 545 archived refs · word_alignments 7,150/385,120 · translations 1,028/207,623
APPLY    · word_alignments 7,150 · translations 1,028 · audit rows appended 8,178
```

Post-remap verification:

| Check | Result |
|---|---|
| rows still on archived refs | `word_alignments` **0** · `translations` **0** |
| distinct invalid refs left | `word_alignments` **0** · `translations` **2** (the `news:`/`parallel:` pseudo-refs) |
| `remap_rows` (pending) | **0 / 0** (was 7,150 / 1,028) |
| audit reason | `bible_ref_fix_v1: downstream_remap by cli` = **8,178** |
| audit fields | `ref` 7,697 · `reference` 1,028 (no text/ZO fields) |

Note: the apply scan reported `scanned 385,378` vs `385,120` static count — extra *visits* from
b-tree restructuring while updating the indexed `ref` column inside one transaction. The remapped
totals matched the dry-run exactly and the post-check shows 0 residual rows, so no double writes
(audit total is exactly 7,150 + 1,028).

---

## 9. Idempotency & revert path

| Re-run | Result |
|---|---|
| `fix --apply` (2nd time) | `actions 0 · archived 0 · audit_rows_written 0` · rows stay 31,102 |
| `remap --apply` (2nd time) | `remapped 0 · audit_rows_written 0` · `data_audit_log` stays **8,725** |
| `revert --apply` | restores archived ids/text **byte-identically** — test-asserted (`test_revert_restores_rows_byte_identically`); not run against live DB |

---

## 10. Evidence for the founder's GEN 1:2 sighting

The wrong ZO for `GEN 1:2` the founder saw is **test-fixture data, not DB data**:

- `zolai-core/tests/test_observation_pipeline.py:71` — fabricated `"Gam ka lak hi."`
- `zolai-core/tests/test_attestation_index.py:79` — same fabricated sentence

No `bible_verses` row carried it. Fixing those fixtures is a separate cleanup (not in plan scope).

---

## 11. Doc sweep — `31,649 → 31,102` (plan Phase 0)

**Updated (21 living files, 44 replacements):** `README.md`, `profile/README.md`,
`context/{architecture,MASTER_PLAN,project-overview,UPDATED_RESEARCH_SYNTHESIS,ZOLAI_KNOWLEDGE_BASE,MASTER_GRAMMAR_REFERENCE,WORKFLOW}.md`,
`docs/database/tables.md`, `docs/data/data-model.md`, `docs/architecture/{current-state,integrations}.md`,
`docs/research/methodology.md`, `docs/linguistics/POS_SPEC.md`, `docs/audit/phase0/dependency_map.md`,
`docs/strategy/{whitepaper,13-community-impact}.md`, `docs/reports/SOURCE_OF_TRUTH_MATRIX.md`,
`docs/reports/DATABASE_INTEGRITY_REPORT.md` (+ provenance note in its header),
`docs/planning/PHASE2_OBSERVATION_PLAN.md`.

**Intentionally left at 31,649 (still true or historical):**

- `context/DATA_MANAGEMENT_PLAN.md`, `context/ZOLAI_V2_CURRENT_STATE.md` — they count the
  **JSONL file** `data/bible/parallel_corpus_v1.jsonl`, which still has 31,649 rows (§14 follow-up).
- `docs/planning/BIBLE_REF_FIX_PLAN.md` — pre-fix diagnosis figures (status flipped to COMPLETE).
- Dated snapshots: `docs/audits/0x-*`, `docs/reports/CHATGPT_*`, `CORPUS_CLEAN_AUDIT_*`,
  `ECOSYSTEM_*`, `docs/strategy/01-strategic-audit.md`, old `context/progress-tracker.md` entries —
  they describe their as-of date; this report supersedes them for current counts.

**Grep clean:** no `31,649` remains in `zolai-core/{zolai,tests,eval}` or
`zolai-datasets/{scripts,tests}`.

---

## 12. Validation / test evidence

### 12.1 Regression caught by the full suite: untyped archive columns (found + fixed)

The first full run after the live apply returned `6 failed, 1621 passed, 201 errors` — all errors
the same exception:

```
sqlalchemy.exc.CompileError: Can't generate DDL for NullType();
    (in table 'bible_verses_archive', column 'id')
```

**Root cause:** the archive `CREATE TABLE` copied bare column *names* from `PRAGMA table_info`.
SQLite accepts untyped columns, but SQLAlchemy then reflects them as `NullType` and any
reflect + `create_all` path (`database.py`, `migrations.py`, `sync.py`) refuses to compile the DDL
— so **the live apply had broken every API/migration/sync startup** against `data/zolai.db`
(these are the 201 errors + 6 failures; they do **not** reproduce against a fresh DB).

**Fix (code):** `_archive_ddl()` now mirrors the source column definitions — declared type,
`NOT NULL`, `DEFAULT`, `PRIMARY KEY` — and parenthesizes defaults (SQLite rejects the bare
`DEFAULT datetime('now')` form that `PRAGMA` reports, accepting only `DEFAULT (datetime('now'))`).

**Fix (live data):** the already-created archive table was rebuilt in place — rename → recreate
typed via the fixed production `_ensure_archive_table()` → copy back → **byte-identical sha256
(`db6b1536788a97bc…`, 547 rows)** → drop the untyped copy → re-verify (`PRAGMA integrity_check
ok`, indexes restored, reflect+compile OK). No canonical data touched; the one-off repair script
is intentionally *not* part of the engine so `bible_ref_fix.py` keeps its source-scan guarantee
(`no ALTER TABLE / DROP TABLE` — asserted by `test_archive_ddl_is_create_only_and_additive`).

**Guard:** `test_archive_columns_declare_types_so_sqlalchemy_can_compile` asserts every archive
column type equals the source type and that a reflected `CreateTable(...).compile(engine)` succeeds.

### 12.2 Gates

| Gate | Result |
|---|---|
| `ruff check zolai tests` (zolai-core) | clean |
| `pytest tests/test_bible_ref_fix.py` | **28 passed** |
| re-run of the 7 previously failing files (`test_foundation_migrations`, `test_phase_d_integration`, `test_sync`, `test_contracts_migrations`, `test_cost_tracking`, `test_database`, `test_word_engine_api`) | **148 passed, 6 skipped, 0 failed, 0 errors** |
| zolai-core full suite (`pytest -q`) | **1825 passed, 0 failed, 8 skipped, 1 xfailed** (exit 0; gate ≥1716) |
| zolai-datasets suite | **86 passed / 5 failed** — the same 5 failures reproduce on HEAD without my changes (baseline verified by stash); plus a pre-existing `tests/test_export_utils.py` collection error (`ModuleNotFoundError: scripts.export_utils`) |
| `pytest tests/test_bible_ref_guard.py` (datasets, guard) | **23 passed** |
| pre-existing ruff in datasets builder | 5 × `RUF012` — identical at HEAD (not introduced here) |
| live DB untyped-column sweep | only the pre-existing FTS5 virtual tables remain (already filtered by `database.py`); `bible_verses_archive` fully typed |

---

## 13. Commits

| Repo | SHA | Message |
|---|---|---|
| root | `2161d41` | `docs(plan): bible ref fix plan` |
| zolai-core | `ac866bb` | `feat(data): bible ref audit/fix/revert engine + CLI` |
| zolai-core | `68228a6` | `fix(data): count archived refs as pending downstream remap` |
| zolai-core | `f4cab32` | `fix(data): declare bible_verses_archive column types for SQLAlchemy` |
| zolai-datasets | `60b1f73` | `fix(bible): reject impossible verse refs at build time` |
| root | `45490bd` | `docs(data): bible_verses count 31,649 → 31,102 after bible-ref fix` |
| root | (this commit) | `docs(bible-ref): audit report, plan COMPLETE, tracker` |

Deviations from the plan's commit list: Phase 2 shipped atomically inside commit 2 (its own
dedicated commit, plan line 73, was not made — the remap had already run by then); one extra
zolai-core fix commit (`f4cab32`) for the §12.1 regression; doc sweep split into its own root
commit. **zolai-core and zolai-datasets were pushed to `origin/main` after the gates passed.**

---

## 14. Follow-ups / needs-founder

1. **JSONL source still stale** — `data/bible/parallel_corpus_v1.jsonl` (31,649 rows) and the md
   source keep the chapter-header flush bug. Regeneration now **refuses** (build-time guard,
   `60b1f73`) until the source parser is fixed. Re-run `fix` against a rebuilt import, or
   regenerate the JSONL from the fixed DB.
2. **`zolai-landing/src/components/Credits.tsx:7`** still says "31,649 parallel EN/ZO/MY verses"
   (separate repo, needs its own commit + Pages deploy).
3. **150,965 non-verse rows in `translations`** (`news:`/`parallel:` source keys, 2 distinct refs)
   — separate cleanup decision.
4. **GEN 1:2 test fixtures** (§10) — cosmetic test-data cleanup, not DB data.
5. Standing queue: nightly backup cron, `ZOLAI_API_AUTH=enforce` flip, validator IGNORECASE vs
   titlecase `Ram` (C1 residuals).
