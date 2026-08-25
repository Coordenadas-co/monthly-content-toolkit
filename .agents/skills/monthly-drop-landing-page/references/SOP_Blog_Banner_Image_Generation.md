# SOP — Blog Banner Image Generation

> **RETIRED — 2026-08-25.** Pablo no longer generates blog banners by hand in ChatGPT.
> `blog-post-generator` now writes a generation-ready prompt per post (Step 4b) that goes
> through the same automated pipeline as carousels (`n8n` profile → ComfyUI Cloud, via
> `/webhook/one-click`). Kept below for historical reference / style continuity only —
> the 16:9 ratio and `blog.N` filename convention it documents still apply.

**Owner:** Pablo (Coordenadas)
**Status:** Documented manual process. Fully human-guided — no companion skill exists or is planned
for this step, as the process is short and consistent enough not to need one.
**Scope:** This step runs after the `blog-post-generator` skill has produced the month's blog
titles. It covers generating one banner image per blog post (and newsletter, since they share the
same banner). It does NOT cover resizing, logo placement, or client delivery — those are later,
separate steps.

---

## Overview

This is a single-part, fully manual process. The output is one finished, ready-to-use banner image
per blog title, generated in ChatGPT using the brand's established visual style. No post-processing
skill is involved — the images come out at the right ratio and generally need no touch-up.

The key to keeping this fast is a properly set-up, brand-trained chat in ChatGPT. Once the chat has
seen the brand's visual references, individual prompts become a single line. The setup work pays for
itself from the second banner onward.

---

## Step 1 — Open (or create) the brand's banner chat in ChatGPT

In the company ChatGPT account, go to the specific brand's Project. Look for a chat named something
like **"Blog banner image generator"** (or similar). Most active brands already have one set up and
trained.

If the chat doesn't exist yet for this brand, create it now — it will persist and accumulate
context across every future monthly run.

---

## Step 2 — Initialize the chat with visual references (first time only)

This step only applies when opening a brand-new chat. Skip to Step 3 if the chat already exists
and has been used before.

Before writing any prompt, attach the visual references that will train the chat's style. Use one
of the following, in order of preference:

- **3–4 existing banner images** from this brand's history (strongest signal — the model will
  replicate the actual output, not an interpreted description of it).
- **A design sheet** for the brand, combined with a more descriptive prompt (see below) if no past
  banners exist.

Then send the initialization prompt. Adapt based on what references you're attaching:

**If using past banner images:**
> "You will be a chat used solely for the purpose of generating images. Specifically banners that
> will be used for blog posts and newsletters. I want you to replicate the same design styles and
> layouts of the images attached to follow the same branding.
> Now generate a banner for a blog with the title: **[Blog_Title]**"

**If using a design sheet (no past banners):**
> "I need you to create the images for the blog banners. Follow the design style of the image
> attached — same colours, same contrasts, same fonts, same design elements, same ratio, same
> layouts, similar photography style. You may generate new images, but keep them visually
> consistent.
> The title for the first blog banner is: **[Blog_Title]**"

Always select **"Create Image"** as the action and **16:9** as the image ratio before generating.

---

## Step 3 — Generate one banner per blog title

For each blog title in the month's content plan, in order:

1. Send a short prompt — once the chat is trained, a single line is enough:
   > "Now I want you to create a banner for the title: **[Blog_Title]**"
2. Select **"Create Image"** and confirm the ratio is **16:9**.
3. Review the output. Blog banners rarely need a retry, but if the style drifts noticeably from the
   established look, regenerate before moving on.

Repeat for every blog title. There is no need to reference previous prompts or re-attach references
within the same chat — the context carries.

---

## Step 4 — Download and name files as you go

Download each banner immediately after approving it and name it using this convention:

```
blog.[number]
```

Examples:
```
blog.1
blog.2
blog.3
blog.4
```

The number corresponds to the blog's order in the content plan for that month. Name at download
time — not at the end of the session — so the order is never lost.

---

## Principles to preserve

- **Set up the chat once, reuse it every month.** A trained chat is an asset. Don't create a new
  one each run — the accumulated style context is what keeps prompts short and output consistent.
- **Visual references beat written descriptions.** Past banner images are the strongest input you
  can give. Use them whenever available.
- **16:9 is the fixed ratio — always confirm it.** ChatGPT doesn't always retain the last ratio
  selection between generations; check before each generate.
- **Name at download, not at the end.** The `blog.N` convention has to be applied the moment the
  file leaves ChatGPT, or order gets lost in a folder of untitled images.
- **This step doesn't need touch-up by design.** Blog banners don't require logo placement or pixel
  standardization the way carousel slides do — the ratio is standard, and the banner is used as-is.
  If a banner needs significant manual correction, it's faster to regenerate than to edit.
