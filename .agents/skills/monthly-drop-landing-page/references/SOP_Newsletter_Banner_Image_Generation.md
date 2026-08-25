# SOP — Newsletter Banner Image Generation

> **RETIRED — 2026-08-25.** Pablo no longer generates newsletter banners by hand in ChatGPT.
> `content-plan-generator` now writes a generation-ready prompt per newsletter (Newsletter/Email
> step) that goes through the same automated pipeline as carousels (`n8n` profile → ComfyUI
> Cloud, via `/webhook/one-click`). Kept below for historical reference / style continuity only —
> the 16:9 ratio and `newsletter.N` filename convention it documents still apply.

**Owner:** Pablo (Coordenadas)
**Status:** Documented manual process. Fully human-guided — no companion skill exists or is planned
for this step.
**Scope:** This step runs after the `blog-post-generator` skill has produced the month's newsletter
subjects. It covers generating one banner image per newsletter. It does NOT cover resizing, logo
placement, or client delivery — those are later, separate steps.

---

## Overview

This process is nearly identical to the Blog Banner SOP. The only structural difference is that
newsletters live in their own dedicated chat inside the brand's ChatGPT Project — separate from the
blog banner chat — even if the visual difference between the two is subtle. Keeping them separate
preserves independent style contexts and prevents cross-contamination between the two banner types
over time.

---

## Step 1 — Open (or create) the brand's newsletter banner chat in ChatGPT

In the company ChatGPT account, go to the specific brand's Project. Look for a chat named something
like **"Newsletter banner image generator"** (or similar).

If it doesn't exist yet, create it now. Do not use the blog banner chat for this — even if the
designs look nearly identical, they stay in separate chats.

---

## Step 2 — Initialize the chat with visual references (first time only)

Skip to Step 3 if the chat already exists and has been used before.

Attach the brand's visual references — past newsletter banners if available, or the design sheet if
not — then send the initialization prompt. Mirror the blog banner initialization exactly, substituting
"newsletter" for "blog":

**If using past newsletter banners:**
> "You will be a chat used solely for the purpose of generating images. Specifically banners that
> will be used for newsletters. I want you to replicate the same design styles and layouts of the
> images attached to follow the same branding.
> Now generate a banner for a newsletter with the subject: **[Newsletter_Subject]**"

**If using a design sheet (no past banners):**
> "I need you to create the images for the newsletter banners. Follow the design style of the image
> attached — same colours, same contrasts, same fonts, same design elements, same ratio, same
> layouts, similar photography style. You may generate new images, but keep them visually
> consistent.
> The subject for the first newsletter banner is: **[Newsletter_Subject]**"

Always select **"Create Image"** as the action and **16:9** as the image ratio before generating.

---

## Step 3 — Generate one banner per newsletter

For each newsletter in the month's content plan, in order:

1. Send a short prompt — the title, subject line, or a close variation of it:
   > "Now I want you to create a banner for the newsletter: **[Newsletter_Subject]**"
2. Select **"Create Image"** and confirm the ratio is **16:9**.
3. Review and approve before moving to the next one.

---

## Step 4 — Download and name files as you go

Download and name each banner immediately using this convention:

```
newsletter.[number]
```

Examples:
```
newsletter.1
newsletter.2
newsletter.3
newsletter.4
```

The number corresponds to the newsletter's order in the month's content plan. Name at download
time, not at the end of the session.

---

## Principles to preserve

- **Separate chat from blog banners, always.** Even a small design difference justifies its own
  chat — style contexts should never mix between content types.
- **Same rules as blog banners otherwise.** Visual references over written descriptions, 16:9 every
  time, name at download, regenerate instead of editing.
- **Use the newsletter subject, not the blog title.** The prompt input here is the newsletter
  subject line (or a variation of it) — not a rephrased blog title, even when the topic overlaps.
