---
title: "Post–docs-OS recommendations & remaining prompt gaps"
status: UNDER REVIEW
created: 2026-09-18
last_updated: 2026-09-18
---

# Recommended next work (after Docs OS v2.4)

Derived from Master Restructuring Prompt close-out + peer research pass + CI/data pass.  
Evidence-first: do not mark OKRs done without links in `docs/reports/`.

## Completed this research + ops pass

| Item | Artifact |
|------|----------|
| Peer communities deep compare | `docs/research/peer-language-communities.md` |
| CREDITS → license inventory | `docs/governance/credits-license-inventory.md` |
| NatGeo / LINGUA official checks | `docs/grants/opportunities.md` |
| FineWeb2 / HPLT annotated notes | `docs/research/papers/fineweb2.md`, `hplt-v2.md` |
| Local pytest green | **1010 passed**, 5 skipped (`zolai-core`) |
| Org lint scoped to `scripts/` | `.github/workflows/lint.yml` + `ruff.toml` |
| Core ruff CI path | `zolai-core` `pyproject.toml` per-file-ignores |
| Datasets CI manifests | `zolai-datasets/data/{DATASET,ARCHIVE}_MANIFEST.json` + `DATA_INDEX.md` |
| Web monitor CF/landing fix | `zolai-web` monitor/deploy — `zolai.space` is landing, not Next cron |
| Annotation brief draft | `docs/community/annotation-brief.md` |
| Whitepaper related-work scrub | VERIFIED URLs only |
| Profile license honesty | code MIT vs data RESTRICTED |
| Benchmarks stub → v0 task table | `docs/research/benchmarks.md` |
| Data path aliases | `docs/governance/data-path-aliases.md` |

## Remaining gaps (priority)

| # | Gap | Why | Recommended action |
|---|-----|-----|--------------------|
| 1 | KR2.1 tests | **CLOSED locally** — push/monitor `zolai-core` CI | Keep MetaData FTS scrub; green Actions |
| 2 | Bible/dict permissions | Inventory S1–S3 RESTRICTED | Founder review → `permission-outreach.md` |
| 3 | KR1.4 Masakhane membership | Still open | Join Slack/GitHub; intro post; screenshot evidence |
| 4 | KR3.2 benchmarks | Task table only | Implement gold JSONL under `data/eval/` |
| 5 | Advisor / Grok QC of docs OS | Reviewer pending | Founder review of SoT + commercial stub |
| 6 | Whitepaper citation scrub | **Related work scrubbed** | Full biblio pass vs literature-review VERIFIED rows |
| 7 | Profile/README license honesty | **Updated** | Keep in sync when CREDITS change |
| 8 | AmericasNLP 2026 paper | Track record gap | Confirm CFP geo fit; draft from outline |
| 9 | Data-governance CARE mapping | Policy UNDER REVIEW | Founder sign-off |
| 10 | Private commercial arrangement | Undefined for funders | Keep private; disclose when applying |
| 11 | CF Bot Fight vs monitors | Landing 403 to curl | Optional: WAF skip for `/health` or set `APP_HEALTH_URL` |
| 12 | Next app public URL | Monitor skips Next cron | Set `APP_HEALTH_URL` secret when VPS/public URL known |

## Prompt / Docs OS hygiene

- Keep master prompt gitignored under `docs/prompts/` — execute via audited public docs only  
- Continue evidence notes in `docs/reports/` per OKR change  
- Anti-stop: finish auto-continue queue before pausing mid-goal  

## Do not

- Apply LINGUA Europe/Africa or Enduring Voices as Zolai funding  
- Cite UNKNOWN literature rows in grants  
- Point health monitors at `https://zolai.space/api/cron/*` (landing has no Next routes)
