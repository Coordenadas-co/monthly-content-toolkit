# Brand Guide Extraction Checklist

Read this before writing any prompts. Its job is to make sure every visual decision in the prompt
comes from the brand guide — not from habit, not from what looked good for a previous client.

The brand guide can arrive in several forms: a file uploaded directly to the chat (PDF, DOCX, MD,
TXT, image), or a document already sitting in the Claude Project's knowledgebase (e.g. a Marketing
Brain output like `MasterStrategyDoc.html`). Either way, locate and read it before extracting
anything below. If it's an image (e.g. a brand board screenshot), read it visually — colors,
typography, layout density are often easier to see than to find written down.

---

## What to extract

Go through the brand guide and pull out, verbatim where possible:

| Field | What you're looking for | Where it's used |
|---|---|---|
| **Color palette** | Exact hex values (or named colors if hex isn't given) for background, accent, and text colors | Section 5 — Color System, every slide |
| **Typography** | Typeface family, weight, serif/sans-serif, any stated exceptions | Section 6 — Typography Rule, every slide |
| **Visual tone / emotional register** | Words like aspirational, urgent, editorial, warm, premium, playful — whatever the brand guide actually says | Section 7 — Style Summary |
| **Density preference** | Minimal/clean vs. dense info-graphic-style layouts — look for example images or explicit statements | Sections 2, 4, 7 |
| **Graphic system** | Pills, bubbles, accent bars, badges, icons — only if the brand guide documents one | Section 4 — Graphic Elements |
| **Imagery rules** | What kinds of photos/illustrations are on-brand or off-limits (e.g. "always real photography, never illustration," or "never show people's faces") | Section 2 — Background/Image Direction |
| **Brand voice for on-image copy** | If the brand guide has tone-of-voice rules that affect how headline copy should *read* visually (e.g. all caps vs. sentence case) | Section 3 — Text Layout |

---

## Handling gaps

Brand guides are rarely complete. When something this process needs isn't in the brand guide:

1. **Don't invent it.** Never default to a previous client's colors, "bold sans-serif," LaHaus-style
   density, or any other unstated assumption — even if it would look fine.
2. **Flag it clearly** to the user in your response, naming exactly what's missing (e.g. "the brand
   guide doesn't specify an accent color — only the dark green background and cream text are
   defined") rather than silently working around it.
3. **Ask before proceeding** if the gap is large enough to block a whole section (e.g. no
   typography information at all). If it's a small, single-field gap, you can proceed using only
   what's confirmed and note the gap inline in your summary so the user can fill it in before
   sending prompts off to generate images.

---

## A note on reused brand guides

If you're generating prompts for a brand you've already extracted details for earlier in this same
conversation, don't re-ask the user to re-confirm unless something's genuinely ambiguous — reuse
what's already been extracted and stay consistent across all 10 carousels in the run.
