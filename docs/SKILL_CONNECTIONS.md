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
          │  content-       │ │  blog-post-     │ │  infographic-   │
          │  strategy       │ │  generator      │ │  brief-         │
          │  (marketing     │ │  (custom)        │ │  generator      │
          │   skill)        │ │                  │ │  (custom)       │
          └────────┬────────┘ └────────┬─────────┘ └────────┬────────┘
                   │                   │                    │
    ┌──────────────┼──────────────┐    │    ┌───────────────┼──────────────┐
    ▼              ▼              ▼    │    ▼               ▼              ▼
┌────────┐ ┌──────────────┐ ┌────────┐│┌────────┐ ┌───────────────┐ ┌────────┐
│carousel│ │copywriting   │ │image   │││copywrit│ │seo-audit      │ │image   │
│prompt  │ │(marketing)   │ │(market │││ing     │ │(marketing)    │ │(market │
│genera- │ │              │ │ing)    │││(market │ │              │ │ing)    │
│tor     │ │              │ │        │││ing)    │ │              │ │        │
│(custom)│ │              │ │        │││        │ │              │ │        │
└───┬────┘ └──────┬───────┘ └────────┘│└────────┘ └──────┬───────┘ └────────┘
    │             │                   │                  │
    │   ┌─────────┘                   │    ┌─────────────┘
    │   │                             │    │
    ▼   ▼                             │    ▼
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

### Step 0 — Brand Context Loading

Every skill loaded downstream reads from these files indirectly through the agent's working memory:

| File / Directory | Path | What It Provides |
|---|---|---|
| Product marketing doc | `Brands/{BrandName}/.agents/product-marketing.md` | Positioning, ICP, personas, voice, tone, competitive landscape, proof points, goals |
| Master Strategy Doc | `Brands/{BrandName}/Knowledgebase/*MasterStrategyDoc*.html` | Brand positioning, core value props, strategic priorities |
| Marketing Brain | `Brands/{BrandName}/Knowledgebase/*marketing_brain*.html` | Campaign logic, growth model, key narratives |
| Message Block Library | `Brands/{BrandName}/Knowledgebase/*MessageBlockLibrary*.html` or `*message*.html` | Approved phrases, tone rules, words to avoid |
| Channel Acquisition Map | `Brands/{BrandName}/Knowledgebase/*ChannelAcquisitionMap*.html` or `*Channel*.html` | Channel rules per segment |
| Buyer Clusters | `Brands/{BrandName}/Knowledgebase/*BuyerCluster*.html` or `*persona*.html` or `*cluster*.html` | Cluster names, priority ranking, triggers |
| Objections | `Brands/{BrandName}/Knowledgebase/*Objection*.html` | Objections to neutralize in content |
| Genesis / Origin | `Brands/{BrandName}/Knowledgebase/*Genesis*.html` or `*origin*.html` | Brand origin, founding story, trust signals |
| Intelligence / Raw | `Brands/{BrandName}/Knowledgebase/*Intelligence*.html` or `*Raw*.html` | Market data, competitor context |
| Brand Guide | `Brands/{BrandName}/BrandKit/brand-guide.html` | Color palette, typography, logo usage rules, visual style guidelines |
| Logo files | `Brands/{BrandName}/BrandKit/logos/` | Logo SVG/PNG for brand recognition |
| App screenshots | `Brands/{BrandName}/BrandKit/app-screenshots/` | Reference for visual design briefs |
| Mockups | `Brands/{BrandName}/BrandKit/mockups/` | Reference for visual design briefs |

### Skills It Loads — With File Paths

| Step | Skill(s) Loaded | Reads From | Purpose |
|---|---|---|---|
| 2 | `content-strategy` | `Brands/{BrandName}/.agents/product-marketing.md` (positioning), `Knowledgebase/*BuyerCluster*.html` (clusters), `Knowledgebase/*Intelligence*.html` (market data) | Define 3-5 content pillars, score topics, map to buyer stages |
| 4a | `marketing-psychology` | Carousel entries (title, topic, persona from the content plan being built), `BrandKit/brand-guide.html` (visual style for hook/CTA recommendations) | Select psychology principles for carousel hooks |
| 4b | `copywriting` | `Knowledgebase/*MessageBlockLibrary*.html` (approved phrases), `Brands/{BrandName}/.agents/product-marketing.md` (voice, tone, positioning) | Write copy for every deliverable type |
| 4c | `seo-audit` or `ai-seo` | Blog post outlines (H2 skeleton, keywords from the content plan), `Knowledgebase/` (related topics for internal linking) | SEO metadata for blog posts and SEO pages |
| 4d | `emails` | `Knowledgebase/*MessageBlockLibrary*.html` (tone), `Knowledgebase/*Objection*.html` (pain points to address) | Email sequence design, subject lines, body |
| 4e | `social` | `Knowledgebase/*BuyerCluster*.html` (persona for platform choice), content plan deliverable entries | Platform-specific social post copy |
| 4f | `video` | Content plan's video entries (topic, format), `BrandKit/brand-guide.html` (visual direction) | Video script structure and production approach |
| 4g | `ad-creative` | Content plan's ad entries (goal, audience), `Knowledgebase/` (value props, differentiators) | Ad headline and description variants |
| 4h | `lead-magnets`, `offers` | `Knowledgebase/*Objection*.html` (pain points to gate behind content), `Brands/{BrandName}/.agents/product-marketing.md` (offer structure) | Lead magnet format, topic, gating strategy |
| 4i | `programmatic-seo` or `competitors` | `Knowledgebase/` (target keywords, competitor intel), `Brands/{BrandName}/.agents/product-marketing.md` (differentiators) | SEO page templates (programmatic pages or competitor comparisons) |
| 4j | `image` | `BrandKit/brand-guide.html` (colors, typography, density), content plan infographic entries | Infographic design brief and visual direction |
| 5 | `copy-editing` | Every piece written in Step 4 (carousel copy, blog body, email body, social posts, ad copy, lead magnet copy, SEO page copy) | Seven Sweeps polish on all copy (Clarity, Voice, So What, Prove It, Specificity, Heightened Emotion, Zero Risk) |
| 6 | `analytics` | Brand URLs from `Knowledgebase/` (CTAs, landing pages), deliverable types from the content plan | UTM parameters, tracking events, conversion goals |

### Skills It Delegates To (cross-skill)

| Deliverable | Delegated To | What the Sub-Skill Produces | Input It Receives |
|---|---|---|---|
| Carousel prompts | `carousel-prompt-generator` (custom) | Per-slide AI image prompts (md + html) | Content plan carousel entries (title, persona, slide copy, design brief) |
| Blog posts | `blog-post-generator` (custom) | SEO-optimized blog posts (md + html) | Content plan blog entries (title, persona, intro, H2 skeleton, CTA hint) + knowledgebase + sitemap |
| Infographic briefs | `infographic-brief-generator` (custom) | Design briefs (md + html) | Content plan infographic entries (title, topic, persona, data points, visual hints) + brand guide |

### Default Deliverable Set

| Deliverable | Count | Optional? | Skills Loaded |
|---|---|---|---|
| Carousels (3-4 slides, visual-first) | 8 | — | `marketing-psychology`, `copywriting` |
| Blog Posts (SEO-optimized) | 4-6 | — | `copywriting`, `seo-audit`/`ai-seo` |
| Newsletters / Emails | 4-6 | — | `emails`, `copywriting` |
| Social Posts (LinkedIn, X, Instagram) | 8-12 | Optional | `social`, `copywriting` |
| Video Scripts (AI or programmatic) | 2-4 | Optional | `video`, `copywriting` |
| Ad Creative (headlines, descriptions, variants) | 3-5 | Optional | `ad-creative` |
| Lead Magnets (gated content) | 1-2 | Optional | `lead-magnets`, `offers` |
| SEO Content Pages (programmatic or comparison) | 2-3 | Optional | `programmatic-seo`, `competitors` |
| Infographics (design brief) | 2 | — | `image` |

### Output

| File | Path |
|---|---|
| Markdown draft | `Monthly_Cycles/[NN]-[MMMYY]/01_content_plan/output/[BrandName]_Content_Plan_[MONTH]_[YEAR].md` |
| Approved HTML | `Monthly_Cycles/[NN]-[MMMYY]/01_content_plan/output/[BrandName]_Content_Plan_[MONTH]_[YEAR].html` |
| Config (optional) | `Brands/{BrandName}/.agents/content-plan-config.json` |
| Template used | `@skill_root/references/content-plan-template.html` |

---

## 3. carousel-prompt-generator

### Step 1 — Extract Carousel Entries

| Reads From | What It Extracts |
|---|---|
| Content plan output file: `Monthly_Cycles/[NN]-[MMMYY]/01_content_plan/output/[BrandName]_Content_Plan_[MONTH]_[YEAR].md` or `.html` | Carousel entries: title, persona, slide copy, design brief, role tags (Hook, Info, Conversion, CTA) |

Ignores blog posts, emails, newsletters, push notifications, and infographic entries — they're not part of this process.

### Skills It Loads — With File Paths

| Step | Skill(s) Loaded | Reads From | Purpose |
|---|---|---|---|
| 2 | `image` | `BrandKit/brand_guide.md` (colors, typography, tone, density, graphic system, imagery rules) following `references/brand-extraction-checklist.md`. Then checks `Knowledgebase/[BrandName]_Prompt_Improvement_Guide.md` if it exists | Extract visual rules from brand guide. Inform model-specific visual direction (Flux, Midjourney, DALL-E). Also extract: photorealistic vs. illustrated, color overlays vs. clean photography, platform-specific visual rules |
| 3 | `marketing-psychology` | Content plan carousel entries (slide copy and role tags extracted in Step 1) | Select psychology principle per slide role: Hook → curiosity gap, Info → authority/chunking, Conversion → anchoring/contrast, CTA → scarcity/loss aversion |
| 3 | `image` (reloaded) | Brand visual rules from Step 2 + slide's role and copy from Step 1 | Recommend optimal AI model (Flux for photorealistic, Midjourney for stylized, DALL-E for text rendering). Reads `references/master-prompt-structure.md` for the 7-section creative brief format |
| 3 (optional) | `social` | Slide copy from Step 1. Only when user specifies platform (LinkedIn, Instagram, TikTok) | Platform-specific carousel formatting |
| 3 (optional) | `ad-creative` | Slide copy from Step 1. Only when user specifies ad-ready carousels | Ad-ready carousel formatting |

### Reference Files (bundled in skill directory)

| File | Purpose |
|---|---|
| `references/brand-extraction-checklist.md` | Step-by-step guide for what to extract from the brand guide: colors, typography, density, graphic system, imagery rules |
| `references/master-prompt-structure.md` | 7-section creative brief format per slide: preamble (aspect ratio, model, "Remove AI Slop"), Section 0-6 structure |
| `references/carousel-prompt-template.html` | HTML template for final output — dark/light toggle, copy-to-clipboard, sidebar navigation |

### Output

| File | Path |
|---|---|
| Markdown draft | `Monthly_Cycles/[NN]-[MMMYY]/02_prompts_and_copy/output/[BrandName]_Carousel_Prompts_[Month]_[Year].md` |
| Approved HTML | `Monthly_Cycles/[NN]-[MMMYY]/02_prompts_and_copy/output/[BrandName]_Carousel_Prompts_[Month]_[Year].html` |

---

## 4. blog-post-generator

### Step 1 — Locate Knowledgebase and Sitemap

| Reads From | What It Extracts |
|---|---|
| `Brands/{BrandName}/_knowledgebase/*.md`, `*.html`, `*.txt` | Brand tone, voice, approved/avoided phrasing, services, offers, differentiators, audience, buyer psychology, cluster docs, past content |
| `Brands/{BrandName}/_knowledgebase/sitemap.md` or `_knowledgebase/sitemap.xml` | Every real URL available for internal linking, organized by page type |

### Step 2 — Extract Blog Entries

| Reads From | What It Extracts |
|---|---|
| Content plan output file: `Monthly_Cycles/[NN]-[MMMYY]/01_content_plan/output/[BrandName]_Content_Plan_[MONTH]_[YEAR].md` or `.html` | Blog entries: title, persona, intro direction, H2 skeleton, CTA/URL hint |

Ignores carousels, emails, push notifications, and infographic briefs.

### Skills It Loads — With File Paths

| Step | Skill(s) Loaded | Reads From | Purpose |
|---|---|---|---|
| 3 | `copywriting` | Blog entry (title, intro, H2 skeleton from Step 2). Also reads `references/writing-rules.md` (brand-agnostic writing system: persuasive arc, sentence length, formatting) and `references/claims-policy.md` (governs facts, prices, claims — never invent) | Generate full blog body with H1-H3, persuasive structure, value proposition framing. Apply brand voice from knowledgebase |
| 3 | `seo-audit` | The generated blog post (body, headings, keywords from Step 3). Additionally uses knowledgebase for topic context | Validate title tags (under ~60 chars), meta descriptions (~140-160 chars), heading hierarchy (one H1, clean H2/H3), keyword placement, internal linking, readability (Grade 6-8), images & alt text |
| 3 | `ai-seo` | Same blog post body + knowledgebase content | Optimize for AI search visibility: LLM citations, featured snippets, structured answers, clear direct answers within first 200 words, `llms.txt`-compatible structure |

### Governance Files (bundled in skill directory)

| File | Purpose |
|---|---|
| `references/writing-rules.md` | Writing system: purpose, voice, SEO logic, structure, length, CTA logic, internal & external linking, readability target, images & alt text |
| `references/claims-policy.md` | Never invent facts, prices, or claims. Brand knowledgebase and uploaded file conflicts — trust the upload |

### Per-Post Metadata Produced

| Field | Format |
|---|---|
| SEO Title | Under ~60 characters, keyword-relevant |
| Meta Description | ~140-160 characters, compelling |
| URL Slug | Short, lowercase, hyphenated |
| Primary Keyword | From content plan |
| Secondary Keywords | Related terms, long-tail phrases, semantic variations |
| Search Intent | informational / commercial / local / navigational / transactional |

### Output

| File | Path |
|---|---|
| Markdown draft | `Monthly_Cycles/[NN]-[MMMYY]/02_prompts_and_copy/output/[BrandName]_Blog_Posts_[Month]_[Year].md` |
| Approved HTML | `Monthly_Cycles/[NN]-[MMMYY]/02_prompts_and_copy/output/[BrandName]_Blog_Posts_[Month]_[Year].html` (per-post `<article>` with `id="post-N"` anchors, sidebar nav, "Copy post" button, QA-only box) |

---

## 5. infographic-brief-generator

### Step 1 — Extract Infographic Entries

| Reads From | What It Extracts |
|---|---|
| Content plan output file: `Monthly_Cycles/[NN]-[MMMYY]/01_content_plan/output/[BrandName]_Content_Plan_[MONTH]_[YEAR].md` or `.html` | Infographic entries: title, topic, persona, data points, visual hints |

### Skills It Loads — With File Paths

| Step | Skill(s) Loaded | Reads From | Purpose |
|---|---|---|---|
| 2 | `image` | `BrandKit/brand_guide.md` (color palette — hex values, typography — family/weights/case, visual density — minimal vs. rich, imagery style — icons/illustrations/photography) | Inform infographic best practices: information density, color theory for data visualization, typography hierarchy for readability at various sizes. Also check for any existing infographic examples in past content |

### Per-Brief Sections Produced

| Section | Details |
|---|---|
| Overview | Title, persona, purpose (educate/compare/persuade/explain), format (static image / multi-page PDF) |
| Dimensions & Format | Canvas size (e.g. 1080x1920), orientation (vertical/horizontal/square), resolution (72dpi web / 300dpi print), bleed |
| Visual Hierarchy | Hero area, flow direction, section structure, reading order |
| Color System | Background, accent, text, data colors, neutral tones — from `BrandKit/brand_guide.md` or descriptive |
| Typography | Headline, body, data/numbers, labels — from `BrandKit/brand_guide.md` |
| Data Presentation | Chart types, data callouts, comparisons, iconography |
| Layout Structure | Header, body sections, footer, white space |
| Style Summary | Density (minimal/balanced/dense), tone (professional/playful/luxury), design reference keywords |

### Output

| File | Path |
|---|---|
| Markdown draft | `Monthly_Cycles/[NN]-[MMMYY]/03_infographic_briefs/output/[BrandName]_Infographic_Briefs_[Month]_[Year].md` |
| Approved HTML | `Monthly_Cycles/[NN]-[MMMYY]/03_infographic_briefs/output/[BrandName]_Infographic_Briefs_[Month]_[Year].html` |

---

## 6. monthly-drop-landing-page — The Terminal Consumer

### Skills It Loads

**None.** This skill does not load any marketing skills. It is a pure file-assembly and deployment skill.

### What It Reads From Prior Stages — With Exact File Paths

| Input | Source Stage | Reads From | Format / Convention |
|---|---|---|---|
| Content plan | Stage 1 — content-plan-generator | `Monthly_Cycles/[NN]-[MMMYY]/01_content_plan/output/[BrandName]_Content_Plan_[MONTH]_[YEAR].html` (or `.md`) | Copied to `public/content-plan.html`. If `.md` given, agent generates HTML version using the same dark/light template |
| Blog posts | Stage 2 — blog-post-generator | `Monthly_Cycles/[NN]-[MMMYY]/02_prompts_and_copy/output/[BrandName]_Blog_Posts_[MONTH]_[YEAR].html` | Copied to `public/blog-posts.html`. Each post must have `id="post-N"` anchor for landing page linking |
| Brand hub URL | User-provided | Any URL (e.g. blog, website, Google Doc) | Used as the "Marketing Hub" link on the landing page hero section |
| Carousel slides | Stage 4 — human (ChatGPT) | Named PNGs per SOP: `carousel.N.M.png` (N = carousel number 1-indexed, M = slide number 1-indexed) | Mapped to `src/assets/[brandname]/carousels/cN/slide-(M-1).png` (zero-indexed) |
| Blog banners | Stage 4 — human (ChatGPT) | `blog.N.png` (N = blog number) | Mapped to `src/assets/[brandname]/blogs/blog{N}-banner.png` |
| Blog stories | Stage 4 — human (ChatGPT per SOP_Instagram_Story) | `blog.N-story.png` | Mapped to `src/assets/[brandname]/blogs/blog{N}-story.png` |
| Newsletter banners | Stage 4 — human (ChatGPT) | `newsletter.N.png` | Mapped to `src/assets/[brandname]/newsletters/newsletter.N.png` |
| Newsletter stories | Stage 4 — human (ChatGPT per SOP_Instagram_Story) | `newsletter.N-story.png` | Mapped to `src/assets/[brandname]/newsletters/email{N}-story.png` |

### Bundled Template

| Resource | Path | Purpose |
|---|---|---|
| Template root | `@skill_root/template/` | Full TanStack Start + shadcn/ui project |
| Config files | `template/package.json`, `vite.config.ts`, `tsconfig.json`, `vercel.json`, `bunfig.toml` | Project configuration, Vercel deployment settings |
| Routes | `template/src/routes/index.tsx`, `__root.tsx` | Landing page structure and layout |
| Content config reference | `template/src/lib/paywise-content.ts` | Model file — agent creates `src/lib/[brandname]-content.ts` from this |
| UI components | `template/src/components/ui/` (46 shadcn components) | accordion, alert, button, card, carousel, dialog, dropdown-menu, etc. |
| Brand components | `template/src/components/paywise/ImageOrPlaceholder.tsx`, `Lightbox.tsx` | Graceful image handling, click-to-expand lightbox |
| Placeholder images | `template/src/assets/paywise/` | 49 PNGs (carousels, blogs, newsletters) — swapped for real images in Step 5 |
| API | `template/api/index.js` | Vercel serverless function |
| Styles | `template/src/styles.css` | Brand theming (customized in Step 8) |

### SOPs Referenced

| SOP File | Path in Skill | Content Type |
|---|---|---|
| Carousel Slide Generation | `refferences/SOP_Carousel_Slide_Generation.md` (and `docs/SOP_reference/SOP_Carousel_Slide_Generation.md`) | 3:4 ratio → 1080x1350, logo placement, slide naming |
| Blog Banner Generation | `refferences/SOP_Blog_Banner_Image_Generation.md` (and `docs/SOP_reference/SOP_Blog_Banner_Image_Generation.md`) | 16:9 banners, single trained chat per brand |
| Instagram Story Banner Generation | `refferences/SOP_Instagram_Story_Banner_Generation.md` (and `docs/SOP_reference/SOP_Instagram_Story_Banner_Generation.md`) | 9:16 conversion, logo removal, naming |
| Newsletter Banner Generation | `refferences/SOP_Newsletter_Banner_Image_Generation.md` (and `docs/SOP_reference/SOP_Newsletter_Banner_Image_Generation.md`) | 16:9 banners, separate trained chat from blog |

### Image Mapping Details

```
carousel.1.1.png  →  src/assets/[brandname]/carousels/c1/slide-0.png
carousel.1.2.png  →  src/assets/[brandname]/carousels/c1/slide-1.png
carousel.2.1.png  →  src/assets/[brandname]/carousels/c2/slide-0.png
blog.1.png        →  src/assets/[brandname]/blogs/blog1-banner.png
blog.1-story.png  →  src/assets/[brandname]/blogs/blog1-story.png
newsletter.1.png  →  src/assets/[brandname]/newsletters/newsletter.1.png
newsletter.1-story.png  →  src/assets/[brandname]/newsletters/email1-story.png
```

### Output

| Item | Path / URL |
|---|---|
| Vercel deployment | Public URL (e.g. `https://[project].vercel.app/`) |
| GitHub repo | e.g. `github.com/[user]/[brand]-monthly-drop-[NN]` |
| Local project | `[brand_folder]/Monthly_Drops/[NN]-[MMMYY]-Monthly_Drop/` (can be deleted after deploy) |

---

## 7. Data Flow Between Stages

### Stage 1 → Stage 2 (content plan → carousel prompts)

```
Monthly_Cycles/[NN]-[MMMYY]/01_content_plan/output/
  [BrandName]_Content_Plan_[MONTH]_[YEAR].md or .html
                            │
                            ▼
carousel-prompt-generator extracts per entry:
  ┌──────────────────────┐
  │ Carousel 1:          │
  │   Title              │
  │   Persona            │
  │   Slide 1 copy       │
  │   Slide 2 copy       │
  │   ...                │
  │   Design brief       │
  │   Role tags          │
  └──────────────────────┘
```

### Stage 1 → Stage 2 (content plan → blog posts)

```
Monthly_Cycles/[NN]-[MMMYY]/01_content_plan/output/
  [BrandName]_Content_Plan_[MONTH]_[YEAR].md or .html
                            │
                            ▼
blog-post-generator extracts per entry:
  ┌──────────────────────┐
  │ Blog 1:              │
  │   Title              │
  │   Persona            │
  │   Intro paragraph    │
  │   H2 skeleton        │
  │   CTA hint           │
  │   Target keywords    │
  └──────────────────────┘
```

Also reads in Step 1:
```
Brands/{BrandName}/_knowledgebase/
  *.md, *.html, *.txt    (tone, voice, offers, differentiators)
  sitemap.md             (internal linking URLs)
  sitemap.xml            (alternative sitemap format)
```

### Stage 1 → Stage 3 (content plan → infographic briefs)

```
Monthly_Cycles/[NN]-[MMMYY]/01_content_plan/output/
  [BrandName]_Content_Plan_[MONTH]_[YEAR].md or .html
                            │
                            ▼
infographic-brief-generator extracts per entry:
  ┌──────────────────────┐
  │ Infographic 1:       │
  │   Title              │
  │   Topic              │
  │   Persona            │
  │   Data points        │
  │   Visual hints       │
  └──────────────────────┘
```

Also reads in Step 2:
```
Brands/{BrandName}/BrandKit/brand_guide.md
  → color palette (hex), typography (family/weights), visual density, imagery style
```

### Stage 1 + 2 + 4 → Stage 5 (all prior → landing page)

```
Stage 1 output:
  Monthly_Cycles/[NN]-[MMMYY]/01_content_plan/output/
    [BrandName]_Content_Plan_[MONTH]_[YEAR].html   →  public/content-plan.html
    (carousel titles, slide counts, blog H2 anchors, CTA text, push notification copy)

Stage 2 output:
  Monthly_Cycles/[NN]-[MMMYY]/02_prompts_and_copy/output/
    [BrandName]_Blog_Posts_[MONTH]_[YEAR].html      →  public/blog-posts.html
    (with id="post-1", id="post-2", ... anchors)

Stage 4 — human output (named per SOPs):
  carousel.1.1.png, carousel.1.2.png, ...            →  carousels/c1/slide-0.png, ...
  blog.1.png, blog.2.png, ...                        →  blogs/blog1-banner.png, ...
  blog.1-story.png, blog.2-story.png, ...            →  blogs/blog1-story.png, ...
  newsletter.1.png, newsletter.2.png, ...            →  newsletters/newsletter.1.png, ...
  newsletter.1-story.png, newsletter.2-story.png, ... →  newsletters/email1-story.png, ...

User-provided:
  Brand hub URL                                      →  landing page "Marketing Hub" link
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

| Stage Pair | Relationship | Why | File Dependency |
|---|---|---|---|
| 1 → 2 | **Sequential** | Carousel prompts need content plan entries | `01_content_plan/output/*.html` → carousel-prompt-generator |
| 1 → 3 | **Sequential** | Infographic briefs need content plan entries | `01_content_plan/output/*.html` → infographic-brief-generator |
| 2 + 3 | **Parallel** | No cross-dependency. Both read from stage 1 independently | Stage 1 output is read-only |
| 2 → 4 | **Sequential** | Image prompts must exist before human image generation | `02_prompts_and_copy/output/*carousel*` → ChatGPT |
| 3 → 4 | **Sequential** | Design briefs must exist before image generation | `03_infographic_briefs/output/*` → ChatGPT/designer |
| 4 → 5 | **Sequential** | Images must be generated and named before landing page assembly | Named PNG files → `src/assets/[brandname]/` |
| 5 → 6/7 | **Sequential** | Landing page must be approved before scheduling/reporting | Vercel URL → scheduling |

### Current Limitation

Although stages 2 and 3 are technically parallel, the content-plan-generator skill currently generates them **sequentially within its own pipeline** (Step 4a → carousels, Step 4b → blogs, Step 4c → infographics). True parallelism would require running the three sub-skills as independent agents — which the skill system could support but the SKILL.md instructions don't currently prescribe.

---

## 9. Fallback Behavior (Skill Missing)

Every custom skill documents what happens when a referenced marketing skill isn't installed.

### content-plan-generator

> *"If a referenced skill doesn't exist at `~/.agents/skills/{name}/`, note the gap and generate the piece using general best practices instead."*

| Missing Skill | Fallback Effect |
|---|---|
| `content-strategy` | Agent defines pillars from general marketing knowledge + brand context already loaded from `product-marketing.md` |
| `marketing-psychology` | Carousel hooks use general curiosity/callout composition instead of psychology-specific visual direction |
| `copywriting` | Agent writes copy using general persuasive writing skills from `product-marketing.md` tone rules |
| `seo-audit` / `ai-seo` | Agent applies general SEO best practices (keyword in H1, meta desc, etc.) |
| `emails` | Email sequences use general email marketing structure instead of skill-specific templates |
| `social` | Social posts use general platform knowledge |
| `video` | Video script structure uses general narrative arc |
| `ad-creative` | Ad variants use general copywriting formulas |
| `lead-magnets` / `offers` | Lead magnet uses general content gating strategy |
| `programmatic-seo` / `competitors` | SEO pages use general template structure |
| `image` | Visual direction uses brand guide directly without model-specific optimization |
| `copy-editing` | Posts skip the Seven Sweeps polish but are still reviewed by the agent |
| `analytics` | UTM parameters are generated from general conventions rather than skill-specific templates |

### carousel-prompt-generator

> *"If `image` or `marketing-psychology` don't exist at `~/.agents/skills/{name}/`, note the gap and generate prompts using general best practices instead."*

| Missing Skill | Fallback Effect |
|---|---|
| `image` | No AI model recommendation (Flux/Midjourney/DALL-E). Aspect ratios use defaults. No "Remove AI Slop" preamble. Still reads `brand_guide.md` directly |
| `marketing-psychology` | No psychology-based slide role targeting. Agent uses general composition advice per role. Still reads `master-prompt-structure.md` for format |
| `social` (optional) | Platform-specific formatting skipped — uses generic carousel format |
| `ad-creative` (optional) | Ad-specific formatting skipped — uses generic carousel format |

### blog-post-generator

> *"If `copywriting`, `seo-audit`, or `ai-seo` don't exist at `~/.agents/skills/{name}/`, note the gap and write posts using general best practices."*

| Missing Skill | Fallback Effect |
|---|---|
| `copywriting` | Agent writes blog body using general persuasive structure. Still reads `writing-rules.md` and `claims-policy.md` |
| `seo-audit` | Agent applies general SEO rules (title length, meta desc, heading hierarchy) from `writing-rules.md` |
| `ai-seo` | AI search optimization uses general best practices (direct answers, FAQ structure). `llms.txt` compatibility skipped |

### infographic-brief-generator

> *"If `image` skill not installed: note the gap and generate briefs using general design best practices and the brand guide directly."*

| Missing Skill | Fallback Effect |
|---|---|
| `image` | Brand guide is still read directly. Color palette uses descriptive language if no hex values available. Model-specific visual optimization skipped |

### monthly-drop-landing-page

No skill-loading fallback needed (loads 0 marketing skills). Fallback behavior exists for **missing images**:

> *"If any images are missing, flag the gap to the user and ask them to provide the missing files before proceeding. Do not generate placeholder content for missing images."*

The template's `ImageOrPlaceholder.tsx` component handles missing images at runtime by showing a styled placeholder with the image name and dimensions, but the SKILL.md instructs the agent not to proceed with missing files.

---

## 10. Validation Summary

### All Referenced Marketing Skills Exist in the Installed Catalog

| Skill | Referenced By | File Paths It Reads | Status |
|---|---|---|---|
| `content-strategy` | content-plan-generator (Step 2) | `product-marketing.md`, `Knowledgebase/*.html` | ✅ Installed |
| `marketing-psychology` | content-plan-generator (4a), carousel-prompt-generator (3) | Content plan entries, `brand_guide.md` | ✅ Installed |
| `copywriting` | content-plan-generator (4b), blog-post-generator (3) | `product-marketing.md`, `Knowledgebase/*message*.html`, `writing-rules.md`, `claims-policy.md` | ✅ Installed |
| `seo-audit` | content-plan-generator (4c), blog-post-generator (3) | Blog post body + metadata, `writing-rules.md` | ✅ Installed |
| `ai-seo` | content-plan-generator (4c alt), blog-post-generator (3) | Blog post body, knowledgebase | ✅ Installed |
| `emails` | content-plan-generator (4d) | `Knowledgebase/*message*.html`, `*Objection*.html` | ✅ Installed |
| `social` | content-plan-generator (4e), carousel-prompt-generator (3 opt) | Content plan entries, `Knowledgebase/` | ✅ Installed |
| `video` | content-plan-generator (4f) | Content plan video entries, `brand_guide.md` | ✅ Installed |
| `ad-creative` | content-plan-generator (4g), carousel-prompt-generator (3 opt) | Content plan ad entries, `product-marketing.md` | ✅ Installed |
| `lead-magnets` | content-plan-generator (4h) | `Knowledgebase/*Objection*.html`, `product-marketing.md` | ✅ Installed |
| `offers` | content-plan-generator (4h, with lead-magnets) | `product-marketing.md` (offer structure) | ✅ Installed |
| `programmatic-seo` | content-plan-generator (4i) | `Knowledgebase/` (keywords), `product-marketing.md` (differentiators) | ✅ Installed |
| `competitors` | content-plan-generator (4i alt) | `Knowledgebase/` (competitor intel) | ✅ Installed |
| `image` | content-plan-generator (4j), carousel-prompt-generator (2), infographic-brief-generator (2) | `BrandKit/brand_guide.md`, `brand-extraction-checklist.md`, optionally `Prompt_Improvement_Guide.md` | ✅ Installed |
| `copy-editing` | content-plan-generator (5) | Every piece written in Step 4 of content plan | ✅ Installed |
| `analytics` | content-plan-generator (6) | Brand URLs from knowledgebase, deliverable types from content plan | ✅ Installed |

### Custom Skill Cross-References

| From | To | Input Passed | How |
|---|---|---|---|
| content-plan-generator (4a) | carousel-prompt-generator | Content plan carousel entries (title, persona, slide copy, design brief) | "For full carousel prompt generation, load the dedicated `carousel-prompt-generator` skill" |
| content-plan-generator (4b) | blog-post-generator | Content plan blog entries (title, persona, intro, H2 skeleton, CTA hint) + knowledgebase + sitemap | "For full blog post production, load the dedicated `blog-post-generator` skill" |
| content-plan-generator (4c) | infographic-brief-generator | Content plan infographic entries (title, topic, persona, data points, visual hints) + brand guide | "For infographics, load the dedicated `infographic-brief-generator` skill" |

These cross-references are **one-directional** — the sub-skills never load back into content-plan-generator. No circular dependencies.

### Pipeline Stage File Read Relationships

| Stage | Reads From (Exact Paths) | Writes To |
|---|---|---|
| 1 — content-plan-generator | `Brands/{BrandName}/.agents/product-marketing.md`, `Knowledgebase/*.html` (8 patterns), `BrandKit/brand-guide.html`, `BrandKit/logos/`, `BrandKit/app-screenshots/`, `BrandKit/mockups/` | `01_content_plan/output/[Brand]_Content_Plan_[M]_[Y].md` + `.html` |
| 2 — carousel-prompt-generator | `01_content_plan/output/*.html` (carousel entries), `BrandKit/brand_guide.md`, `Knowledgebase/*Prompt_Improvement_Guide.md` (optional), `references/brand-extraction-checklist.md`, `references/master-prompt-structure.md` | `02_prompts_and_copy/output/[Brand]_Carousel_Prompts_[M]_[Y].md` + `.html` |
| 2 — blog-post-generator | `01_content_plan/output/*.html` (blog entries), `Brands/{BrandName}/_knowledgebase/*` (tone, offers), `_knowledgebase/sitemap.md` or `.xml` (internal links), `references/writing-rules.md`, `references/claims-policy.md` | `02_prompts_and_copy/output/[Brand]_Blog_Posts_[M]_[Y].md` + `.html` |
| 3 — infographic-brief-generator | `01_content_plan/output/*.html` (infographic entries), `BrandKit/brand_guide.md` (colors, typography, density) | `03_infographic_briefs/output/[Brand]_Infographic_Briefs_[M]_[Y].md` + `.html` |
| 4 — image generation (human) | `02_prompts_and_copy/output/*carousel*` (prompts), `03_infographic_briefs/output/*` (design briefs), `docs/SOP_reference/*.md` (4 SOPs) | `carousel.N.M.png`, `blog.N.png`, `blog.N-story.png`, `newsletter.N.png`, `newsletter.N-story.png` |
| 5 — monthly-drop-landing-page | Content plan `.html`, blog posts `.html` (with `#post-N` anchors), all named PNGs, `@skill_root/template/`, `@skill_root/references/*SOP*.md`, `src/lib/paywise-content.ts` | Deployed Vercel URL |

### Graceful Degradation

| Scenario | Behavior |
|---|---|
| Marketing skill not installed | Note gap, use general best practices |
| Custom sub-skill not available | Use inline templates in content-plan-generator |
| Images missing at landing page | Flag gap, ask user, do not proceed |
| No sitemap for blog posts | Note gap, proceed without internal links |
| Brand guide has no color palette | Use generic descriptive language, no invented hex values |
| Content plan has 0 infographics | Flag and stop — nothing to generate for infographic-brief-generator |
| `Prompt_Improvement_Guide.md` missing | Proceed without it — generic defaults are fine |

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
- The content config (`[brandname]-content.ts`) matches the actual file structure
- Anchor IDs in `blog-posts.html` match what the route files expect

**Practical impact:** The build step catches most issues, and `ImageOrPlaceholder.tsx` handles missing images gracefully. This is a minor gap.

### 11.4 offers Skill Referenced But Not Explicitly Loaded

In `content-plan-generator/SKILL.md`, the lead magnet row says skills: `lead-magnets`, `offers`. However, the detailed Step 4h section only says "Load `lead-magnets` skill" — it doesn't explicitly call `skill("offers")`. The `offers` skill is listed in the table but may not be actively loaded during execution.

**Status:** Minor documentation inconsistency. The `offers` skill provides offer construction (bonuses, guarantees, scarcity) which is relevant to lead magnet design. Whether it's loaded depends on the agent following the table vs. the detailed step text.

### 11.5 Landing Page Has No Skill Fallback for Missing Content Plan

The landing page requires `content-plan.html` and `blog-posts.html`. If these don't exist, the skill says "flag the gap." But unlike the other skills, there is no inline template or fallback generation — the skill simply cannot proceed without prior stage outputs. This is by design (terminal skill), but it's the hardest dependency in the system.

---

## Summary

| Aspect | Verdict |
|---|---|
| All referenced skills exist in catalog | ✅ 16 marketing skills + 5 custom skills all accounted for |
| All file paths trace to actual files | ✅ Every input/output mapped to exact paths |
| No circular dependencies | ✅ Clean DAG — content-plan → sub-skills → landing page |
| Graceful fallback for missing skills | ✅ Every content skill has documented fallback |
| Parallel stages documented | ✅ Stages 2+3 documented as parallel (though not maximized in instruction) |
| Data flows between stages | ✅ Each skill's input/output files are documented with exact paths |
| Landing page has hard dependencies | ✅ By design — terminal skill requires prior outputs |
| Minor gaps found | 4 issues identified above |

**Overall: Properly connected.** The 5 custom skills form a clean directed acyclic graph. All 16 referenced marketing skills exist in the installed catalog. Every skill documents its fallback behavior and reads from known file paths. The only improvements would be formal schema validation between stages, explicit parallelization instructions, and a pre-build validation script for the landing page.

---

*End of skill connections report.*
