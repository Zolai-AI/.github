---
title: "Zolai AI — Public vs Private Documentation"
description: "Boundary for publishable vs local-only records"
created: 2026-09-18
last_updated: 2026-09-18
status: CONFIRMED
---

# Public vs Private Documentation

## Public (may appear in README, website, grants, white paper)

- Mission, vision, research goals
- Technology overview (implemented vs planned labeled)
- Community / literacy goals (evidence-based language)
- Public roadmap (high level)
- Publications, datasets **where legally permitted**
- Contributor acknowledgements (with consent)
- Advisors by name/role when they consent to public listing

## Private (local / restricted — not for public marketing)

| Category | Location | Notes |
|----------|----------|-------|
| Undefined commercial arrangements | `docs/private/` (gitignored) | Negotiation details; not equity/ownership until formalized |
| Sensitive partner info | `docs/private/` | — |
| Unpublished grant strategy details | Prefer `docs/grants/` internal status; redact before public | Never invent eligibility |
| Credentials / secrets | Never in git | `.env`, keys, tokens |
| Unresolved ownership / IP questions | Private until decided | Record decision later in `decisions.md` without sensitive terms if public |

## Rules

1. Do **not** propagate informal commercial percentages into public README, website, white paper, or grant applications unless formally agreed and relevant.
2. Do **not** expose personal data of community participants without consent.
3. Prefer stubs in public trees that point to “internal governance (not published)” rather than deleting history.

## Private folder

`docs/private/` is **gitignored**. Create local files there for sensitive records. A tracked stub index may live at `docs/private/README.md` only if it contains no sensitive content (this repo gitignores the whole directory — keep a short note in this file instead).
