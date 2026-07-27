# Skill Connections — Architecture Deep Dive

> How the 5 custom skills wire together, which skills load which,  
> what data flows between them, and whether everything is properly connected.

---

## Table of Contents

1. [Dependency Graph](#1-dependency-graph)
2. [content-plan-generator — The Orchestrator](#2-content-plan-generator--the-orchestrator)
3. [carousel-prompt-generator](#3-carousel-prompt-generator)
4. [blog-post-generator](#4-blog-post-generator)
5. [infographic-brief-generator](#5-infographic-brief-generator)
6. [monthly-drop-landing-page — The Terminal Consumer](#6-monthly-drop-landing-page--the-terminal-consumer)
7. [Data Flow Between Stages](#7-data-flow-between-stages)
8. [Parallel vs Sequential Execution](#8-parallel-vs-sequential-execution)
9. [Fallback Behavior (Skill Missing)](#9-fallback-behavior-skill-missing)
10. [Validation Summary](#10-validation-summary)
11. [Identified Gaps](#11-identified-gaps)

---

## 1. Dependency Graph

```
                          ┌──────────────────────────────┐
                          │   content-plan-generator     │
                          │   (The Orchestrator)         │
                          │                              │
                          │  Loads 14 marketing skills   │
                          │  + delegates 3 custom skills │
                          └─────────────┬────────────────┘
                                        │
                    ┌───────────────────┼───────────────────┐
                    │                   │                   │
                    ▼                   ▼                   ▼
          ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
          │  content-       │ │  content-       │ │  content-       │
          │  strategy       │ │  strategy       │ │  strategy       │
          │  (marketing     │ │  (marketing     │ │  (marketing     │
          │   skill)        │ │   skill)        │ │   skill)        │
          └────────┬────────┘ └────────┬────────┘ └────────┬────────┘
                   │                   │                   │
    ┌──────────────┼──────────────┐    │    ┌──────────────┼──────────────┐
    ▼              ▼              ▼    │    ▼              ▼              ▼
┌────────┐ ┌──────────────┐ ┌────────┐│┌────────┐ ┌──────────────┐ ┌────────┐
│carousel│ │blog-post     │ │info-   │││carousel│ │blog-post     │ │info-   │
│prompt  │ │generator     │ │graphic │││prompt  │ │generator     │ │graphic │
│genera- │ │(custom)      │ │brief   │││genera- │ │(custom)      │ │brief   │
│tor     │ │              │ │genera- │││tor     │ │              │ │genera- │
│(custom)│ │              │ │tor     │││(custom)│ │              │ │tor     │
└───┬────┘ └──────┬───────┘ │(custom)││└───┬────┘ └──────┬───────┘ │(custom)│
    │             │         └────────┘│    │             │         └────────┘
    │             │                   │    │             │
    │   ┌─────────┘                   │    │   ┌─────────┘
    │   │                             │    │   │
    ▼   ▼                             │    ▼   ▼
┌─────────────────────────────────────┘┌─────────────────────────────────────┐
│  image-generation (human step)       │  image-generation (human step)      │
│  ChatGPT per SOPs → named PNGs      │  ChatGPT per SOPs → named PNGs      │
└────────────────┬────────────────────┘└────────────────┬────────────────────┘
                 │                                      │
                 └──────────┬───────────────────────────┘
                            ▼
              ┌─────────────────────────────┐
              │  monthly-drop-landing-page  │
              │  (terminal — reads output   │
              │   files, deploys to Vercel) │
              └─────────────────────────────┘
```

### Key Insight — Two Layers of Dispatching

| Layer | What | Mechanism |
|---|---|---|
| **Cross-skill** | content-plan-generator delegates to carousel/blog/infographic skills | The SKILL.md says "for full carousel prompt generation, load the dedicated `carousel-prompt-generator` skill" |
| **In-skill** | Each custom skill loads marketing skills at specific steps | Uses `skill("skill-name")` calls within the pipeline |

The content-plan-generator is the **only** skill that dispatches to other custom skills. The other 4 custom skills (carousel, blog, infographic, landing page) load only marketing skills (or none).

---

## 2. content-plan-generator — The Orchestrator

This is the most complex skill. It loads **14 marketing skills** and delegates to **3 custom skills**.

### Skills It Loads Directly

| Step | Skill(s) Loaded | Purpose | Required |
|---|---|---|---|
| 2 | `content-strategy` | Define 3-5 content pillars, score topic ideas, map to buyer stages, cross-reference clusters, identify anchor events | Yes |
| 4a | `marketing-psychology` | Select psychology principles for carousel hooks | Yes |
| 4b | `copywriting` | Write copy for every deliverable type | Yes |
| 4c | `seo-audit` or `ai-seo` | SEO metadata for blog posts and SEO pages | Yes |
| 4d | `emails` | Email sequence design, subject lines, body copy | Yes |
| 4e | `social` | Platform-specific social post copy (LinkedIn, X, Instagram) | Yes |
| 4f | `video` | Video script structure and production approach | Yes |
| 4g | `ad-creative` | Ad headline and description variants | Yes |
| 4h | `lead-magnets` | Lead magnet format, topic, gating strategy | Yes |
| 4i | `programmatic-seo` or `competitors` | SEO page templates (programmatic pages or competitor comparisons) | Yes |
| 4j | `image` | Infographic design brief and visual direction | Yes |
| 5 | `copy-editing` | Seven Sweeps polish on all copy (Clarity, Voice, So What, Prove It, Specificity, Heightened Emotion, Zero Risk) | Yes |
| 6 | `analytics` | UTM parameters, tracking events, conversion goals | Yes |

### Skills It Delegates To (cross-skill)

| Deliverable | Delegated To | What the Sub-Skill Produces |
|---|---|---|
| Carousel prompts | `carousel-prompt-generator` (custom, Step 4a) | Per-slide AI image prompts (md + html) |
| Blog posts | `blog-post-generator` (custom, Step 4b) | SEO-optimized blog posts (md + html) |
| Infographic briefs | `infographic-brief-generator` (custom, Step 4c) | Design briefs (md + html) |

### Key Architectural Decision

The content-plan-generator's SKILL.md includes **inline templates** for every deliverable type (carousel slide structure, blog post structure, email structure, etc.) as fallback. It says: *"For full carousel prompt generation, load the dedicated `carousel-prompt-generator` skill"* — meaning the inline templates are used only when the dedicated skill isn't available or when the user says "skip sub-skills."

This means the content-plan-generator could theoretically function without the 3 sub-skills, but the output quality would be lower (inline templates are less specialized).

---

## 3. carousel-prompt-generator

### Skills It Loads

| Step | Skill(s) Loaded | Purpose | Required |
|---|---|---|---|
| 2 | `image` | Extract visual rules from brand guide (colors, typography, density, graphic system, imagery rules). Recommend optimal AI model per slide type. | Yes |
| 3 | `marketing-psychology` | Select psychology principles per slide role. Hook → curiosity gap. Info → authority/chunking. Conversion → anchoring/contrast. CTA → scarcity/loss aversion. | Yes |
| 3 (optional) | `social` | Platform-specific carousel formatting (LinkedIn, Instagram, TikTok). Only when user says these carousels are for a specific platform. | No |
| 3 (optional) | `ad-creative` | Ad-ready carousel formatting. Only when user says these are for ads. | No |

### What It Reads From Prior Skills

| Input | Source |
|---|---|
| Carousel entries (title, persona, slide copy, design brief) | content-plan-generator output (content plan) |
| Brand visual rules (colors, typography, density) | `BrandKit/brand_guide.md` |
| Brand extraction checklist | `references/brand-extraction-checklist.md` (bundled) |

### What It Produces

- Per-carousel, per-slide AI image prompts (7-section creative brief per slide)
- AI model recommendation (Flux, Midjourney, DALL-E)
- Technical preamble (aspect ratio, dimensions, "Remove AI Slop")

---

## 4. blog-post-generator

### Skills It Loads

| Step | Skill(s) Loaded | Purpose | Required |
|---|---|---|---|
| 3 | `copywriting` | Inform brand voice, persuasive structure, value proposition framing per post | Yes |
| 3 | `seo-audit` | On-page SEO checklist: title tags, meta descriptions, heading hierarchy, keyword placement | Yes |
| 3 | `ai-seo` | Optimize for AI search visibility (LLM citations, featured snippets, structured answers) | Yes |

### What It Reads From Prior Skills

| Input | Source |
|---|---|
| Blog entries (title, persona, intro, H2 skeleton, CTA hint) | content-plan-generator output (content plan) |
| Knowledgebase (marketing brain, message blocks, buyer psychology) | `_knowledgebase/` |
| Sitemap / page list (for internal linking) | `_knowledgebase/sitemap.md` or `sitemap.xml` |

### What It Produces

- Per-post metadata (SEO title, meta description, URL slug, keywords, search intent)
- Full post body (H1-H3, Grade 6-8 reading level)
- Internal + external links, CTA, optional FAQ, QA notes

### Governance Files

| File | Purpose |
|---|---|
| `references/writing-rules.md` | Writing system: persuasive arc, sentence length, formatting rules |
| `references/claims-policy.md` | Never invent facts, prices, or claims |

---

## 5. infographic-brief-generator

### Skills It Loads

| Step | Skill(s) Loaded | Purpose | Required |
|---|---|---|---|
| 2 | `image` | Extract color palette, typography, visual density, imagery style from brand guide | Yes |

### What It Reads From Prior Skills

| Input | Source |
|---|---|
| Infographic entries (title, topic, persona, data points, visual hints) | content-plan-generator output (content plan) |
| Brand visual guide (colors, fonts, imagery style) | `BrandKit/brand_guide.md` |

### What It Produces

- Per-infographic structured brief: Overview, Dimensions & Format, Visual Hierarchy, Color System (hex values), Typography, Data Presentation, Layout Structure, Style Summary

---

## 6. monthly-drop-landing-page — The Terminal Consumer

### Skills It Loads

**None.** This skill does not load any marketing skills. It is a pure file-assembly and deployment skill.

### What It Reads From Prior Stages

| Input | Source Stage | Format |
|---|---|---|
| Content plan (all deliverables) | Stage 1 — content-plan-generator | `.md` or `.html` |
| Blog posts (with anchor IDs) | Stage 2 — blog-post-generator | `.html` |
| Carousel slide images | Stage 4 — human (ChatGPT) | Named PNGs per SOP |
| Blog banner images | Stage 4 — human (ChatGPT) | Named PNGs per SOP |
| Blog story images | Stage 4 — human (ChatGPT) | Named PNGs per SOP |
| Newsletter images | Stage 4 — human (ChatGPT) | Named PNGs per SOP |

### Bundled Template

The skill bundles a full TanStack Start + shadcn/ui project at `template/`. This includes:
- 46 shadcn UI components
- `ImageOrPlaceholder.tsx` (gracefully handles missing images)
- `paywise-content.ts` (model file — agent creates `{brandname}-content.ts` from this)
- Vercel deployment config

### Why It Loads No Skills

The landing page is a **compile + deploy** operation, not a content-generation operation. It:
1. Copies an existing template
2. Places images into correct directories
3. Generates a TypeScript config file
4. Runs `vite build`
5. Pushes to GitHub → Vercel

All content was already written by prior skills. This skill just packages and ships it.

---

## 7. Data Flow Between Stages

### Stage 1 → Stage 2 (content plan → carousel prompts)

```
content-plan output                   carousel-prompt-generator input
┌─────────────────────┐               ┌─────────────────────┐
│ Carousel 1:         │   extracts    │ Carousel 1:         │
│   Title             │──────────────→│   Title             │
│   Persona           │               │   Persona           │
│   Slide 1 copy      │               │   Slide 1 copy      │
│   Slide 2 copy      │               │   Slide 2 copy      │
│   Design brief      │               │   Design brief      │
└─────────────────────┘               └─────────────────────┘
```

### Stage 1 → Stage 2 (content plan → blog posts)

```
content-plan output                   blog-post-generator input
┌─────────────────────┐               ┌─────────────────────┐
│ Blog 1:             │   extracts    │ Blog 1:             │
│   Title             │──────────────→│   Title             │
│   Persona           │               │   Persona           │
│   Intro paragraph   │               │   Intro paragraph   │
│   H2 skeleton       │               │   H2 skeleton       │
│   CTA hint          │               │   CTA hint          │
│   Target keywords   │               │   Target keywords   │
└─────────────────────┘               └─────────────────────┘
```

### Stage 1 → Stage 3 (content plan → infographic briefs)

```
content-plan output                   infographic-brief-generator input
┌─────────────────────┐               ┌─────────────────────┐
│ Infographic 1:      │   extracts    │ Infographic 1:      │
│   Title             │──────────────→│   Title             │
│   Topic             │               │   Topic             │
│   Persona           │               │   Persona           │
│   Data points       │               │   Data points       │
│   Visual hints      │               │   Visual hints      │
└─────────────────────┘               └─────────────────────┘
```

### Stage 1 + 2 + 4 → Stage 5 (all prior → landing page)

```
content-plan-generator (Stage 1)
  ├── content-plan.html ─────────────────────┐
  ├── blog H2 anchors, CTA text              │
  ├── carousel titles, slide counts          │
  └── push notification copy                 │
                                             │
blog-post-generator (Stage 2)                │
  └── blog-posts.html (with anchor IDs) ─────┤
                                             │
image-generation (Stage 4 — human)           │
  ├── carousel.N.M.png (31 PNGs)             ├─→ monthly-drop-landing-page
  ├── blog.N.png (5 PNGs)                    │
  ├── blog.N-story.png (5 PNGs)              │
  ├── newsletter.N.png (4 PNGs)              │
  └── newsletter.N-story.png (4 PNGs)        │
                                             │
brand guide / hub URL                        │
  └── brand name, colors, logo ──────────────┘
```

---

## 8. Parallel vs Sequential Execution

From `docs/WORKFLOW.md` and `CONTEXT.md`:

```
CYCLE_CONTEXT.md → 01 → 02 ──┐
                      ├─→ 03 ─┤
                          04 ←┘
                           ↓
                          05 → (PM Review) → 06 → 07
```

| Stage Pair | Relationship | Why |
|---|---|---|
| 1 → 2 | **Sequential** | Carousel prompts need content plan entries |
| 1 → 3 | **Sequential** | Infographic briefs need content plan entries |
| 2 + 3 | **Parallel** | No cross-dependency. Both read from stage 1 output |
| 2 → 4 | **Sequential** | Image prompts must exist before image generation |
| 3 → 4 | **Sequential** | Design briefs must exist before image generation |
| 4 → 5 | **Sequential** | Images must be generated before landing page assembly |
| 5 → 6/7 | **Sequential** | Landing page must be approved before scheduling/reporting |

### Current Limitation

Although stages 2 and 3 are technically parallel, the content-plan-generator skill currently generates them **sequentially within its own pipeline** (Step 4a → carousels, Step 4b → blogs, Step 4c → infographics). True parallelism would require running the three sub-skills as independent agents — which the skill system could support but the SKILL.md instructions don't currently prescribe.

---

## 9. Fallback Behavior (Skill Missing)

Every custom skill documents what happens when a referenced marketing skill isn't installed.

### content-plan-generator

> *"If a referenced skill doesn't exist at `~/.agents/skills/{name}/`, note the gap and generate the piece using general best practices instead."*

**Practical effect:** The skill can still produce every deliverable type using inline templates and general copywriting knowledge. The marketing skills provide depth and specialization but aren't critical-path.

### carousel-prompt-generator

> *"If `image` or `marketing-psychology` don't exist at `~/.agents/skills/{name}/`, note the gap and generate prompts using general best practices instead."*

**Practical effect:** Without `image`, the agent can't recommend AI models or handle model-specific aspect ratios. Without `marketing-psychology`, psychology-based slide roles are skipped (agent uses general composition advice).

### blog-post-generator

> *"If `copywriting`, `seo-audit`, or `ai-seo` don't exist at `~/.agents/skills/{name}/`, note the gap and write posts using general best practices."*

**Practical effect:** Without `seo-audit`, the agent uses generic SEO knowledge. Without `ai-seo`, AI search optimization is less structured. The skill still produces valid blog posts.

### infographic-brief-generator

> *"If `image` skill not installed: note the gap and generate briefs using general design best practices and the brand guide directly."*

**Practical effect:** The brand guide is still read directly. The `image` skill primarily adds model-specific visual direction. Briefs are still usable.

### monthly-drop-landing-page

No skill-loading fallback needed (loads 0 marketing skills). Fallback behavior exists for **missing images**: *"If any images are missing, flag the gap to the user and ask them to provide the missing files before proceeding. Do not generate placeholder content for missing images."*

---

## 10. Validation Summary

### All Referenced Marketing Skills Exist in the Installed Catalog

| Skill | Referenced By | Status |
|---|---|---|
| `content-strategy` | content-plan-generator (Step 2) | ✅ Installed |
| `marketing-psychology` | content-plan-generator (4a), carousel-prompt-generator (3) | ✅ Installed |
| `copywriting` | content-plan-generator (4b), blog-post-generator (3) | ✅ Installed |
| `seo-audit` | content-plan-generator (4c), blog-post-generator (3) | ✅ Installed |
| `ai-seo` | content-plan-generator (4c, alt), blog-post-generator (3) | ✅ Installed |
| `emails` | content-plan-generator (4d) | ✅ Installed |
| `social` | content-plan-generator (4e), carousel-prompt-generator (3, opt) | ✅ Installed |
| `video` | content-plan-generator (4f) | ✅ Installed |
| `ad-creative` | content-plan-generator (4g), carousel-prompt-generator (3, opt) | ✅ Installed |
| `lead-magnets` | content-plan-generator (4h) | ✅ Installed |
| `offers` | content-plan-generator (4h, with lead-magnets) | ✅ Installed |
| `programmatic-seo` | content-plan-generator (4i) | ✅ Installed |
| `competitors` | content-plan-generator (4i, alt) | ✅ Installed |
| `image` | content-plan-generator (4j), carousel-prompt-generator (2), infographic-brief-generator (2) | ✅ Installed |
| `copy-editing` | content-plan-generator (5) | ✅ Installed |
| `analytics` | content-plan-generator (6) | ✅ Installed |

### Custom Skill Cross-References

| From | To | How |
|---|---|---|
| content-plan-generator (4a) | carousel-prompt-generator | "For full carousel prompt generation, load the dedicated `carousel-prompt-generator` skill" |
| content-plan-generator (4b) | blog-post-generator | "For full blog post production, load the dedicated `blog-post-generator` skill" |
| content-plan-generator (4c) | infographic-brief-generator | "For infographics, load the dedicated `infographic-brief-generator` skill" |

These cross-references are **one-directional** — the sub-skills never load back into content-plan-generator. No circular dependencies.

### Pipeline Stage Read Relationships

| Stage | Reads From | Writes To |
|---|---|---|
| 1 — content-plan-generator | Brand context (AGENT.md, knowledgebase, brand guide) | Content plan (md + html) |
| 2 — carousel-prompt-generator | Content plan (carousel entries), brand guide | Carousel prompts (md + html) |
| 2 — blog-post-generator | Content plan (blog entries), knowledgebase, sitemap | Blog posts (md + html) |
| 3 — infographic-brief-generator | Content plan (infographic entries), brand guide | Infographic briefs (md + html) |
| 4 — image generation (human) | Carousel prompts, design briefs, SOPs | Named PNG files |
| 5 — monthly-drop-landing-page | All prior stage outputs (files + images) | Deployed Vercel URL |

### Graceful Degradation

| Scenario | Behavior |
|---|---|
| Marketing skill not installed | Note gap, use general best practices |
| Custom sub-skill not available | Use inline templates in content-plan-generator |
| Images missing at landing page | Flag gap, ask user, do not proceed |
| No sitemap for blog posts | Note gap, proceed without internal links |
| Brand guide has no color palette | Use generic descriptive language, no invented hex values |
| Content plan has 0 infographics | Flag and stop — nothing to generate |

---

## 11. Identified Gaps

### 11.1 No Formal Schema Validation Between Stages

Each stage reads the prior stage's output as unstructured text (md/html files). There is no:
- JSON schema defining what a "carousel entry" must contain
- TypeScript interface that blog entries must satisfy
- Validation step that checks content plan completeness before delegation

**Risk:** If content-plan-generator produces a carousel entry missing a required field (e.g., no design brief), the carousel-prompt-generator would silently proceed with incomplete data. The fallback is the agent's general knowledge, not a structured validation.

**Mitigation:** Each skill's SKILL.md says "extract carousel entries" or "pull blog entries" — the agent is expected to handle missing fields conversationally. In practice, the content-plan-generator's template ensures all fields are present.

### 11.2 Parallelism Not Explicitly Instructed

The SKILL.md files describe a sequential pipeline within content-plan-generator:
```
Step 4a (carousels) → Step 4b (blogs) → Step 4c (infographics) → ...
```

But pipeline stages 2 and 3 are documented as parallel in `CONTEXT.md` and `WORKFLOW.md`. The content-plan-generator currently blocks on generating all content types before releasing to stages 2/3/4, even though those stages could start as soon as their specific deliverable section is complete.

**No structural issue** — the agent could still parallelize by running sub-skills independently. The SKILL.md just doesn't instruct this explicitly.

### 11.3 Landing Page Has No Pre-Build Validation Script

Before creating the GitHub repo and pushing to Vercel, the landing page skill runs `npx vite build` which catches compilation errors. However, there is no earlier validation check that:
- All expected image files exist before the build step
- The content config (`{brandname}-content.ts`) matches the actual file structure
- Anchor IDs in blog-posts.html match what the route files expect

**Practical impact:** The build step catches most issues, and `ImageOrPlaceholder.tsx` handles missing images gracefully. This is a minor gap.

### 11.4 offers Skill Referenced But Not Documented as Loaded

In `content-plan-generator/SKILL.md`, the lead magnet row says skills: `lead-magnets`, `offers`. However, the detailed Step 4h section only says "Load `lead-magnets` skill" — it doesn't explicitly call `skill("offers")`. The `offers` skill is listed in the table but may not be actively loaded during execution.

**Status:** Minor documentation inconsistency. The `offers` skill provides offer construction (bonuses, guarantees, scarcity) which is relevant to lead magnet design. Whether it's loaded depends on the agent following the table vs. the detailed step text.

### 11.5 Landing Page Has No Skill Fallback for Missing Content Plan

The landing page requires `content-plan.html` and `blog-posts.html`. If these don't exist, the skill says "flag the gap." But unlike the other skills, there is no inline template or fallback generation — the skill simply cannot proceed without prior stage outputs. This is by design (terminal skill), but it's the hardest dependency in the system.

---

## Summary

| Aspect | Verdict |
|---|---|
| All referenced skills exist in catalog | ✅ 16 marketing skills + 5 custom skills all accounted for |
| No circular dependencies | ✅ Clean DAG — content-plan → sub-skills → landing page |
| Graceful fallback for missing skills | ✅ Every content skill has documented fallback |
| Parallel stages documented | ✅ Stages 2+3 documented as parallel (though not maximized in instruction) |
| Data flows between stages | ✅ Each skill's inputs/outputs are documented |
| Landing page has hard dependencies | ✅ By design — terminal skill requires prior outputs |
| Minor gaps found | 4 issues identified above (schema, parallelism, pre-build validation, offers skill) |

**Overall: Properly connected.** The 5 custom skills form a clean directed acyclic graph. All 16 referenced marketing skills exist in the installed catalog. Every skill documents its fallback behavior. The only improvements would be formal schema validation between stages and explicit parallelization instructions.

---

*End of skill connections report.*
