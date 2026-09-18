---
title: "Agent model routing (Cursor + OpenCode)"
description: "Best model per role + fallback when limits hit (Auto / free-model chains)"
created: 2026-09-18
last_updated: 2026-09-18
status: CONFIRMED
---

# Agent Model Routing (Cursor + OpenCode)

Both **Cursor** and **OpenCode** are first-class tools in this org. Route models by environment.

## Cursor

Prefer the **Cursor Models** pool. On **usage limit / rate limit / model unavailable**, do **not** stop the task — fall through the chain below.

```text
Preferred model for role
        ↓ (limit / error / unavailable)
Auto (Cursor router)  ← default recovery
        ↓ (if Auto also fails or user wants explicit pick)
Next task-fit alternate in the table
        ↓
Parent / inherit agent continues the work
```

1. Detect limit messages (`out of usage`, `Increase limits`, model rejected, etc.).
2. **Immediately** retry with **Auto** (or omit explicit model / use `inherit`) — do not wait for quota reset mid-task.
3. If a specialist is still needed and Auto is weak for that step, try the **alternate** for that role.
4. Log which model actually ran in the batch report (`Preferred → Actual`).
5. Only after the fallback chain is exhausted: note `MODEL_FALLBACK_EXHAUSTED` and continue manually on the parent agent.

## Role → preferred → fallback

| Role / task | Preferred | Fallback 1 | Fallback 2 (alternate) | Avoid as default |
|-------------|-----------|------------|------------------------|------------------|
| Plan / Ask / explain | Composer 2.5 (standard) | **Auto** | inherit (parent) | Fast variants |
| Implement / edit docs & code | Composer 2.5 (standard) | **Auto** | inherit | Other Models pool |
| Hard architecture / long-horizon strategy QC | Grok 4.6 (high) | **Auto** | Composer 2.5 standard | Stop the job |
| Verify / lint / consistency | Composer 2.5 | **Auto** | inherit | Paid frontier unless stuck |
| Explore / file find | Explore (default) | **Auto** | generalPurpose + inherit | — |
| Rare “must be frontier” | — | — | Opus / GPT only if user asks | Daily default |

**Auto** = Cursor’s automatic model routing (use when preferred is limited or for mixed small tasks).

## Subagent `model` parameter (this workspace)

When spawning Task subagents, prefer:

| Intent | `model` value |
|--------|----------------|
| Default / implement | `inherit` (follows parent; recovers via Auto if parent is Auto) |
| Hard QC / architecture | `cursor-grok-4.6-high` → on failure retry **same prompt** with `inherit` or no model (Auto) |
| Fast explore only | omit model / explore default |

Do **not** burn Claude/GPT “Other Models” for routine docs unless the user explicitly requests them or Cursor/Auto selects them.

## OpenCode (separate)

Free-model chain only (`mimo-v2.5-free` → configured free fallbacks). Refresh/probe pools on error — same idea: never stall on one model.

## Session log

| Date | Preferred | Actual | Reason |
|------|-----------|--------|--------|
| 2026-09-18 | Grok 4.6 QC (Batch 2–3) | Parent Composer + manual QC | Usage limit → should have used Auto immediately |
| 2026-09-18 | (policy update) | — | Fallback-to-Auto rule added |
