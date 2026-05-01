---
name: jujutsu-first
description: "Use for any work in a Jujutsu-managed repository (`.jj/` present or `jj root` succeeds) — status, log, diff, new/describe/squash/split/rebase, bookmark work, conflicts, recovery, and syncing with Git remotes. Default to `jj` over `git`; fall back to `git` only when `jj` cannot do the job. Workflow is describe-first with strict bookmark control (never auto-push). Also covers this dotfiles repo's `scope: summary` commit convention and common jj pitfalls (immutable, abandoned, divergent)."
---

# Jujutsu First

Default VCS interface for any repo where `.jj/` exists or `jj root` succeeds. Prefer `jj` over `git`; use `git` only when `jj` cannot do it.

## Workflow: describe-first, flexible mid-flight

The user writes the change description **before** the code, then keeps `@` focused on that intent. But the plan often shifts — treat `jj describe` and `jj split`/`jj squash` as the tools for absorbing that drift, not as a failure to stick to plan.

Typical shape:

1. `jj new -m "scope: what I intend to do"` on top of the right parent.
2. Edit files. `@` auto-snapshots.
3. If the work drifts:
   - description no longer matches → `jj describe` to rewrite it.
   - one change became two concerns → `jj split` (interactive) to separate them.
   - accidental scratch work ended up in `@` → `jj split` then `jj abandon` the scratch revision.
   - small fix for an earlier change → edit on `@`, then `jj squash --into <rev>` (or `jj absorb` to auto-distribute hunks across the mutable stack).
4. Before pushing, re-read `jj log` and tidy with `jj squash`/`jj split`/`jj rebase` as needed.

## Bookmarks and pushing — strict, never automatic

- Bookmarks do **not** move with `@` automatically. After making commits, move the bookmark explicitly: `jj bookmark move <name> --to @-` (or `-r <rev>`).
- **Never run `jj git push` without an explicit instruction from the user.** Even if the user asked to "finish up" or "wrap this", stop at the point where a push would happen and report what bookmarks are ahead of remote.
- Before any push the user asks for: run `jj git fetch`, show the relevant `jj log -r 'bookmarks() | @'` output, and confirm the target bookmark. Then push with `jj git push -b <bookmark>` (or `--bookmark <name>`). Never `--all` unless explicitly requested.
- Track new remote bookmarks with `jj bookmark track <name>@<remote>` rather than relying on auto-tracking globs.

## Conflicts — don't panic, don't block

Jujutsu records conflicts inside commits instead of halting the operation. This is a feature, not a bug.

- A `rebase`/`squash` that produces conflicts is **not an error**. The operation completes; the conflict lives inside the resulting revision and shows as `conflict` in `jj log`.
- You can keep working — create new changes on top, inspect other revisions — while conflicts remain unresolved. Resolve them later.
- To resolve: `jj resolve` (external merge tool) on the conflicted revision, or edit the file directly and `jj squash` the resolution where it belongs.
- `jj status` and `jj log` both mark conflicted revisions. Check them before a push.
- Do **not** reach for `jj undo` just because a conflict appeared — undo reverts the whole op, including clean parts of the rebase.

## Recovery

- First reflex: `jj op log` → `jj undo` (or `jj op restore <op>` for a specific earlier state). Operations are the unit of recovery.
- For content drift on a single revision: `jj restore -r <rev> <path>` or `jj restore --from <src> --to <dst>`.
- For "I edited the wrong revision": `jj new <right-rev>`, redo the edit, `jj abandon <wrong-rev>` or let it become empty.
- `jj evolog -r <rev>` shows how one change evolved — useful when you need to recover an intermediate state.

## Common pitfalls

- **Immutable revisions.** `trunk()` and tagged/remote-tracked commits are immutable by default; rewriting them errors out. Either rebase *on top of* them, or (rarely, with intent) pass `--ignore-immutable`. Never do the latter silently.
- **Abandoned vs deleted.** `jj abandon` marks a revision abandoned; its descendants get rebased onto its parent. The commit object still exists in the op log — you can recover via `jj op restore`. "Abandoned" is not "gone".
- **Divergent changes.** If the same change-id appears on two commits (e.g. after concurrent operations from two workspaces), `jj log` marks it `divergent`. Resolve with `jj abandon` on the unwanted side, or `jj duplicate` + rebase to pick a winner. Don't push while divergent.
- **Empty revisions after squash/rebase.** Squashing can leave the source revision empty; it's auto-abandoned by default. If you see "nothing changed" warnings, that's why.
- **Working copy is a commit.** `@` is a real (mutable) revision. `jj new` creates a *new* `@` on top; `jj edit <rev>` moves `@` *onto* an existing revision (and any edits you make rewrite that revision). Prefer `jj new` unless you specifically want to amend.
- **Bookmarks ≠ Git branches.** They don't track `HEAD`. They're pointers you move explicitly. Fetch doesn't fast-forward local bookmarks — you rebase or move them yourself.
- **`--at-operation` implies `--ignore-working-copy`.** Mutating at an earlier op creates a concurrent op; usually not what you want.
- **`.gitignore` + `.jjignore`.** `jj` reads `.gitignore` but also supports `.jjignore` for jj-only patterns. Co-located repos still honor both.
- **Co-located repos.** If `.git/` exists alongside `.jj/`, the working copy is shared. Don't run `git` mutations (commit, reset, checkout) while jj is tracking — snapshot/import mismatches will appear. Prefer `jj git import/export` around any necessary git-side mutation.

## Command reference (use as defaults)

| intent | command |
|---|---|
| status | `jj status` (alias `jj st`) |
| history | `jj log` (default; alias `jj l` if configured) |
| show a rev | `jj log -r <rev>` / `jj show <rev>` |
| current diff | `jj diff` |
| annotate | `jj file annotate <path>` |
| start a change | `jj new -m "<desc>"` |
| edit description | `jj describe` (alias `jj desc`) |
| split current | `jj split` |
| squash into parent | `jj squash` |
| squash into specific rev | `jj squash --into <rev>` |
| auto-distribute hunks | `jj absorb` |
| rebase | `jj rebase -s <src> -d <dst>` (or `-r`/`-b`) |
| restore files | `jj restore [--from <rev>] <path>` |
| abandon | `jj abandon <rev>` |
| resolve conflicts | `jj resolve` |
| op log | `jj op log` |
| undo last op | `jj undo` |
| fetch | `jj git fetch` |
| move bookmark | `jj bookmark move <name> --to <rev>` |
| list bookmarks | `jj bookmark list` (alias `jj b l`) |
| track remote bookmark | `jj bookmark track <name>@<remote>` |
| push (explicit only) | `jj git push -b <bookmark>` |

## Config recommendations (`~/.config/jj/config.toml`)

These match the user's current setup and are worth preserving/extending:

```toml
[user]
name = "…"
email = "…"

[ui]
default-command = "log"         # bare `jj` shows log
bookmark-list-sort-keys = ["committer-date-"]
diff-editor = ":builtin"
pager = "less -FR"

[fsmonitor]
backend = "watchman"
watchman.register-snapshot-trigger = true

[revset-aliases]
# Revisions that are mine and still mutable — the daily working set.
'mine()' = 'mutable() & author.email(exact:"<my-email>")'
# Ready-to-push: mutable + has a local bookmark that's ahead of its remote.
'ready()' = 'bookmarks() & mutable() & ~remote_bookmarks()'

[aliases]
l     = ["log", "-r", "::@ | @::"]
tug   = ["bookmark", "move", "--from", "closest_bookmark(@-)", "--to", "@-"]
# `tug` moves the nearest bookmark to @- — handy after stacking commits.

[template-aliases]
# Shorter log lines; tune to taste.
'format_short_change_id(id)' = 'id.shortest(8)'

[git]
# Don't auto-push; we always push explicitly.
push-bookmark-prefix = ""
```

Only suggest config changes the user asked for; don't rewrite their `config.toml` unprompted.

## Git fallbacks

Use direct `git` only when:
- a tool shells out to `git` and has no `jj` equivalent (LFS, some hooks, some CI glue);
- low-level maintenance `jj` doesn't expose (`git gc`, `git reflog` for pre-jj history);
- the user explicitly asks for raw git.

When falling back: prefer read-only `git` commands; never `git reset --hard`, `git checkout --`, `git push --force`, or `git rebase` against a jj-tracked revision without explicit consent. Return to `jj` immediately after.

## Communication

- Name the `jj` command you actually used, not the git analogue.
- If you translated a git concept, say so briefly in jj terms (e.g. "moved the bookmark to `@-`, the jj equivalent of fast-forwarding the branch").
- If you fell back to `git`, state the concrete reason.
- When you finish a local change stack, report bookmark state and **stop** — do not push.

## Dotfiles commit convention (`~/.dotfiles`)

In this repository, write commit messages (and `jj describe` bodies) as `scope: summary`.

- Scope is the top-level config directory: `hypr`, `nvim`, `zsh`, `zed`, `kitty`, `yazi`, `rofi`, `mpv`, `starship`, `ashell`, `mxbin`, `jj`, `latex`, `skills`, etc.
- Hyprland-related changes → `hypr`, even when they touch supporting scripts that only exist for the Hyprland config.
- Neovim-related changes → `nvim`.
- Summary is short English, describes *what* changed, not *why*.
- One scope per commit. Split unrelated directory groups into separate commits; don't combine under a generic message.
- Avoid `update`, `wip`, `fix` as the whole message.

Examples:

- `hypr: migrate Hyprland config to Lua modules`
- `nvim: improve LSP server detection and restart commands`
- `zsh: add atuin history keybindings`
- `skills: rewrite jujutsu-first for describe-first workflow`

## Minimal translation guide

- "branch" → bookmark or revision, depending on context
- "commit --amend" → `jj describe` (message only) or edit `@` then `jj squash` (content)
- "checkout/switch" → `jj edit <rev>` (rewrite that rev) or `jj new <rev>` (start a child)
- "pull" → `jj git fetch`, then `jj rebase -d <remote-bookmark>` as appropriate
- "stash" → usually unnecessary; `jj new` to start a fresh change, or `jj split` to peel off work
- "merge" → `jj new <rev1> <rev2>` creates a merge commit; conflicts land inside it without blocking
