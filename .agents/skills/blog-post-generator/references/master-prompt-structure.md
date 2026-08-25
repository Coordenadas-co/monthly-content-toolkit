# Master Prompt Structure (Brand-Agnostic)

This is the fixed 7-section structure every slide prompt must follow. It's the brand-agnostic
descendant of the original `MASTER_PROMPT_SYSTEM.txt` (built for Sierra Nevada / LaHaus-style
real estate ads). The structure stays the same across every brand — what fills each section comes
from that brand's brand guide, never from a hardcoded default.

Use this file as the section-by-section skeleton when writing each slide's prompt. Read
`references/brand-extraction-checklist.md` first to know what to pull from the brand guide before
writing prompts.

---

## 0. Preamble — Technical Image Parameters (applied to every prompt)

This preamble is prepended to **every** slide's prompt, before the 7 creative sections below.

**Always included — aspect ratio & dimensions:**
```
Make the image 4:5 aspect ratio. Make it exactly 1080 x 1350 pixels.
```

**Included by default — realism instructions (omit only if user explicitly asks to exclude them):**
```
Remove AI Slop:
Create a highly realistic, professional photo as if taken with a real phone camera.
- Preserve natural skin texture, pores, slight facial hair, natural redness, and subtle oil shine.
- Avoid overly smooth, artificial, or posterized skin tones.
- Ensure realistic lighting and contrast; do not add perfect cinematic lighting or exaggerated shadows.
- Maintain natural color gradients; avoid hyper-dramatic HDR or contrast.
- Replicate real camera imperfections: slight tilts, off-center framing, and cropped foreheads or edges.
- Preserve depth and detail in clothing, hair, and surrounding objects.
- Avoid AI-generated "enhancements" that make the image look unnatural or like a poster.
- The photo should feel like a genuine candid shot rather than a cinematic or magazine-style photo.
```

Format in every prompt:
```
[Preamble text — aspect ratio + realism instructions]

---
[7-section creative brief starting with "Slide X of Y — ..."]
```

---

## The 7 sections, in order, every time

### 1. Context Header
- Slide number (e.g. "Slide 2 of 5")
- Carousel title / topic
- Slide role: **Hook / Info / Conversion / CTA** (pulled directly from the Content Plan's slide tag
  — never inferred or guessed; see SKILL.md Step 2 for what to do if a role tag is missing)

### 2. Background / Image Direction
- **Type of image** — aerial, lifestyle, architecture, product, portrait, abstract, etc. Pick what
  fits the slide's role and the brand's documented imagery style.
- **Lighting** — golden hour, bright/flat, moody, studio, natural daylight, etc. — from the brand
  guide if it specifies a mood/lighting preference; otherwise pick what fits the slide's role
  (Hook slides often want more dramatic/aspirational lighting than an Info slide, for instance).
- **Composition** — what's visible, where, and roughly how much of the frame it occupies. Be
  specific enough that two different image models would produce visually similar layouts.
- **Overlay instructions** — color + opacity of any color overlay on top of the photo/illustration,
  using the brand's actual palette (never a placeholder color).
- **Continuity rule** — if this slide is part of a multi-slide carousel, state explicitly what
  should stay visually consistent with the other slides in *this same carousel* (e.g. same
  location, same color overlay treatment, same subject). Continuity is scoped to the current
  carousel only — never reference other carousels in the same content plan.

### 3. Text Layout
Break into the sub-areas that apply to this slide (omit any that don't apply — don't force a price
block onto a Hook slide that has no price):
- **Top area** — small label, tag, or kicker text if the slide copy has one
- **Main headline** — the slide's primary message, taken from the Content Plan's slide copy
- **Supporting text** — secondary copy, if the slide copy includes it
- **Price block** — only if the slide copy includes pricing/numeric info
- **CTA** — only on slides with a CTA role, or where the slide copy explicitly contains a CTA

### 4. Graphic Elements
Only include elements the brand guide actually calls for — never assume pills, bubbles, accent
bars, or badges by default. If the brand guide specifies a graphic system, name the elements and
how they're used (e.g. "rounded pill tags for category labels, positioned top-left"). If the brand
guide is minimal/clean with no graphic system, say so explicitly in the prompt rather than
inventing decoration.

### 5. Color System
Pull exact values from the brand guide:
- Background tones (hex or named, as the brand guide provides)
- Accent color(s)
- Text color(s)

Never invent or default a palette. If the brand guide doesn't specify enough colors to fill this
section, flag the gap (see SKILL.md Step 3 — Handling Gaps) rather than guessing.

### 6. Typography Rule
- Typeface family/style as specified in the brand guide (serif vs. sans-serif, weight, case
  treatment, any specific font names given)
- If the brand guide is silent on typography, flag the gap rather than defaulting to "bold
  sans-serif" or any other unstated assumption

### 7. Style Summary
- **Emotional tone** — urgent / aspirational / editorial / warm / authoritative / etc., matched to
  both the brand guide's documented voice and this slide's specific role
- **Density level** — minimal vs. dense info-graphic — from the brand guide's documented style, not
  assumed
- **Visual intention** — conversion-focused or storytelling-focused, matched to the slide's role
  (CTA and Conversion slides skew conversion; Hook and Info slides can skew storytelling depending
  on the brand)

---

## Formatting each slide's output

Each slide becomes one prompt block, structured as:

1. **The preamble** (Section 0 above — aspect ratio + realism instructions)
2. A `---` separator line
3. **The 7-section creative brief** (Sections 1–7 below) written in clean prose/structured text

Write the creative brief the way a creative director would brief an image generator: specific,
intentional, no filler like "nice design" or "modern look." A human reading the prompt should be
able to picture the exact image before generating it.

The preamble handles all technical rendering parameters consistently — the 7 sections below focus
purely on creative direction (composition, text layout, colors, typography, etc.).

## Worked example (illustrative only — not a template to copy verbatim)

This shows the *shape* the final prompt prose should take, using placeholder brand values. Replace
every bracketed value with the real brand guide's content and the real slide copy.

> Make the image 4:5 aspect ratio. Make it exactly 1080 x 1350 pixels.
> Remove AI Slop:
> Create a highly realistic, professional photo as if taken with a real phone camera.
> - Preserve natural skin texture, pores, slight facial hair, natural redness, and subtle oil shine.
> - Avoid overly smooth, artificial, or posterized skin tones.
> - Ensure realistic lighting and contrast; do not add perfect cinematic lighting or exaggerated shadows.
> - Maintain natural color gradients; avoid hyper-dramatic HDR or contrast.
> - Replicate real camera imperfections: slight tilts, off-center framing, and cropped foreheads or edges.
> - Preserve depth and detail in clothing, hair, and surrounding objects.
> - Avoid AI-generated "enhancements" that make the image look unnatural or like a poster.
> - The photo should feel like a genuine candid shot rather than a cinematic or magazine-style photo.
>
> ---
>
> **Slide 1 of 5 — "[Carousel Title]" — Role: Hook**
>
> Aerial photograph of [subject], captured at [lighting condition], composition centered on
> [focal point] with [supporting element] visible in the [frame position]. Apply a [color, e.g.
> "#1B3D2F"] overlay at roughly [opacity]% across the lower third to seat the text block. This is
> slide 1 of a 5-slide carousel — establish the location/subject here so slides 2–5 can stay
> visually consistent with it.
>
> Text layout: small kicker label top-left reading "[kicker copy]"; main headline centered in the
> lower third reading "[headline copy from slide copy]"; no supporting text on this slide; no price
> block; no CTA (reserved for the final slide).
>
> Graphic elements: [only if brand guide specifies any — otherwise state "no additional graphic
> elements; clean photographic treatment only"].
>
> Color system: background tone [hex], accent [hex] used in the kicker label background, headline
> text in [hex].
>
> Typography: [brand guide's specified typeface/weight], headline in [weight] for maximum
> legibility against the photo.
>
> Style summary: aspirational, high-impact opening tone; minimal density (single message,
> uncluttered); storytelling intention — establish the dream/outcome before the carousel moves into
> specifics on slides 2–4.
