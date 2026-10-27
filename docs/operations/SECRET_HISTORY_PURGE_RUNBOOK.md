# Secret History Purge Runbook — F1 (Gmail app password) & F2 (Kaggle API token)

**Status: PREPARED ONLY. Nothing in this document has been executed.**
Prepared 2026-10-27 from read-only inspection (`git log -G`, `git grep`, `git cat-file`,
`git fsck`, `gh api`, SSH read-only path checks). No `git filter-repo`, no `git gc`,
no `git reflog expire`, no force-push, no rotation, no deletion was run while writing this.

**Rule for every reader of this file:** no full credential value appears here, ever.
Identifiers are masked:

| ID | Secret | Shape | Mask |
|----|--------|-------|------|
| **F1** | Gmail app password used as `SMTP_PASS` | lowercase alnum (audit: 16; see note) | `civiyk…kcbq` |
| **F2** | Kaggle API token (`KAGGLE_API_TOKEN`) | `KGAT_` + 32 lowercase hex = 37 chars | `KGAT_cb3a6c…5287` |

> **Note on F1 length:** the literal observed in the dangling blobs measures 15 chars in the
> inspected lines, while the audit records 16. Do **not** build match patterns with a fixed
> length. Always use the prefix/suffix form `civiyk[A-Za-z0-9]+kcbq`.

---

## 0. Where each credential actually is (measured 2026-10-27)

### F1 — Gmail app password (`SMTP_PASS`) — `civiyk…kcbq`

| Surface | Status | Evidence |
|---|---|---|
| `Zolai-AI/.github` dangling commits **`6451a24`, `dd67d87`, `44be0c2`** (pushed 2026-10-07) | **LIVE, publicly fetchable by SHA** | `gh api repos/Zolai-AI/.github/commits/6451a24` → 200; files: `context/architecture.md`, `context/code-standards.md`, `docs/architecture/CIRCUIT_BREAKER.md`, `docs/architecture/NOTIFICATIONS.md`, `docs/operations/DEPLOY_RUNBOOK.md`, `docs/planning/AI_AGENTS_RBAC_PLAN.md`, `docs/planning/COMPLETION_PLAN.md` (+ `context/progress-tracker.md` for `dd67d87`/`44be0c2`) |
| `Zolai-AI/.github` `origin/main` **and** all local refs | **CLEAN** | `git log --all -G'civiyk[A-Za-z0-9]+kcbq'` → 0 hits; `git grep -E … origin/main` → 0 hits; none of the 3 SHAs is an ancestor of `main` |
| Local reflog-reachable objects (root repo) | **5 blob paths in 3 reflog-reachable commits** | `context/code-standards.md`, `context/progress-tracker.md`, `docs/architecture/NOTIFICATIONS.md`, `docs/operations/DEPLOY_RUNBOOK.md`, `docs/planning/AI_AGENTS_RBAC_PLAN.md`; repo has **21 unreachable commits** total |
| Other 12 workspace repos (HEAD + history) | **CLEAN** | `-G` scan of every clone returned 0 |
| Tracked env templates (`.env.production.template`, `.env.example`, `.env.production.example`) | **CLEAN** (0 literal matches) | boolean scan |
| GitHub code search | **0 relevant hits** (9 hits, all unrelated third-party repos) | `gh api search/code -f q='civiyk kcbq'` |
| Server `pcore-server` consumers | **`.env.dev` (live), `.env.production`, 2× `.env.production.bak-*`, `.env.production.example`** | read-only `grep -rl SMTP_PASS /home/ubuntu/zolai-core/.env*` |
| GitHub Actions secrets | **none** (no repo secrets, no `secrets.*` refs in workflows) | `gh secret list -R …` empty; only `lint.yml` (root) and `ci.yml`/`eval-smoke.yml` (core) |

### F2 — Kaggle API token — `KGAT_cb3a6c…5287`

| Surface | Status | Evidence |
|---|---|---|
| **`Zolai-AI/zolai-core` `origin/main`** (tip `9ad5e00`) | **LIVE on the default branch** | `git show origin/main:scripts/deploy/kaggle/upload_all.sh` and `…/upload_final_v2.sh` → token on line 3 of both |
| Introduced by | `a08c55b` (2026-09-04), ancestor of `origin/main` | `git merge-base --is-ancestor` |
| Local fix | **`f9afeaa` (2026-10-21) — local only, NOT pushed** | 4 files: both upload scripts + 2 docs; ancestor of local `main`, **not** of `origin/main` |
| **`peterlianpi/zolai-ai`** (personal, **PUBLIC**) | **LIVE + indexed by GitHub code search (2 hits)** | `search/code q='KGAT_cb3a6c'` → `peterlianpi/zolai-ai :: scripts/deploy/kaggle/upload_all.sh` and `…/upload_final_v2.sh`; blob fetched from GitHub confirms the token (masked match); commit `f6d2ecf` (2026-05-09) |
| Local mirror `personal-history.git` (inside workspace, excluded at `.git/info/exclude:55`) | contains the token: 1 commit `a6fa70b`, 2 file paths; 190 MB, 98 commits, refs `master`/`main` + 2 feature branches, remote `git@github.com:peterlianpi/zolai-ai.git`, bare-style git-dir | `git --git-dir=… log --all -G'…'` |
| Other 12 workspace repos (HEAD + history) | **CLEAN** | `-G` scan returned 0 (incl. `zolai-ai-local`, which has no remote) |
| `Zolai-AI/zolai-ai` (org repo) | **CLEAN** (no `kaggle` paths in its tree) | `git/trees/main?recursive=1` |
| Server `pcore-server` | **no Kaggle token** (no `~/.kaggle`, no `KGAT_` in scanned env dirs) | read-only `grep -rl` |
| Local `~/.kaggle/kaggle.json` (mode 600, dated 2026-10-24) | holds a **well-formed token that is NOT the leaked one** (prefix/suffix mismatch, verified by boolean compare only) | does **not** prove the leaked token is dead — see §2.2 |

### Org security posture (live, 2026-10-27 — supersedes the 2026-10-21 audit)

- **12 public org repos, all with `secret_scanning=disabled` AND
  `secret_scanning_push_protection=disabled`** (audit said nine on 10-21; the org now exposes
  12: `.github`, `zolai-tauri`, `zolai-datasets`, `zolai-training`, `zolai-web`, `zolai-wiki`,
  `zolai-core`, `zolai-ai`, `zolai-ai.github.io`, `zolai-landing`, `zolai-explorer`,
  `zolaigpt-website`). The long-standing belief that these were active is **false**.
- `peterlianpi/zolai-ai`: secret scanning, push protection, validity checks, non-provider
  patterns, dependabot security updates — **all `disabled`**.
- Org `two_factor_requirement_enabled: false`; `members_allowed_repository_creation_type: all`.

### Backup status — the old backups are GONE

`/tmp/opencode/*-pre-rewrite-*.bundle` **no longer exist**. `/tmp/opencode/` was recreated by
the 2026-10-27 restart (dir mtime `Oct 27 18:51`) and is **empty** (verified). Do **not**
assume any pre-rewrite backup survives. Every purge below must first take a **new** backup to
a path **outside `/tmp`** (§3.1). Free space: 55 GB on `/`.

---

## 1. MANDATORY ORDERING — rotate first, then purge (hard precondition)

> **A pushed secret is public regardless of what the history looks like.** Purging history
> removes the *evidence trail* while the credential keeps working; rotating while the
> credential is still live does not help either. Only **rotate → verify → then purge** is
> correct. If purge runs first and rotation never happens, you have destroyed your audit trail
> and still have a working stolen credential.

- [ ] **F1 rotated and verified** (§2.1) — checkbox ticked by the founder, with date/time.
- [ ] **F2 rotated and verified** (§2.2) — checkbox ticked by the founder, with date/time.
- [ ] **§3.0 blocking preconditions all ticked** (unpushed-work collision, clean worktrees).
- [ ] **§3.1 backups written to `/home/peter/zolai-purge-backups/<date>/` and verified**
      (restorable — see §7 test), **outside `/tmp`**.

**Not one purge command in §3 may run until all four boxes above are ticked.**

---

## 2. Per-credential rotation checklists (DO NOT execute from this document — founder action)

### 2.1 F1 — Gmail app password (`SMTP_PASS`), `civiyk…kcbq`

Where the value lives and must be replaced:

- [ ] **Google Account → Security → 2-Step Verification → App passwords**: find the app
      password matching the mask `civiyk…kcbq` and **delete/revoke it** (deleting the specific
      app password is required — merely creating a new one does not kill the old value).
- [ ] **Generate a replacement** app password; store it only in env files (never in git, docs,
      commit messages, or chat).
- [ ] **`pcore-server` → `/home/ubuntu/zolai-core/.env.dev`** — this is the **live**
      consumer (`zolai-core-dev.service` → `EnvironmentFile=/home/ubuntu/zolai-core/.env.dev`).
  - [ ] Replace `SMTP_PASS` here.
  - [ ] `sudo systemctl restart zolai-core-dev.service`, then `curl -sf http://127.0.0.1:8001/health`
        and a `send_test_notification` / real SMTP probe (expect `ehlo 250 → starttls 220 →
        auth 235`) with the **new** value.
- [ ] **Same server, stale copies that also contain the old value** — replace or delete each:
      `/home/ubuntu/zolai-core/.env.production`,
      `/home/ubuntu/zolai-core/.env.production.bak-20261011-184735`,
      `/home/ubuntu/zolai-core/.env.production.bak-231908`,
      `/home/ubuntu/zolai-core/.env.production.example`
      (an `.example` file carrying a real value is itself a defect — make it a placeholder).
- [ ] Check any other host/CI that reads `SMTP_PASS`. GitHub Actions holds **no** secret with
      this name in `Zolai-AI/.github` or `Zolai-AI/zolai-core` (verified). Org-level Actions
      secrets returned **403** for this account — an **org admin must check** them
      (`gh secret list --org Zolai-AI`).
- [ ] Confirm the old value is dead: a Gmail app password deleted at Google is invalid
      immediately. Do **not** "test" it by sending; trust the Google revocation + a successful
      send with the new value.

### 2.2 F2 — Kaggle API token (`KGAT_cb3a6c…5287`)

Where the value lives and must be replaced:

- [ ] **Kaggle → Account → API → *Generate New Token***, and confirm the leaked value no longer
      appears among active tokens (if the account exposes a single token, regeneration
      implicitly revokes the old one). The local `~/.kaggle/kaggle.json` already holds a
      **different** token dated 2026-10-24 — that is evidence of a regeneration, **not proof
      the leaked token was revoked**; verify in the Kaggle UI.
- [ ] **Local `~/.kaggle/kaggle.json`** (mode 600) and **`~/.kaggle/access_token`** — confirm
      they hold only the new token.
- [ ] **`pcore-server`** — no `~/.kaggle` and no `KGAT_` found in scanned env dirs; re-check
      after rotation anyway (cheap): `ssh pcore-server 'ls -la ~/.kaggle 2>/dev/null; grep -rl
      KGAT_ ~/.kaggle 2>/dev/null'` (paths only).
- [ ] **Any script/CI expecting `KAGGLE_API_TOKEN`** must read it from the environment only.
      The local (unpushed) fix `f9afeaa` already converts
      `scripts/deploy/kaggle/upload_all.sh` and `upload_final_v2.sh` to env-only — it ships as
      part of this work (§3.3).
- [ ] `context/KAGGLE_SETUP.md` (tracked in the root repo) is clean at HEAD — keep it that way.

---

## 3. Purge procedure — exact commands (founder-run, after §1 boxes ticked)

### 3.0 BLOCKING PRECONDITIONS (measured 2026-10-27)

- [ ] **B1 — Rotation complete** (§1 boxes ticked).
- [ ] **B2 — `zolai-core` unpushed/dirty work collision (HARD BLOCKER).**
      `zolai-core` is **+22 commits ahead of `origin/main`** with **89 dirty files**.
      `git filter-repo` **aborts on a dirty tree** (its own message: `you have uncommitted
      changes`) and, once it runs, **rewrites SHAs of the 22 unpushed commits** too.
      You must, before any rewrite: (a) commit or stash the 89 dirty files, and (b) park the 22
      commits as **SHA-independent patches** (§3.1) so nothing is lost if the rewrite or the
      force-push goes wrong.
- [ ] **B3 — root repo (`.github`) is dirty**: **+1 unpushed** (`b37f958 docs(agents): add
      canonical Secret Hygiene rules`) and **11 modified files + untracked `.pcore/`, `.qoder/`,
      `.wrangler/`**. Same `filter-repo` dirty-tree abort applies. (Correction to the briefing:
      the root repo is +1 ahead, not clean.)
- [ ] **B4 — `zolai-explorer` is NOT ahead** (briefing said ~8; measured **+0/−0**) but has
      **62 dirty files**. It needs **no rewrite** (no F1/F2 in HEAD or history) — leave it
      alone, but do not run anything repo-wide that would touch it.
- [ ] **B5 — server checkout must be reconciled after force-push.**
      `pcore-server:/home/ubuntu/zolai-core` is on `main`, **0/0 vs `origin/main`, 1 dirty
      file**, tip `9ad5e00`. After the `zolai-core` force-push its `main` will hold pre-rewrite
      SHAs → `git pull` will refuse or merge wrongly. Plan: save the 1 dirty file, then
      `git fetch && git reset --hard origin/main`, restore the dirty file, restart
      `zolai-core-dev.service`, re-run `/health`.
- [ ] **B6 — every other clone must re-clone.** Known clones of the two rewritten repos:
      workspace `zolai-core` (the only local one found — `find /home/peter -name zolai-core`
      found no others), the server checkout above, and the backups in §3.1. Any contributor
      with a clone must be told **before** the push.
- [ ] **B7 — founder decision required for `peterlianpi/zolai-ai`** (public, personal account,
      outside the org, and the only surface where F2 is currently **code-search indexed**).
- [ ] **B8 — new backups exist at a non-`/tmp` path** (§3.1) and have been restore-tested (§7).

### 3.1 Pre-flight backups — to a path OUTSIDE `/tmp` (mandatory)

The previous `/tmp/opencode/*-pre-rewrite-*.bundle` backups are **gone**. Take fresh ones:

```bash
set -euo pipefail
BK=/home/peter/zolai-purge-backups/2026-10-27
mkdir -p "$BK"
W=/home/peter/Documents/Projects/zolai-ai

# --- root repo (Zolai-AI/.github) — F1 lives in unreachable objects here ---
git -C "$W" bundle create "$BK/github-dot-github.bundle" --all
git clone --mirror "$W" "$BK/github-dot-github.git"
# refs-only mirror/bundle do NOT carry the dangling F1 objects — also take a byte copy:
cp -a "$W/.git" "$BK/github-dot-github.git-dir"          # includes unreachable objects

# --- zolai-core — F2 on origin/main ---
git -C "$W/zolai-core" bundle create "$BK/zolai-core.bundle" --all
git clone --mirror "$W/zolai-core" "$BK/zolai-core.git"
cp -a "$W/zolai-core/.git" "$BK/zolai-core.git-dir"

# --- park the 22 unpushed zolai-core commits as SHA-independent patches ---
git -C "$W/zolai-core" format-patch origin/main..main --stdout > "$BK/zolai-core-unpushed-22.patch"
git -C "$W/zolai-core" diff --binary               > "$BK/zolai-core-wip-tracked.patch"
git -C "$W/zolai-core" status --porcelain          > "$BK/zolai-core-dirty-list.txt"

# --- park the root repo's 1 unpushed commit + dirty work ---
git -C "$W" format-patch origin/main..main --stdout > "$BK/github-root-unpushed-1.patch"
git -C "$W" diff --binary                          > "$BK/github-root-wip-tracked.patch"
git -C "$W" status --porcelain                     > "$BK/github-root-dirty-list.txt"

# --- personal mirror (already bare) — this IS the pre-rewrite copy of peterlianpi/zolai-ai ---
cp -a "$W/personal-history.git" "$BK/personal-history.git"

# --- integrity check of what you just made ---
for b in "$BK"/*.bundle; do git bundle verify "$b" | tail -1; done
du -sh "$BK"/*
```

Notes:
- `clone --mirror` / `bundle --all` capture **reachable refs only**. The `cp -a .git` copies
  are the only backups that preserve the dangling F1 objects — that is intentional.
- Patch files (`.patch`) survive a rewrite because they are SHA-independent; bundles of
  rewritten history are not interchangeable with pre-rewrite history.

### 3.2 `Zolai-AI/.github` (root) — F1

**Reality check first:** F1 is **not on any ref** (verified §0). Reachable history is already
clean, so a rewrite changes nothing on `main`. The only local work here is dropping the
unreachable/reflog objects (§3.5). `filter-repo` is optional and is given for completeness
(it also prunes reflogs/old objects, per its own `--help`).

```bash
cd /home/peter/Documents/Projects/zolai-ai
git status --porcelain        # MUST be empty first (11 dirty + untracked at prep time)

# expressions file: one secret per line, "<old>==><new>" (no other format needed)
cat > /home/peter/zolai-purge-backups/2026-10-27/replace-f1.txt <<'EOF'
literal:PASTE_F1_FULL_VALUE_HERE==>[REMOVED:Gmail app password]
EOF
# NOTE: this build parses lines as  literal:<old>==><new>  (rsplit on the LAST '==>');
#       a line with no '==>' is replaced with ***REMOVED***.
#       Put the real value in the file with a secure editor, chmod 600 the file, and
#       delete it after the run. NEVER paste it into a shell history or a commit.

git filter-repo --force --replace-text /home/peter/zolai-purge-backups/2026-10-27/replace-f1.txt
#   --force is required: this is not a fresh clone (filter-repo: "this does not look like a
#   fresh clone … use --force"). It also implies immediate reflog/old-object pruning.
#   If 'origin' is missing afterwards: git remote add origin git@github.com:Zolai-AI/.github.git
```

Then (as the primary local action for F1) run the unreachable-object purge in **§3.5**.

### 3.3 `Zolai-AI/zolai-core` — F2

```bash
cd /home/peter/Documents/Projects/zolai-ai/zolai-core
git status --porcelain                       # MUST be empty (89 dirty at prep time → B2)
git stash push -u -m "pre-purge WIP"         # or commit; either satisfies filter-repo

cat > /home/peter/zolai-purge-backups/2026-10-27/replace-f2-core.txt <<'EOF'
literal:PASTE_F2_FULL_VALUE_HERE==>[REMOVED:Kaggle API token]
EOF
chmod 600 /home/peter/zolai-purge-backups/2026-10-27/replace-f2-core.txt

git filter-repo --force --replace-text /home/peter/zolai-purge-backups/2026-10-27/replace-f2-core.txt

git remote -v                                 # re-add if filter-repo dropped it:
git remote add origin git@github.com:Zolai-AI/zolai-core.git   # only if missing

git log --all -G'KGAT_[0-9a-f]{32}' --oneline # MUST be empty before pushing
git push --force origin main                  # ships the rewritten history AND f9afeaa fix
git push --force origin --all                 # if any other branch exists (measured: only main)

git stash pop                                 # restore the parked WIP, resolve conflicts
```

- The rewrite also rewrites your **22 unpushed commits** (their content survives as new SHAs);
  the patches from §3.1 are the fallback if you prefer to drop them instead and `git am` later.
- `f9afeaa` (the source fix, unpushed today) is **included** in the pushed result.
- **Do not** push before §1 rotation is ticked.

### 3.4 `peterlianpi/zolai-ai` (public personal repo) — F2

Purge from a **fresh mirror clone**, keeping `personal-history.git` untouched as the rollback
copy:

```bash
BK=/home/peter/zolai-purge-backups/2026-10-27
git clone --mirror git@github.com:peterlianpi/zolai-ai.git "$BK/peterlianpi-zolai-ai.purge.git"
cd "$BK/peterlianpi-zolai-ai.purge.git"

cat > "$BK/replace-f2-personal.txt" <<'EOF'
literal:PASTE_F2_FULL_VALUE_HERE==>[REMOVED:Kaggle API token]
EOF
chmod 600 "$BK/replace-f2-personal.txt"

git filter-repo --force --replace-text "$BK/replace-f2-personal.txt"
git log --all -G'KGAT_[0-9a-f]{32}' --oneline     # MUST be empty
git push --force --mirror origin                   # refs measured: master, main, 2 feature branches
```

Equivalent one-liner against the existing local mirror (only if you accept losing it as a
pristine rollback copy):

```bash
git --git-dir=/home/peter/Documents/Projects/zolai-ai/personal-history.git \
    filter-repo --force --replace-text "$BK/replace-f2-personal.txt"
```

### 3.5 Dangling / reflog objects (the F1 case — run inside the root repo)

```bash
cd /home/peter/Documents/Projects/zolai-ai
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git fsck --unreachable --no-reflogs | head          # expect: no unreachable objects left
```

> **These three commands are NOT executed yet** — they are destructive to local history copies.

**Critical honesty:** F1's exposure is **GitHub-side**. Purging the local object store removes
`6451a24` / `dd67d87` / `44be0c2` **only from your machine**. GitHub still serves all three by
SHA today (`gh api repos/Zolai-AI/.github/commits/6451a24` → HTTP 200, measured 2026-10-27),
and force-pushing `main` does **not** touch them — no ref points at them, so a ref update is
irrelevant to their survival. See §5.

### 3.6 Force-push + contributor coordination

| Repo | Rewrite? | Push action | Blocked by |
|---|---|---|---|
| `Zolai-AI/.github` | optional (refs already clean) | `git push --force origin main` only if SHAs actually changed | B3 dirty tree; **local gc only clears your copy, not GitHub's** |
| `Zolai-AI/zolai-core` | **YES** (F2 on `origin/main`) | `git push --force origin main` | **B2: +22 unpushed, 89 dirty** · B5 server checkout |
| `peterlianpi/zolai-ai` | **YES** (F2 on public default branch) | `git push --force --mirror origin` | B7 founder decision (outside org) |
| all other 10 workspace repos + `zolai-ai-local` | **NO** | none | §4 |

Active local work that a rewrite would invalidate (measured 2026-10-27):

| Repo | ahead of `origin/main` | dirty files |
|---|---|---|
| `zolai-core` | **+22** | **89** |
| `zolai-explorer` | +0 | **62** |
| `.` (root `.github`) | **+1** (`b37f958`) | 11 + untracked `.pcore/`, `.qoder/`, `.wrangler/` |
| `zolai-training` | +4 | 0 |
| `zolai-wiki` | +1 | 0 |
| `zolai-datasets`, `zolai-web`, `zolai-tauri`, `zolai-landing`, `zolai-journey`, `zolai-ai.github.io` | +1 each | 0 |
| `zolai-mcp-server` | +0 | 0 |
| `zolai-ai-local` | no remote | 0 |
| server `/home/ubuntu/zolai-core` | 0 | 1 |

Coordination requirements:
1. Announce a **freeze** on the rewritten repos (push/pull) for the duration.
2. Tell every collaborator to **re-clone** after the force-push (`git pull` on a rewritten repo
   produces duplicate/phantom history — never "fix" it with a merge).
3. Commit or stash dirty work in every repo where you intend to run `filter-repo` (only the
   three in the table above).
4. Unpushed commits in **non-rewritten** repos (the `+1`s and `+4`) are unaffected — push them
   normally before or after; do not fold them into this task.
5. Reconcile the server checkout (B5) immediately after the `zolai-core` push.

---

## 4. What MUST NOT be rewritten

- **`zolai-wiki`** — it already had its own `git-filter-repo` history rewrite on **2026-09-13**
  (third-party repo references removed; rewritten history is the *source of truth* there).
  Verified clean of F1 and F2 (HEAD + full history). **Do not touch it** beyond that.
- **The other 10 workspace repos + `zolai-ai-local`** — verified clean of both credentials in
  HEAD *and* history. No rewrite, no force-push, no `gc --aggressive` required.
- **Never rewrite anything unrelated to these two values**: no author-identity/date rewriting
  (`--mailmap`, `--email-callback`, `--name-callback` are out of scope), no path renames, no
  file deletions, no branch deletions, no tag rewriting, no submodule/`gitattributes` changes.
- **Do not** edit `.gitignore`, `.git/info/exclude`, or `docs/` as part of the purge, and do
  not delete `personal-history.git` before §3.1's copy exists.
- **Do not** run `filter-repo --path …` style path filters: in `git-filter-repo`, `--path`
  *includes* the listed paths and **drops everything else** — that would destroy the repos.
  Use `--replace-text` only (content replacement, all paths preserved).

---

## 5. GitHub-side steps the founder must do

1. **Dangling-commit reality (honest expectation).** `6451a24`, `dd67d87`, `44be0c2` remain
   fetchable from `Zolai-AI/.github` **by SHA** (confirmed from GitHub's own object store on
   2026-10-27). Force-pushing `main` does not remove them. GitHub **will not purge arbitrary
   unreachable SHAs on request**; support may eventually run its own GC, with no SLA and no
   guarantee for objects that have already been fetched by third parties (the audit fetched
   them). **The rotation in §2 is the real mitigation. The history purge is hygiene.** State
   this to stakeholders so nobody reports "history cleaned" as "credential secured".
2. **Re-enable secret scanning + push protection** (the audit's "enabled" belief is false):
   - Org: **GitHub org `Zolai-AI` → Settings → Code security and analysis** → enable
     *Secret scanning* and *Push protection* for the org (public repos get both at no cost).
   - Per repo: **repo → Settings → Code security and analysis** → *Secret scanning* →
     **Enable** / **Enable push protection**.
   - Affected: **all 12 public org repos** (all `disabled` today) **plus**
     `peterlianpi/zolai-ai` (also `disabled`, including validity checks).
   - Verify any change with (read-only):
     ```bash
     gh api repos/Zolai-AI/zolai-core --jq '.security_and_analysis'
     gh api repos/peterlianpi/zolai-ai --jq '.security_and_analysis'
     ```
     Optional batch enable (confirm against current API docs first; the UI is authoritative):
     ```bash
     gh api -X PATCH repos/Zolai-AI/zolai-core \
       -f 'security_and_analysis[secret_scanning][status]=enabled' \
       -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled'
     ```
3. **`two_factor_requirement_enabled` is `false`.** Org → **Settings → Authentication
   security** → require 2FA for all members (members without 2FA must be removed or
   suspended), and consider restricting
   `members_allowed_repository_creation_type` (currently `all`).
4. **After enabling**, re-scan: GitHub's secret scanning does **not** retroactively cover
   already-merged history for every pattern; treat the enablement as future protection, and
   rely on §2 + §6 for the existing exposure.

---

## 6. Verification commands (run AFTER a purge; read-only)

```bash
W=/home/peter/Documents/Projects/zolai-ai

# --- per repo: pickaxe over ALL refs (F1 root, F2 core/personal) ---
cd "$W"
git log --all -S 'civiyk[A-Za-z0-9]+kcbq' --oneline        # needs --pickaxe-regex? use -G instead:
git log --all -G 'civiyk[A-Za-z0-9]+kcbq' --oneline        # expect: empty
git log --all -G 'KGAT_[0-9a-f]{32}'        --oneline       # expect: empty
git grep -I -n -E 'civiyk[A-Za-z0-9]+kcbq' $(git rev-list --all) | head   # expect: empty
git grep -I -n -E 'KGAT_[0-9a-f]{32}'       $(git rev-list --all) | head   # expect: empty

# --- object-level sweep: every reachable object, type + size, then content probe ---
git rev-list --objects --all \
  | git cat-file --batch-check='%(objectname) %(objecttype) %(objectsize)' \
  | awk '$2=="blob" && $3<5000000 {print $1}' \
  | while read o; do
      git cat-file blob "$o" | grep -qE 'KGAT_[0-9a-f]{32}|civiyk[A-Za-z0-9]+kcbq' \
        && echo "HIT $o"
    done
# expect: no HIT lines

# --- the part -S/-G CANNOT see: unreachable objects (where F1 lives today) ---
git fsck --unreachable --no-reflogs \
  | awk '/^unreachable (blob|commit)$/{print $3}' \
  | while read o; do
      git cat-file -p "$o" | grep -qE 'civiyk[A-Za-z0-9]+kcbq|KGAT_[0-9a-f]{32}' \
        && echo "STILL PRESENT $o"
    done
# expect: no output after §3.5

# --- GitHub-side (founder; read-only) ---
gh api repos/Zolai-AI/.github/commits/6451a24 --jq .sha    # 404 = purged, 200 = still served
gh api repos/Zolai-AI/.github/commits/dd67d87 --jq .sha
gh api repos/Zolai-AI/.github/commits/44be0c2 --jq .sha
gh search code 'KGAT_cb3a6c' --limit 20                     # expect: 0 results
gh api -X GET search/code -f q='KGAT_cb3a6c' --jq .total_count
git -C "$W/zolai-core" show origin/main:scripts/deploy/kaggle/upload_all.sh \
  | grep -c 'KGAT_'                                         # after force-push: token absent
```

**Honest caveat — absence of search hits does NOT prove absence:**
- GitHub code search indexes **default branches of reachable content**; it does **not** index
  unreachable/dangling objects. Measured evidence of how misleading search can be:
  `search/code q='KGAT_cb3a6c org:Zolai-AI'` returned **0** even though the token *is* on
  `Zolai-AI/zolai-core` `origin/main`; the same query returned **2** for
  `peterlianpi/zolai-ai` (indexed) — so search both **under-reports** (index lag/exclusion)
  and, for unrelated repos, **over-reports** (`civiyk kcbq` → 9 hits, none of them ours).
  `search/commits q='repo:Zolai-AI/.github SMTP_PASS'` → **0** while the three dangling
  commits still exist and serve the value.
- The **only** trustworthy negatives are (a) local `-G`/object sweeps over reachable refs,
  (b) `fsck` sweeps over unreachable objects, and (c) direct `gh api` SHA/blob fetches for the
  known exposure points. Search results are a supplement, never proof.

---

## 7. Rollback

If a rewrite or force-push goes wrong, restore from §3.1 (never from `/tmp`):

```bash
BK=/home/peter/zolai-purge-backups/2026-10-27
W=/home/peter/Documents/Projects/zolai-ai

# --- option A: restore refs from the bundle (portable, refs-reachable content) ---
cd "$W/zolai-core"
git fetch "$BK/zolai-core.bundle" '+refs/heads/*:refs/heads/*'
git reset --hard main-pre-restore 2>/dev/null || true        # keep a pointer BEFORE you start
# practical form: create a safety branch first, then hard-reset to the restored ref:
git branch pre-purge-backup "$(git rev-parse main)" 2>/dev/null || true
git fetch "$BK/zolai-core.bundle" '+refs/heads/*:refs/heads/*'
git reset --hard origin/main

# --- option B: restore refs from the mirror clone ---
cd "$W/zolai-core"
git remote add rollback "$BK/zolai-core.git"
git fetch rollback '+refs/heads/*:refs/heads/*' '+refs/tags/*:refs/tags/*'
git branch -f main rollback/main
git remote remove rollback

# --- option C: byte-exact restore of the object store (includes dangling F1 objects) ---
mv "$W/zolai-core/.git" "$W/zolai-core/.git.broken"          # worktree untouched
cp -a "$BK/zolai-core.git-dir" "$W/zolai-core/.git"
git status && git fsck                                        # verify

# --- restore the remote (only if you must un-do a force-push) ---
git push --force origin main

# --- personal repo ---
git fetch "$BK/personal-history.git" '+refs/*:refs/*' && git push --force --mirror origin
# (or: cp -a "$BK/personal-history.git" back into place)
```

**Rollback warning:** restoring pre-rewrite history **re-publishes the credentials**. Only roll
back for a functional reason, and re-run §2 rotation immediately afterwards if you do.

---

## Appendix A — read-only inspection evidence (2026-10-27)

| Check | Result |
|---|---|
| `/tmp/opencode/` | empty (recreated 2026-10-27 18:51) — old bundles gone |
| `git-filter-repo` | `/home/peter/.local/bin/git-filter-repo`, module `…/site-packages/git_filter_repo.py` (build `a40bce548d2c`); `--replace-text` parses `literal:<old>==><new>`, default `***REMOVED***`; refuses dirty trees; needs `--force` on non-fresh clones |
| `git version` | 2.43.0 |
| F1 dangling SHAs | exist locally (`git cat-file -t` = commit) and on GitHub (`gh api` → 200) |
| F1 reflog-reachable | 3 commits / **5 blob paths** (listed §0); root repo has 21 unreachable commits |
| F1 on any ref / on `origin/main` | **no** (`git log --all -G`, `git grep origin/main`) |
| F2 on `zolai-core` `origin/main` | **yes**, 2 files, line 3 (tip `9ad5e00`) |
| F2 local fix | `f9afeaa` 2026-10-21, 4 files, **unpushed** |
| F2 on `peterlianpi/zolai-ai` (public) | **yes** — blob fetched (masked match) + 2 code-search hits |
| F2 elsewhere | no (13 repos scanned, HEAD + history; `Zolai-AI/zolai-ai` tree has no kaggle paths) |
| `personal-history.git` | 190 MB bare mirror of `peterlianpi/zolai-ai`, 98 commits, refs `master`/`main`+2, excluded at `.git/info/exclude:55` |
| Server consumers | `SMTP_PASS` in `.env.dev` (live unit) + 4 other env copies; no Kaggle token on server |
| GitHub Actions secrets | none in the two repos (org-level check needs org admin: HTTP 403) |
| Org security | 12/12 public repos: scanning **disabled**, push protection **disabled**; 2FA requirement **false** |

## Appendix B — hard rules observed while preparing this document

- Nothing destructive executed: no `git filter-repo`, no `git gc`, no `git reflog expire`, no
  force-push, no `rm`, no rotation, no `git add`/`commit`/`push`.
- Only read-only inspection was used (`git log/-G/-S`, `git grep`, `git cat-file`,
  `git fsck`, `git ls-tree`, `gh api`, SSH read-only `grep -l`/`ls`/`systemctl`).
- No full credential value appears in this file — only the masks `civiyk…kcbq` and
  `KGAT_cb3a6c…5287` and the pattern forms `civiyk[A-Za-z0-9]+kcbq` / `KGAT_[0-9a-f]{32}`.
- `data/zolai.db` was not read; the FastAPI app was not instantiated.
- `.gitignore` / `.git/info/exclude` untouched; this file is **not staged and not committed**.

---

## Phase A findings — 2026-10-27 (backup + park EXECUTED; Phase B still BLOCKED)

**This section was appended after Phase A ran. Nothing above it was rewritten.**
Phase A did only: backup creation outside `/tmp`, `git format-patch`, `git status` /
`git stash list` (read-only) / `git log` / `git fsck` / `git bundle verify` /
`git cat-file` / `git grep -c` (counts only) and throwaway `git clone` replays for
verification. **No `git filter-repo`, no force-push, no `gc`, no `reflog expire`, no
`reset`, no `checkout`, no `stash`, no `clean`, no commit, no push, no SSH, no rotation.**
No credential value is printed anywhere below (F2 verified by line **counts** only).
`.gitignore` and `.git/info/exclude` untouched; `data/zolai.db` not read; FastAPI not
imported. Scratch analysis lists were written under `/tmp/opencode/` — **backups were not**.

### A.1 §3.1 backups taken and verified — `/home/peter/zolai-purge-backups/2026-10-27/` (2.3 GB)

Three forms per repo (bundle / `clone --mirror` / `cp -a .git`), because refs-only forms do
not carry the dangling F1 objects. Full tables in `…/2026-10-27/VERIFICATION.md`.

| repo | form | verification result |
|---|---|---|
| root `.git` | `github-dot-github.bundle` (2.45 MB) | `git bundle verify` → "records a complete history"; replay clone **1729/1729 objects**, refs identical → **VERIFIED** |
| | `github-dot-github.git-mirror` (11 MB) | **1729/1729** objects, 2/2 refs identical, `fsck --full` clean → **VERIFIED** |
| | `github-dot-github.git-copy` (18 MB) | total **1838 = 1838** objects, unreachable **106 = 106** (sets identical), `count-objects` 1203/632/1773 identical → **VERIFIED** |
| `zolai-core` | `zolai-core.bundle` (4.96 MB) | complete history; replay **4696/4696**, all 4 refs incl. `refs/stash` + `worktrees/core-head/HEAD` → **VERIFIED** |
| | `zolai-core.git-mirror` (19 MB) | **4696/4696**, 4/4 refs identical, `fsck` clean → **VERIFIED** |
| | `zolai-core.git-copy` (19 MB) | total **4859 = 4859**, unreachable **160 = 160** identical, `count-objects` 2770/2086/2586 identical → **VERIFIED** |
| `personal-history.git` (peterlianpi/zolai-ai) | `personal-history.bundle` (196 MB) | complete history; replay **14986/14986**, all 6 refs incl. both `refs/pull/*` → **VERIFIED** |
| | `personal-history.git-mirror` (190 MB) | **14986/14986**, 6/6 refs identical, `fsck` clean → **VERIFIED** |
| | `personal-history.git-copy` (190 MB) | total **15016 = 15016**, unreachable sets identical, `count-objects` 0/14986/191988 identical (4 stale `tmp_pack_*`/`tmp_idx_*` files copied byte-for-byte too) → **VERIFIED** |

- **F1 dangling SHAs `6451a24` / `dd67d87` / `44be0c2` are present** in the root `.git-copy`
  **and** the root `.git-mirror` (`cat-file -t` = `commit`), and **absent from the bundle
  replay** — as expected: `bundle --all` carries refs-reachable objects only. `.git-copy` is
  the authoritative F1 backup; the mirror also has them here because a local `clone --mirror`
  shares the object store (not a guarantee — do not rely on mirrors alone for dangling work).
- **F2 still present, by design, in every zolai-core backup**: `origin/main = 9ad5e00`,
  `git show 9ad5e00:scripts/deploy/kaggle/upload_all.sh | grep -c KGAT_` = **1** in source,
  copy, mirror and bundle replay. Same for the personal mirror: `a6fa70b:upload_all.sh` and
  `a6fa70b:upload_final_v2.sh` = **1** matching line each in all five copies examined.
  These are pre-rewrite rollback copies — §7's warning applies (restoring re-publishes).
- **Promisor caveat on `personal-history.git`:** it is a **partial clone**
  (`remote.origin.promisor=true`, `partialclonefilter=blob:none`). Two measured consequences:
  (a) `git rev-list --missing --objects --all | grep -c '^missing '` = **0**, i.e. every
  object of every ref is present locally, so the backups *are* complete for reachable
  history; (b) `fsck --unreachable` there is **unreliable** — it reports 14,981 objects as
  "unreachable" that `rev-list --objects --all` lists as reachable, while the mirror clone
  reports 0. **Do not quote that number**; the `--missing` = 0 figure is the real one.
- Nothing failed verification. The two caveats above (bundle-vs-dangling; promisor fsck) are
  documented limitations, not failures.
- Also written: `…/2026-10-27/VERIFICATION.md` (full tables), `…/patches/README.txt`
  (reapply instructions), `…/dirty/*.txt` (inventories), `…/verify/*` (replay clones —
  `verify/am-core` and `verify/am-root` are **aborted scratch** from a first, flawed replay
  attempt and must be ignored; `verify/am-core2` / `verify/am-root2` are the valid ones).

### A.2 §3.1 patches — 36 unpushed commits parked in `…/2026-10-27/patches/`

`git format-patch -o <BK>/patches/<repo> origin/main..HEAD` for every repo with ahead>0
(measured during Phase A; other sessions are live, so re-measure at Phase B):

| repo | ahead | patches |
|---|---|---|
| `zolai-core` | **+23** (runbook §3.0 says +22 — it grew by one during prep) | 23 |
| `zolai-training` | +4 | 4 |
| `zolai-landing` | +2 (was +1) | 2 |
| `.` root | +1 (`b37f958`) | 1 |
| `zolai-wiki`, `zolai-datasets`, `zolai-web`, `zolai-tauri`, `zolai-journey`, `zolai-ai.github.io` | +1 each | 6 |
| `zolai-explorer`, `zolai-mcp-server` | +0 | 0 |
| `zolai-ai-local` | no remote | 0 |
| **total** | **+36** | **36** |

**Replay verified**: in throwaway clones, 23 patches onto `9ad5e00` reproduce a tree
**byte-identical** to source HEAD `696cc51`, and the root's 1 patch onto `76e5aa3` reproduces
`b37f958`. Exact reapply command (post-rewrite, clean checkout of the **new** `origin/main`):

```bash
BK=/home/peter/zolai-purge-backups/2026-10-27
W=/home/peter/Documents/Projects/zolai-ai
git -C "$W/zolai-core" fetch origin
git -C "$W/zolai-core" checkout -B main origin/main     # only after B2 dirty work is parked
git -C "$W/zolai-core" am --3way "$BK"/patches/zolai-core/*.patch
# root: same shape with "$BK"/patches/github-root/*.patch; the other 8 repos likewise.
# conflicts: resolve then `git am --continue`; total abort: `git am --abort`.
```
`git am` rewrites SHAs — that is intended; the patches carry no dependence on the old ones.

### A.3 §3.0 dirty-tree inventory — RECORDED, NOT TOUCHED

Files: `…/2026-10-27/dirty/<repo>.txt` (porcelain), `.stash.txt`, `.branch.txt`.
**Not one dirty entry was committed, stashed, reset, checked out or cleaned.** All
`git stash list` reads were read-only; the only stash that exists is pre-existing.

| repo | porcelain lines | breakdown | stash | categorisation |
|---|---|---|---|---|
| `zolai-core` | **96** (runbook said 89) | 84 modified + 12 untracked | **1** pre-existing (`stash@{0}: On main: pre-existing test changes`) | see below |
| `zolai-explorer` | **62** | 57 modified + 5 untracked | 0 | see below |
| `.` root | **12** | 8 modified docs + 4 untracked | 0 | 8 `docs/**` files (ROADMAP, component-status, database/*, source-of-truth, PHASE6_RAG_PLAN, SOURCE_OF_TRUTH_MATRIX) + untracked `.pcore/`, `.qoder/`, `.wrangler/` + **this runbook itself** |
| `zolai-datasets` | **2** | 2 **deletions**: `data/zolai.db`, `zolai.db` | 0 | ⚠️ two tracked SQLite files deleted in the worktree — foreign session's work, flagged, **not touched** |
| all other 9 repos | 0 | — | 0 | — |

`zolai-core` (96) categorised by area (`zolai/learning` 15, `tests` 15, `zolai/api` 13,
`zolai/syllable` 5, `zolai/eval` 5, `zolai/cli` 5, `zolai/knowledge` 4, `zolai/data` 4,
`zolai/rag` 3, rest ≤2 each + 12 untracked):

1. **foreign "learning agents" feature** — all 10 `zolai/learning/agents/*` files,
   `zolai/learning/__init__.py`, `zolai/learning/discovery/*` (3), `learning/metrics/dashboard.py`,
   `zolai/api/learning_tools_router.py`, and `zolai/api/server.py` (wires
   `learning_agents_router`, `learning_tools_router`, `contributions_router`);
2. **test-infra work** — 19 modified `tests/*` plus 7 untracked `tests/*` including an
   untracked `tests/conftest.py` and a new `pytestmark = pytest.mark.usefixtures("scratch_db")`
   pattern (scratch-DB fixture, not committed);
3. **broad style/lint sweep** — import-reorder and trailing-whitespace-only hunks across
   api/eval/cli/syllable/rag/knowledge/data/publishing/…;
4. **untracked new modules** — `zolai/rag/vectors.py`,
   `scripts/maintenance/{compact_embeddings,consolidation_r2a,r2a_lib}.py`,
   `scripts/migrate_eval_store.py`.

`zolai-explorer` (62): a UI design-system sweep — `src/components` (22, incl. `AGENTS.md`,
`README.md`, `package.json`, `bun.lock`, `docs/OPEN-ISSUES.md`), `src/routes` (14),
`src/lib` (8), `src/features` (5) + untracked `.cursor/` and 4 new components
(`MetaList`, `Notice`, `PageHeader`, `StatGrid`). Explorer is **+0 ahead** and needs no
rewrite (§3.0 B4) — leave the whole repo alone.

**These trees belong to other live sessions.** `git filter-repo` will refuse to run while
they exist, and their owners must park them; Phase A deliberately did not.

### A.4 §3.6 server reconciliation — commands documented here, **NOT run, no SSH taken**

`pcore-server:/home/ubuntu/zolai-core` is on `main` @ `9ad5e00`, 0 ahead/0 behind
`origin/main`, 1 dirty file (B5). After the `zolai-core` force-push its `main` holds
pre-rewrite SHAs; **never `git pull` a rewritten repo** (duplicate/phantom history — §3.6
coordination rule 2). Run this **only after** `git push --force origin main` succeeds:

```bash
# 0. read-only pre-check (before the push): record tip + the single dirty path
ssh pcore-server 'cd /home/ubuntu/zolai-core && git status --porcelain && git log -1 --format=%H'
#    expect: 1 dirty line (record its exact path as <DIRTY>), tip 9ad5e00...

# 1. preserve the dirty file OUTSIDE the repo (path substituted from step 0)
ssh pcore-server 'cd /home/ubuntu/zolai-core && mkdir -p /home/ubuntu/zolai-preserve-20261027 && \
  cp -a "<DIRTY>" /home/ubuntu/zolai-preserve-20261027/'
ssh pcore-server 'ls -la /home/ubuntu/zolai-preserve-20261027'   # confirm before continuing

# 2. reconcile to the rewritten history (in-place form)
ssh pcore-server 'cd /home/ubuntu/zolai-core && git fetch origin && git checkout main && \
  git reset --hard origin/main'
#    if reset refuses because of the dirty file: it must already be copied out (step 1);
#    only then: git checkout -- "<DIRTY>"

# 3. restore the preserved dirty file
ssh pcore-server 'cd /home/ubuntu/zolai-core && cp -a /home/ubuntu/zolai-preserve-20261027/<DIRTY> <DIRTY>'

# 4. verify the NEW tip and that F2 is gone from server history
ssh pcore-server 'cd /home/ubuntu/zolai-core && git log -1 --format=%H'   # must NOT be 9ad5e00...
ssh pcore-server 'cd /home/ubuntu/zolai-core && git log --all -G "KGAT_[0-9a-f]{32}" --oneline | head'  # MUST be empty

# 5. restart + health (the native unit needs ~13 s — POLL, do not single-shot)
ssh pcore-server 'sudo systemctl restart zolai-core-dev.service'
ssh pcore-server 'for i in $(seq 1 30); do curl -sf http://127.0.0.1:8001/health && break; sleep 2; done'

# 6. the rewrite does NOT touch env files — §2.1/§2.2 rotation must already be done there
#    (.env.dev live, .env.production, 2x .env.production.bak-*, .env.production.example)
```

Safer alternative if the checkout is entangled: `git clone <repo> /home/ubuntu/zolai-core.new`
at the post-rewrite tip, move the dirty file across, switch the systemd `WorkingDirectory`
path, restart, then retire the old directory (founder decision).

### A.5 What still BLOCKS Phase B — explicit

1. **(a) Credential rotation is still the hard precondition (§1).** Neither box is ticked:
   F1 (`SMTP_PASS`, `civiyk…kcbq`) and F2 (`KGAT_cb3a6c…5287`) are both still live.
   Rotate → verify → **then** purge (§1 ordering). Nothing in Phase A changes that.
2. **(b) The dirty trees.** `filter-repo` aborts on them and would rewrite other sessions'
   work: `zolai-core` **96 entries + 1 pre-existing stash**, root **12**,
   `zolai-datasets` **2 deletions** (and `zolai-explorer` **62** — no rewrite needed there,
   but do not run anything repo-wide while it is dirty). Their owners must commit/stash/land
   them first; Phase A deliberately left every one of them in place.
3. The parked patch series must be reapplied (or consciously dropped) after the rewrite —
   parked ≠ landed; `zolai-core` is now **+23**, not +22.
4. Still open from §3.0: **B5** (execute A.4 immediately after the push), **B6** (announce
   re-clone to every contributor), **B7** (founder decision on `peterlianpi/zolai-ai`),
   **B8** (restore-test §7 against these backups before trusting them).
5. **Re-measure immediately before Phase B** — counts moved during Phase A
   (`zolai-mcp-server` reached +0/+0, `zolai-landing` went +1 → +2, `zolai-core` 22 → 23),
   i.e. other sessions are actively pushing. A backup+park is only valid for the moment it
   was measured; re-run §3.0 and re-take A.1/A.2 if anything moved.

### A.6 Phase A close-out re-measurement (2026-10-27 20:20) — the premises MOVED mid-run

Another live session pushed while Phase A was executing. Read-only `git ls-remote` proof:

| fact | measured at Phase A start (~19:40) | measured at close-out (20:20) |
|---|---|---|
| `zolai-core` vs `origin/main` | **+23 unpushed** (local `origin/main` = `9ad5e00`) | **+0** — GitHub `refs/heads/main` = **`696cc51`** = local HEAD; local `refs/remotes/origin/main` written **20:12:43** with `update by push` |
| F2 on `zolai-core` default branch **content** | present at `9ad5e00` (`upload_all.sh` line 3) | **absent at `696cc51`** (`grep -c KGAT_` = 0) — the `f9afeaa` sanitisation **shipped** |
| F2 in `zolai-core` **pushed history** | present (introduced `a08c55b`) | **still present** — pickaxe over `--all` = **2 commits** (`a08c55b`, plus `f9afeaa` which removes it) |
| root `.github` vs `origin/main` | +1 (`b37f958`) | **+1 unchanged** (remote `76e5aa3`) |
| dirty trees | core 96 / root 12 / explorer 62 / datasets 2 | unchanged (all re-read at close-out) |

Consequences for Phase B:
- B2's "unpushed collision" half is **resolved for `zolai-core`** (the 23 commits are on
  GitHub now); the **dirty-tree half is not** — 96 entries + 1 stash remain, so
  `git filter-repo` still aborts. Re-apply A.2's patches only if the rewrite is run from a
  state where those commits are not already on the rewritten branch.
- The F2 exposure has **changed shape, not disappeared**: the token is no longer in tip
  content but is in pushed history, which is exactly what §3.3 rewrites. Rotation (§2.2) is
  still the mitigation that matters; the tip going clean must not be reported as "secured".
- The 23-commit patch series in A.2 is now a **redundant safety net**, kept deliberately
  (it costs ~1 MB and proves the tree replays). The root's 1 patch is still live work.
- **Re-measure everything at Phase B**: this run saw three premise changes in 40 minutes
  (mcp-server → 0, landing +1 → +2, core +23 → 0 + pushed). No precondition measured in
  §3.0 or in Phase A may be trusted without re-reading it.

**Correction to the A.6 table (re-read 20:25):** `zolai-core` dirty went **96 → 102** between
the inventory write (20:03) and close-out — six more entries from another live session.
`zolai-explorer` 62, root 12, `zolai-datasets` 2 unchanged; **0 files staged in any repo**
(the 102 are entirely foreign WIP, none of it mine). The authoritative inventory file is
`dirty/zolai-core.txt` (96 entries @ 20:03); treat every dirty number here as a
**timestamped snapshot**, never as a stable precondition.
