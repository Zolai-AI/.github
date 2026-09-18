---
title: "Data path aliases (post history scrub)"
status: CONFIRMED
created: 2026-09-18
---

# Data path aliases

Git history scrub removed third-party vendor strings from **code**. Local `data/online/` folders may still use legacy directory names on disk.

## Neutral aliases (use these in code)

| Alias (code) | Points to (local symlink) |
|--------------|---------------------------|
| `data/online/zolai-web-corpus` | `paumkim-corpus` |
| `data/online/zolai-extra-dictionary` | `dalsuum-zolai-dictionary` |

Create/update with:

```bash
cd data/online
ln -sfn paumkim-corpus zolai-web-corpus
ln -sfn dalsuum-zolai-dictionary zolai-extra-dictionary
```

Do **not** reintroduce scrubbed vendor names into committed source.
