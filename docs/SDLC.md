---
title: "Zolai-AI SDLC — 7 stages, ordered workflow, exit tokens"
description: "Canonical engineering lifecycle; mirrors pcore-orchestra's 7-stage route without inventing new gates"
created: 2026-11-24
last_reviewed: 2026-11-24
status: CONFIRMED
canonical_source: true
owner: workspace-governance
---

# Zolai-AI SDLC (canonical)

This file is the workspace's canonical statement of the engineering lifecycle. It
reflects the installed **P-Core Orchestra** route; it does not add gates, rename
tokens, or supersede a repo's own invariants. Source citations are exact line
ranges so drift can be checked:

- `pcore-orchestra/context/ai-workflow-rules.md:24-26` — ordered improvement workflow.
- `bundle/agents/orchestra.md:280-290` — ordered improvement algorithm (all routes).
- `bundle/agents/orchestra.md:292-315` — 22-step 7-stage sequence.
- `bundle/agents/orchestra.md:321-327` — stage-to-agent token map.
- `bundle/agents/orchestra.md:329-338` — gate-failure and max-steps rules.

## 7 stages — strict order

| Order | Stage | Exit token |
|:----:|-------|------------|
| 1 | PLAN | `PLAN_READY` |
| 2 | DESIGN | `DESIGN_SIGNED_OFF` |
| 3 | BUILD | `BUILD_COMPLETE` |
| 4 | TEST | `TESTS_PASS` |
| 5 | REVIEW | `REVIEW_APPROVED` |
| 6 | DEPLOY | `DEPLOY_COMPLETE` |
| 7 | OPERATE | `OPERATE_STEADY_STATE` |

A stage is not complete until its exit token is reached. No stage may be skipped.
Entry tokens and approval gates are listed in the 22-step sequence below
(`bundle/agents/orchestra.md:321-327`).

## 22-step sequence (15 numbered steps + 7 completion lines)

Verbatim structure from `bundle/agents/orchestra.md:292-315`:

1. `task` → `ai-trigger` → issue readiness (requirement owners/evidence checked) → `ISSUE_READY`
2. `task` → `product-owner` → scope approval → `SCOPE_APPROVED`
3. `task` → `architect` → spec drafting (five-step decisions recorded) → `SPEC_DRAFTED`
   → **Stage 1 complete: `PLAN_READY`**
4. `task` → `architect` → spec refinement
5. `task` → `tech-lead` → design sign-off → `DESIGN_SIGNED_OFF`
   → **Stage 2 complete: `DESIGN_SIGNED_OFF`**
6. `task` → `coding-agent` → implementation → `CODE_READY`
7. `task` → `engineer` → PR approval → `PR_APPROVED`
   → **Stage 3 complete: `BUILD_COMPLETE`**
8. `task` → `qa-agent` → test writing/running → `TESTS_PASS` / `TESTS_FAIL`
9. `task` → `auto-retry` → retry loop → `TESTS_PASSING` (max 3 fix loops) / `TESTS_FAILED_MAX_RETRIES`
   → **Stage 4 complete: `TESTS_PASS`**
10. `task` → `review-agent` → first-pass PR review (verified ordered-step evidence) → `REVIEW_APPROVED` / `REVIEW_REJECTED`
    → **Stage 5 complete: `REVIEW_APPROVED`**
11. `task` → `release-agent` → flagged rollout → `ROLLOUT_COMPLETE` / `ROLLOUT_FAILED`
12. `task` → `release-manager` → prod approval → `RELEASE_APPROVED` / `RELEASE_REJECTED`
    → **Stage 6 complete: `DEPLOY_COMPLETE`**
13. `task` → `sre-agent` → SLO monitoring → `SLO_HEALTHY` / `SLO_DEGRADED` / `SLO_BREACHED`
14. `task` → `sre-agent-2` → incident escalation → `ESCALATION_HANDLED` / `ESCALATION_MISSED`
15. `task` → `on-call-engineer` → incident ownership → `INCIDENT_CLOSED` / `INCIDENT_ONGOING`
    → **Stage 7 complete: `OPERATE_STEADY_STATE`**

Completion lines (7): PLAN_READY · DESIGN_SIGNED_OFF · BUILD_COMPLETE ·
TESTS_PASS · REVIEW_APPROVED · DEPLOY_COMPLETE · OPERATE_STEADY_STATE.

## Gate failure and max steps

From `bundle/agents/orchestra.md:329-338`:

- On approval-gate failure (any stage): return to the previous stage with feedback;
  **max 3 fix loops per stage**, then escalate; **never skip a gate**.
- On max steps without an ending token: resume the same agent with its `sessionID`;
  **max 5 resumes per stage**, then escalate.

## Five-step algorithm — internal operating principle

Strict order, in every route and before build; confirmed at review. This is an
**internal operating principle of this workspace and P-Core Orchestra**, documented at
`pcore-orchestra/context/ai-workflow-rules.md:24-26` and
`bundle/agents/orchestra.md:280-290`. It is not attributed to any external person
or company; no such citation is claimed or required.

1. **Question requirements** — name the accountable person and cite source/evidence. An unknown owner is a clarification item, never invented authority.
2. **Delete unnecessary parts or processes** — require caller/dependency analysis, tests and rollback before removal. The 10% add-back idea is a retrospective heuristic, **not a deletion quota**.
3. **Simplify and optimize** — only what remains, measured against a baseline and reusing existing components.
4. **Accelerate cycle time** — shorten feedback loops only after steps 1–3, without skipping verification or approvals.
5. **Automate last** — only a proven, reversible process, with bounded authority, audit trail and rollback.

PLAN records the decisions; BUILD keeps the order and reports evidence; REVIEW checks
actual execution, not just the stated plan. Safety, security, legal duties, human
approval and required gates are never traded for speed.

## Reuse first

Before creating a document, component, tool, or service, check what already exists:
the canonical map ([`docs/governance/source-of-truth.md`](governance/source-of-truth.md)),
the root [`AGENTS.md`](../AGENTS.md), per-repo `AGENTS.md` / `README.md`, and the
architecture status ([`docs/architecture/status.md`](architecture/status.md)). Reuse
and extend first; record any new artifact with the evidence that it was necessary.
Frontend work reuses the existing shadcn/ui layer before considering any new
component kit; backend work reuses Python in `zolai-core` and the Hono routes in
`zolai-web` rather than adding a new server framework.
