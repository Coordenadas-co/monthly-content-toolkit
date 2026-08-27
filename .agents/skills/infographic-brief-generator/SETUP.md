# Infographic Brief Generator — Setup Guide

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
> this skill still produces contract-correct briefs using the brand guide +
> general infographic best practices. Treat that as degraded, NOT a parallel
> choice — the bundled guidance is a static snapshot and can go stale (real
> example: DALL-E 3 deprecation and current model guidance live in the `image`
> catalog skill, not in any bundled fallback). Flag "marketing skills not
> installed" explicitly in the output if you run this way. See
> `docs/EXECUTION_MODES.md`.

## 2. Add the Infographic Brief Skill

Place the `infographic-brief-generator` folder in your project's `.agents/skills/` directory:

```
YourProject/.agents/skills/infographic-brief-generator/SKILL.md
YourProject/.agents/skills/infographic-brief-generator/SETUP.md
```

If using git, commit `.agents/` — teammates get it on clone.

## 3. Verify

```powershell
npx skills list --global
```

You should see `infographic-brief-generator` in the list.

## 4. Dependencies

- Requires the `image` marketing skill from `coreyhaines31/marketingskills` at `~/.agents/skills/`
- No external libraries — output is pure HTML/CSS
