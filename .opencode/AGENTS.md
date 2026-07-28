# Monthly Content Toolkit — Installer

## Purpose

Install 5 content production skills into OpenCode so they're available globally.
This is a one-time installer — after running setup.ps1, this repo can be deleted.

## How to install (agent-assisted)

1. Clone this repo to a temporary location
2. Verify prerequisites: `node --version`, `npx --version`, `opencode --version`
3. Run: `.\setup.ps1` (PowerShell 5.1+ on Windows)
4. For a full smoke test (validates all 4 pipeline stages + Vercel deploy):
   `.\setup.ps1 -SmokeTest`
5. To reinstall (overwrite existing): `.\setup.ps1 -Force`

## What gets installed

| Skill | Purpose |
|-------|---------|
| `content-plan-generator` | Monthly content plan (.md → .html) |
| `carousel-prompt-generator` | Per-slide AI image prompts (.md → .html) |
| `blog-post-generator` | Full SEO blog posts (.md → .html) |
| `infographic-brief-generator` | Design briefs for infographics (.md → .html) |
| `monthly-drop-landing-page` | Deployed Vercel landing page (TanStack Start) |

Plus 46 marketing sub-skills from `coreyhaines31/marketingskills` (content-strategy,
copywriting, image, seo-audit, ai-seo, marketing-psychology, etc.).

## After install

- All skills are at `~/.config/opencode/skills/`
- This repo can be deleted — skills persist in OpenCode
- Next step: clone the workspace repo for actual brand content work

## If install fails

- Node.js: https://nodejs.org/
- OpenCode: https://opencode.ai
- Re-run with `-Verbose` flag: `.\setup.ps1 -Verbose`
