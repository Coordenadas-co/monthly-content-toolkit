---
name: content-plan-generator
description: >
  Generates a comprehensive monthly content plan for any brand, integrating
  all installed marketing skills (copywriting, SEO, social, emails, ads,
  video, image, etc.) for deep, skill-backed content. Outputs a styled
  .html file (dark/light toggle) based on the skillui-test design system.
  Brand-agnostic — works for any brand project with a knowledgebase and brand kit.
compatibility: >
  Requires the marketing skills from coreyhaines31/marketingskills installed
  at ~/.agents/skills/. No external dependencies — output is pure HTML/CSS.
---

# Content Plan Generator v2

Generates a complete, skill-backed monthly content plan for any brand.
Every deliverable is produced by loading the relevant marketing skill
(copywriting, social, emails, ads, video, image, etc.) and adapting its
output into the plan format. The result is a .md file for review, then a styled
.html file (dark/light toggle) once approved.

---

## How Skill Integration Works

Throughout this workflow, you will load marketing skills using the `skill`
tool. Each skill produces output tailored to its domain. You adapt that
output into the content plan templates below.

| Step | Skill to load | Why |
|---|---|---|
| Step 2 | `content-strategy` | Define pillars, score topics, map to buyer stages |
| Step 4a | `marketing-psychology` | Select psychology principles for carousel hooks |
| Step 4b | `copywriting` | Write copy for each deliverable |
| Step 4c | `seo-audit` or `ai-seo` | SEO metadata for blog posts and SEO pages |
| Step 4d | `emails` | Email sequence design, subject lines, body |
| Step 4e | `social` | Platform-specific social post copy |
| Step 4f | `video` | Video script structure and production approach |
| Step 4g | `ad-creative` | Ad headline and description variants |
| Step 4h | `lead-magnets` | Lead magnet format and gating strategy |
| Step 4i | `programmatic-seo` or `competitors` | SEO page templates and comparison pages |
| Step 4j | `image` | Infographic design brief and visual direction |
| Step 5 | `copy-editing` | Seven Sweeps polish on all copy |
| Step 6 | `analytics` | UTM parameters and tracking plan |

When loading a skill, pass brand context (product-marketing.md, knowledgebase,
brand kit) in memory so the skill has everything it needs.

---

## Default Deliverable Set

| Type | Default Qty | Optional? | Requires Skill |
|---|---|---|---|
| Carousels (3-4 slides, visual-first) | 8 | — | `marketing-psychology`, `copywriting` |
| Blog Posts (SEO-optimized) | 4-6 | — | `copywriting`, `seo-audit`/`ai-seo` |
| Newsletters / Emails | 4-6 | — | `emails`, `copywriting` |
| Social Posts (LinkedIn, X, Instagram) | 8-12 | Optional | `social`, `copywriting` |
| Video Scripts (script only, no production) | per cycle config | Optional | `references/video-script-guide.md` |
| Ad Creative (headlines, descriptions, variants) | 3-5 | Optional | `ad-creative` |
| Lead Magnets (gated content) | 1-2 | Optional | `lead-magnets`, `offers` |
| SEO Content Pages (programmatic or comparison) | 2-3 | Optional | `programmatic-seo`, `competitors` |
| Infographics (design brief) | 2 | — | `image` |
| Push Notifications | 1 per blog | — | — |

Keep a running count as you generate. Before writing the output file, verify all counts are met.

---

## Step 0 — Load Brand Context

Load all brand context before any planning. This feeds every downstream skill.

### 0a — Find the brand directory

If the user has not specified the brand, ask. The expected structure is:

```
Brands/{BrandName}/
  .agents/
    product-marketing.md
  01_knowledge_base/
    ... .html files
  02_brand_kit/
    brand_guide.md
    logos/
    product_visuals/
    print_collateral/
```

### 0b — Load product-marketing.md

Check `Brands/{BrandName}/.agents/product-marketing.md`. If it exists:

- Extract: positioning, ICP, personas, voice, tone, competitive landscape, proof points, goals
- Keep this in working memory — all skills reference it

If it does **not** exist:
- Offer to create one from the knowledgebase files
- If user agrees, scan knowledgebase HTMLs, extract the fields, and write `.agents/product-marketing.md`
- Tell the user this file will make every marketing skill more effective

### 0c — Load Knowledgebase files

Scan `Brands/{BrandName}/01_knowledge_base/` for `.html` files. Read them in this priority:

| Priority | Match pattern | What to extract |
|---|---|---|
| 1 | `*MasterStrategyDoc*` or `*Strategy*` | Brand positioning, core value props, strategic priorities |
| 2 | `*marketing_brain*` | Campaign logic, growth model, key narratives |
| 3 | `*MessageBlockLibrary*` or `*message*` | Approved phrases, tone rules, words to avoid |
| 4 | `*ChannelAcquisitionMap*` or `*Channel*` | Channel rules per segment |
| 5 | `*BuyerCluster*` or `*persona*` or `*cluster*` | Cluster names, priority ranking, triggers |
| 6 | `*Objection*` | Objections to neutralize in content |
| 7 | `*Genesis*` or `*origin*` | Brand origin, founding story, trust signals |
| 8 | `*Intelligence*` or `*Raw*` | Market data, competitor context |

Extract and hold in working memory:
- **Active clusters** — names, descriptions, main triggers, priority ranking
- **Message blocks** — exact approved phrases, what to avoid
- **Channel rules** — which format/channel serves which cluster
- **Tone fingerprint** — voice, register, localization notes, banned words
- **Brand URLs** — documented links for CTAs

### 0d — Load Brand Guide

The brand guide is the visual identity source. Look for it in this priority:

1. **Preferred:** `Brands/{BrandName}/[BrandName]_brand_guide.md` (our canonical convention — e.g., `PayWise_brand_guide.md`)
2. **Fallback:** `Brands/{BrandName}/brand_guide.md` (unprefixed)
3. **Last resort:** Scan `Brands/{BrandName}/02_brand_kit/` for any file with a name containing `brand-guide` or `brand_guide` (any extension)

Found file at whichever location:

- Extract: color palette (hex values), typography (typeface, weights), logo usage rules, visual style guidelines, voice and tone cues
- Note available assets: logo files, screenshots, mockups
- Store for design brief generation in Step 5

If no brand guide exists anywhere, skip — design briefs will note "no brand guide available."

---

## Step 0.5 — Language

If the user has not specified a language, ask:

> "Should this content plan be in **English** or **Spanish**?"

If they specify both (e.g., English blogs + Spanish carousels), note it and respect per-deliverable. If they don't answer, default to English.

Every deliverable — strategy, copy, templates, UTM labels — is produced in the chosen language from this point forward.

---

## Step 1 — Direction Interview

Ask the user the following in ONE message — do not split across turns:

> **1. Campaign angle** — Any client request, seasonal theme, or out-of-the-box campaign idea for this month?
>
> **2. Message direction** — Any specific tone, story angle, or narrative to hit?
>
> **3. Visual direction** — Any visual style, palette, or imagery preference?
>
> **4. Deliverable mix** — Which content types + quantities? Menu:
>
>    | Type | Default Qty | Optional? |
>    |---|---|---|
>    | Carousels (3-4 slides, visual-first) | 8 | — |
>    | Blog Posts (SEO-optimized) | 4-6 | — |
>    | Newsletters / Emails | 4-6 | — |
>    | Social Posts (LinkedIn, X, Instagram) | 8-12 | Optional |
>    | Video Scripts (AI or programmatic) | 2-4 | Optional |
>    | Ad Creative (headlines, descriptions, variants) | 3-5 | Optional |
>    | Lead Magnets (gated content) | 1-2 | Optional |
>    | SEO Content Pages (programmatic or comparison) | 2-3 | Optional |
>    | Infographics (design brief) | 2 | — |
>    | Push Notifications | 1 per blog | — |
>
>    (If not specified, I'll plan all types at default quantities.)

**If the user has already given clear direction** earlier in the conversation, skip the interview and go straight to the echo-back.

After receiving answers, **echo the direction back in 3-5 sentences**:

> "Got it. For July we're leading with the bill payment feature targeting Cash-Poor Bill Payers, with a mid-month pivot to business payments for Sale-Losing Operators. Conversion-focused tone throughout, anchored around the July 15 product update. Full campaign with all deliverable types. Does that match your intent?"

Wait for confirmation. If user says "looks good" or equivalent, proceed. If they don't respond after a follow-up, treat silence as approval.

---

## Step 2 — Strategic Planning

Load the `content-strategy` skill using the `skill` tool. With brand context in memory, follow the skill's workflow:

1. **Define 3-5 content pillars** — use product-led, audience-led, search-led, or competitor-led approaches
2. **Score topic ideas** using the framework:
   - Customer Impact: 40%
   - Content-Market Fit: 30%
   - Search Potential: 20%
   - Resources: 10%
3. **Map pillars to buyer stages** (awareness → consideration → decision)
4. **Cross-reference with knowledgebase clusters** — ensure every persona cluster is served
5. **Identify anchor events** — any launches, promotions, seasonal moments from the interview

Output: a prioritized topic list with target keywords, buyer stage, and cluster assignment.

---

## Step 3 — Distribution Plan

Before writing any content, map out the full schedule:

1. **Divide the month into weeks** — 5-7 day windows, starting from the first publishing date
2. **Assign deliverables to weeks** — spread types evenly:
   - 1-2 carousels + 0-1 email + 0-1 blog per week (adjust based on deliverable mix)
3. **Distribute personas** — no single cluster dominates more than 3 carousels
4. **Theme each week** — give it a short label (e.g., "Month-End Bills Reminder", "Business Onboarding Push")
5. **Place infographics** — Week 1 (strategy overview) and mid-month or final week (persona/channel map)
6. **Mark blog-push pairs** — every blog post gets a push notification; note the pairing upfront
7. **Add optional deliverables** — slot social posts, video, ads, lead magnets into appropriate weeks

Share this skeleton plan with the user as a simple week-by-week list. Ask if the distribution looks right. Adjust before proceeding.

---

## Step 4 — Generate Deliverables

For each deliverable, load the relevant marketing skill and adapt its output into the template format below.

### Carousel (load `marketing-psychology` + `copywriting`)

For full carousel prompt generation, load the dedicated `carousel-prompt-generator` skill.
Within the content plan, produce the copy outline here:

1. Load `marketing-psychology` skill — select 2-3 psychology principles that fit the topic (e.g., Loss Aversion for urgency, Social Proof for trust, Reciprocity for lead gen)
2. Load `copywriting` skill — generate short, punchy text-on-image copy (5-15 words per slide)
3. Output using this template:

```
[Date] — Carousel
👤 Persona: [Exact cluster name from knowledgebase]
📄 Format: Carousel (3-4 slides)
📅 Week [N] · [Week Theme]
🧠 Psychology: [principles used]

OBJECTIVE
[1 sentence: what behavior or belief this carousel moves]

TITLE
[Punchy, outcome-first headline — 3-6 words]

SLIDE COPY (text-on-image — short, punchy, 5-15 words each)
Slide 1: [Short hook — pain or curiosity, 3-8 words]
Slide 2: [Benefit phrase, 5-12 words]
Slide 3: [Proof or social proof, 5-12 words]
Slide 4 (optional): [CTA — action phrase, 3-8 words]

* Text-on-image must be minimal — the image and brand design do the heavy lifting.
* Only produce heavy-text slides if user explicitly requested "detailed carousel" or "educational carousel."

DESIGN BRIEF
- Brand guide: `brand_guide.md`
- Color palette: [from brand kit — primary, secondary, accent]
- Typography: [from brand kit — headline + body fonts]
- Image style: [from brand kit or interview direction]
- Logo placement: [from brand kit]

CAPTION
[1-2 sentence caption. Conversational. Ends with CTA + URL.]
```
```

### Blog Post (load `copywriting` + `seo-audit`/`ai-seo`)

For full blog post production, load the dedicated `blog-post-generator` skill.
Within the content plan, generate the structural outline here:

1. Load `copywriting` skill — generate full blog copy with H2 structure
2. Load `seo-audit` or `ai-seo` skill — generate meta title, meta description, keyword recommendations
3. Output:

```
[Date] — Blog Post
👤 Persona: [Exact cluster name]
📄 Format: Blog Post
📅 Week [N] · [Week Theme]
🔍 SEO Focus: [target keyword cluster]

TITLE
[SEO-friendly, outcome-first title — 6-10 words]

META DESCRIPTION
[120-155 characters, includes target keyword, compels click]

INTRO PARAGRAPH
[2-3 sentences. Hook the reader with the problem or benefit immediately.]

BLOG STRUCTURE
H2: [Section heading]
Explain: [What this section covers and key points to hit]

H2: [Section heading]
Explain: [What this section covers]

H2: [Section heading — social proof or trust]
Explain: [What this section covers]

H2: [Section heading — final push]
Explain: [What this section covers]

CTA: → [Action phrase]: [URL]

↳ PUSH NOTIFICATION (paired with this blog post)
See Push Notification section below for format.
```

### Newsletter / Email (load `emails` + `copywriting`)

1. Load `emails` skill — design sequence structure, subject line, preview, body
2. Load `copywriting` skill — polish body copy
3. Output:

```
[Date] — Email Marketing
👤 Persona: [Exact cluster name]
📄 Format: Email
📅 Week [N] · [Week Theme]
📧 Sequence position: [e.g., "Welcome — Email 2 of 5"]

SUBJECT LINE
[Subject — curiosity or benefit-led; under 50 characters]

PREVIEW TEXT
[Preview — 1 sentence that completes or extends the subject line]

EMAIL BODY
Hi [First Name],

[Opening — acknowledge the pain or moment. 2-3 sentences.]

[Value paragraph — what the brand does about it. 2-3 sentences.]

[Proof or urgency — social proof, stat, or time pressure. 1-2 sentences.]

→ [CTA phrase]: [URL]
```

4. **Generate the banner image prompt.** As of 2026-08-25 this replaces the manual ChatGPT
   process from `SOP_Newsletter_Banner_Image_Generation.md` (retired) — one banner per
   newsletter now goes through the same automated pipeline as carousels (`n8n` profile →
   ComfyUI Cloud). Read `references/master-prompt-structure.md` for the preamble/7-section
   structure and `references/brand-extraction-checklist.md` for the brand pull. Override the
   preamble's aspect-ratio line to **16:9** (not the carousel default of 4:5), keep the
   "Remove AI Slop" block, and describe the brand's banner look explicitly in words (hex
   colors, fonts, layout) since no reference image gets attached anymore. Use the newsletter's
   subject line, not the blog title, as the prompt subject — even when the topic overlaps with
   a blog post.
5. **Also write the Instagram Story companion prompt** (as of 2026-08-25, replaces the manual
   ChatGPT process from `SOP_Instagram_Story_Banner_Generation.md`, retired). Same approach as
   `blog-post-generator`'s Step 4b: reuse the banner prompt's composition/color/typography
   description verbatim, change the aspect-ratio line to `Make the image 9:16 aspect ratio,
   1080x1920 pixels.`, and explicitly instruct the model to omit any logo (keeps the Story's
   bottom clear for an Instagram Link sticker).
6. Append both prompts to the plan's Newsletter section:
   ```markdown
   #### Banner — newsletter.[N]
   [Full prompt text]

   #### Story — newsletter.[N]-story
   [Full prompt text, banner composition reused, 9:16, no logo]
   ```
   The `newsletter.N` / `newsletter.N-story` labels are what the `n8n` profile reads to build
   the `newsletter-N` key of the image-generation webhook payload — number in the order
   newsletters appear in the plan. Both count toward the same `newsletter-N` list.

### Social Post (load `social` + `copywriting`)

1. Load `social` skill — follow hook formulas, platform-specific formatting
2. Generate per-platform variants (LinkedIn, X, Instagram)
3. Output:

```
[Date or Week N] — Social Post
📱 Platform: [LinkedIn / X / Instagram]
👤 Persona: [Exact cluster name]
📅 Week [N] · [Week Theme]

COPY
[Hook — follow social skill's hook formula for the platform]
[Body — concise, value-forward, 1-3 paragraphs depending on platform]
[CTA — action with URL]

ASSETS NEEDED
[Description of image, video, or graphic needed]
```

### Video Script (references/video-script-guide.md)

Type, aspect ratio and presenter for each `video.N` come pre-decided from the
cycle config — never ask live. If a video's type arrives as "Mixed", pick the
real type yourself from the guide's table based on the cycle's strategic
direction, and never repeat the same type across two videos in the same mix.

1. Read `references/video-script-guide.md` — it has the type/aspect/presenter
   tables and the beat-sheet script format. This replaces loading a general
   `video` production skill: no video is actually rendered here, only the
   script text, so tooling/API guidance doesn't apply.
2. Label the block with the literal prefix `video.N —` (N = its 1-based
   position among the videos in this mix) — it's the identifier the pipeline
   validates against, don't change its shape.
3. Output:

```
video.N — [Week N] — Video Script
👤 Persona: [Exact cluster name]
🎬 Type: [Demo / Explainer / Testimonial / Social clip / Ad / Tutorial]
📐 Aspect: [9:16 vertical / 16:9 horizontal / 1:1 feed]
🛠 Presenter: [Sin presentador (screen recording + voiceover) / AI avatar / Sólo voz en off]

SCRIPT (beat sheet)
[0–Ns] Visual: [what's on screen this beat]
Audio: [what's said or heard]
[repeat per beat until the CTA closes it]

VISUAL NOTES
[Scene descriptions, on-screen text, brand elements to include]
```

### Ad Creative (load `ad-creative`)

1. Load `ad-creative` skill — generate headline and description variants
2. Output:

```
[Date or Week N] — Ad Creative
👤 Persona: [Exact cluster name]
🎯 Platform: [Google / Meta / LinkedIn / X]
📅 Week [N] · [Week Theme]

VARIANT 1
Headline: [30 chars max for Google, shorter for social]
Description: [90 chars max]
CTA: [Action text]

VARIANT 2
Headline: ...
Description: ...
CTA: ...

VARIANT 3
Headline: ...
Description: ...
CTA: ...
```

### Lead Magnet (load `lead-magnets`)

1. Load `lead-magnets` skill — determine format, topic, gating strategy
2. Output:

```
[Date or Week N] — Lead Magnet
👤 Persona: [Exact cluster name]
📅 Week [N] · [Week Theme]
📥 Format: [Checklist / Guide / Template / Assessment / Toolkit]

TOPIC
[What the lead magnet covers — must solve a specific problem]

OUTLINE
[Key sections or steps]

GATING STRATEGY
[Full gate / Partial gate / Content upgrade / Ungated]

LANDING PAGE BRIEF
- Headline:
- Subheadline:
- Key bullet points:
- Social proof to include:
- Form fields:
```

### SEO Content Page (load `programmatic-seo` or `competitors`)

1. Load `programmatic-seo` or `competitors` skill — choose playbook, design template
2. Output:

```
[Date or Week N] — SEO Page
👤 Persona: [Exact cluster name]
📅 Week [N] · [Week Theme]
🔍 Playbook: [Comparison / Template / Location / Glossary / etc.]

URL
[/page-slug]

TITLE TAG
[60 chars max]

META DESCRIPTION
[155 chars max]

H1
[Page heading]

STRUCTURE
[Template structure with H2s, content blocks, internal links]
```

### Infographic (load `image`)

For full infographic design briefs, load the dedicated `infographic-brief-generator`
skill. Within the content plan, produce the outline here:

1. Load `image` skill — craft design brief with brand visual references
2. Output:

```
INFOGRAPHIC [1 or 2] — [Title]
👤 Audience: [Persona or "All clusters"]
📅 Publish: [Date or Week N]

CONCEPT
[What this infographic visualizes. 2-3 sentences for the design team.]

KEY DATA POINTS
- [Stat or section 1]
- [Stat or section 2]
- [Stat or section 3]

DESIGN BRIEF
- Brand guide: `brand_guide.md`
- Color palette: [from brand kit]
- Typography: [from brand kit]
- Visualization style: [chart types, iconography, layout preference]
- Logo placement: [from brand kit]

COPY DIRECTION
[Tone notes, register, key phrases to use, what to emphasize visually]
```

### Push Notification

Push notifications are paired with blog posts and social posts. Generate one
per blog post and one per high-priority social post:

1. Load `copywriting` skill — write short, urgent copy under platform character limits
2. Output:

```
📲 PUSH NOTIFICATION — [Related blog/social post title]
👤 Persona: [Exact cluster name]
📅 Week [N] · [Week Theme]

NOTIFICATION TEXT
[Line 1: Urgency or benefit hook — max 50 chars.]
[Line 2: Action prompt — max 40 chars.]

DEEP LINK
[URL the notification opens on tap]

PLATFORM SPECIFICS
- iOS: [any iOS-specific considerations]
- Android: [any Android-specific considerations]
- Web: [any Web push considerations]
```

---

## Step 5 — Design Brief Generation

For every visual deliverable (carousels, infographics, social graphics):

1. Read the brand kit (loaded in Step 0d)
2. Add a DESIGN BRIEF block to each piece containing:
   - Color palette reference
   - Typography rules
   - Logo usage notes
   - Image style direction (from interview or brand default)
3. If no brand kit exists, note: "No brand kit available — request from client."

---

## Step 6 — Copy Polish (load `copy-editing`)

After all content is generated, load the `copy-editing` skill and run the **Seven Sweeps** across every piece:

1. **Clarity** — Is the message immediately understood?
2. **Voice/Tone** — Does it match the brand's documented voice?
3. **So What** — Does every point answer "why should I care?"
4. **Prove It** — Are claims backed by evidence?
5. **Specificity** — Are generic phrases replaced with specific details?
6. **Heightened Emotion** — Does the language resonate emotionally?
7. **Zero Risk** — Are objections handled? Is trust built?

Fix any issues directly in the content. This is non-negotiable — every plan gets polished.

---

## Step 7 — Analytics & Tracking (load `analytics`)

Load the `analytics` skill and generate per-deliverable:

- **UTM parameters** for every CTA link and URL in the plan
- **Suggested tracking events** — what to track per content piece
- **Conversion goals** — what constitutes a conversion for each type

Append this as a section at the end of the plan:

```
# Analytics & Tracking — [Month]

## UTM Strategy
| Content | URL | utm_source | utm_medium | utm_campaign | utm_content |
|---|---|---|---|---|---|

## Events to Track
| Event | Trigger | Category |
|---|---|---|

## Conversion Goals
| Goal | Definition | Content Types |
|---|---|---|
```

---

## Step 8 — Deliverable Count Check

Before moving to output, verify counts against what was agreed:

```
✅ Carousels:           [N] / 8
✅ Blog Posts:          [N] / 4-6
✅ Newsletters:         [N] / 4-6
✅ Social Posts:        [N] / [agreed count or 0]
✅ Video Scripts:       [N] / [agreed count or 0]
✅ Ad Creative:         [N] / [agreed count or 0]
✅ Lead Magnets:        [N] / [agreed count or 0]
✅ SEO Content Pages:   [N] / [agreed count or 0]
✅ Infographics:        [N] / 2
✅ Push Notifications:  [N] / [equals blog post count]
```

If any count is off, generate the missing pieces before proceeding.

---

## Step 9 — Content Calendar Table

Append this at the end of the plan content (before writing the output file):

```
Content Calendar — [Month] [Year]

| Date | Format | Topic / Headline | Target Persona |
|------|--------|-----------------|----------------|
[One row per deliverable, sorted chronologically]
```

Push notifications do not appear as calendar rows — they're attached to their blog post.

---

## Step 10 — Output

### 10a — Write the .md file

Use the `write` tool to save the full plan:

```
output/[BrandName]_Content_Plan_[Month]_[Year].md
```

Example: `output/PayWise_Content_Plan_September_2026.md`

> **Filename month-token convention (CRITICAL):** use a Title-case full month name (`August_2026`, `September_2026`) — the SAME token carousel-prompt-generator and blog-post-generator emit (`[BrandName]_Carousel_Prompts_August_2026.html`, `[BrandName]_Blog_Posts_August_2026.html`). Do NOT use uppercase (`AUGUST_2026`) or abbreviations (`AUG`) — Stage 2/3 filenames use Title-case full months, and the manifest's `detail_link` values must reference those exact filenames.

Include the complete plan with all headings, tables, and formatting.

### 10b — Deliver for User Approval

Present the .md to the user:

> "Here's the full content plan: `output/[file].md`
>
> Total deliverables: [N] · Persona coverage: [clusters] · Key themes: [themes]
>
> Review and let me know if anything needs changing. Once approved, I'll generate the styled HTML version."

Wait for explicit approval ("looks good", "approved", "proceed") before generating the HTML.

If the user requests changes, apply them first, then loop back to approval.

If the user says "generate both at once" or "skip approval", proceed directly to 10c without waiting.

### 10c — Generate the .html File

After approval, generate the styled HTML version:

1. **Read the template** — load `references/content-plan-template.html` from this skill's directory
2. **Inject content** — replace template placeholders with the plan content:
   - `{{BRAND_NAME}}` — brand name
   - `{{MONTH_YEAR}}` — e.g., "July 2026"
   - `{{LANGUAGE}}` — "English" or "Spanish"
   - `{{EDITORIAL_NOTE}}` — short editorial summary
   - `{{PERSONA_CARDS}}` — HTML for persona grid cards (3 per row, name + description)
   - `{{COUNT_CHECK}}` — deliverable count items as HTML
   - `{{SIDEBAR_WEEK_LINKS}}` — sidebar nav links for each week:
     ```html
     <a href="#week-1" class="sidebar-link" data-section="week-1">Week 1 — [Theme]</a>
     <a href="#week-2" class="sidebar-link" data-section="week-2">Week 2 — [Theme]</a>
     ```
   - `{{WEEK_SECTIONS}}` — full week-by-week content as HTML. Each week:
     ```html
     <section class="week-section" id="week-1">
       <div class="week-header">
         <h2>Week 1</h2>
         <span class="week-theme">Theme name</span>
         <span class="week-count">N items</span>
         <span class="week-toggle-icon">▼</span>
       </div>
       <div class="deliverable-grid">
         <!-- cards -->
       </div>
     </section>
     ```
     Each deliverable card (expandable, filterable):
     ```html
     <div class="deliverable-card" data-type="carousel" data-persona="persona-slug" id="carousel-1">
       <div class="deliverable-header">
         <div class="deliverable-header-left">
           <div class="deliverable-meta">
             <span class="deliverable-type">Type</span>
             <span class="deliverable-persona">Persona Label</span>
           </div>
           <div class="deliverable-title">Deliverable title</div>
         </div>
         <span class="card-toggle-icon">▶</span>
       </div>
       <div class="deliverable-body-wrap">
         <div class="deliverable-body">Full body content here</div>
         <!-- optional design brief -->
         <div class="design-brief"><strong>Design Brief:</strong> visual direction</div>
         <div class="card-actions">
           <button class="copy-btn">📋 Copy</button>
         </div>
       </div>
     </div>
     ```
     - `data-type` values: use singular lowercase (carousel, blog, email, infographic, video, social, ad, lead-magnet, seo-page, push)
     - `data-persona` values: use kebab-case slug matching the persona key (diaspora-dreamers, savvy-savers, etc.)
     - Push notifications go as separate `.deliverable-card` with type="push" attached beneath the related blog post card
      - **Card ID contract (CRITICAL):** every deliverable card MUST carry a unique `id` matching the real downstream anchor exactly, per type:
        - Carousels → `id="carousel-1"`, `id="carousel-2"`, … `carousel-N` (matches `carousel-prompt-generator`'s static sections → `id="carousel-N"` → `#carousel-1…#carousel-N`. Do NOT use `c1`/`c2` — that scheme diverged from the real anchor and is retired.)
        - Blog posts → `id="post-1"`, `id="post-2"`, … `post-N` (matches `blog-post-generator`'s rendered `id="post-${p.id}"` → `#post-N`. Do NOT use `b1`/`b2` — that scheme diverged from the real anchor and is retired.)
       - Newsletters → `id="nl1"`, `id="nl2"`, … (no confirmed downstream anchor yet — keep as-is)
       - Infographics → `id="ig1"`, `id="ig2"`, … (no confirmed downstream anchor yet — keep as-is)
       - Videos → `id="video-1"`, `id="video-2"`, … `video-N` (REQUIRED — matches the `video.N` label used in
         content-plan.md; the pipeline validates both). No downstream stage consumes this today, but keep the
         anchor stable for when one exists — same reasoning as carousels/blog posts, just earlier.
       - Other types: `id` optional unless a downstream anchor exists
     - **Default ID policy (CRITICAL):** when a downstream skill for a type exists, audit its REAL rendered anchor format first (open an actual generated output file and check the `id`/`href` it emits), then align this content-plan card ID to match — never the reverse, never guessed in advance. The detail-link JS in the template resolves cards by this ID.
     - The template's built-in JS reads `#content-manifest` (embedded via `{{MANIFEST_JSON}}`) and injects a `🔗 Detail` link into each matching card's `.card-actions` automatically. Just provide the right `id` and the manifest (Step 10d). Do not hand-write detail links in card HTML.
   - `{{CALENDAR_ROWS}}` — `<tr>` rows for the content calendar table
   - `{{ANALYTICS_SECTION}}` — UTM table, events table, conversion goals (or empty if user declined analytics)
   - `{{MANIFEST_JSON}}` — raw JSON of the content manifest (see Step 10d); goes inside the template's `<script type="application/json" id="content-manifest">` block
   - `{{GENERATED_DATE}}` — current date
3. **Write the file** — use the `write` tool:
   ```
   output/[BrandName]_Content_Plan_[Month]_[Year].html
   ```
4. **Deliver summary** — tell the user the file path and include the same 3-bullet summary from Step 10b

**Notes:**
- The sidebar, toolbar (search + filter chips), expand/collapse behavior, and copy-to-clipboard are all handled by the template's built-in JavaScript. You just provide the right data attributes and structure.
- The search input and filter bar are rendered by the template. On page load, JS scans all cards for `data-type` and `data-persona` and generates filter chips automatically.
- Weeks start expanded by default. Users can collapse individual weeks via the header, or use the "Collapse all" / "Expand all" toolbar buttons.
- Cards start collapsed (body hidden). Click the header to expand.
- Print stylesheets hide the sidebar, toolbar, and buttons — content prints cleanly.

### 10d — Generate the JSON Manifest

Write a machine-readable manifest alongside the HTML, one entry per **carousel** and per **blog post** (only these two types — they are the only ones with a dedicated downstream output file and confirmed anchors). Use the `write` tool:

```
output/[BrandName]_Content_Plan_[Month]_[Year].json
```

Schema:

```json
{
  "brand": "PayWise",
  "month": "September 2026",
  "generated_date": "2026-08-05",
  "deliverables": [
    {
      "type": "carousel",
      "id": "carousel-1",
      "title": "Carousel 1 — Your Counter. Your Commission.",
      "detail_link": "../../02_prompts_and_copy/output/PayWise_Carousel_Prompts_September_2026.html#carousel-1"
    },
    {
      "type": "blog_post",
      "id": "post-1",
      "title": "Pharmacies in T&T: The Secret to Earning More",
      "detail_link": "../../02_prompts_and_copy/output/PayWise_Blog_Posts_September_2026.html#post-1"
    }
  ]
}
```

Rules:

- `id` MUST equal the card `id` used in Step 10c AND the real downstream anchor (`carousel-1…#carousel-N`, `post-1…post-N`) — verified, not guessed.
- `detail_link` is **relative to the content-plan output page** (the manifest/HTML both live in `01_content_plan/output/`): `../../02_prompts_and_copy/output/[BrandName]_Carousel_Prompts_[Month]_[Year].html#<id>` for carousels, `../../02_prompts_and_copy/output/[BrandName]_Blog_Posts_[Month]_[Year].html#<id>` for blog posts. The `../../` climbs from `01_content_plan/output/` up to the cycle root, then into `02_prompts_and_copy/output/`. Do NOT use cycle-folder-relative paths (`02_prompts_and_copy/output/...`) — resolved from the content-plan page they produce a nonexistent `01_content_plan/output/02_prompts_and_copy/output/...` path. Do NOT use workspace-root-relative paths (`Brands/...`) — they only work when the page is opened from the workspace root.
- **Verify before delivering (CRITICAL):** after writing the manifest, resolve every `detail_link` relative to `01_content_plan/output/` (e.g., `node -e` or equivalent) and confirm (a) the target Stage-2/3 file exists on disk (for an already-completed cycle) or matches the exact filename Stage 2/3 will emit, and (b) the `#<id>` fragment equals a real `id` in that target file's HTML. Fix any mismatch before delivering. For a freshly generated plan whose Stage 2/3 files don't exist yet, confirm the filename token and anchor match the downstream skill specs exactly.
- The manifest is written at content-plan generation time, BEFORE Stage 2/3 output files exist. The links are forward-pointing by design — do not edit the plan afterward once Stage 2/3 runs.
- **Escaping (CRITICAL):** titles may contain apostrophes, quotes, and ampersands. Emit valid JSON — escape `"` as `\"`, `&` and `'` as `\u0026` / `\u0027` (the convention already used in carousel-prompt-generator's data JSON). After writing, validate the file parses (e.g., `JSON.parse`) before delivering. Never inline-append a raw title into JSON.
- Embed the same JSON into the HTML via the `{{MANIFEST_JSON}}` placeholder (the template's `<script type="application/json" id="content-manifest">` block) — write it as raw JSON inside the script block. The template JS parses it and injects Detail links into matching cards automatically. If a title contains `</script>`, escape the `<` to `\u003c`.
- If the user declines or the plan has zero carousels and zero blog posts, write `{"brand": "...", "month": "...", "generated_date": "...", "deliverables": []}`.

---

## Step 11 — Monthly Loop Offer

After the plan is delivered, ask:

> "Want to save this month's direction so next month I can regenerate with one command? I'll save your deliverable mix, strategic focus, and brand context references — you just tell me the month."

If yes:
- Save a config file at `Brands/{BrandName}/.agents/content-plan-config.json`
- Include: default deliverable mix, strategic pillars used, brand context paths, direction answers
- Next month: "Run the same plan for [Month]?" → skip to Step 3 with saved config

---

## Iteration & Revision

If the user asks to revise after the plan is generated:

- **"Adjust Week 3"** → rewrite only Week 3 deliverables, regenerate calendar rows
- **"Change the tone on the diaspora carousel"** → rewrite only that piece
- **"Add another blog post"** → generate, update count check, update calendar
- **"Add social posts"** → generate via `social` skill, slot into appropriate weeks
- **"Regenerate the whole thing"** → go back to Step 1 (direction may have changed)
- **"Run the same for next month"** → use saved config, ask for new month + any direction changes

After any revision, regenerate the .md file and, if already approved, the .html file.

---

## Edge Cases

- **No product-marketing.md found**: offer to create one from knowledgebase. If user declines, proceed with knowledgebase-only context but note that skills work better with the full context.
- **No knowledgebase files found**: ask the user to confirm the project is set up correctly; offer to run with manually pasted brand context.
- **No brand kit found**: skip design brief details, note "no brand kit" in visual deliverables.
- **User skips confirmation at echo-back**: treat silence as approval and proceed after one follow-up.
- **No URLs provided**: use `[brand-domain]/[page-slug]` placeholders; note them for the user.
- **Fewer than 3 active persona clusters**: distribute deliverables across available clusters; do not invent new ones.
- **Multi-month plan requested**: generate separate weekly sections per month but a single unified calendar.
- **Skill not installed**: if a referenced skill doesn't exist at `~/.agents/skills/{name}/`, note the gap and generate the piece using general best practices instead.
- **User requests heavy-text carousels**: only if explicitly requested ("detailed carousel," "educational carousel," "data-heavy slides"). Default remains visual-first with minimal text-on-image.
