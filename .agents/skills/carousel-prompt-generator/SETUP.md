# Carousel Prompt Generator — Setup Guide

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
> this skill's bundled `references/` files (e.g. `master-prompt-structure.md`,
> `brand-extraction-checklist.md`) still produce contract-correct output.
> Treat that as degraded, NOT a parallel choice — the bundled references are
> static snapshots and can go stale (real example: DALL-E 3 deprecation and
> current model guidance live in the `image` catalog skill, not in the bundled
> fallback). Flag "marketing skills not installed" explicitly in the output if
> you run this way. See `docs/EXECUTION_MODES.md`.

## 2. Add the Carousel Prompt Skill

Place the `carousel-prompt-generator` folder in your project's `.agents/skills/` directory:

```
YourProject/.agents/skills/carousel-prompt-generator/SKILL.md
YourProject/.agents/skills/carousel-prompt-generator/references/master-prompt-structure.md
YourProject/.agents/skills/carousel-prompt-generator/references/brand-extraction-checklist.md
```

If using git, commit `.agents/` — teammates get it on clone.

The skill directory does not require any external dependencies — HTML output is generated directly by the agent.

## 3. Verify

```powershell
npx skills list --global
```

You should see `carousel-prompt-generator` in the list.

## 4. Dependencies

- Requires the marketing skills from `coreyhaines31/marketingskills` at `~/.agents/skills/` (`image`, `marketing-psychology`)
- No Python, no external libraries — output is pure HTML/CSS
