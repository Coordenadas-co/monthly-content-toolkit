# SOP — Carousel Slide Image Generation

> **STALE / SUPERSEDED — 2026-08-25.** This document predates the automated pipeline and was
> never updated: `carousel-prompt-generator` produces the per-slide prompts (unchanged), and
> generation now runs through `n8n` → ComfyUI Cloud (`/webhook/one-click`), not manual ChatGPT.
> Confirmed live — 24 real carousel images (8 carousels × 3 slides) generated this way for
> PayWise. Part 2 (post-processing: standardize dimensions, logo placement, file naming) may
> still apply depending on whether `carousel-slide-processor` runs after the automated
> generation — not re-verified as part of this pass. Kept below for historical reference only.

**Owner:** Pablo (Coordenadas)
**Status:** Documented manual process. Part 2 (post-generation) has a companion Claude skill
(`carousel-slide-processor`) that handles the automatable steps. Part 1 (generation in ChatGPT)
stays manual — Claude doesn't have control over the company ChatGPT account or Photoshop.
**Scope:** This is the step that comes right after `carousel-prompt-generator`. That skill produces
the per-slide prompts; this SOP covers turning those prompts into final, brand-ready slide images.
It does NOT cover banner generation, landing page preview, or client notification — those are
later, separate steps in the larger pipeline.

---

## Overview

Two parts:

1. **Image generation** (manual, in ChatGPT) — turn each slide prompt into a raw generated image.
2. **Post-processing** (semi-automated, via the `carousel-slide-processor` Claude skill) —
   standardize every slide to the same pixel dimensions, remove any unwanted artifacts ChatGPT
   added, place the brand logo consistently, and organize/name the final files.

Human judgment stays in the loop at two points by design: which direction to crop each image, and
which slides actually need the logo. Neither of these should be automated away — they're real
creative decisions, not busywork.

---

## Part 1 — Generate the raw images (manual, ChatGPT)

### Step 1 — Open the brand's image generation project in ChatGPT
In the company ChatGPT account, go into the specific brand's Project. Inside it, there's a chat
dedicated to this task, usually named something like **"Carousel slide image generator"**. Most
active brands already have this chat set up. If one doesn't exist yet, the project manager creates
it from scratch for that brand.

### Step 2 — Generate one slide at a time
For each slide, in order:
1. Tell ChatGPT (using the **ChatGPT Image 2.0** model):
   > "Let's create slide number **[X]** of a new/the previous carousel: **[paste the slide's full
   > prompt from the carousel-prompt-generator output]**"
2. Attach supporting visual references as needed: the brand logo, the brand's design sheet, or any
   other visual direction/style reference.
3. Select **"Create image."**
4. Select **3:4** as the image aspect ratio. This isn't the final target ratio (see Part 2) — it's
   the closest option ChatGPT currently offers to the actual target of 1080×1350 (a 4:5 ratio), so
   3:4 is the deliberate workaround.

### Step 3 — Download and name files as you go
Download each finished slide and name it immediately using this convention:

```
carousel.[carousel number].[slide number]
```

Examples:
```
carousel.1.1
carousel.1.2
carousel.1.3
carousel.2.1
carousel.2.2
```

This naming is what preserves carousel/slide order and identity once files leave ChatGPT's chat
history — don't skip it or rename loosely later, since the post-processing step depends on knowing
which slide belongs to which carousel.

---

## Part 2 — Standardize and finalize (semi-automated, `carousel-slide-processor` skill)

Once all raw slides for a batch are generated and named, hand them to the
`carousel-slide-processor` skill (or do this manually in Photoshop/Affinity if the skill isn't
being used for a given run). The problem this part solves: ChatGPT's 3:4 output doesn't actually
come out at a single consistent pixel size across slides, and 3:4 isn't the real target ratio
anyway. Every slide needs to land on the exact same final dimensions so the logo — once placed —
sits at identical margins on every slide.

### Step 1 — Resize and crop to 1080 × 1350px
The fixed target for every brand, every carousel, is **1080px × 1350px**. Since ChatGPT's 3:4
output (ratio 0.75) is narrower than the 4:5 target (ratio 0.8), some cropping is unavoidable —
there's always a little more image than the final frame needs in one dimension.

**Crop direction is a per-image creative decision, not something to automate blindly.** Look at
each image and decide whether the crop should come from the top, the bottom, or be centered,
based on where the actual subject/visual weight of that specific image sits. A photo with the
subject's face near the top crops differently than one with the focal point lower in frame.

### Step 2 — Remove any unwanted elements
Sometimes ChatGPT's output includes something that needs to be cleaned up before the brand's real
logo goes on — a watermark-like artifact, an unwanted stray element, or a placeholder mark. Remove
it with a content-aware/inpainting fill so the area blends naturally with its surroundings. This
matters most on simpler, flatter backgrounds — busy photographic backgrounds are harder to clean
seamlessly and may still need a manual touch-up pass in Photoshop/Affinity afterward.

### Step 3 — Place the brand logo
Once every slide in the batch is the exact same 1080×1350px, the logo can be placed at one fixed
position (corner + margin) and that position will look identical across every slide — this is the
entire reason standardizing pixel size first matters. The logo file and its exact placement (which
corner, margin in px) come from the brand guide. If the brand guide doesn't document logo placement,
flag the gap rather than guessing a position.

**Not every slide needs the logo.** This is a human call, made explicitly per slide — never
inferred automatically. Common patterns (not rules): the logo often goes on the first and/or last
slide, sometimes skipped through the middle, but there's no fixed formula — it depends on the
specific carousel and what looks right. Always get an explicit list of which slide numbers get the
logo before placing it.

### Step 4 — Save and organize
Save all final slides, organized into folders by carousel number, using the same naming convention
established in Part 1:

```
/Carousel 1/
  carousel.1.1.png
  carousel.1.2.png
  carousel.1.3.png
/Carousel 2/
  carousel.2.1.png
  carousel.2.2.png
```

---

## Principles to preserve

- **Human judgment stays at the two real decision points**: crop direction per image, and which
  slides get the logo. Never auto-decide either of these — ask explicitly every time.
- **Pixel-perfect consistency is the whole point of standardizing.** Margins only look identical
  across a carousel if every slide is the exact same final pixel size before the logo goes on.
- **Logo placement is brand-guide-sourced, not assumed.** Corner and margin come from documented
  brand specs; flag the gap if they're not documented rather than picking a default.
- **Naming discipline starts at download, not at the end.** The `carousel.N.N` convention has to be
  applied the moment files leave ChatGPT, or slide/carousel identity gets lost.
- **Content-aware removal is best-effort, not guaranteed.** Code-based inpainting handles simple
  cases well; busy or highly detailed backgrounds may still need a manual Photoshop/Affinity pass.
