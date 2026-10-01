# PLAN: Zolai Backend Core v1 — PLAN_READY (orchestra-planner)

Phases (execution order): P0 backup baseline (S, FIRST, blocks data phases) → P1 /api/v1 core+review/public (L) → P2 engine contract harness (M, ∥P1) → P3 light training tokenizer+CRF POS+ngram (M, NO translation) → P4 L1.4/L1.5/L2 waves (M, ∥P3) → P5 deploy+domain+public (L, LAST; prep ∥ earlier).

## P0 — Backup + checksum baseline (S)
Run scripts/backup-zolai.sh --verify; baseline sha256 + per-table counts; reconcile docs/database/tables.md (G14: 101→105 tables, import_log vs jsonl_import_log, staging 1.52M). Artifacts: data/backups/baseline-*. Files: backup script, tables.md. Commits: chore(data): record Phase 0 backup baseline. needs-founder: cron install.

## P1 — /api/v1 core surface + review/public data (L)
BUILD now: GET /api/v1/lexicon/{word}, /lexicon/search?q= (dict + dict_en_zo, cursor pagination, Cache-Control public); POST /api/v1/linguistics/{pos,syllable} + alias foundation analysis/search under /linguistics/*; GET /api/v1/predictions/{next,complete,corrections} (mount prediction_api on MAIN app); GET /api/v1/records?table=&q= (whitelist: dictionary,bible_verses,grammar_patterns,phrases,vocabulary, read-only); GET /api/v1/audit?table=&row_id= (data_audit_log); PATCH /api/v1/review/records/{table}/{id} correct → audit + review_status. LATER (doc-mark): sources,datasets,quality,pipelines,catalog,rag,imports,admin users.
Files: zolai/api/{lexicon_router,word_engine_router,records_router,record_review_router}.py + server.py mounts + api-design.md BUILD-now column. Tests: test_lexicon_api, test_word_engine_api, test_records_api, test_review_records_api; suite ≥1383.
Commits: docs(api): mark v1 BUILD-now vs later → feat(api): lexicon + records/audit read routes → feat(api): word-engine routes + record correction → test(api): v1 resource suites.

## P2 — Engine contract harness + API smoke (M)
Registry zolai/engines.py (~14 engines: dictionary lookup, translation fallback(deprio), syllable, morphology, phonology/tone, POS normalize + rule tagger, ZVS/grammar, corpus ngram, prediction ngram, polysemy, attestation, online search, tokenizer, context validator) w/ invariants (ZVS determinism, no-network). Parametrized contract tests + tests/test_api_smoke.py. Defects → xfail(reason) + docs/linguistics/ENGINE_FINDINGS.md (NO behavior changes here).
Commits: feat(engines): registry → test(engines): contract+smoke → docs(engines): findings.

## P3 — Light training, NO translation (M)
Tokenizer: SP BPE/Unigram trainer (patterns: zolai/syllable/tokenizer_training.py; new zolai/tokenizer/train.py + `zolai-train tokenizer` CLI) on bible_verses/translations text → data/tokenizer/zolai_spm_v1.model (gitignored) + manifest (sha256,vocab,rows) IN git; eval = UNK/coverage/roundtrip vs whitespace baseline → eval_runs. CRF POS baseline (L1.7): zolai/pos_tagger/train.py sklearn-crfsuite, silver labels from dict POS + closed classes, macro-F1 → eval_runs (gold tiny = needs-speakers). ngram/lm-lite eval-only (knowledge/ngram next-word top-k held-out). OUT: translation, MarianMT, LoRA, RAG changes. Tests: test_train_smoke (tiny-corpus CI), test_tokenizer (artifact check).
Commits: feat(tokenizer): SP trainer + manifest → feat(pos): CRF baseline trainer → test(train): smoke + eval metrics.

## P4 — L1.4/L1.5/L2 (M)
L1.4: docs/linguistics/ANNOTATION_GUIDE_POS.md + JSONL schema (sentence_id,tokens[{text,lemma,pos,features}]) + validator test. L1.5: zolai/pos_tagger/annotate.py CLI (suggest→review→write, no UI). L2: DECIDE foundation/morphology.py vs new zolai/morphology/ ownership first (extend-not-duplicate); compound splitter vs zolai_vocabulary; SYLLABLE_SPEC.md. No DB schema change (L1.3 cols exist).
Commits: docs(linguistics): POS annotation format v0.1 → feat(pos): annotation CLI scaffold → feat(morphology): analyzer + compound splitter.

## P5 — Deploy + domain + public (L, LAST)
Smallest stack: one VPS, compose with API ONLY (drop Redis), api 127.0.0.1:8001, host nginx vhost api.zolai.space → Cloudflare proxied DNS (Full strict + Origin Cert), --workers 2, data/ volume, monitoring internal-only. Security: nginx allowlist public = /api/v1/* (key-gated) + safe legacy GETs + /health; DENY all legacy mutations (POST /crawl /clean /chat/* /settings /dictionary/add /learning/*, /desktop/jsonl/*) + DENY /metrics /api/metrics*; limit_req anonymous. Base-only API image (no torch).
Steps: P0 baseline → provision → build → up → smoke (200 w/key, 401 enforce, 429, legacy POST 403, /metrics blocked) → issue consumer keys (mcp ZOLAI_CORE_URL, tauri, scripts) → FOUNDER GATE flip ZOLAI_API_AUTH=enforce → CF cache rules → rollback drill.
Files: deploy/{nginx.conf,.env.production.example,deploy.sh}, docs/DEPLOYMENT.md runbook, docker-compose.prod.yml cleanup, optional workflow_dispatch deploy job (model zolai-web).
Commits: chore(deploy): compose+nginx stack → docs(deploy): runbook+rollback → chore(env): .env.production.example.
needs-founder: server SSH/IP+specs, CF DNS control, enforce flip, backup cron, ZOLAI_CORE_URL secret.

## Risks/unknowns
Legacy-mutation consumers unknown (block at proxy); POS/morph gold needs speakers; morphology ownership P4 decision; prediction_api move to main app = public surface change (document).
## Done when
P1 routes live+tested w/ audit; P2 registry+green suites+findings; P3 artifacts reproducible+eval_runs+no translation; P4 landed; P5 public reads with keys+enforce+metrics/mutations blocked+rollback; P0 baseline+drill. Complexity: S,L,M,M,M,L.

---

# PLAN REVISION R1 (2026-10-01) — founder directives (authoritative over original sections where they conflict)

## D1. Deployment = pcore-server + Docker (replaces original P5 target)
- **Host:** `pcore-server` SSH alias → 54.251.217.180 (Lightsail, ap-southeast-1, ubuntu, LightsailDefaultKey-ap-southeast-1.pem). Ubuntu 24.04.5, 2 vCPU, 7.6GB RAM (≈3.8 free), 154GB disk (100GB free), **Docker 29.8.1 + Compose v5.5.1 preinstalled**.
- Docker is the **recommended deployment method**: prod compose (SQLite stays canonical until founder-gated PG cutover; container mounts data/ volume read-write for WAL, read-only for code image layers), nginx/Caddy TLS reverse proxy, healthchecks, restart policies, log rotation. Existing `Dockerfile` + `docker-compose.prod.yml` + `ops/` (Prometheus/Grafana) reused/extended — monitoring stack runs on pcore-server too (fits RAM budget: API + metrics + Grafana ≈ well under 4GB).
- Domain: api.zolai.space (or subdomain the founder prefers) → Cloudflare DNS → pcore-server. Public data + review endpoints exposed; metrics/auth admin stay internal (existing P5 posture unchanged).
- Phase 0 backup baseline MUST exist on the server too (rsync backup dir + sha256 before go-live); backup cron still needs-founder.

## D2. Engine: works WITH and WITHOUT AI; data-driven — NO hardcoded tags/headwords/sentences
- Every learned artifact (POS tags, syllable compounds, collocations, phrase patterns, n-gram successors/predecessors) must be **derived from DB tables + trained artifacts**, never Python dict/set literals of words/tags. Sweep for hardcode: any `{word: tag}` style literal or `KNOWN_WORDS = {...}` constant in engine paths → replace with DB/config-table lookup + versioned artifact load (JSON/pickle/ONNX in `data/artifacts/`, rebuildable via CLI).
- **With-AI / without-AI modes:** `ZOLAI_ENGINE_MODE=rule|hybrid|ai` — `rule` (offline, no network, deterministic: ngram+CRF+pattern engine), `hybrid` (local first, optional AI enrichment async), `ai` (LLM call when key present). Same public contract for all modes; engine router exposes `mode` in health metadata. AI optional = absence of key must never break endpoints (warn-mode precedent).

## D3. Corpus cleaning + usage-pattern learning + flash-train small model (new phases before P5)
- **C1 Corpus clean:** audit + clean ALL Zolai words & sentences (dictionary, dictionary_en_zo, bible_verses, phrases, translations, vocabulary, word_usage, training_exercises, proverbs...) — ZVS-2018 normalization (forbidden forms pathian/ram/fapa/bawipa/siangpahrang/cu-cun → canonical), dedupe, case/whitespace/HTML-entity strip (patterns proven in 2026-09-13 dictionary cleaning), language-ID sanity (ZO fields `[a-z-]+`). **Save to each table correctly** = in-place UPDATE with `data_audit_log` rows (old→new, batch reason) — additive/reviewable, NO drops; `*_import` staging where in doubt + promote with audit. Deliver cleaning report + counts before/after per table.
- **C2 Usage-pattern learning:** mine per-word context features into proper tables: predecessor/successor n-grams (n=1..4) with counts+probabilities, collocations (PMI, expand word_collocations 5,000 rows), phrase patterns (multiword expressions beyond phrases 10,722), order patterns (SOV/ergative attestations per frame). Research online (websearch primary sources: statistical collocation methods, n-gram LM for morphologically-rich SOV languages, KenLM/sentencepiece practices for low-resource) before choosing estimators (additive smoothing/backoff). No hardcoded pattern lists — all rows derived from corpus.
- **C3 Flash-train small model:** lightweight trainable artifact — candidate stack (verify latest stable): sentencepiece unigram/BPE tokenizer (small vocab ~8-16k) on cleaned corpus; CRF/linear-chain POS tagger (sklearn-crfsuite in base deps) on auto-labeled + any gold data; interpolated n-gram LM (KenLM or pure-Python backoff) for predictions/next replacing hardcoded backoff; all exported to `data/artifacts/` with metadata JSON (corpus hash, params, metrics). Training = `zolai train` CLI (CPU minutes, fits 2 vCPU server — local training primary, server inference). NO translation model (master prompt §1).
- Engine consumes C2 tables + C3 artifacts at runtime (replaces hardcoded tags/headwords/sentences — D2 enforcement point). Eval harness (eval_v1) extended: POS tag-accuracy on held-out auto+gold slice, next-token top-k acc, perplexity — gate improvements vs baseline.

## Revised phase order
P0 ✅ · P1 ✅ · P2 ✅ · **C1 corpus clean** · **C2 usage-pattern mining** · **C3 flash-train** · P3 (light training — folded into C3 where natural) · P4 (L1.4/L1.5 gold + L2 morphology — overlaps C2/C3) · **P5 deploy to pcore-server via Docker + domain + public access** (LAST, after engine upgrades so server ships the new engine).
