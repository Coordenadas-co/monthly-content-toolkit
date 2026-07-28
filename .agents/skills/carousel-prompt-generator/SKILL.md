---
name: carousel-prompt-generator
description: >
  Generates AI image-generation prompts for every slide of every carousel in a
  brand's Content Plan. Integrates the `image` skill (for model-specific prompt
  optimization and visual direction) and `marketing-psychology` skill (for
  slide-role-targeted psychological hooks). Output is a .md file for review,
  then a styled .html file (dark/light toggle) with copy-to-clipboard and
  sidebar navigation. Brand-agnostic — works for any client.
compatibility: >
  Requires the marketing skills from coreyhaines31/marketingskills installed at
  ~/.agents/skills/. Uses `image` and `marketing-psychology` at specific steps.
  No external dependencies — output is pure HTML/CSS.
---

# Carousel Prompt Generator v2

Turns a Content Plan's carousel section into a complete set of ready-to-paste AI
image-generation prompts — one prompt per slide, structured the same way every
time, but visually grounded in whatever brand guide is provided for that client.
No brand's visual style is ever assumed by default; the brand guide is the only
source of truth for color, typography, density, and tone.

This skill is step one of a longer pipeline (prompts → generate images →
banners → landing page preview → client notification). It only covers prompt
generation — stop once both output files are delivered.

---

## How Skill Integration Works

Throughout this workflow, you will load marketing skills using the `skill` tool.
Each skill produces output tailored to its domain. You adapt that output into
the prompt generation process.

| Step | Skill to load | Why |
|---|---|---|
| Step 2 | `image` | Inform model-specific visual direction, aspect ratios, overlay techniques when parsing the brand guide |
| Step 3 | `image` | Recommend optimal AI model (Flux, Midjourney, DALL-E) per slide type + platform conventions |
| Step 3 | `marketing-psychology` | Select psychology principles per slide role: Hook → curiosity gap, Info → authority/chunking, Conversion → anchoring/contrast, CTA → scarcity/loss aversion |

`social` and `ad-creative` skills are available but optional — only load them if
the user explicitly says these carousels are for a specific social platform
(LinkedIn vs Instagram) or for paid advertising use.

---

## What you need before starting

Three inputs, all of which may already be available in context (uploaded files,
or files already loaded in the knowledgebase) — check before asking the user to
provide anything:

1. **The Content Plan** for the relevant month(s) — containing the carousel
   section you'll extract from. Carousels follow the `content-plan-generator`
   skill's format: numbered slides with role tags, e.g. `Slide 1 (Hook):`,
   `Slide 2 (Info):`.
2. **The brand guide** for the client — any format (text, MD, HTML, PDF, image,
   or knowledgebase doc like a Marketing Brain output).
3. **The Master Prompt structure** — read `references/master-prompt-structure.md`
   in this skill. This is the fixed 7-section structure every prompt follows.
   You don't need anything from the user for this — it's bundled.

If the Content Plan or brand guide isn't in context and wasn't uploaded, ask for
it before proceeding. Don't generate prompts from assumptions about a brand you
haven't actually seen documentation for.

---

## Step 0 — Language

If the user has not specified a language, ask:

> "Should these prompts be in **English** or **Spanish**?"

If they specify both (e.g., English prompts with Spanish on-image copy), note it
and respect per-slide. If they don't answer, default to English.

Every prompt, label, and output file uses the chosen language from this point
forward.

---

## Step 1 — Extract the carousels from the Content Plan

Read through the Content Plan and pull out **only the carousel entries** —
ignore blog posts, emails, newsletters, push notifications, and infographic
briefs entirely. They're not part of this process.

For each carousel, capture:
- Title
- Persona (if listed)
- Each slide's number, role tag, and copy
- Visual or design brief (if the content plan has one for the carousel)

**If a slide is missing its role tag** (older content plans, or one written
outside the content-plan-generator skill, won't have it): don't guess silently.
Infer the most likely role from position (first slide = Hook, last slide = CTA,
middle slides = Info or Conversion based on content) and **flag to the user**
which slides you inferred roles for, so they can correct any before you generate
the full prompt set. This is a fallback, not the expected path — the expected
path is a content plan that already has roles tagged.

---

## Step 2 — Read the brand guide

Before reading the brand guide, load the `image` skill:

```
skill("image")
```

This gives you context on how different AI image models handle color,
typography, overlays, and composition — which helps you extract the right
details from the brand guide.

Then read `references/brand-extraction-checklist.md` and follow it exactly. It
tells you what to pull from the brand guide (colors, typography, tone, density,
graphic system, imagery rules) and — just as importantly — how to handle
anything the brand guide doesn't specify.

**With the `image` skill loaded, also extract:**
- Whether the brand tends toward **photorealistic or illustrated** imagery
- Whether the brand uses **color overlays** or **clean photography** for text
  legibility
- Whether the brand has **different visual rules for different platforms**
  (Instagram vs LinkedIn vs website)

If you've already extracted this brand's details earlier in the same
conversation, reuse that rather than re-reading the guide from scratch — but
stay alert for the user correcting or updating something.

### Step 2b — Check for brand-specific improvement guide

After reading the brand guide, check whether a file named
`[BrandName]_Prompt_Improvement_Guide.md` exists in the
01_knowledge_base/rules/ directory for this client. If it exists, read it.

This file contains brand-specific quality corrections that override the
generic defaults in this skill and in the client's template library. Apply
its rules when writing prompts — they fix known issues from previous
generations (e.g., exaggerated faces, thin decorative elements, simple
typography, phone-dominant compositions, repetitive trust signals, and
bloated slide counts).

If the file does not exist, proceed without it — the generic defaults are
fine as a starting point.

---

## Step 3 — Generate one prompt per slide

Load the `marketing-psychology` skill:

```
skill("marketing-psychology")
```

This gives you a framework of psychological principles keyed to each slide role.
Apply them as follows when writing prompts:

| Slide Role | Psychology principle | How it affects the visual |
|---|---|---|
| Hook | **Curiosity gap / Pattern interrupt** | Composition should feel slightly unexpected — asymmetrical framing, an unusual angle, a detail cropped in an intriguing way. The image itself asks "what's happening here?" |
| Info | **Authority / Chunking** | Clean, structured, easy-to-scan visual hierarchy. Info graphics, clear sectioning, data presented in digestible chunks. The image should feel trustworthy and organized. |
| Conversion | **Anchoring / Contrast** | Visual contrast between "before/after" or "old/new". Price anchoring via size/position emphasis. Comparison layouts. The image should make the choice feel obvious. |
| CTA | **Scarcity / Loss aversion** | Urgency cues — countdowns, "limited" visual language, exclusive-feeling color treatments (gold, dark + single accent). The image should make the viewer feel they might miss out. |

Then load the `image` skill (if not already loaded):

```
skill("image")
```

This informs model-specific recommendations. For each prompt, consider:

- **Flux** — best for photorealistic lifestyle, architecture, product shots with
  natural lighting and skin texture
- **Midjourney** — best for stylized/artistic compositions, brand-world
  illustration, surreal or aspirational concepts
- **DALL-E** — best for precise text rendering, complex multi-element scenes,
  specific typography-on-image

Match the model recommendation to the slide's role and the brand's visual style.

Now read `references/master-prompt-structure.md` for the preamble (Section 0)
and the full 7-section structure. For every slide in every carousel:

1. Build the 7-section creative brief populated with:
   - That slide's actual copy and role (from Step 1)
   - That brand's actual visual rules (from Step 2)
   - The psychology principle for that role (from marketing-psychology above)
   - A model recommendation in Section 1 (e.g. "Optimized for Flux — realistic
     phone photography style")
2. Keep continuity **within** a carousel — slides in the same carousel should
   read like one cohesive visual set (same subject/location continuity, same
   overlay treatment, etc., as described in the structure file). Carousels are
   independent of each other — never carry continuity across two different
   carousels in the same plan.
3. Default to exactly one prompt per slide. Only generate multiple prompt
   variants for a slide if the user explicitly asks for variants on that slide
   or carousel.
4. **Prepend the technical preamble** — Before the 7-section creative brief, add
   the mandatory preamble from Section 0 of `references/master-prompt-structure.md`
   (aspect ratio + dimensions + Remove AI Slop realism instructions). The aspect
   ratio line is always included. The Remove AI Slop block is included by
   default; omit it only if the user explicitly asks to exclude it.
5. Separate the preamble from the creative brief with a `---` line.

Work through carousels in the order they appear in the Content Plan. Pace
yourself methodically rather than rushing; a rushed prompt that skips brand
details defeats the purpose of this process.

---

## Step 4 — Write the Markdown deliverable

Structure the `.md` file as:

```markdown
# [Brand Name] — Carousel Image Prompts — [Month Year]

## [Carousel 1 Title]
_Persona: [persona] · [N] slides_

### Slide 1 — Hook
[Full prompt text]

### Slide 2 — Info
[Full prompt text]

...

## [Carousel 2 Title]
...
```

One `##` section per carousel, one `###` sub-section per slide, in Content-Plan
order. Save this file as:

```
output/[BrandName]_Carousel_Prompts_[Month]_[Year].md
```

---

## Step 5 — Deliver for User Approval

Present the .md to the user:

> "Here are the carousel image prompts: `output/[file].md`
>
> Total carousels: [N] · Total slides: [N] · Brand: [name]
>
> [Flag any inferred role tags or missing brand guide details here]
>
> Review and let me know if anything needs changing. Once approved, I'll
> generate the styled HTML version with copy-to-clipboard."

Wait for explicit approval ("looks good", "approved", "proceed") before
generating the HTML.

If the user requests changes, apply them first, then loop back to approval.

If the user says "generate both at once" or "skip approval", proceed directly
to Step 6 without waiting.

---

## Step 6 — Generate the .html File

After approval, generate the styled HTML version directly — no Python script
needed.

### 6a — Read the template and inject content

1. **Read the template** — load `references/carousel-prompt-template.html`
   from this skill's directory
2. **Inject content** — replace template placeholders with the plan content:
   - `{{BRAND_NAME}}` — brand name
   - `{{MONTH_YEAR}}` — e.g., "July 2026"
   - `{{LANGUAGE}}` — "English" or "Spanish"
   - `{{SIDEBAR_LINKS}}` — sidebar nav links, one per carousel:
     ```html
     <a href="#carousel-1" class="sidebar-link">Carousel Title</a>
     <a href="#carousel-2" class="sidebar-link">Another Title</a>
     ```
   - `{{CAROUSEL_SECTIONS}}` — full carousel HTML content (see structure
     below)
   - `{{GENERATED_DATE}}` — current date

### 6b — Carousel section structure

Each carousel becomes a `<section class="carousel-section" id="carousel-N">`
with the following child elements:

**Header** (click to collapse/expand):
```html
<div class="carousel-header">
  <h2>[Title]</h2>
  <span class="carousel-meta">N slides · [Persona]</span>
  <span class="carousel-toggle-icon">▼</span>
</div>
```

**Slides wrap** (hidden when collapsed):
```html
<div class="slides-wrap">
```

**Each slide card:**
```html
<div class="slide-card">
  <div class="slide-card-header">
    <span class="slide-number">Slide N</span>
    <span class="role-tag" data-role="[hook|info|conversion|cta]">[Role]</span>
    <span class="slide-meta">[optional: model recommendation]</span>
    <button class="copy-btn">📋</button>
  </div>
  <div class="prompt-box">
    <pre>[Full prompt text with preamble + --- + creative brief]</pre>
  </div>
</div>
```

**Close the slides wrap**: `</div>` after all slide cards for this carousel.

**Role tag colors** are handled by CSS based on the `data-role` attribute:
Hook → amber, Info → blue, Conversion → green, CTA → red. No inline styles
needed.

### 6c — Write the file

```
output/[BrandName]_Carousel_Prompts_[Month]_[Year].html
```

### 6d — Notes

- The sidebar navigation, theme toggle, collapse/expand, copy-to-clipboard, and
  scroll-spy are all handled by the template's built-in JavaScript. You only
  need to provide the correct content and data attributes.
- Role tag colors are applied via `data-role` attribute CSS — no inline styles
  needed.
- The template includes mobile responsive, print, and `prefers-reduced-motion`
  styles. No additional styling work needed.

---

## Step 7 — Deliver summary

Present the .html file path and a summary:
- Total carousels and total slides/prompts generated
- Brand name and month covered
- Any gaps flagged during brand guide extraction or role-tag inference
  that the user should double-check before sending prompts to an image generator

---

## Edge Cases

- **Content Plan has fewer or more than 10 carousels**: process whatever's
  actually there — 10/month is typical, not a hard requirement.
- **Brand guide conflicts with itself** (e.g. two different hex values given
  for the same color in different places): flag the conflict to the user and
  ask which is correct rather than picking one.
- **User wants prompts for only some carousels, not the whole plan**: process
  only the requested carousels; still extract full carousel-section data so
  titles/personas are accurate for those.
- **User requests variants on a specific slide**: generate the requested number
  of alternate prompts for that slide only, label them clearly (e.g. "Slide 3 —
  Variant A / Variant B"), and include all variants in both output files.
- **Brand guide is an image only** (e.g. a brand board screenshot with no
  accompanying text): read it visually for colors/typography/density; if
  something can't be determined visually (e.g. a specific font name), flag
  it as a gap.
- **User wants to exclude the Remove AI Slop realism block**: if the user
  explicitly says "don't include the AI slop instructions" or similar, omit the
  realism block from all prompts in that run. The aspect ratio + dimension line
  is still included.
- **User needs different dimensions or aspect ratio**: if the user requests a
  different format (e.g. "these are for Instagram Stories, 9:16"), update the
  preamble's dimension line to match the requested specs for that run.
- **User asks for social-specific carousels**: if they specify a platform
  (LinkedIn, Instagram, TikTok), optionally load the `social` skill for
  platform-specific conventions. Flag that you can do this and ask if they want it.
- **User asks for ad-ready carousels**: optionally load the `ad-creative` skill
  for ad-platform formatting requirements. Flag and ask.
- **Marketing skills not installed**: if `image` or `marketing-psychology` don't
  exist at `~/.agents/skills/{name}/`, note the gap and generate prompts using
  general best practices instead.
