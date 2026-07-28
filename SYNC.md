# SYNC.md — How to Work With This Repo

This is the **installer repo** — one-time clone, run `setup.ps1`, delete the repo.
All skills persist in `~\.config\opencode\skills\` after install. See README.md.

## Who edits the skills

| Folder | Who edits | Notes |
|--------|-----------|-------|
| `.agents/skills/` | Humans (authors) | Skill code — hand-edited, machine-read |
| `docs/` | Humans (authors) | Toolkit documentation |
| `SYNC.md` | Humans (authors) | This file — team contract |

## Branching

- `master` is the single source of truth.
- No long-running feature branches. If experimenting, use a local-only branch
  and rebase onto `master` before merging.
