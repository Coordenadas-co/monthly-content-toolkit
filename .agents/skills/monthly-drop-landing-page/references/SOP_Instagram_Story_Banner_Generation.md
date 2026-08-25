# SOP — Instagram Story Banner Generation

> **RETIRED — 2026-08-25.** Pablo no longer converts banners to Stories by hand in ChatGPT.
> `blog-post-generator` (Step 4b) and `content-plan-generator` (Newsletter/Email step) now each
> write a Story companion prompt alongside the banner prompt — same composition reused verbatim,
> 9:16 instead of 16:9, logo explicitly omitted — through the same automated pipeline (`n8n`
> profile → ComfyUI Cloud). No image-to-image step: the visual match comes from reusing the same
> detailed prompt text, not from feeding the banner image back in. Kept below for historical
> reference only — the 1080×1920 size and `blog.N-story`/`newsletter.N-story` filename convention
> it documents still apply.

**Owner:** Pablo (Coordenadas)
**Status:** Documented manual process. Fully human-guided — no companion skill exists or is planned
for this step.
**Scope:** This step runs after both the Blog Banner and Newsletter Banner SOPs are complete. It
covers converting every 16:9 banner into a 9:16 Instagram Story version. It does NOT cover
scheduling, posting, or client delivery — those are later, separate steps.

---

## Overview

A simple conversion step. Each blog and newsletter banner gets a Story version — a 1080×1920px
vertical reformat — timed to go out alongside its corresponding blog post or newsletter send. The
only creative decision is whether to remove the logo: if the banner has one, it comes off, so the
bottom of the Story stays clear for an Instagram Link sticker.

All conversions happen in a single shared chat inside the brand's ChatGPT Project, regardless of
whether the source banner is a blog or newsletter banner.

---

## Step 1 — Open (or create) the brand's Story chat in ChatGPT

In the company ChatGPT account, go to the specific brand's Project. Look for a chat named something
like **"IG Story Banner Generator"** (or similar).

If it doesn't exist yet, create it. No initialization or training prompt is needed — this chat
doesn't need to learn a style. Each banner image you drop in carries its own visual context.

---

## Step 2 — Convert each banner, one at a time

For each banner (blog and newsletter), in order:

1. Drop the 16:9 banner image directly into the chat.
2. Send the appropriate prompt based on whether the banner includes a logo:

   **If the banner has a logo:**
   > "Recreate the same banner design but in a 9:16 ratio (1080×1920 pixels) so I can post it as a
   > story on IG. Just remove the logo."

   **If the banner does not have a logo:**
   > "Recreate the same banner design but in a 9:16 ratio (1080×1920 pixels) so I can post it as a
   > story on IG."

3. Select **"Create Image"** as the action. Ratio selection isn't needed here since it's specified
   in the prompt, but confirm the output dimensions look correct before downloading.

The logo is removed specifically to keep the bottom of the Story clear for an Instagram Link
sticker — not for aesthetic reasons. Don't skip this step on banners that have a logo.

---

## Step 3 — Download and name files as you go

Download and name each Story image immediately using this convention, mirroring the source file's
number:

```
blog.[number]-story
newsletter.[number]-story
```

Examples:
```
blog.1-story
blog.2-story
blog.3-story
blog.4-story
newsletter.1-story
newsletter.2-story
newsletter.3-story
newsletter.4-story
```

The number must match the source banner's number exactly — `blog.2-story` is the Story version of
`blog.2`, and so on. Name at download time.

---

## Principles to preserve

- **One shared chat for all Story conversions.** Blog and newsletter stories both go through the
  same "IG Story Banner Generator" chat — there's no need to separate them since no persistent
  style training is involved.
- **Logo removal is functional, not aesthetic.** It exists to keep the bottom of the Story clear
  for an Instagram Link sticker. Always remove the logo if it's present in the source banner.
- **The source image is the prompt.** No written style description needed — dropping the 16:9
  banner directly into the chat gives the model everything it needs.
- **Name must mirror the source number.** The `-story` suffix ties each Story back to its source
  file. Don't renumber or reorder.
