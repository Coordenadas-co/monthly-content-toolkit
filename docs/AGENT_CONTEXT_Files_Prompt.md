# AGENT.md + CONTEXT.md Generation Prompt

**Referenced from:** `Brand_Onboarding_Sprint_Dashboard.html`, Phase 4.
**Safely re-runnable** — if these files already exist, this updates them in place
rather than duplicating. In particular, CONTEXT.md's "current cycle" line goes stale
every month until Phase 2 automates that update — re-running this monthly is expected
maintenance, not just a one-time onboarding step.

---

```
BRAND ONBOARDING FILES — AGENT.md + CONTEXT.md — [BRAND_NAME]

Purpose: generate this brand's AGENT.md (Layer 0 — identity) and CONTEXT.md
(Layer 1 — task routing) per FOLDER_STRUCTURE_TEMPLATE.md. Both are structural
files every brand needs, populated from real context — not filled in with
placeholders or guesses.

INPUTS TO READ FIRST (don't guess anything these files can tell you):
- Brands/[BRAND_NAME]/[BrandName]_marketing_brain.html
- Brands/[BRAND_NAME]/[BrandName]_brand_guide.html
- Brands/[BRAND_NAME]/_knowledgebase/ (industry/category context)
- Brands/[BRAND_NAME]/BrandKit/ (what actually exists — logos, design sheets,
  which subfolders are populated vs. empty)
- Brands/[BRAND_NAME]/Monthly_Cycles/ (list existing cycle folders, identify
  the most recent one)
- AGENTS.md at repo root (team roster — Copy/Images ownership per brand)

PART 1 — AGENT.md

Populate every field below from what you actually read above. If something
genuinely isn't discoverable from available files (e.g. client-side primary
contact, credentials not yet provisioned), write "Not yet documented — confirm
with Pablo" rather than inventing a plausible-sounding value. A blank or
flagged field is honest; a guessed one is a future bug.

# AGENT.md — [BRAND_NAME]

## Identity
- Brand name: [BRAND_NAME]
- Industry / category: [from marketing brain / brand guide]
- Primary contact (client-side): [if discoverable, else flag]
- Internal owner — Copy: [from AGENTS.md roster]
- Internal owner — Images: [from AGENTS.md roster]
- Cadence: [monthly, unless something in the brand's files indicates otherwise]

## Process deviations from default
[Only note something here if you found an actual documented deviation —
otherwise "None yet."]

## Credentials/scopes specific to this brand
- GoHighLevel subaccount: [if found, else "Not yet documented"]
- Scheduling tool account: [if found, else "Not yet documented — blocked on
  the scheduling tool decision, see BLUEPRINT_Coordenadas_Automation.md §2"]
- Brand-specific API keys: [if any, else "None"]

## Notes
[Anything relevant you found that doesn't fit the fields above — real
observations only, not filler.]

PART 2 — CONTEXT.md

This file is mostly fixed/generic (the routing table is the same shape for
every brand) — the only per-brand value is the current cycle line. Generate:

# CONTEXT.md — [BRAND_NAME] — Task Routing

Read this first. It routes a request to the right place — don't hold the whole
pipeline in memory, just follow this.

| If the request is about... | Go to... |
|---|---|
| Brand identity, positioning, strategy | `[BrandName]_marketing_brain.html`, `[BrandName]_MasterStrategyDoc.html`, `_knowledgebase/` |
| Visual identity, colors, fonts, logos | `BrandKit/` |
| This month's content plan | `Monthly_Cycles/[current]/01_content_plan/` |
| Carousel/blog/infographic prompts or copy | `Monthly_Cycles/[current]/02_prompts_and_copy/` and `03_infographic_briefs/` |
| Image generation | `Monthly_Cycles/[current]/04_image_generation/` — see `image_gen_references/` for the SOPs |
| The live monthly drop / landing page | `Monthly_Cycles/[current]/05_landing_page/` |
| Scheduling status | `Monthly_Cycles/[current]/06_scheduling/` |
| Performance report | `Monthly_Cycles/[current]/07_report/` |
| An urgent/custom request outside the normal cycle | Create a new `Monthly_Cycles/AH-[YYYYMMDD]-[slug]/` folder — don't reuse the current monthly cycle folder |

Current cycle: [the actual most recent Monthly_Cycles/ folder name found above]

OUTPUT: save both to Brands/[BRAND_NAME]/ root, overwriting any existing
versions. Show me a summary of what was populated vs. flagged as missing
before considering this done.
```
