---
name: blog-post-generator
description: >
  Writes the full, ready-to-publish copy for blog posts listed in a brand's
  Content Plan. Integrates `copywriting` (for brand voice and persuasive
  structure), `seo-audit` (for on-page SEO optimization), and `ai-seo` (for
  AI-search visibility). Also generates one banner image prompt per post (Step 4b,
  16:9, feeds the automated image-generation pipeline — replaces the retired manual
  ChatGPT banner process). Output is a .md file for review, then a styled .html
  file (dark/light toggle) with per-post "Copy" buttons. Brand-agnostic.
compatibility: >
  Requires the marketing skills from coreyhaines31/marketingskills installed at
  ~/.agents/skills/. Uses `copywriting`, `seo-audit`, and `ai-seo` at specific
  steps. No external dependencies — output is pure HTML/CSS.
---

# Blog Post Generator v2

Turns a Content Plan's blog post entries — title, rough intro direction, and a
generic H2 outline — into complete, SEO-optimized, ready-to-publish blog posts.
Every post is grounded in the brand's actual knowledgebase: real tone, real
offers, real differentiators, real internal links from the real sitemap. Nothing
about a fact, price, or claim is ever invented — see
`references/claims-policy.md`, which governs every post this skill writes.

This skill is the natural next step after `content-plan-generator`: that skill
gives you the blog post's title and skeleton; this skill writes the actual
publishable article.

---

## How Skill Integration Works

| Step | Skill to load | Why |
|---|---|---|
| Step 3 | `copywriting` | Inform brand voice, persuasive structure, value proposition framing per post |
| Step 3 | `seo-audit` | On-page SEO checklist: title tags, meta descriptions, heading hierarchy, keyword placement |
| Step 3 | `ai-seo` | Optimize for AI search visibility (LLM citations, featured snippets, structured answers) |

---

## What you need before starting

Three inputs. Check what's already available before asking the user for anything:

1. **The Content Plan** for the relevant month(s) — specifically its blog post
   entries (title, intro direction, H2 skeleton, persona, CTA hint).
2. **The brand's knowledge base (`01_knowledge_base/`)** — check the brand's `01_knowledge_base/` first
   (Marketing Brain outputs, message block library, buyer psychology docs, past
   content, etc.).
3. **A sitemap or page list** for internal linking — same rule: knowledgebase
   first, uploaded file as fallback.

If the Content Plan's blog section isn't available at all, ask for it before
proceeding — this skill writes full copy *for* planned posts, it doesn't invent
new blog topics from nothing.

---

## Step 0 — Language

If the user has not specified a language, ask:

> "Should these blog posts be in **English** or **Spanish**?"

If they specify both (e.g., English body copy with Spanish meta), note it and
respect per-field. If they don't answer, default to English.

Every post, label, and output file uses the chosen language from this point
forward.

---

## Step 1 — Locate the knowledge base and sitemap

Before writing anything, confirm where the brand's knowledgebase and sitemap
actually live for this run. Hold in mind, from `01_knowledge_base/`:
- Brand tone, voice, and approved/avoided phrasing
- Services, offers, differentiators, audience
- Buyer psychology / cluster docs
- Past content, so new posts don't contradict or duplicate

And from the sitemap/page list:
- Every real URL available for internal linking, organized by page type

---

## Step 2 — Extract the blog post entries from the Content Plan

Pull out each blog post's title, persona, intro direction, H2 skeleton, and any
CTA/URL hint. Ignore carousels, emails, push notifications, and infographic
briefs — they're not part of this process.

---

## Step 3 — Write each blog post

Load the relevant skills:

```
skill("copywriting")
skill("seo-audit")
skill("ai-seo")
```

Read `references/writing-rules.md` in full — it's the brand-agnostic writing
system (purpose, voice, SEO logic, structure, length, CTA logic, internal &
external linking, readability, images & alt text) this skill follows for every
post. Read `references/claims-policy.md` before writing any specific fact,
price, or claim.

For each blog post in the batch, produce:

**Metadata** (for WordPress/Yoast/RankMath fields — not part of the pasteable
post body):
1. **SEO Title** — clear, keyword-relevant, under ~60 characters
2. **Meta Description** — compelling, ~140–160 characters
3. **URL Slug** — short, lowercase, hyphenated
4. **Primary Keyword**
5. **Secondary Keywords** — related terms, long-tail phrases, semantic variations
6. **Search Intent** — informational / commercial / local / navigational / transactional

**The paste-ready post itself:**
7. **Blog Post body** — one H1, H2s, H3s, short paragraphs, Grade 6–8 reading
   level. Use the Content Plan's H2 skeleton as a starting draft; restructure if
   the topic calls for it. **Internal links (real sitemap URLs) and external
   links (only when a real source exists) must be woven directly into the body
   as inline `<a>` links.**
8. **Suggested CTA** — matched to the topic's awareness stage, written as a
   natural closing section
9. **Optional FAQ Section** — 3–5 FAQs, only when genuinely useful

**QA / production reference only:**
10. **Internal Links Used** — list of sitemap URLs placed in the body and why
11. **Image Placement Suggestions** — one line per natural break point
12. **Notes / Assumptions** — only if needed

**With the loaded skills, also apply:**
- `copywriting`: check that the post structure follows a persuasive arc (hook →
  problem → solution → proof → CTA), and that the value proposition is
  front-loaded where appropriate
- `seo-audit`: verify title tag structure, heading hierarchy is clean (one H1,
  no skipped levels), primary keyword appears in H1 + first paragraph + one H2,
  meta description length
- `ai-seo`: add clear, direct answers early in the post (within first 200
  words) for LLM citation potential; use structured lists for "What is X"
  questions; consider an `llms.txt`-compatible structure

Work through the batch in the order the blog posts appear in the Content Plan.
Don't pause between posts to check in — flag gaps inline per post (via
Notes/Assumptions) and keep moving through the full batch in one pass.

---

## Step 4 — Write the Markdown deliverable

One combined `.md` file containing every blog post in the batch, back to back,
in Content-Plan order:

```markdown
# [Brand Name] — Blog Posts — [Month Year]

---

## SEO Blog Post — [Post 1 Title]

### Suggested SEO Title
...

### Meta Description
...

### Suggested URL Slug
...

### Primary Keyword
...

### Secondary Keywords
...

### Search Intent
...

### Blog Post
[Full body, internal/external links already inline]

### Suggested CTA
...

### Optional FAQ Section
...

### Internal Links Used
[QA reference list]

### Image Placement Suggestions
...

### Notes / Assumptions
[Only if needed]

---

## SEO Blog Post — [Post 2 Title]
...
```

Use `---` horizontal rules to separate each post. Save as:

```
output/[BrandName]_Blog_Posts_[Month]_[Year].md
```

---

## Step 4b — Generate the banner image prompt

**As of 2026-08-25, this replaces the manual ChatGPT process from
`SOP_Blog_Banner_Image_Generation.md` (retired) — Pablo no longer generates blog banners by
hand.** One banner image per post now goes through the same automated pipeline as carousels
(`n8n` profile → ComfyUI Cloud, via `/webhook/one-click`), so it needs a text prompt detailed
enough to replace what a brand-trained ChatGPT chat with reference images used to provide.

1. Read `references/master-prompt-structure.md` for the preamble (Section 0) and the 7-section
   structure — same skeleton `carousel-prompt-generator` uses. Read
   `references/brand-extraction-checklist.md` for what to pull from the brand guide.
2. **Aspect ratio override:** blog banners are **16:9**, not the carousel's 4:5. Replace the
   preamble's aspect-ratio line with:
   ```
   Make the image 16:9 aspect ratio.
   ```
   Keep the "Remove AI Slop" realism block as-is (included by default).
3. Because there's no reference image to attach (unlike the old ChatGPT flow), describe the
   brand's established banner look explicitly in the composition/color/typography sections —
   pull concrete hex values, fonts, and layout conventions from the brand guide rather than
   general adjectives.
4. One prompt per blog post, using that post's actual title and core takeaway as the subject.
5. Append to the same `.md` deliverable from Step 4, after all posts, as its own section:

```markdown
## Banner Image Prompts

### Banner — blog.1 — [Post 1 Title]
[Full prompt text]

### Banner — blog.2 — [Post 2 Title]
[Full prompt text]
```

The `blog.N` label is the filename convention the `n8n` profile reads to build the
`blog-N` key of the image-generation webhook payload — keep the numbering in Content-Plan
order, matching the post order in Step 4.

---

## Step 5 — Deliver for User Approval

Present the .md to the user:

> "Here are the blog posts: `output/[file].md`
>
> Total posts: [N] · Brand: [name] · Month: [month]
>
> [Flag any assumptions made, missing pricing, or posts with no internal link match]
>
> Review and let me know if anything needs changing. Once approved, I'll
> generate the styled HTML version with per-post Copy buttons."

Wait for explicit approval before generating the HTML. If the user says
"generate both at once" or "skip approval", proceed directly to Step 6.

---

## Step 6 — Generate the .html File

After approval, generate the styled HTML version directly — no Python script
needed.

### 6a — Build the HTML structure

Each post becomes an `<article>` with:
- Sidebar nav link (one per post, scroll-spy active state)
- Meta panel (SEO title, meta description, slug, keywords, search intent)
- Post body container (what the "Copy post" button copies)
- QA-only box below (internal links, image notes)
- Notes/assumptions if any

**Per-post structure:**
```html
<article class="post" id="post-N">
  <div class="post-header-row">
    <h3>[Post title]</h3>
    <button class="copy-post-btn" onclick="copyPost(event)">Copy post</button>
  </div>
  <div class="meta-panel">
    <div class="meta-row"><span class="meta-label">SEO Title:</span> ...</div>
    <div class="meta-row"><span class="meta-label">Meta Description:</span> ...</div>
    <!-- slug, keywords, intent -->
  </div>
  <div class="post-body">
    <h1>[Title]</h1>
    <p>...</p>
    <h2>...</h2>
    <p>...<a href="[real URL]">anchor text</a>...</p>
    <h2>Next Steps</h2>
    <p>[CTA]</p>
    <h2>FAQ</h2>
    <div class="faq-item"><strong>Q:</strong> ...</div>
  </div>
  <div class="qa-only">
    <h4>Internal Links Used (QA reference — not copied)</h4>
    <ul>...</ul>
    <h4>Image Placement Suggestions (not copied)</h4>
    <p>...</p>
  </div>
  [optional notes box]
</article>
```

**The "Copy post" button** must copy exactly: body (excluding H1 if desired) +
Next Steps section + FAQ section — in that order. The meta panel, QA box, and
notes must NOT be included in the copy.

### 6b — Design system

Use the same skillui-test design tokens as the content-plan-generator HTML:
- `#000000` bg, `#2a2a2a` surface, `#3b82f6` accent, `#3a3a3a` border,
  `#9ca3af` muted text
- Dark/light toggle via `data-theme` attribute on `<html>`
- Theme toggle wired with `addEventListener` (no `onclick`)
- `prefers-reduced-motion` respect
- Print styles: hide sidebar, toggle, buttons

### 6c — JavaScript features

- **Theme toggle**: `document.getElementById('themeToggle').addEventListener(...)`
  — toggle `data-theme`, store in localStorage, respect system preference on
  first load
- **Sidebar scroll-spy**: highlight active post link on scroll
- **Copy post**: find nearest `.post-body`, copy its innerHTML as `text/html`
  and innerText as `text/plain` (via `ClipboardItem`), show "Copied!"
  feedback for 1.5s

### 6d — Write the file

```
output/[BrandName]_Blog_Posts_[Month]_[Year].html
```

---

## Step 7 — Deliver summary

Present the .html file path and a summary:
- Total blog posts written
- Brand name and month
- Reminder that each post has a "Copy post" button ready for WordPress/WYSIWYG
- Any Notes/Assumptions flagged across the batch

---

## Edge Cases

- **Content Plan has more or fewer blog posts than the typical 4–6/month**:
  process whatever's actually there.
- **No sitemap/page list available at all**: proceed without internal links;
  note this once at the top of Notes/Assumptions.
- **Knowledgebase is thin on a specific topic**: write a genuinely useful, more
  general article on the topic — flag the thinness in Notes/Assumptions.
- **User wants only some posts from the batch**: process only the requested
  posts.
- **Brand knowledgebase and an uploaded file disagree**: treat the upload as
  the override for this run.
- **Topic is medical, legal, financial, or another regulated industry**: apply
  extra claims caution per `references/writing-rules.md`'s industry-specific
  care section.
- **User asks for a non-default reading level**: follow an explicit user
  request, but still avoid unnecessary complexity.
- **A post has no natural spot for an image suggestion**: it's fine to include
  just one general suggestion near the top.
- **Marketing skills not installed**: if `copywriting`, `seo-audit`, or
  `ai-seo` don't exist at `~/.agents/skills/{name}/`, note the gap and write
  using general best practices instead.
