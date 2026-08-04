# Coordenadas Content System — Comprehensive Report

> Generated: 21 Jul 2026  
> Repo: `github.com/Coordenadas-co/monthly-content-toolkit`  
> Runtime: **OpenCode** skills system  
> Skills: 5 custom + 46 marketing (coreyhaines31/marketingskills)

---

## Table of Contents

1. [Repository Structure](#1-repository-structure)
2. [Architecture — ICM Layers 0-4](#2-architecture--icm-layers-0-4)
3. [The 5 Custom Skills](#3-the-5-custom-skills)
   - 3.1 [content-plan-generator](#31-content-plan-generator)
   - 3.2 [carousel-prompt-generator](#32-carousel-prompt-generator)
   - 3.3 [blog-post-generator](#33-blog-post-generator)
   - 3.4 [infographic-brief-generator](#34-infographic-brief-generator)
   - 3.5 [monthly-drop-landing-page](#35-monthly-drop-landing-page-terminal-skill)
4. [The 46 Marketing Skills Catalog](#4-the-46-marketing-skills-catalog)
5. [Pipeline Connection — End-to-End Monthly Cycle](#5-pipeline-connection--end-to-end-monthly-cycle)
6. [Installation & Repo Disposability](#6-installation--repo-disposability)
7. [Documentation Index](#7-documentation-index)
8. [Key Numbers](#8-key-numbers)
9. [What's Not Yet Built](#9-whats-not-yet-built)

---

## 1. Repository Structure

**147 files** across **42 directories** (excluding `.git/` and `node_modules/`).

```
monthly-content-toolkit/
│
├── .gitignore
├── README.md                          # Top-level documentation
├── setup.ps1                          # One-time bootstrap installer
├── SYNC.md                            # Team sync/commit discipline
│
├── .opencode/
│   └── AGENTS.md                      # OpenCode project context
│
├── .agents/skills/                    # 5 custom skills (Layer 2)
│   ├── content-plan-generator/
│   │   ├── SKILL.md                   # 12-step pipeline
│   │   ├── SETUP.md
│   │   └── references/content-plan-template.html
│   │
│   ├── carousel-prompt-generator/
│   │   ├── SKILL.md                   # 8-step pipeline
│   │   ├── SETUP.md
│   │   └── references/
│   │       ├── brand-extraction-checklist.md
│   │       ├── carousel-prompt-template.html
│   │       └── master-prompt-structure.md
│   │
│   ├── blog-post-generator/
│   │   ├── SKILL.md                   # 8-step pipeline
│   │   ├── SETUP.md
│   │   └── references/
│   │       ├── claims-policy.md
│   │       └── writing-rules.md
│   │
│   ├── infographic-brief-generator/
│   │   ├── SKILL.md                   # 8-step pipeline
│   │   └── SETUP.md
│   │
│   └── monthly-drop-landing-page/
│       ├── SKILL.md                   # 12-step pipeline (terminal skill)
│       ├── references/                # 4 image-generation SOPs
│       │   ├── SOP_Blog_Banner_Image_Generation.md
│       │   ├── SOP_Carousel_Slide_Generation.md
│       │   ├── SOP_Instagram_Story_Banner_Generation.md
│       │   └── SOP_Newsletter_Banner_Image_Generation.md
│       ├── assets/ (empty)
│       ├── scripts/ (empty)
│       └── template/                  # Bundled TanStack Start + shadcn/ui
│           ├── src/
│           │   ├── routes/ (index.tsx, __root.tsx)
│           │   ├── components/
│           │   │   ├── paywise/ (ImageOrPlaceholder, Lightbox)
│           │   │   └── ui/ (46 shadcn components: accordion → tooltip)
│           │   ├── lib/ (paywise-content.ts, download.ts, utils.ts)
│           │   └── assets/paywise/ (placeholders)
│           │       ├── carousels/ (7 carousels, 4-5 slides each = 31 PNGs)
│           │       ├── blogs/ (5 blog banners + 5 blog stories = 10 PNGs)
│           │       └── newsletters/ (8 newsletter PNGs)
│           ├── api/index.js
│           ├── package.json, tsconfig.json, vite.config.ts
│           └── vercel.json
│
├── docs/
│   ├── SYSTEM_REPORT.md               # This file
│   ├── WORKFLOW.md                    # 5-stage monthly pipeline walkthrough
│   ├── monthly-loop.md                # Config-save & re-run mechanism
│   └── SOP_reference/                 # Canonical image-generation SOPs
│       ├── SOP_Blog_Banner_Image_Generation.md
│       ├── SOP_Carousel_Slide_Generation.md
│       ├── SOP_Instagram_Story_Banner_Generation.md
│       └── SOP_Newsletter_Banner_Image_Generation.md
│
└── Brands/
    └── _template/                     # Copy per new client
        ├── AGENT.md                   # Layer 0 — brand identity (8 sections)
        ├── CONTEXT.md                 # Layer 1 — stage routing
        ├── _knowledgebase/
        │   └── README.md              # What goes in knowledgebase (7 doc types)
        ├── BrandKit/
        │   ├── README.md              # Brand kit structure guide
        │   ├── design_sheets/ (.gitkeep)
        │   ├── fonts/ (.gitkeep)
        │   └── logos/ (.gitkeep)
        ├── hl_subaccount_config/ (.gitkeep)
        ├── image_gen_references/ (.gitkeep)
        └── Monthly_Cycles/ (.gitkeep)
```

---

## 2. Architecture — ICM Layers 0-4

The system follows the **Interpretable Context Methodology (ICM)**, a 5-layer hierarchy that separates concerns by how often each layer changes.

| Layer | What | Location | Who Edits | Change Frequency |
|---|---|---|---|---|
| 0 | Brand identity (name, audience, positioning, voice, credentials) | `Brands/[NAME]/AGENT.md` | Brand manager | Set once, updated rarely |
| 1 | Task routing (maps stages to folders) | `Brands/[NAME]/CONTEXT.md` | Machine (pipeline) | Auto-updated each cycle |
| 2 | Reusable skills (brand-agnostic logic) | `.agents/skills/` | Authors | As skills evolve |
| 3 | Stable reference (brand guide, knowledgebase, SOPs) | `_knowledgebase/`, `BrandKit/`, `docs/SOP_reference/` | Strategists, designers | Per quarter |
| 4 | Working artifacts (cycle deliverables) | `Monthly_Cycles/[NN]-[MMMYY]/` | **Machine-written** | Every cycle |

### Key Design Principles

- **Skills are brand-agnostic** — brand-specific behavior lives in `AGENT.md`, never forked skills.
- **SOPs are canonical** in `docs/SOP_reference/`, referenced by each brand's `image_gen_references/` (no duplication).
- **CONTEXT.md at Layer 1** is machine-updated — humans only touch it when adding a new stage type.

### Layer 3 Reference Structure (per brand)

| Resource | Path |
|---|---|
| Brand Guide | `BrandKit/brand_guide.md` |
| Design Sheet (MAIN) | `BrandKit/design_sheets/MAIN.md` |
| Negative Prompt Block | `BrandKit/design_sheets/negative_prompt_block.md` |
| Knowledgebase | `_knowledgebase/` |
| Image Gen SOPs | `image_gen_references/` (symlinked from `docs/SOP_reference/`) |
| HL Sub-account Config | `hl_subaccount_config/` |

### Layer 4 Monthly Cycle Folder Layout

| Stage | Folder | Contents |
|---|---|---|
| 0 | `CYCLE_CONTEXT.md` | Brand manager's direction for this month (or fallback) |
| 1 | `01_content_plan/` | Content plan .md + .html |
| 2 | `02_prompts_and_copy/` | Carousel prompts, blog posts |
| 3 | `03_infographic_briefs/` | Infographic design briefs |
| 4 | `04_image_generation/` | Generated images per SOP |
| 5 | `05_landing_page/` | Deployed landing page URL |
| 6 | `06_scheduling/` | Schedule confirmations |
| 7 | `07_report/` | Performance report |

Ad-hoc cycles use `AH-[YYYYMMDD]-[slug]/` prefix.

---

## 3. The 5 Custom Skills

### 3.1 content-plan-generator

**Purpose:** Generates a comprehensive monthly content plan integrating 13 marketing skills.

**Pipeline (12 steps):**

| Step | Action | Skill(s) Loaded |
|---|---|---|
| 0 | Load brand context (AGENT.md, knowledgebase, brand kit) | — |
| 0.5 | Set language (English/Spanish) | — |
| 1 | Direction interview (campaign angle, message, visual, deliverable mix) → **user confirms** | — |
| 2 | Define 3-5 content pillars, score topic ideas, map to buyer stages | `content-strategy` |
| 3 | Build distribution plan (weeks, personas, themes, blog-push pairs) → **user approves skeleton** | — |
| 4 | Generate each deliverable: carousels, blogs, emails, social, video, ads, lead magnets, SEO pages, infographics, push notifications | Per-type skill dispatch |
| 5 | Add design brief blocks to visual deliverables | `image` |
| 6 | Copy polish (Seven Sweeps: Clarity, Voice, So What, Prove It, Specificity, Heightened Emotion, Zero Risk) | `copy-editing` |
| 7 | Analytics (UTM parameters, tracking events, conversion goals) | `analytics` |
| 8 | Deliverable count verification | — |
| 9 | Append content calendar table | — |
| 10 | **Write .md → user approves → generate .html** | — |
| 11 | Offer to save config for next month | — |

**Marketing skills consumed:** `content-strategy`, `marketing-psychology`, `copywriting`, `seo-audit`, `ai-seo`, `emails`, `social`, `video`, `ad-creative`, `lead-magnets`, `programmatic-seo`, `image`, `copy-editing`, `analytics`

**Approval gates:** 3 (direction echo-back, weekly skeleton, .md before HTML)

**Reference file:** `references/content-plan-template.html`

**Output:** `{Brand}_Content_Plan_{Month}_{Year}.md` + `.html`

---

### 3.2 carousel-prompt-generator

**Purpose:** Turns content plan carousel entries into per-slide AI image-generation prompts.

**Pipeline (8 steps):**

| Step | Action | Skill(s) Loaded |
|---|---|---|
| 0 | Set language | — |
| 1 | Extract carousel entries from content plan | — |
| 2 | Load `image` skill + read brand extraction checklist → extract colors, typography, tone, density, graphic system, imagery rules | `image` |
| 3 | For each slide: apply psychology per role (Hook → curiosity gap, Info → authority/chunking, Conversion → anchoring/contrast, CTA → scarcity/loss aversion). Build 7-section creative brief. Recommend AI model. Prep technical preamble. | `marketing-psychology` |
| 4 | Write combined .md | — |
| 5 | **User approves .md** | — |
| 6 | Generate .html from template | — |
| 7 | Summary with totals and flags | — |

**Marketing skills consumed:** `image`, `marketing-psychology` (optional: `social`, `ad-creative`)

**Reference files:** `brand-extraction-checklist.md`, `master-prompt-structure.md`, `carousel-prompt-template.html`

**Output:** `{Brand}_Carousel_Prompts_{Month}_{Year}.md` + `.html`

---

### 3.3 blog-post-generator

**Purpose:** Turns content plan blog entries into complete SEO-optimized posts.

**Pipeline (8 steps):**

| Step | Action | Skill(s) Loaded |
|---|---|---|
| 0 | Set language | — |
| 1 | Locate knowledgebase + sitemap for internal linking | — |
| 2 | Extract blog entries from content plan | — |
| 3 | For each post: metadata (SEO title, meta desc, URL slug, keywords, search intent), full body (H1-H3, Grade 6-8 reading level), internal + external links, CTA, FAQ, QA notes. Governed by `writing-rules.md` + `claims-policy.md`. | `copywriting`, `seo-audit`, `ai-seo` |
| 4 | Write combined .md | — |
| 5 | **User approves .md** | — |
| 6 | Generate .html (per-post `<article>` with sidebar nav, "Copy post" button, QA box) | — |
| 7 | Summary with totals | — |

**Marketing skills consumed:** `copywriting`, `seo-audit`, `ai-seo`

**Governance files:** `writing-rules.md` (writing system), `claims-policy.md` (never invent facts/prices/claims)

**Output:** `{Brand}_Blog_Posts_{Month}_{Year}.md` + `.html`

---

### 3.4 infographic-brief-generator

**Purpose:** Produces complete design briefs for each infographic in the content plan.

**Pipeline (8 steps):**

| Step | Action | Skill(s) Loaded |
|---|---|---|
| 0 | Set language | — |
| 1 | Extract infographic entries from content plan | — |
| 2 | Load `image` skill + read brand guide → extract colors, typography, visual density, imagery style | `image` |
| 3 | For each infographic: structured brief with sections — Overview, Dimensions & Format, Visual Hierarchy, Color System (hex values), Typography, Data Presentation, Layout Structure, Style Summary | — |
| 4 | Write combined .md | — |
| 5 | **User approves .md** | — |
| 6 | Generate .html (sidebar nav, color swatches, "Copy brief" button per infographic) | — |
| 7 | Summary with totals | — |

**Marketing skills consumed:** `image`

**Edge cases:** If plan has 0 infographics, flag and stop. If brand guide has no color palette, use generic descriptive language (no invented hex values).

**Output:** `{Brand}_Infographic_Briefs_{Month}_{Year}.md` + `.html`

---

### 3.5 monthly-drop-landing-page (terminal skill)

**Purpose:** Generates a deployed Vercel landing page showing all monthly deliverables. Runs last, after all images exist.

**Pipeline (12 steps):**

| Step | Action |
|---|---|
| 1 | Determine brand project folder |
| 2 | Scan existing drops for sequence number → `{NN}-{MMMYY}-Monthly_Drop` |
| 3 | Copy bundled TanStack Start template → `npm install` |
| 4 | Create `src/assets/{brandname}/` with subdirectories |
| 5 | **Place images** (map named files per SOP naming conventions) |
| 5b | Copy `content-plan.html` and `blog-posts.html` to `public/` |
| 6 | Create `src/lib/{brandname}-content.ts` (modeled on bundled `paywise-content.ts`) |
| 7 | Update route files (`index.tsx`, `__root.tsx`) with brand data |
| 8 | Optional design customization |
| 9 | **Verify build** (`npx vite build` — fix errors) |
| 10 | `git init` → `git add` → `git commit` → `gh repo create` → Vercel auto-deploys |
| 11 | Deliver URL + summary |

**Image mapping conventions:**

| Source filename | Destination |
|---|---|
| `carousel.N.M.png` | `carousels/cN/slide-(M-1).png` |
| `blog.N.png` | `blogs/blog{N}-banner.png` |
| `blog.N-story.png` | `blogs/blog{N}-story.png` |
| `newsletter.N.png` | `newsletters/newsletter.N.png` |
| `newsletter.N-story.png` | `newsletters/email{N}-story.png` |

**Marketing skills consumed:** None directly (reads outputs of prior skills)

**Template bundled at:** `@skill_root/template/` — full TanStack Start + shadcn/ui React project (374 packages)

**Reference files:** 4 image-generation SOPs (also in `docs/SOP_reference/`)

**Output:** Full deployed Vercel URL + GitHub repo URL

---

## 4. The 46 Marketing Skills Catalog

Installed into `~\.config\opencode\skills\` by `setup.ps1`. Sourced from [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills).

| Category | Skills |
|---|---|
| **Strategy & Planning** | `content-strategy`, `marketing-plan`, `marketing-ideas`, `marketing-loops`, `marketing-psychology`, `product-marketing`, `customer-research`, `brainstorming` |
| **Copy & Content** | `copywriting`, `copy-editing` |
| **SEO** | `seo-audit`, `ai-seo`, `schema`, `site-architecture`, `programmatic-seo`, `competitors` |
| **Paid Media** | `ads`, `ad-creative` |
| **Email & SMS** | `emails`, `cold-email`, `sms` |
| **Social & Video** | `social`, `video` |
| **Conversion** | `cro`, `signup`, `onboarding`, `paywalls`, `popups`, `offers`, `pricing` |
| **Growth** | `referrals`, `co-marketing`, `community-marketing`, `launch`, `lead-magnets`, `free-tools`, `directory-submissions` |
| **Sales & Revenue** | `sales-enablement`, `revops`, `prospecting`, `churn-prevention` |
| **PR** | `public-relations` |
| **Analytics** | `analytics`, `ab-testing` |
| **Visual** | `image` |
| **ASO** | `aso` |
| **Competitor** | `competitor-profiling` |
| **Other** | `sheet-file-generator` |

---

## 5. Pipeline Connection — End-to-End Monthly Cycle

```
┌──────────────────────────────────────────────────────────────────┐
│                         MONTHLY CYCLE                            │
│                                                                  │
│  ┌─────────────┐    ┌──────────────┐    ┌───────────────────┐   │
│  │ CYCLE_      │───→│ Stage 1:     │───→│ Stage 2:          │   │
│  │ CONTEXT.md  │    │ content-plan │    │ carousel-prompts  │──┐│
│  │ (human      │    │ generator    │    │ + blog-posts      │  ││
│  │  direction) │    │              │    │ (parallel!)       │  ││
│  └─────────────┘    └──────────────┘    └───────────────────┘  ││
│                                        ┌───────────────────┐   ││
│                          ┌────────────→│ Stage 3:          │   ││
│                          │             │ infographic-briefs│   ││
│                          │             │ (parallel with 2) │   ││
│                          │             └───────────────────┘   ││
│                          │                                     ││
│                          └──────────────────┐──────────────────┘│
│                                             ▼                   │
│                                    ┌──────────────┐            │
│                                    │ Stage 4:     │            │
│                                    │ image gen    │            │
│                                    │ (human via   │            │
│                                    │  SOP + GPT)  │            │
│                                    └──────────────┘            │
│                                           ▼                    │
│                                    ┌──────────────┐            │
│                                    │ Stage 5:     │            │
│                                    │ landing page │            │
│                                    │ (terminal    │            │
│                                    │  skill)      │            │
│                                    └────┬─────────┘            │
│                                         ▼                      │
│                                    PM Review Gate              │
│                                         ▼                      │
│                              Stage 6 + 7: Schedule + Report    │
└──────────────────────────────────────────────────────────────────┘
```

### Dependency Chain

```
CYCLE_CONTEXT.md → 01 → 02 ──┐
                      ├─→ 03 ─┤
                          04 ←┘
                           ↓
                          05 → (PM Review) → 06 → 07
```

### What Runs in Parallel vs Sequence

| Stages | Relationship | Rationale |
|---|---|---|
| 2 + 3 | **Parallel** | Both read from stage 1 output; no cross-dependency |
| 1 → 2, 1 → 3 | Sequential | Stages 2 and 3 need the content plan first |
| 4 → 5 | Sequential | Images need prompts/briefs from stages 2/3; landing page needs images |
| 2 + 3 → 4 | Sequential | Image generation needs carousel prompts and infographic briefs |

### Config Persistence

Stage 1 optionally saves `content-plan-config.json` to `Brands/{ClientName}/`. Next month: "Run the same plan for August" skips the direction interview, asking only:
1. Any new direction for this month?
2. Any changes to deliverable mix?

Delete the config file to force a fresh direction interview.

---

## 6. Installation & Repo Disposability

### One-Time Bootstrap Flow

```
git clone https://github.com/Coordenadas-co/monthly-content-toolkit.git
cd monthly-content-toolkit
.\setup.ps1
cd ..
Remove-Item -Recurse -Force monthly-content-toolkit
```

### What setup.ps1 Does

| Step | Command | Effect |
|---|---|---|
| 1 | `npx skills add coreyhaines31/marketingskills --global -y` | Installs 46 marketing skills to `~\.agents\skills\` (global, reliable destination) |
| 2a | Copy all from `~\.agents\skills\` → `~\.config\opencode\skills\` | Moves marketing skills into OpenCode-specific directory |
| 2b | `Remove-Item -Recurse ~\.agents\skills\` | Deletes global copies — skills are no longer shared with other agent types |
| 2c | Copy 5 custom skills from repo → `~\.config\opencode\skills\` | Custom skills now live in OpenCode too |
| 3 | `npm install` in landing page template | Installs TanStack/shadcn dependencies |
| 4 | Prints success message | Notifies user: repo can be deleted |

### After Repo Deletion

- **`~\.config\opencode\skills\`** has all 51 skills (46 marketing + 5 custom)
- OpenCode auto-discovers skills from this directory on launch
- The `monthly-drop-landing-page` skill's bundled template + `node_modules/` persists inside OpenCode's directory
- The repo's `Brands/_template/` is lost — user re-clones if they need the template reference; otherwise brand context is created interactively in OpenCode

---

## 7. Documentation Index

| File | Covers |
|---|---|
| `README.md` | System overview, ICM architecture, folder structure, quick start, how to use, roadmap, remote info |
| `docs/WORKFLOW.md` | Step-by-step 5-stage monthly pipeline with exact prompts, output folders, prerequisites |
| `docs/monthly-loop.md` | Config-saving mechanism for one-command monthly re-runs |
| `docs/SOP_reference/*.md` | 4 canonical image-generation SOPs |
| `docs/SYSTEM_REPORT.md` | This file — full system report |
| `SYNC.md` | Team discipline: who edits what, commit rules, branching strategy |
| `.opencode/AGENTS.md` | OpenCode project-level context (development fork, key file map) |
| `Brands/_template/AGENT.md` | Layer 0 brand identity template (8 sections to fill) |
| `Brands/_template/CONTEXT.md` | Layer 1 stage routing template (machine-updated) |
| `Brands/_template/_knowledgebase/README.md` | What docs to place for brand context (7 types) |
| `Brands/_template/BrandKit/README.md` | Visual assets structure (logos, fonts, design sheets) |

### SOPs (Standard Operating Procedures) — Image Generation

| File | Purpose |
|---|---|
| `SOP_Carousel_Slide_Generation.md` | Turn slide prompts into brand-ready carousel images (3:4 → 1080x1350, logo placement). Two-part: manual ChatGPT generation + semi-automated post-processing. **Human judgment required** for crop direction and logo placement. |
| `SOP_Blog_Banner_Image_Generation.md` | Generate one 16:9 banner per blog post in ChatGPT. Fully manual, single-part process. Trained chat persists per brand. |
| `SOP_Instagram_Story_Banner_Generation.md` | Convert 16:9 banners to 9:16 Instagram Story format (1080x1920). Logo removal mandatory if present (keep bottom clear for IG Link sticker). |
| `SOP_Newsletter_Banner_Image_Generation.md` | Generate one 16:9 banner per newsletter subject. Nearly identical to Blog Banner SOP but **must use a separate dedicated chat**. |

---

## 8. Key Numbers

| Metric | Count |
|---|---|
| Total files | 147 |
| Directories (excl. .git/node_modules) | 42 |
| Custom skills | 5 |
| Marketing skills | 46 |
| Total skills installed | 51 |
| Reference files bundled with skills | 12 |
| Template npm packages | 374 |
| shadcn/ui components | 46 |
| Placeholder images in template | 49 |
| Skill approval gates | content-plan: 3, carousel: 1, blog: 1, infographic: 1, landing-page: 0 |
| Pipeline stages defined | 7 (5 implemented, 2 planned) |
| Python usage | 0 (Markdown + HTML + TypeScript only) |
| GitHub CLI version | 2.96.0 |
| Vercel test URL | `https://test-monthly-drop.vercel.app/` |

---

## 9. What's Not Yet Built

### External Skills (exist but not ported into this repo)

| Skill | Purpose |
|---|---|
| `marketing-brain` | 8-phase pipeline → Marketing Brain HTML + Strategy Doc |
| `hl-subaccount-setup` | GoHighLevel bot/pipeline config |
| `design-sheet-generator` | Per-persona visual reference sheets |
| `ai-video-prompt-writer` | Two-stage AI video prompt pipeline |
| `carousel-slide-processor` | Image post-processing (resize, logo, naming) |

### Planned Skills (not yet built)

| Skill | Purpose |
|---|---|
| `prompt-improvement-filter` | Rewrites raw prompts against design-sheet tokens + negative exclusions |
| `image-generation` | Executes SOPs via GPT-image-2 API |
| `marketing-hub-generator` | Public hub page per brand |
| `content-scheduler` | API-based scheduling + 2-week buffer check |
| `performance-report-generator` | Monthly performance report from analytics |

### Pipeline Stages Without Skills

| Stage | Folder | Status |
|---|---|---|
| 6 | `06_scheduling/` | Folder exists, no skill yet |
| 7 | `07_report/` | Folder exists, no skill yet |

---

*End of system report.*
