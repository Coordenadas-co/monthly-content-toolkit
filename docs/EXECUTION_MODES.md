# Execution Modes & the Marketing-Skills Dependency

How this toolkit is meant to run, and how the marketing sub-skills dependency
should be treated. Read this before deciding whether to install the catalog,
skip it, or lean on the bundled references.

---

## Two execution modes (both proven)

### 1. Native execution (recommended)

The five pipeline skills are plain `SKILL.md` + `references/` folders. Any
agent that can read files and follow a skill — Hermes, OpenCode, Claude Code,
or another coding agent — can execute them directly. No OpenCode install is
required.

This was proven end-to-end on 2026-08-12: all four content skills ran natively
(Hermes Agent) against a real brand cycle (Factronics USA, August 2026), with
the full deliverable mix (8 carousels / 4 blog posts / 2 newsletters / 2
infographics), and passed contract verification (card IDs, JSON manifest,
escaping, `detail_link` resolution against real downstream anchors).

### 2. OpenCode-assisted execution

The original design. `setup.ps1` installs the skills into OpenCode's skill
directory and you drive them through OpenCode. Still valid; not required.

---

## The marketing-skills catalog (default install)

The pipeline skills reference marketing sub-skills by name
(`content-strategy`, `marketing-psychology`, `copywriting`, `seo-audit`,
`ai-seo`, `emails`, `social`, `video`, `ad-creative`, `lead-magnets`,
`programmatic-seo`, `competitors`, `image`, `copy-editing`, `analytics`,
`offers`). These come from the community catalog:

```
npx skills add coreyhaines31/marketingskills --global -y
```

**Install this catalog by default.** It is the fully supported path. The
`skills` CLI (v1.5.x) detects the target agent (Hermes Agent, OpenCode, etc.),
installs into that agent's skill directory (e.g. `~/.agents/skills/` for
Hermes Agent), and maintains a lockfile registry (`~/.agents/.skill-lock.json`).
It is NOT a plain file copy — it registers, links, and tracks the install.

Verify with:

```
npx skills list --global
```

You should see the 49 marketing skills registered for your agent.

---

## The bundled references (degraded / emergency-only fallback)

Each pipeline skill ships `references/` files — `master-prompt-structure.md`,
`writing-rules.md`, `claims-policy.md`, `brand-extraction-checklist.md`,
HTML templates — that allow the skill to produce contract-correct output even
when the marketing catalog is absent. The 2026-08-12 native run confirmed the
fallback works: correct structure, correct anchors, grounded in the brand's
real knowledge base.

**However: treat the bundled references as degraded, emergency-only — NOT an
equally valid parallel choice.** They are static snapshots. Nothing in the
pipeline automatically checks them against current reality.

### Real evidence: DALL-E 3 deprecation

The `image` marketing skill (v2.0.1) documents that **DALL-E 3 is fully
deprecated** and that OpenAI's current image models are the GPT Image /
ChatGPT Images family (`gpt-image-1` and later). The catalog also carries live
model comparisons (Flux, Ideogram 3.0, Midjourney v7, Recraft V3) with current
capability notes.

The carousel-prompt-generator bundled fallback did **not** carry this. In the
fallback-only run, model recommendations still treated DALL-E as a current
option and lacked the Ideogram/Flux guidance — stale guidance that nothing in
the pipeline would have flagged. This is exactly the failure mode static
references produce: correct-looking, current-sounding, wrong.

### Practical rule

- **Default:** `npx skills add coreyhaines31/marketingskills --global -y`
- **Fallback (only when the catalog genuinely cannot be installed):** the
  bundled references. Works, but treat as degraded/emergency-only.
- **Never assume the bundled references are current.** If you lean on the
  fallback, verify any model / tool / pricing / deprecation claims before
  shipping them downstream (especially into image-generation prompts).

---

## What each run should report

When executing the pipeline, state which mode you used and whether the catalog
was present:

```
Execution mode: native (Hermes Agent) | OpenCode
Marketing catalog: installed (49 skills) | not installed (bundled fallback)
```

If the catalog was not installed, flag the degraded status explicitly in the
output (per each skill's edge-case rule: "marketing skills not installed —
note the gap and generate using general best practices instead") so a human
can decide whether to install before the output reaches image generation.
