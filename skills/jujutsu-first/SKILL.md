---
name: jujutsu-first
description: Prefer this skill whenever work happens in a version-controlled repository and the user prefers Jujutsu over Git. Use it for status checks, history inspection, commits, rebases, squashing, branch/bookmark work, syncing with remotes, and general repository hygiene. The skill makes the agent use `jj` by default and only fall back to `git` when `jj` cannot do the job or when a Git-only tool is explicitly required.
---

# Jujutsu First

The user prefers Jujutsu. In repositories that support `jj`, use `jj` as the default VCS interface.

## Rules

- Prefer `jj` over `git` for all read and write operations.
- Before using `git`, ask whether the task can be done with `jj` or `jj git`.
- If a command would normally be `git status`, `git log`, `git diff`, `git commit`, `git rebase`, `git branch`, `git switch`, `git stash`, `git fetch`, `git push`, or `git pull`, translate it to a `jj` workflow first.
- Avoid mixed `git` and `jj` mutation in the same task unless a Git-only integration requires it.
- If direct `git` is unavoidable, keep it narrow, explain why, and return to `jj` immediately after.

## Quick Detection

Treat the repo as Jujutsu-managed if any of these are true:

- `.jj/` exists
- `jj root` succeeds
- the user explicitly says to use Jujutsu

If detection fails, use the repository's existing workflow instead of forcing `jj`.

## Default Command Mapping

- Inspect repo status: `jj status`
- Show current change: `jj diff`
- Show history: `jj log`
- Show a specific revision: `jj log -r <rev>`
- Annotate a file: `jj file annotate <path>`
- Create or edit a change description: `jj describe`
- Record a new change explicitly: `jj new`
- Split changes: `jj split`
- Squash into parent: `jj squash`
- Restore files or hunks: `jj restore <path>`
- Rebase work: `jj rebase ...`
- Undo the last repo operation: `jj undo`
- Show operation history: `jj op log`
- Sync from remotes: `jj git fetch`
- Push bookmarks: `jj git push`
- Clone a Git remote into a jj repo: `jj git clone <url>`

## Working Style

- Read history with `jj log` before rewriting it.
- Prefer immutable-looking, reviewable steps such as `jj new`, `jj squash`, `jj split`, and `jj rebase` over ad hoc Git sequences.
- Prefer bookmarks over Git branches when operating inside `jj`.
- When updating commit messages or change descriptions, use `jj describe` rather than Git commit amend flows.
- When recovering from mistakes, try `jj undo` first.

## Git Fallbacks

Use direct `git` only for cases like:

- a third-party tool shells out to `git` and has no `jj` path
- low-level Git maintenance that `jj` does not expose
- user explicitly requests raw Git commands

When falling back:

- prefer read-only `git` commands when possible
- avoid `git checkout --`, `git reset --hard`, and other destructive commands unless the user explicitly requests them
- do not rewrite history with `git` if the same task can be completed with `jj`

## Communication

When describing repository actions to the user:

- name the `jj` command you used, not the equivalent `git` command
- if translating from a Git-centric concept, explain it briefly in `jj` terms
- if a direct `git` command was necessary, state the concrete reason

## Dotfiles Commit Convention

When working in this dotfiles repository, write commit messages in the form `scope: summary`.

- Use the top-level config area as the `scope`, such as `hypr`, `nvim`, `zsh`, `zed`, `kitty`, or `yazi`.
- For Hyprland-related changes, always use `hypr`, even when the files include helper scripts or deployment changes that exist only to support the Hyprland config migration.
- For Neovim-related changes, always use `nvim`.
- Use a short English summary after the colon that states what changed, not why the commit exists.
- Prefer one scope per commit. Split unrelated directory groups into separate commits instead of combining them into a generic update.
- Avoid placeholder messages such as `update`, `wip`, or `fix`.

Examples:

- `hypr: migrate Hyprland config to Lua modules`
- `nvim: improve LSP server detection and restart commands`
- `zsh: add atuin history keybindings`

## Minimal Translation Guide

- "branch" often maps to "bookmark" or "revision", depending on context
- "commit --amend" usually maps to `jj describe` or `jj squash`
- "checkout/switch" usually maps to `jj edit`, `jj new`, or revision selection via `-r`
- "pull" is usually `jj git fetch` followed by the appropriate `jj rebase` or other history operation
- "stash" is often unnecessary in `jj`; prefer creating a new change, splitting, or restoring paths
