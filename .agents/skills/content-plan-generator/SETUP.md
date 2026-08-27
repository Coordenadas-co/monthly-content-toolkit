# Content Plan Generator — Setup Guide

## 1. Install Marketing Skills (default)

```powershell
npx skills add coreyhaines31/marketingskills --global -y
```

**Install the catalog by default.** The `skills` CLI detects your agent
(Hermes Agent, OpenCode, etc.), installs into that agent's skill directory,
and maintains a lockfile — it is not a plain file copy. Verify:

```powershell
npx skills list --global
```

> **Fallback (emergency-only):** if the catalog genuinely cannot be installed,
> this skill's bundled `references/` (e.g. `content-plan-template.html`) still
> produces contract-correct output. Treat that as degraded, NOT a parallel
> choice — the bundled references are static snapshots and can go stale (real
> example: DALL-E 3 deprecation and current model guidance live in the `image`
> catalog skill, not in the bundled fallback). Flag "marketing skills not
> installed" explicitly in the output if you run this way. See
> `docs/EXECUTION_MODES.md`.

## 2. Add the Content Plan Skill

Place the `content-plan-generator` folder in your project's `.agents/skills/` directory:

```
YourProject/.agents/skills/content-plan-generator/SKILL.md
```

If using git, commit `.agents/` — teammates get it on clone.

The skill directory must contain `references/content-plan-template.html` (dark/light toggle HTML template).

## 3. Verify

```powershell
npx skills list --global
```

You should see `content-plan-generator` in the list.

## 4. Set Up Brand Context

Each brand needs this structure:

```
Brands/{BrandName}/
  .agents/product-marketing.md     ← Run this in opencode:
                                     "Set up product marketing context for {brand}"
  Knowledgebase/                   ← Your strategy docs, message blocks, personas
  BrandKit/                        ← Brand guide, logos, visual assets
```

## 5. Use It

```powershell
# In your project directory, ask opencode:
"Generate the content plan for July"
```
