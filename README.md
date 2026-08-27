# Monthly Content Toolkit

One-time installer for the Coordenadas content production pipeline skills.
Clone, run `setup.ps1`, delete the repo. Skills persist in your agent's skill
directory (OpenCode, Hermes Agent, or another agent).

**Execution modes:** the five pipeline skills can run natively in any agent
that reads files and follows a skill (proven with Hermes Agent on 2026-08-12)
or through OpenCode. See `docs/EXECUTION_MODES.md` — including which marketing
sub-skills catalog to install by default and why the bundled fallback
references are degraded/emergency-only, not a parallel choice.

---

## Quick start (agent-assisted)

Give this URL to your OpenCode agent:

```
https://github.com/Coordenadas-co/monthly-content-toolkit
```

Say: **"Install the monthly content toolkit from this repo."**

The agent will clone this repo, run setup, and confirm installation.

## Quick start (manual)

```powershell
git clone https://github.com/Coordenadas-co/monthly-content-toolkit.git
cd monthly-content-toolkit
.\setup.ps1
```

Add `-SmokeTest` to run a real pipeline validation (creates a landing page on
Vercel, then deletes it):

```powershell
.\setup.ps1 -SmokeTest
```

Add `-Force` to reinstall if skills already exist:

```powershell
.\setup.ps1 -Force
```

## What you get

| Skill | Purpose |
|-------|---------|
| `content-plan-generator` | Monthly content plan (.md → .html) |
| `carousel-prompt-generator` | Per-slide AI image prompts (.md → .html) |
| `blog-post-generator` | Full SEO blog posts (.md → .html) |
| `infographic-brief-generator` | Design briefs for infographics (.md → .html) |
| `monthly-drop-landing-page` | Deployed Vercel landing page (TanStack Start) |

Plus 46 marketing sub-skills (content-strategy, copywriting, image, seo-audit,
ai-seo, marketing-psychology, social, ad-creative, brainstorming, etc.)

All skills live in your agent's skill directory after install (e.g.
`~/.agents/skills/` for Hermes Agent; OpenCode's directory for OpenCode).
Install the marketing catalog by default:
`npx skills add coreyhaines31/marketingskills --global -y` — see
`docs/EXECUTION_MODES.md` for why this is the default and what the bundled
fallback is good for (emergency-only, not a parallel choice).

## Prerequisites

| Tool | Required for | Install |
|------|-------------|---------|
| Node.js | Running skills (npx) | https://nodejs.org/ |
| OpenCode | Running skills | https://opencode.ai |
| GitHub CLI (`gh`) | Landing page deploy | `winget install GitHub.cli` then `gh auth login` |
| Vercel CLI (`vercel`) | Landing page deploy | `npm install -g vercel` then `vercel login` |
| PowerShell 5.1+ | setup.ps1 | Ships with Windows 10/11 |

GitHub CLI and Vercel CLI are **optional** — only needed for the landing page
stage of the pipeline. The content plan, carousel prompts, blog posts, and
infographic brief skills work without them.

## After install

1. Delete this repo — all skills persist in OpenCode's directory
2. Clone or open your workspace repo (where brand data lives)
3. In OpenCode, run: *"Create the content plan for [month] for [Brand]"*

## Smoke test

`.\setup.ps1 -SmokeTest` runs all 4 pipeline stages against TestBrand:

| Stage | Skill | What it tests |
|-------|-------|---------------|
| 1 | content-plan-generator | Content plan .html generation |
| 2 | carousel-prompt-generator | Carousel prompt .html generation |
| 3 | blog-post-generator | Blog post .html generation |
| 4 | monthly-drop-landing-page | Landing page build + Vercel deploy |

After Stage 4 passes, the Vercel project is deleted and local output is cleaned
up. Total runtime: ~30-45 minutes.

## Remote

```
origin  https://github.com/Coordenadas-co/monthly-content-toolkit.git
```
